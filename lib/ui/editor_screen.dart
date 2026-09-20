import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../canvas/editor_canvas.dart';
import '../canvas/export_presets.dart';
import '../canvas/pdf_export_service.dart';
import 'toolbar/tool_sidebar.dart';
import 'inspector/inspector_panel.dart';
import 'layers/layers_panel.dart';
import '../tools/tool_provider.dart';
import '../tools/tool.dart';
import '../tools/node_tool.dart';
import '../tools/line_tool.dart';
import '../tools/polygon_tool.dart';
import '../tools/star_tool.dart';
import '../tools/freehand_tool.dart';
import '../state/editor_notifier.dart';
import '../state/history_manager.dart';
import '../state/editor_state.dart';
import '../commands/delete_element_command.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../canvas/scene_exporter.dart';
import '../svg/svg_importer.dart';
import '../svg/svg_exporter.dart';
import '../models/vx_document.dart';
import '../models/vx_element.dart';
import '../services/shortcut_service.dart';
import 'package:uuid/uuid.dart';
import '../services/clipboard_service.dart';
import '../commands/add_element_command.dart';
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  bool _isPanelExpanded = true;
  bool _isPanelPinned = false;
  static const _presetStoreFile = 'export_presets.json';

  @override
  Widget build(BuildContext context) {
    final viewport = ref.watch(
      editorProvider.select((state) => state.viewport),
    );
    final editorState = ref.watch(editorProvider);
    final screenSize = MediaQuery.sizeOf(context);
    final activeTool = ref.watch(toolProvider);
    final toolSettingsHeight = _toolSettingsHeight(activeTool);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vectix'),
        elevation: 0,
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48 + toolSettingsHeight),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 12),
                    _buildPageChip(ref),
                    const SizedBox(width: 8),
                    _buildCanvasSizeChip(ref),
                    const SizedBox(width: 8),
                    _buildZoomChip(ref, viewport.zoom),
                    const SizedBox(width: 8),
                    _buildCanvasActionChip(
                      label: 'Fit',
                      icon: Icons.fit_screen,
                      onTap: () => ref
                          .read(editorProvider.notifier)
                          .fitToScreen(screenSize),
                    ),
                    const SizedBox(width: 8),
                    _buildCanvasActionChip(
                      label: 'Zoom Sel',
                      icon: Icons.center_focus_strong,
                      onTap: () => ref
                          .read(editorProvider.notifier)
                          .zoomToSelection(screenSize),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.layers_outlined),
                      tooltip: 'Artboard actions',
                      color: const Color(0xFF1E1E1E),
                      onSelected: (value) {
                        final notifier = ref.read(editorProvider.notifier);
                        if (value == 'rename') {
                          final doc = ref.read(editorProvider).document;
                          final currentName =
                              doc.artboards.isNotEmpty &&
                                  doc.activePageIndex < doc.artboards.length
                              ? doc.artboards[doc.activePageIndex].name
                              : 'Artboard';
                          showDialog(
                            context: context,
                            builder: (context) {
                              final controller = TextEditingController(
                                text: currentName,
                              );
                              return AlertDialog(
                                title: const Text('Rename artboard'),
                                content: TextField(
                                  controller: controller,
                                  autofocus: true,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      notifier.renameActivePage(
                                        controller.text,
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (value == 'duplicate') {
                          notifier.duplicateActivePage();
                        } else if (value == 'move_left') {
                          notifier.moveActivePage(-1);
                        } else if (value == 'move_right') {
                          notifier.moveActivePage(1);
                        } else if (value == 'add') {
                          notifier.addPage();
                        } else if (value == 'remove') {
                          notifier.removePage();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'add',
                          child: Text('Add artboard'),
                        ),
                        PopupMenuItem(
                          value: 'duplicate',
                          child: Text('Duplicate artboard'),
                        ),
                        PopupMenuItem(
                          value: 'rename',
                          child: Text('Rename artboard'),
                        ),
                        PopupMenuItem(
                          value: 'move_left',
                          child: Text('Move left'),
                        ),
                        PopupMenuItem(
                          value: 'move_right',
                          child: Text('Move right'),
                        ),
                        PopupMenuItem(
                          value: 'remove',
                          child: Text('Remove artboard'),
                        ),
                      ],
                    ),
                  ],
                ),
                if (toolSettingsHeight > 0) ...[
                  const SizedBox(height: 8),
                  _buildToolSettingsBar(ref, activeTool),
                ],
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Project (Ctrl+S)',
            onPressed: () => _saveProject(ref, context),
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: ref.watch(historyProvider).canUndo
                ? () => ref.read(historyProvider).undo()
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
            onPressed: ref.watch(historyProvider).canRedo
                ? () => ref.read(historyProvider).redo()
                : null,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) async {
              if (value == 'export_png') {
                _showPngExportDialog(context, ref);
              } else if (value == 'export_png_transparent') {
                final document = ref.read(editorProvider).document;
                SceneExporter.exportToPng(
                  document,
                  transparentBackground: true,
                );
              } else if (value == 'export_png_print') {
                final document = ref.read(editorProvider).document;
                SceneExporter.exportToPng(document, scale: 3.0);
              } else if (value == 'export_pdf') {
                _showPdfExportDialog(context, ref);
              } else if (value == 'import_svg') {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['svg'],
                );
                if (result != null && result.files.single.path != null) {
                  final file = File(result.files.single.path!);
                  final xmlString = await file.readAsString();
                  final doc = SvgImporter.import(xmlString);
                  if (doc != null) {
                    ref.read(editorProvider.notifier).loadDocument(doc);
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to parse SVG file. The file might be corrupted or malformed.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else if (value == 'export_svg') {
                final document = ref.read(editorProvider).document;
                final svgString = SvgExporter.export(document);

                if (Platform.isAndroid || Platform.isIOS) {
                  final dir = await getApplicationDocumentsDirectory();
                  final path = '${dir.path}/${document.title}.svg';
                  await File(path).writeAsString(svgString);
                  await Share.shareXFiles([XFile(path)], text: 'Exported SVG');
                } else {
                  final path = await FilePicker.platform.saveFile(
                    dialogTitle: 'Export SVG',
                    fileName: '${document.title}.svg',
                    type: FileType.custom,
                    allowedExtensions: ['svg'],
                  );
                  if (path != null) {
                    await File(path).writeAsString(svgString);
                  }
                }
              } else if (value == 'save_project') {
                await _saveProject(ref, context);
              } else if (value == 'open_project') {
                try {
                  final result = await FilePicker.platform.pickFiles(
                    type: (Platform.isAndroid || Platform.isIOS)
                        ? FileType.any
                        : FileType.custom,
                    allowedExtensions: (Platform.isAndroid || Platform.isIOS)
                        ? null
                        : ['vxp'],
                  );
                  if (result != null && result.files.single.path != null) {
                    if (!result.files.single.path!.endsWith('.vxp')) {
                      if (context.mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Invalid file format. Please open a .vxp file.',
                            ),
                          ),
                        );
                      return;
                    }
                    final file = File(result.files.single.path!);
                    final jsonString = await file.readAsString();
                    final json = jsonDecode(jsonString) as Map<String, dynamic>;
                    final parsedDoc = VxDocument.fromJson(json);
                    ref.read(editorProvider.notifier).loadDocument(parsedDoc);
                    if (context.mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Project loaded.')),
                      );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Open error: $e')));
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'open_project',
                child: Text('Open Project (.vxp)'),
              ),
              const PopupMenuItem(
                value: 'save_project',
                child: Text('Save Project (.vxp)'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'export_png',
                child: Text('Export PNG'),
              ),
              const PopupMenuItem(
                value: 'export_png_transparent',
                child: Text('Export PNG (transparent)'),
              ),
              const PopupMenuItem(
                value: 'export_png_print',
                child: Text('Export PNG (print preset 3x)'),
              ),
              const PopupMenuItem(
                value: 'export_pdf',
                child: Text('Export PDF'),
              ),
              const PopupMenuItem(
                value: 'import_svg',
                child: Text('Import SVG'),
              ),
              const PopupMenuItem(
                value: 'export_svg',
                child: Text('Export SVG (active artboard)'),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: const Color(0xFF2C2C2C), // Dark grey background for app
      body: ShortcutHandler(
        onSave: () => _saveProject(ref, context),
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) return KeyEventResult.ignored;

            // NOTE: Ctrl/Cmd+S, +Z, +Shift+Z, +Y, +C, +V and +D are owned by
            // the enclosing ShortcutHandler. They used to be handled here too,
            // which meant this (inner) Focus consumed the key first: Ctrl+S
            // silently ran an *SVG export* instead of the project save that the
            // toolbar tooltip advertises (finding P0-3). Keep exactly one owner
            // of each shortcut — do not re-add these branches.

            // Delete
            if (event.logicalKey == LogicalKeyboardKey.delete ||
                event.logicalKey == LogicalKeyboardKey.backspace) {
              final state = ref.read(editorProvider);
              final activeTool = ref.read(toolProvider);
              if (state.editingTextId == null &&
                  activeTool is NodeTool &&
                  state.selectedIds.length == 1) {
                // activeTool.deleteSelectedNode(ref);
                return KeyEventResult.handled;
              }
              if (state.selectedIds.isNotEmpty && state.editingTextId == null) {
                final selectedElements = state.selectedIds
                    .map(
                      (id) =>
                          state.document.elements.firstWhere((e) => e.id == id),
                    )
                    .toList();
                ref
                    .read(historyProvider)
                    .execute(DeleteElementCommand(selectedElements));
                return KeyEventResult.handled;
              }
            }

            // Don't switch tools if typing in a text field
            if (ref.read(editorProvider).editingTextId != null) {
              return KeyEventResult.ignored;
            }

            // Tool switching
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              ref.read(toolProvider).onPointerCancel(ref);
              ref.read(editorProvider.notifier).setTool(ActiveTool.select);
              return KeyEventResult.handled;
            }
            final notifier = ref.read(editorProvider.notifier);
            switch (event.logicalKey) {
              case LogicalKeyboardKey.keyV:
                ref.read(toolProvider).onPointerCancel(ref);
                notifier.setTool(ActiveTool.select);
                return KeyEventResult.handled;
              case LogicalKeyboardKey.keyR:
                ref.read(toolProvider).onPointerCancel(ref);
                notifier.setTool(ActiveTool.rect);
                return KeyEventResult.handled;
              case LogicalKeyboardKey.keyO:
                ref.read(toolProvider).onPointerCancel(ref);
                notifier.setTool(ActiveTool.ellipse);
                return KeyEventResult.handled;
              case LogicalKeyboardKey.keyP:
                ref.read(toolProvider).onPointerCancel(ref);
                notifier.setTool(ActiveTool.freehand);
                return KeyEventResult.handled;
              case LogicalKeyboardKey.keyT:
                ref.read(toolProvider).onPointerCancel(ref);
                notifier.setTool(ActiveTool.text);
                return KeyEventResult.handled;
              case LogicalKeyboardKey.keyN:
                ref.read(toolProvider).onPointerCancel(ref);
                notifier.setTool(ActiveTool.node);
                return KeyEventResult.handled;
              case LogicalKeyboardKey.keyH:
                ref.read(toolProvider).onPointerCancel(ref);
                notifier.setTool(ActiveTool.hand);
                return KeyEventResult.handled;
            }

            return KeyEventResult.ignored;
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;

              if (isDesktop) {
                return Row(
                  children: [
                    const SizedBox(
                      width: 50,
                      child: ToolSidebar(isHorizontal: false),
                    ),
                    Expanded(child: _buildCanvasWithActionBar(ref)),
                    Container(
                      width: 300,
                      color: const Color(0xFF2C2C2C),
                      child: const Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: SingleChildScrollView(
                              child: InspectorPanel(),
                            ),
                          ),
                          Divider(height: 1, color: Colors.white24),
                          Expanded(flex: 1, child: LayersPanel()),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // Mobile Layout
              return Column(
                children: [
                  const ToolSidebar(isHorizontal: true),
                  Expanded(
                    child: Stack(
                      children: [
                        _buildCanvasWithActionBar(ref),
                        if (editorState.selectedIds.isNotEmpty || _isPanelPinned)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              color: const Color(0xFF2C2C2C),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 32,
                                    color: const Color(0xFF3C3C3C),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 48),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _isPanelExpanded = !_isPanelExpanded;
                                              });
                                            },
                                            child: Container(
                                              color: Colors.transparent,
                                              child: Icon(
                                                _isPanelExpanded
                                                    ? Icons.keyboard_arrow_down
                                                    : Icons.keyboard_arrow_up,
                                                color: Colors.white54,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          iconSize: 20,
                                          constraints: const BoxConstraints(minWidth: 48),
                                          icon: Icon(
                                            _isPanelPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                            color: _isPanelPinned ? Colors.blue : Colors.white54,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isPanelPinned = !_isPanelPinned;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_isPanelExpanded)
                                    const SizedBox(
                                      height: 350,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            InspectorPanel(),
                                            Divider(
                                              height: 1,
                                              color: Colors.white24,
                                            ),
                                            SizedBox(
                                              height: 150,
                                              child: LayersPanel(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  double _toolSettingsHeight(Tool tool) {
    if (tool is LineTool) return 56;
    if (tool is PolygonTool) return 56;
    if (tool is StarTool) return 96;
    if (tool is FreehandTool) return 56;
    return 0;
  }

  Widget _buildToolSettingsBar(WidgetRef ref, Tool tool) {
    final state = ref.watch(editorProvider);
    if (tool is LineTool) {
      return _buildCompactToolCard(
        title: 'Line',
        child: Row(
          children: [
            const Text('Width', style: TextStyle(color: Colors.white70)),
            Expanded(
              child: Slider(
                value: state.lineStrokeWidth,
                min: 0.5,
                max: 12,
                divisions: 23,
                label: state.lineStrokeWidth.toStringAsFixed(1),
                onChanged: (value) =>
                    ref.read(editorProvider.notifier).setLineStrokeWidth(value),
              ),
            ),
            SizedBox(
              width: 36,
              child: Text(
                state.lineStrokeWidth.toStringAsFixed(1),
                textAlign: TextAlign.end,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
    if (tool is PolygonTool) {
      return _buildCompactToolCard(
        title: 'Polygon',
        child: Row(
          children: [
            const Text('Sides', style: TextStyle(color: Colors.white70)),
            Expanded(
              child: Slider(
                value: state.polygonSides.toDouble(),
                min: 3,
                max: 24,
                divisions: 21,
                label: '${state.polygonSides}',
                onChanged: (value) => ref
                    .read(editorProvider.notifier)
                    .setPolygonSides(value.round()),
              ),
            ),
            SizedBox(
              width: 36,
              child: Text(
                '${state.polygonSides}',
                textAlign: TextAlign.end,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
    if (tool is StarTool) {
      return _buildCompactToolCard(
        title: 'Star',
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 72,
                  child: Text(
                    'Spikes',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: state.starSpikes.toDouble(),
                    min: 3,
                    max: 24,
                    divisions: 21,
                    label: '${state.starSpikes}',
                    onChanged: (value) => ref
                        .read(editorProvider.notifier)
                        .setStarSpikes(value.round()),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${state.starSpikes}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(
                  width: 72,
                  child: Text('Inner', style: TextStyle(color: Colors.white70)),
                ),
                Expanded(
                  child: Slider(
                    value: state.starInnerRatio,
                    min: 0.1,
                    max: 0.9,
                    divisions: 16,
                    label: state.starInnerRatio.toStringAsFixed(2),
                    onChanged: (value) => ref
                        .read(editorProvider.notifier)
                        .setStarInnerRatio(value),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    state.starInnerRatio.toStringAsFixed(2),
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    if (tool is FreehandTool) {
      return _buildCompactToolCard(
        title: 'Freehand',
        child: Row(
          children: [
            const Text('Smoothing', style: TextStyle(color: Colors.white70)),
            Expanded(
              child: Slider(
                value: state.freehandSmoothing,
                min: 0,
                max: 1,
                divisions: 10,
                label: state.freehandSmoothing.toStringAsFixed(1),
                onChanged: (value) => ref
                    .read(editorProvider.notifier)
                    .setFreehandSmoothing(value),
              ),
            ),
            SizedBox(
              width: 36,
              child: Text(
                state.freehandSmoothing.toStringAsFixed(1),
                textAlign: TextAlign.end,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _saveProject(WidgetRef ref, BuildContext context) async {
    try {
      final document = ref.read(editorProvider).document;
      final jsonString = jsonEncode(document.toJson());

      if (Platform.isAndroid || Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/${document.title}.vxp';
        final file = File(path);
        await file.writeAsString(jsonString);
        await Share.shareXFiles([
          XFile(path),
        ], text: 'Vectix Project');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project ready for export.')),
          );
        }
      } else {
        // Fix for FilePicker on Windows: passing filename without explicit extension
        // and safely ensuring `.vxp` is added.
        final title = document.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
        String? path = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Vectix Project',
          fileName: title,
          type: FileType.custom,
          allowedExtensions: ['vxp'],
        );
        if (path != null) {
          if (!path.toLowerCase().endsWith('.vxp')) {
            path = '$path.vxp';
          }
          await File(path).writeAsString(jsonString);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Project saved.')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save error: $e')));
      }
    }
  }

  Widget _buildCanvasWithActionBar(WidgetRef ref) {
    return Stack(
      children: [
        const ClipRect(child: EditorCanvas()),
        _buildFloatingActionBar(ref),
      ],
    );
  }

  Widget _buildFloatingActionBar(WidgetRef ref) {
    final state = ref.watch(editorProvider);
    final clipboard = ref.watch(clipboardProvider);
    
    if (state.selectedIds.isEmpty && clipboard.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.selectedIds.isNotEmpty) ...[
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'Copy',
                  onPressed: () => _copyToClipboard(ref),
                ),
                IconButton(
                  icon: const Icon(Icons.control_point_duplicate, size: 20),
                  tooltip: 'Duplicate',
                  onPressed: () {
                    _copyToClipboard(ref);
                    _pasteFromClipboard(ref);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  tooltip: 'Delete',
                  onPressed: () {
                    final selectedElements = state.selectedIds
                        .map((id) => state.document.elements.firstWhere((e) => e.id == id))
                        .toList();
                    ref.read(historyProvider).execute(DeleteElementCommand(selectedElements));
                  },
                ),
              ],
              if (clipboard.isNotEmpty) ...[
                if (state.selectedIds.isNotEmpty)
                  const SizedBox(
                    height: 24,
                    child: VerticalDivider(color: Colors.white24, width: 16),
                  ),
                IconButton(
                  icon: const Icon(Icons.paste, size: 20),
                  tooltip: 'Paste',
                  onPressed: () => _pasteFromClipboard(ref),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(WidgetRef ref) {
    final state = ref.read(editorProvider);
    if (state.selectedIds.isEmpty) return;
    final elementsToCopy = state.document.elements.where((e) => state.selectedIds.contains(e.id)).toList();
    ref.read(clipboardProvider.notifier).state = elementsToCopy;
  }

  void _pasteFromClipboard(WidgetRef ref) {
    final clipboard = ref.read(clipboardProvider);
    if (clipboard.isEmpty) return;
    
    final uuid = const Uuid();
    final newElements = <VxElement>[];
    final newSelectedIds = <String>{};

    for (final el in clipboard) {
      final newId = uuid.v4();
      final offsetTransform = el.transform.clone()..translate(10.0, 10.0);
      
      VxElement updated = el.when(
        rect: (id, artboardId, x, y, w, h, t, f, s, opacity, locked, visible, clipPathId, maskId) => VxElement.rect(id: newId, artboardId: artboardId, x: x, y: y, width: w, height: h, transform: offsetTransform, fill: f, stroke: s, opacity: opacity, locked: locked, visible: visible, clipPathId: clipPathId, maskId: maskId),
        ellipse: (id, artboardId, cx, cy, rx, ry, t, f, s, opacity, locked, visible, clipPathId, maskId) => VxElement.ellipse(id: newId, artboardId: artboardId, cx: cx, cy: cy, rx: rx, ry: ry, transform: offsetTransform, fill: f, stroke: s, opacity: opacity, locked: locked, visible: visible, clipPathId: clipPathId, maskId: maskId),
        path: (id, artboardId, segs, t, f, s, opacity, locked, visible, clipPathId, maskId) => VxElement.path(id: newId, artboardId: artboardId, segments: segs, transform: offsetTransform, fill: f, stroke: s, opacity: opacity, locked: locked, visible: visible, clipPathId: clipPathId, maskId: maskId),
        text: (id, artboardId, c, x, y, st, align, letterSpacing, wordSpacing, lineHeight, fontWeightValue, fontStyle, maxLines, t, opacity, locked, visible, clipPathId, maskId) => VxElement.text(
          id: newId, artboardId: artboardId, content: c, x: x, y: y, style: st, align: align, letterSpacing: letterSpacing, wordSpacing: wordSpacing, lineHeight: lineHeight, fontWeightValue: fontWeightValue, fontStyle: fontStyle, maxLines: maxLines, transform: offsetTransform, opacity: opacity, locked: locked, visible: visible, clipPathId: clipPathId, maskId: maskId,
        ),
        group: (id, artboardId, children, t, opacity, locked, visible, clipPathId, maskId) => VxElement.group(id: newId, artboardId: artboardId, children: children, transform: offsetTransform, opacity: opacity, locked: locked, visible: visible, clipPathId: clipPathId, maskId: maskId),
        compound: (id, artboardId, op, children, t, f, s, opacity, locked, visible, clipPathId, maskId) => VxElement.compound(id: newId, artboardId: artboardId, operation: op, children: children, transform: offsetTransform, fill: f, stroke: s, opacity: opacity, locked: locked, visible: visible, clipPathId: clipPathId, maskId: maskId),
        use: (id, artboardId, href, t, opacity, locked, visible, clipPathId, maskId) => VxElement.use(id: newId, artboardId: artboardId, href: href, transform: offsetTransform, opacity: opacity, locked: locked, visible: visible, clipPathId: clipPathId, maskId: maskId),
        symbol: (id, artboardId, children, t, opacity, locked, visible, clipPathId, maskId) => VxElement.symbol(id: newId, artboardId: artboardId, children: children, transform: offsetTransform, opacity: opacity, locked: locked, visible: visible, clipPathId: clipPathId, maskId: maskId),
      );
      
      newElements.add(updated);
      newSelectedIds.add(newId);
    }

    for (final el in newElements) {
      ref.read(historyProvider).execute(AddElementCommand(el));
    }
    
    ref.read(editorProvider.notifier).setSelection(newSelectedIds);
  }

  Widget _buildCompactToolCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  Widget _buildZoomChip(WidgetRef ref, double zoom) {
    final pct = (zoom * 100).round();
    return ActionChip(
      label: Text('$pct%'),
      onPressed: () => ref
          .read(editorProvider.notifier)
          .setZoom(1.0, focalPoint: Offset.zero),
      backgroundColor: const Color(0xFF3A3A3A),
      labelStyle: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildCanvasActionChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: Colors.white70),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: const Color(0xFF3A3A3A),
      labelStyle: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildPageChip(WidgetRef ref) {
    final doc = ref.watch(editorProvider).document;
    final artboards = doc.artboards.isEmpty
        ? List.generate(doc.pageCount, (index) => 'Page ${index + 1}')
        : doc.artboards.map((a) => a.name).toList();
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: doc.activePageIndex,
        dropdownColor: const Color(0xFF1E1E1E),
        iconEnabledColor: Colors.white70,
        style: const TextStyle(color: Colors.white),
        items: List.generate(
          artboards.length,
          (index) =>
              DropdownMenuItem(value: index, child: Text(artboards[index])),
        ),
        onChanged: (value) {
          if (value != null) {
            ref.read(editorProvider.notifier).setActivePageIndex(value);
          }
        },
      ),
    );
  }

  Widget _buildCanvasSizeChip(WidgetRef ref) {
    final doc = ref.watch(editorProvider).document;
    final current =
        doc.artboards.isNotEmpty && doc.activePageIndex < doc.artboards.length
        ? doc.artboards[doc.activePageIndex]
        : null;
    final width = current?.width ?? doc.width;
    final height = current?.height ?? doc.height;
    return PopupMenuButton<String>(
      tooltip: 'Artboard size',
      offset: const Offset(0, 36),
      color: const Color(0xFF1E1E1E),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          '${width.toInt()} x ${height.toInt()}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      onSelected: (value) {
        if (value == 'a4') {
          ref.read(editorProvider.notifier).setDocumentSize(2100, 2970);
        } else if (value == 'square') {
          ref.read(editorProvider.notifier).setDocumentSize(1024, 1024);
        } else if (value == 'wide') {
          ref.read(editorProvider.notifier).setDocumentSize(1920, 1080);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'wide', child: Text('Wide 1920 x 1080')),
        PopupMenuItem(value: 'a4', child: Text('Print A4 2100 x 2970')),
        PopupMenuItem(value: 'square', child: Text('Square 1024 x 1024')),
      ],
    );
  }

  Future<void> _showPngExportDialog(BuildContext context, WidgetRef ref) async {
    final document = ref.read(editorProvider).document;
    final backgroundController = TextEditingController(text: 'white');
    double scale = 1.0;
    bool transparent = false;
    final pngProfiles = await _loadPngProfiles(document.metadata);
    var preset = pngProfiles.first;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Export PNG'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: transparent,
                        title: const Text('Transparent background'),
                        onChanged: (value) =>
                            setState(() => transparent = value),
                      ),
                      TextField(
                        controller: backgroundController,
                        enabled: !transparent,
                        decoration: const InputDecoration(
                          labelText: 'Background color name',
                          hintText: 'white',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<PngExportProfile>(
                        value: preset,
                        decoration: const InputDecoration(labelText: 'Preset'),
                        items: pngExportProfiles
                            .map(
                              (profile) => DropdownMenuItem(
                                value: profile,
                                child: Text(profile.label),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            preset = value;
                            scale = value.scale;
                            transparent = value.transparent;
                          });
                        },
                      ),
                      TextButton(
                        onPressed: () => _showPresetManager(
                          context,
                          ref,
                          'PNG Presets',
                          pngProfiles,
                          'pngExportProfiles',
                        ),
                        child: const Text('Manage presets'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<double>(
                        value: scale,
                        decoration: const InputDecoration(labelText: 'Scale'),
                        items: const [
                          DropdownMenuItem(value: 1.0, child: Text('1x')),
                          DropdownMenuItem(value: 2.0, child: Text('2x')),
                          DropdownMenuItem(
                            value: 3.0,
                            child: Text('3x print preset'),
                          ),
                          DropdownMenuItem(value: 4.0, child: Text('4x')),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => scale = value);
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await SceneExporter.exportToPng(
                      document,
                      transparentBackground: transparent,
                      scale: scale,
                    );
                  },
                  child: const Text('Export'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showPdfExportDialog(BuildContext context, WidgetRef ref) async {
    final document = ref.read(editorProvider).document;
    final selectedArtboards = document.artboards.isEmpty
        ? <String>{}
        : document.artboards.map((artboard) => artboard.id).toSet();
    final previewCache = <String, Future<Uint8List?>>{};
    double bleed = 0;
    bool cropMarks = false;
    final pdfProfiles = await _loadPdfProfiles(document.metadata);
    var preset = pdfProfiles.first;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Export PDF'),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<double>(
                        value: bleed,
                        decoration: const InputDecoration(labelText: 'Bleed'),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('No bleed')),
                          DropdownMenuItem(value: 3, child: Text('3px bleed')),
                          DropdownMenuItem(value: 6, child: Text('6px bleed')),
                          DropdownMenuItem(
                            value: 12,
                            child: Text('12px bleed'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => bleed = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<PdfExportProfile>(
                        value: preset,
                        decoration: const InputDecoration(labelText: 'Preset'),
                        items: pdfExportProfiles
                            .map(
                              (profile) => DropdownMenuItem(
                                value: profile,
                                child: Text(profile.label),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            preset = value;
                            bleed = value.bleed;
                            cropMarks = value.cropMarks;
                          });
                        },
                      ),
                      TextButton(
                        onPressed: () => _showPresetManager(
                          context,
                          ref,
                          'PDF Presets',
                          pdfProfiles,
                          'pdfExportProfiles',
                        ),
                        child: const Text('Manage presets'),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Crop marks'),
                        subtitle: const Text(
                          'Add printer crop lines to the PDF',
                        ),
                        value: cropMarks,
                        onChanged: bleed <= 0
                            ? null
                            : (value) => setState(() => cropMarks = value),
                      ),
                      const SizedBox(height: 8),
                      if (document.artboards.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Pages to export',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...document.artboards.map(
                          (artboard) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: FutureBuilder<Uint8List?>(
                              future: previewCache.putIfAbsent(
                                artboard.id,
                                () => _artboardPreviewBytes(document, artboard),
                              ),
                              builder: (context, snapshot) {
                                final imageBytes = snapshot.data;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (selectedArtboards.contains(
                                        artboard.id,
                                      )) {
                                        selectedArtboards.remove(artboard.id);
                                      } else {
                                        selectedArtboards.add(artboard.id);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color:
                                            selectedArtboards.contains(
                                              artboard.id,
                                            )
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Colors.white24,
                                        width:
                                            selectedArtboards.contains(
                                              artboard.id,
                                            )
                                            ? 2
                                            : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Container(
                                            width: 72,
                                            height: 72,
                                            color: Colors.black12,
                                            alignment: Alignment.center,
                                            child: imageBytes == null
                                                ? const CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  )
                                                : Image.memory(
                                                    imageBytes,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(artboard.name),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${artboard.width.toInt()} x ${artboard.height.toInt()}',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Checkbox(
                                          value: selectedArtboards.contains(
                                            artboard.id,
                                          ),
                                          onChanged: (checked) {
                                            setState(() {
                                              if (checked == true) {
                                                selectedArtboards.add(
                                                  artboard.id,
                                                );
                                              } else {
                                                selectedArtboards.remove(
                                                  artboard.id,
                                                );
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ] else
                        const Text(
                          'This document will export as a single page.',
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await const PdfExportService().export(
                      document,
                      artboardIds: selectedArtboards.isEmpty
                          ? null
                          : selectedArtboards.toList(growable: false),
                      bleed: bleed,
                      cropMarks: cropMarks,
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<Uint8List?> _artboardPreviewBytes(
    VxDocument document,
    VxArtboard artboard,
  ) {
    final previewDoc = document.copyWith(
      artboards: [artboard],
      activePageIndex: 0,
      width: artboard.width,
      height: artboard.height,
    );
    return SceneExporter.renderPng(previewDoc, transparentBackground: true);
  }

  Future<void> _showPresetManager<T extends Object>(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<T> entries,
    String metadataKey,
  ) async {
    final working = List<T>.from(entries);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 420,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: working.length,
                  itemBuilder: (context, index) {
                    final item = working[index];
                    return ListTile(
                      title: Text(_presetLabel(item)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() => working.removeAt(index));
                        },
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (working.isNotEmpty) {
                        working.add(working.first);
                      }
                    });
                  },
                  child: const Text('Add Copy'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (working.isNotEmpty) {
                        final item = working.removeLast();
                        working.insert(0, item);
                      }
                    });
                  },
                  child: const Text('Move Last First'),
                ),
                TextButton(
                  onPressed: () {
                    final metadata = Map<String, dynamic>.from(
                      ref.read(editorProvider).document.metadata,
                    );
                    metadata[metadataKey] = working
                        .map((item) => _presetToJson(item))
                        .toList(growable: false);
                    ref
                        .read(editorProvider.notifier)
                        .updateDocumentMetadata(metadata);
                    _savePresetStore(metadata);
                  },
                  child: const Text('Save'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _presetLabel(Object item) {
    if (item is PngExportProfile) return '${item.label} (${item.scale}x)';
    if (item is PdfExportProfile) {
      return '${item.label} (bleed ${item.bleed}px)';
    }
    return item.toString();
  }

  Map<String, dynamic> _presetToJson(Object item) {
    if (item is PngExportProfile) return item.toJson();
    if (item is PdfExportProfile) return item.toJson();
    return <String, dynamic>{'value': item.toString()};
  }

  Future<List<PngExportProfile>> _loadPngProfiles(
    Map<String, dynamic> metadata,
  ) async {
    final raw = metadata['pngExportProfiles'];
    if (raw is List) {
      final parsed = raw
          .whereType<Map>()
          .map(
            (item) =>
                PngExportProfile.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: true);
      if (parsed.isNotEmpty) return parsed;
    }
    final store = await _readPresetStore<PngExportProfile>(
      'pngExportProfiles',
      pngExportProfiles,
    );
    return store;
  }

  Future<List<PdfExportProfile>> _loadPdfProfiles(
    Map<String, dynamic> metadata,
  ) async {
    final raw = metadata['pdfExportProfiles'];
    if (raw is List) {
      final parsed = raw
          .whereType<Map>()
          .map(
            (item) =>
                PdfExportProfile.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: true);
      if (parsed.isNotEmpty) return parsed;
    }
    final store = await _readPresetStore<PdfExportProfile>(
      'pdfExportProfiles',
      pdfExportProfiles,
    );
    return store;
  }

  Future<List<T>> _readPresetStore<T>(String key, List<T> fallback) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_presetStoreFile');
      if (!await file.exists()) return fallback.toList(growable: true);
      final jsonMap =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final raw = jsonMap[key];
      if (raw is List && raw.isNotEmpty) {
        if (T == PngExportProfile) {
          return raw
              .whereType<Map>()
              .map(
                (item) =>
                    PngExportProfile.fromJson(Map<String, dynamic>.from(item))
                        as T,
              )
              .toList(growable: true);
        }
        if (T == PdfExportProfile) {
          return raw
              .whereType<Map>()
              .map(
                (item) =>
                    PdfExportProfile.fromJson(Map<String, dynamic>.from(item))
                        as T,
              )
              .toList(growable: true);
        }
      }
    } catch (_) {}
    return fallback.toList(growable: true);
  }

  Future<void> _savePresetStore(Map<String, dynamic> metadata) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_presetStoreFile');
      await file.writeAsString(jsonEncode(metadata));
    } catch (_) {}
  }
}
