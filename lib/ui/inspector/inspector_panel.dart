import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/editor_notifier.dart';
import '../../models/vx_element.dart';
import 'fill_stroke_section.dart';
import 'transform_section.dart';
import 'alignment_section.dart';
import 'boolean_operations_section.dart';
import 'text_properties_section.dart';
import '../../state/history_manager.dart';
import '../../commands/update_element_command.dart';
import '../../commands/insert_path_node_command.dart';
import '../../commands/delete_path_node_command.dart';
import '../../commands/group_command.dart';
import '../../commands/ungroup_command.dart';
import '../../commands/add_element_command.dart';
import '../../commands/delete_element_command.dart';
import '../../models/vx_document.dart';
import '../../canvas/scene_exporter.dart';
import 'dart:typed_data';
import 'dart:math' as math;

class InspectorPanel extends ConsumerWidget {
  const InspectorPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);

    if (state.selectedIds.isEmpty) {
      return _emptySelectionView(context, ref, state);
    }

    if (state.selectedIds.length > 1) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Multiple elements selected',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  final elements = state.selectedIds
                      .map(
                        (id) => state.document.elements.firstWhere(
                          (e) => e.id == id,
                        ),
                      )
                      .toList();
                  ref.read(historyProvider).execute(GroupCommand(elements));
                },
                icon: Icon(Icons.group),
                label: Text('Group Elements'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 40),
                ),
              ),
            ),
            const Divider(color: Colors.white24),
            const AlignmentSection(),
            const Divider(color: Colors.white24),
            const BooleanOperationsSection(),
            const Divider(color: Colors.white24),
            _MultiSelectionTools(),
          ],
        ),
      );
    }

    final id = state.selectedIds.first;
    final element = state.document.elements.firstWhere((e) => e.id == id);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.white10,
            width: double.infinity,
            child: Row(
              children: [
                const Icon(Icons.tune, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    element.map(
                      rect: (e) => 'Rectangle',
                      ellipse: (e) => 'Ellipse',
                      path: (e) => 'Path',
                      text: (e) => 'Text',
                      group: (e) => 'Group',
                      compound: (e) {
                        switch (e.operation) {
                          case 0: return 'Difference';
                          case 1: return 'Intersection';
                          case 2: return 'Union';
                          case 3: return 'XOR';
                          default: return 'Compound Path';
                        }
                      },
                      use: (e) => 'Use Reference',
                      symbol: (e) => 'Symbol',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (element is VxGroup)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(historyProvider).execute(UngroupCommand(element));
                },
                icon: const Icon(Icons.unfold_less),
                label: const Text('Ungroup Elements'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: TransformSection(element: element)),
              if (element is! VxText)
                Expanded(child: FillStrokeSection(element: element)),
              if (element is VxText)
                Expanded(child: TextPropertiesSection(element: element)),
            ],
          ),
          if (element is VxPath)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Path tools',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      final updated = _insertMidpointNode(element);
                      if (updated != null) {
                        ref
                            .read(historyProvider)
                            .execute(
                              InsertPathNodeCommand(
                                oldElement: element,
                                newElement: updated,
                              ),
                            );
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Insert midpoint node'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      final updated = _deleteLastNode(element);
                      if (updated != null) {
                        ref
                            .read(historyProvider)
                            .execute(
                              DeletePathNodeCommand(
                                oldElement: element,
                                newElement: updated,
                              ),
                            );
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text('Remove last node'),
                  ),
                ],
              ),
            ),
          if (element is VxSymbol)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Symbol assets',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSymbolBrowser(context, ref, state),
                ],
              ),
            ),
          if (element.maskId != null || element.clipPathId != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'References',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (element.clipPathId != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        final updated = _clearReference(
                          element,
                          clipPath: true,
                        );
                        if (updated != null) {
                          ref
                              .read(historyProvider)
                              .execute(
                                UpdateElementCommand(
                                  oldElements: [element],
                                  newElements: [updated],
                                  actionName: 'Remove clip path',
                                ),
                              );
                        }
                      },
                      icon: const Icon(Icons.layers_clear),
                      label: const Text('Remove clip path'),
                    ),
                  if (element.maskId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final updated = _clearReference(element, mask: true);
                          if (updated != null) {
                            ref
                                .read(historyProvider)
                                .execute(
                                  UpdateElementCommand(
                                    oldElements: [element],
                                    newElements: [updated],
                                    actionName: 'Remove mask',
                                  ),
                                );
                          }
                        },
                        icon: const Icon(Icons.hide_source),
                        label: const Text('Remove mask'),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// With nothing selected, show the asset library when the document has one,
  /// so definitions that live in [VxDocument.defs] (imported `<symbol>`s) stay
  /// reachable — they cannot be selected on the canvas because they are not
  /// painted artwork.
  Widget _emptySelectionView(
    BuildContext context,
    WidgetRef ref,
    dynamic state,
  ) {
    final hasSymbols =
        state.document.defs.values.any((e) => e is VxSymbol) ||
        state.document.elements.any((e) => e is VxSymbol);
    if (!hasSymbols) {
      return const Center(
        child: Text(
          'No element selected',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Assets',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildSymbolBrowser(context, ref, state),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolBrowser(BuildContext context, WidgetRef ref, dynamic state) {
    // Symbols live in the artwork tree (documents created in-app) or in the
    // document definitions (imported <symbol> elements). Show both, deduped.
    final byId = <String, VxSymbol>{};
    for (final symbol in state.document.elements.whereType<VxSymbol>()) {
      byId[symbol.id] = symbol;
    }
    for (final symbol in state.document.defs.values.whereType<VxSymbol>()) {
      byId[symbol.id] = symbol;
    }
    final symbols = byId.values.toList();
    if (symbols.isEmpty) {
      return const Text(
        'No symbols in document',
        style: TextStyle(color: Colors.white54),
      );
    }
    final folderFilter = ref.watch(_symbolFolderFilterProvider);
    final searchQuery = ref.watch(_symbolSearchProvider);
    final categories = _symbolCategories(state.document.metadata, symbols);
    final folderNames = <String>{'All', ...categories.values};
    for (final symbol in symbols) {
      folderNames.add(_symbolCategoryFor(symbol, categories));
    }
    final filtered = symbols.where((symbol) {
      final folderOk =
          folderFilter == 'All' ||
          _symbolCategoryFor(symbol, categories) == folderFilter;
      final searchOk =
          searchQuery.isEmpty ||
          symbol.id.toLowerCase().contains(searchQuery.toLowerCase());
      return folderOk && searchOk;
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownButton<String>(
              value: folderFilter,
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              items: folderNames
                  .map(
                    (folder) =>
                        DropdownMenuItem(value: folder, child: Text(folder)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(_symbolFolderFilterProvider.notifier).state = value;
                }
              },
            ),
            SizedBox(
              width: 160,
              child: TextField(
                onChanged: (value) =>
                    ref.read(_symbolSearchProvider.notifier).state = value,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Search symbols',
                ),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _showSymbolCategoryManager(context, ref),
            icon: const Icon(Icons.folder_copy_outlined),
            label: const Text('Manage categories'),
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filtered.map((symbol) {
            return SizedBox(
              width: 180,
              child: Card(
                color: const Color(0xFF262626),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FutureBuilder<Uint8List?>(
                        future: Future.value(
                          SceneExporter.cachedThumbnail(symbol) ??
                              SceneExporter.renderSymbolThumbnailBytes(
                                state.document,
                                symbol,
                              ),
                        ),
                        builder: (context, snapshot) {
                          final bytes = snapshot.data;
                          if (bytes == null) {
                            return Container(
                              height: 84,
                              color: const Color(0xFF1A1A1A),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.diamond_outlined,
                                size: 28,
                              ),
                            );
                          }
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              bytes,
                              height: 84,
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        symbol.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '${_symbolCategoryFor(symbol, categories)} · ${symbol.children.length} child${symbol.children.length == 1 ? '' : 'ren'}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                final use = VxElement.use(
                                  id: 'use_${DateTime.now().millisecondsSinceEpoch}',
                                  artboardId: state.document.artboards.isEmpty
                                      ? null
                                      : state
                                            .document
                                            .artboards[state
                                                .document
                                                .activePageIndex]
                                            .id,
                                  href: symbol.id,
                                  transform: Matrix4.identity()
                                    ..translate(32.0, 32.0),
                                  opacity: 1.0,
                                  locked: false,
                                  visible: true,
                                );
                                ref
                                    .read(historyProvider)
                                    .execute(AddElementCommand(use));
                              },
                              child: const Text('Insert'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Renaming / duplicating / deleting acts on the artwork
                          // tree, so it is only offered for symbols that live there.
                          if (state.document.elements.any(
                            (e) => e.id == symbol.id,
                          ))
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 18),
                            onSelected: (value) {
                              if (value == 'duplicate') {
                                final duplicate = VxElement.symbol(
                                  id: '${symbol.id}_copy',
                                  artboardId: symbol.artboardId,
                                  children: symbol.children,
                                  transform: symbol.transform,
                                  opacity: symbol.opacity,
                                  locked: symbol.locked,
                                  visible: symbol.visible,
                                  clipPathId: symbol.clipPathId,
                                  maskId: symbol.maskId,
                                );
                                ref
                                    .read(historyProvider)
                                    .execute(AddElementCommand(duplicate));
                              } else if (value == 'delete') {
                                ref
                                    .read(historyProvider)
                                    .execute(DeleteElementCommand([symbol]));
                              } else if (value == 'rename') {
                                _showRenameSymbolDialog(
                                  context,
                                  ref,
                                  symbol,
                                  currentCategory: _symbolCategoryFor(
                                    symbol,
                                    categories,
                                  ),
                                );
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'rename',
                                child: Text('Rename'),
                              ),
                              PopupMenuItem(
                                value: 'duplicate',
                                child: Text('Duplicate'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: state.selectedIds.length >= 2
              ? () => _showDocumentMaskPicker(context, ref)
              : null,
          icon: const Icon(Icons.account_tree_outlined),
          label: const Text('Pick from document tree'),
        ),
      ],
    );
  }



  VxElement? _insertMidpointNode(VxElement element) {
    if (element is! VxPath || element.segments.length < 2) return null;
    final segments = List<PathSegment>.from(element.segments);
    for (var i = 0; i < segments.length - 1; i++) {
      Offset? anchorA;
      Offset? anchorB;
      segments[i].whenOrNull(
        moveTo: (p) => anchorA = p,
        lineTo: (p) => anchorA = p,
        quadraticBezierTo: (c, p) => anchorA = p,
        cubicBezierTo: (c1, c2, p) => anchorA = p,
      );
      segments[i + 1].whenOrNull(
        moveTo: (p) => anchorB = p,
        lineTo: (p) => anchorB = p,
        quadraticBezierTo: (c, p) => anchorB = p,
        cubicBezierTo: (c1, c2, p) => anchorB = p,
      );
      if (anchorA == null || anchorB == null) continue;
      final mid = Offset(
        (anchorA!.dx + anchorB!.dx) / 2,
        (anchorA!.dy + anchorB!.dy) / 2,
      );
      segments.insert(i + 1, PathSegment.lineTo(mid));
      return element.copyWith(segments: segments);
    }
    return null;
  }

  VxElement? _deleteLastNode(VxElement element) {
    if (element is! VxPath || element.segments.length <= 2) return null;
    final segments = List<PathSegment>.from(element.segments);
    segments.removeAt(segments.length - 2);
    return element.copyWith(segments: segments);
  }

    VxElement? _clearReference(
    VxElement element, {
    bool clipPath = false,
    bool mask = false,
  }) {
    return element.map(
      rect: (e) => e.copyWith(clipPathId: clipPath ? null : e.clipPathId, maskId: mask ? null : e.maskId),
      ellipse: (e) => e.copyWith(clipPathId: clipPath ? null : e.clipPathId, maskId: mask ? null : e.maskId),
      path: (e) => e.copyWith(clipPathId: clipPath ? null : e.clipPathId, maskId: mask ? null : e.maskId),
      text: (e) => e.copyWith(clipPathId: clipPath ? null : e.clipPathId, maskId: mask ? null : e.maskId),
      group: (e) => e.copyWith(clipPathId: clipPath ? null : e.clipPathId, maskId: mask ? null : e.maskId),
      compound: (e) => e.copyWith(clipPathId: clipPath ? null : e.clipPathId, maskId: mask ? null : e.maskId),
      use: (e) => e.copyWith(clipPathId: clipPath ? null : e.clipPathId, maskId: mask ? null : e.maskId),
      symbol: (e) => e.copyWith(clipPathId: clipPath ? null : e.clipPathId, maskId: mask ? null : e.maskId),
    );
  }
}

class _MultiSelectionTools extends ConsumerWidget {
  const _MultiSelectionTools();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);
    if (state.selectedIds.length < 2) {
      return const SizedBox.shrink();
    }
    final selected = state.selectedIds
        .map((id) => _findElementById(state.document.elements, id))
        .whereType<VxElement>()
        .toList();
    if (selected.length < 2) {
      return const SizedBox.shrink();
    }
    final sourceId = ref.watch(_maskSourceProvider) ?? selected.first.id;
    final targetId = ref.watch(_maskTargetProvider) ?? selected[1].id;
    final maskSource = selected.firstWhere(
      (element) => element.id == sourceId,
      orElse: () => selected.first,
    );
    final target = selected.firstWhere(
      (element) => element.id == targetId,
      orElse: () => selected[1],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Selection tools',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: maskSource.id,
          dropdownColor: const Color(0xFF1E1E1E),
          decoration: const InputDecoration(labelText: 'Mask source'),
          items: selected
              .map(
                (element) => DropdownMenuItem(
                  value: element.id,
                  child: Text(element.id),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(_maskSourceProvider.notifier).state = value;
            }
          },
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: target.id,
          dropdownColor: const Color(0xFF1E1E1E),
          decoration: const InputDecoration(labelText: 'Mask target'),
          items: selected
              .map(
                (element) => DropdownMenuItem(
                  value: element.id,
                  child: Text(element.id),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(_maskTargetProvider.notifier).state = value;
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            final updated = target.mapOrNull(
              rect: (e) => e.copyWith(maskId: maskSource.id),
              ellipse: (e) => e.copyWith(maskId: maskSource.id),
              path: (e) => e.copyWith(maskId: maskSource.id),
              text: (e) => e.copyWith(maskId: maskSource.id),
              group: (e) => e.copyWith(maskId: maskSource.id),
              compound: (e) => e.copyWith(maskId: maskSource.id),
              use: (e) => e.copyWith(maskId: maskSource.id),
              symbol: (e) => e.copyWith(maskId: maskSource.id),
            );
            if (updated != null) {
              ref
                  .read(historyProvider)
                  .execute(
                    UpdateElementCommand(
                      oldElements: [target],
                      newElements: [updated],
                      actionName: 'Create mask from selection',
                    ),
                  );
            }
          },
          icon: const Icon(Icons.content_cut),
          label: const Text('Apply mask'),
        ),
      ],
    );
  }
}

final _symbolFolderFilterProvider = StateProvider<String>((ref) => 'All');
final _symbolSearchProvider = StateProvider<String>((ref) => '');
final _maskSourceProvider = StateProvider<String?>((ref) => null);
final _maskTargetProvider = StateProvider<String?>((ref) => null);

VxElement? _findElementById(List<VxElement> elements, String id) {
  for (final element in elements) {
    if (element.id == id) return element;
    final found = element.mapOrNull(
      group: (e) => _findElementById(e.children, id),
      compound: (e) => _findElementById(e.children, id),
      symbol: (e) => _findElementById(e.children, id),
    );
    if (found != null) return found;
  }
  return null;
}

Map<String, String> _symbolCategories(
  Map<String, dynamic> metadata,
  List<VxSymbol> symbols,
) {
  final raw = metadata['symbolCategories'];
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value.toString()));
  }
  return {for (final symbol in symbols) symbol.id: _symbolCategoryFor(symbol, {})};
}

String _symbolCategoryFor(VxSymbol symbol, Map<String, String> categories) {
  return categories[symbol.id] ?? _symbolFolderFallback(symbol.id);
}

String _symbolFolderFallback(String id) {
  final parts = id.split('/');
  return parts.length > 1 ? parts.first : 'Root';
}

List<VxElement> _flattenElements(List<VxElement> elements) {
  final out = <VxElement>[];
  for (final element in elements) {
    out.add(element);
    element.mapOrNull(
      group: (e) {
        out.addAll(_flattenElements(e.children));
      },
      compound: (e) {
        out.addAll(_flattenElements(e.children));
      },
      symbol: (e) {
        out.addAll(_flattenElements(e.children));
      },
    );
  }
  return out;
}

VxElement? _applyMaskToElement(VxElement target, String maskId) {
  return target.mapOrNull(
      rect: (e) => e.copyWith(maskId: maskId),
      ellipse: (e) => e.copyWith(maskId: maskId),
      path: (e) => e.copyWith(maskId: maskId),
      text: (e) => e.copyWith(maskId: maskId),
      group: (e) => e.copyWith(maskId: maskId),
      compound: (e) => e.copyWith(maskId: maskId),
      use: (e) => e.copyWith(maskId: maskId),
      symbol: (e) => e.copyWith(maskId: maskId),
  );
}

Future<void> _showDocumentMaskPicker(
  BuildContext context,
  WidgetRef ref,
) async {
  final state = ref.read(editorProvider);
  final elements = _flattenElements(state.document.elements);
  if (elements.length < 2) return;
  String sourceId = elements.first.id;
  String targetId = elements[1].id;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Pick mask source/target'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: sourceId,
                    decoration: const InputDecoration(labelText: 'Source'),
                    items: elements
                        .map(
                          (e) =>
                              DropdownMenuItem(value: e.id, child: Text(e.id)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => sourceId = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: targetId,
                    decoration: const InputDecoration(labelText: 'Target'),
                    items: elements
                        .map(
                          (e) =>
                              DropdownMenuItem(value: e.id, child: Text(e.id)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => targetId = value);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  final source = _findElementById(
                    state.document.elements,
                    sourceId,
                  );
                  final target = _findElementById(
                    state.document.elements,
                    targetId,
                  );
                  if (source == null ||
                      target == null ||
                      source.id == target.id) {
                    return;
                  }
                  final updated = _applyMaskToElement(target, source.id);
                  if (updated != null) {
                    ref
                        .read(historyProvider)
                        .execute(
                          UpdateElementCommand(
                            oldElements: [target],
                            newElements: [updated],
                            actionName: 'Create mask from document tree',
                          ),
                        );
                  }
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      );
    },
  );
}
Future<void> _showRenameSymbolDialog(
  BuildContext context,
  WidgetRef ref,
  VxSymbol symbol, {
  required String currentCategory,
}) async {
  final controller = TextEditingController(text: symbol.id);
  final categoryController = TextEditingController(text: currentCategory);
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Rename symbol'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Symbol ID'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newId = controller.text.trim();
              if (newId.isEmpty || newId == symbol.id) {
                Navigator.pop(dialogContext);
                return;
              }
              ref
                  .read(historyProvider)
                  .execute(
                    UpdateElementCommand(
                      oldElements: [symbol],
                      newElements: [symbol.copyWith(id: newId)],
                      actionName: 'Rename symbol',
                    ),
                  );
              final notifier = ref.read(editorProvider.notifier);
              final metadata = Map<String, dynamic>.from(
                ref.read(editorProvider).document.metadata,
              );
              final categories = Map<String, String>.from(
                _symbolCategories(
                  ref.read(editorProvider).document.metadata,
                  ref
                      .read(editorProvider)
                      .document
                      .elements
                      .whereType<VxSymbol>()
                      .toList(),
                ),
              );
              categories.remove(symbol.id);
              categories[newId] = categoryController.text.trim().isEmpty
                  ? categories[newId] ?? 'Components'
                  : categoryController.text.trim();
              metadata['symbolCategories'] = categories;
              notifier.updateDocumentMetadata(metadata);
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

Future<void> _showSymbolCategoryManager(
  BuildContext context,
  WidgetRef ref,
) async {
  final state = ref.read(editorProvider);
  final symbols = state.document.elements.whereType<VxSymbol>().toList();
  final categories = Map<String, String>.from(
    _symbolCategories(state.document.metadata, symbols),
  );
  final controllers = {
    for (final symbol in symbols)
      symbol.id: TextEditingController(text: categories[symbol.id] ?? ''),
  };

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Symbol categories'),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final symbol in symbols) ...[
                      TextField(
                        controller: controllers[symbol.id],
                        decoration: InputDecoration(
                          labelText: symbol.id,
                          helperText: 'Leave empty to use root category',
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
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
                onPressed: () {
                  final updated = <String, String>{};
                  for (final symbol in symbols) {
                    final value = controllers[symbol.id]!.text.trim();
                    updated[symbol.id] = value.isEmpty
                        ? _symbolCategoryFor(symbol, categories)
                        : value;
                  }
                  final metadata = Map<String, dynamic>.from(
                    state.document.metadata,
                  );
                  metadata['symbolCategories'] = updated;
                  ref
                      .read(editorProvider.notifier)
                      .updateDocumentMetadata(metadata);
                  Navigator.pop(dialogContext);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
