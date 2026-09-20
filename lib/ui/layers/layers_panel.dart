import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/vx_element.dart';
import '../../state/editor_notifier.dart';
import '../../state/document_edit.dart';
import '../../state/history_manager.dart';
import '../../commands/reorder_element_command.dart';
import '../../canvas/scene_index.dart';

class LayersPanel extends ConsumerWidget {
  const LayersPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);
    final sceneIndex = SceneIndex.of(state.document);
    final elements = sceneIndex.activeElements.reversed.toList(); // Draw order: last is top
    final query = ref.watch(_layersSearchProvider);
    final filtered = query.isEmpty
        ? elements
        : elements.where((element) => _getNameForElement(element).toLowerCase().contains(query.toLowerCase())).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('LAYERS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white, letterSpacing: 1.2)),
              Text(
                state.document.artboards.isEmpty ? 'Document-wide' : 'Active artboard only',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => ref.read(_layersSearchProvider.notifier).state = value,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Search layers',
                  hintStyle: TextStyle(color: Colors.white38),
                  prefixIcon: Icon(Icons.search, color: Colors.white54, size: 18),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No elements', style: TextStyle(color: Colors.white54)))
              : ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: filtered.length,
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    if (oldIndex == newIndex) return;

                    final oldElements = state.document.elements;
                    
                    // elements is reversed. So index 0 is the top layer.
                    final uiList = List<VxElement>.from(filtered);
                    final element = uiList.removeAt(oldIndex);
                    uiList.insert(newIndex, element);

                    // Find slots occupied by filtered elements
                    final filteredIds = filtered.map((e) => e.id).toSet();
                    final slotIndices = <int>[];
                    for (int i = 0; i < oldElements.length; i++) {
                      if (filteredIds.contains(oldElements[i].id)) {
                        slotIndices.add(i);
                      }
                    }

                    final newElements = List<VxElement>.from(oldElements);
                    // uiList is top-to-bottom. We need bottom-to-top (document order).
                    final documentOrderedFiltered = uiList.reversed.toList();
                    
                    for (int i = 0; i < slotIndices.length; i++) {
                      newElements[slotIndices[i]] = documentOrderedFiltered[i];
                    }

                    ref.read(historyProvider).execute(ReorderElementsCommand(
                      oldElements: oldElements,
                      newElements: newElements,
                    ));
                  },
                  itemBuilder: (context, index) {
                    final element = filtered[index];
                    final isSelected = state.selectedIds.contains(element.id);
                    
                    return ReorderableDragStartListener(
                      key: ValueKey(element.id),
                      index: index,
                      child: ListTile(
                        dense: true,
                        tileColor: isSelected ? Colors.blue.withValues(alpha: 0.3) : null,
                        leading: Icon(_getIconForElement(element), color: isSelected ? Colors.blueAccent : Colors.white54, size: 18),
                        title: Text(_getNameForElement(element), style: const TextStyle(color: Colors.white, fontSize: 12)),
                        subtitle: Text(
                          '${element.artboardId == null ? 'Global' : 'Artboard'}${element.locked ? ' · Locked' : ''}${element.visible ? '' : ' · Hidden'}',
                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              icon: Icon(element.locked ? Icons.lock : Icons.lock_open, size: 16),
                              color: Colors.white54,
                              onPressed: () => ref.recordEdit(
                                element.locked ? 'Unlock element' : 'Lock element',
                                () => ref.read(editorProvider.notifier).updateElementFlags(element.id, locked: !element.locked),
                              ),
                              tooltip: element.locked ? 'Unlock' : 'Lock',
                            ),
                            IconButton(
                              icon: Icon(element.visible ? Icons.visibility : Icons.visibility_off, size: 16),
                              color: Colors.white54,
                              onPressed: () => ref.recordEdit(
                                element.visible ? 'Hide element' : 'Show element',
                                () => ref.read(editorProvider.notifier).updateElementFlags(element.id, visible: !element.visible),
                              ),
                              tooltip: element.visible ? 'Hide' : 'Show',
                            ),
                            const Icon(Icons.drag_handle, color: Colors.white54, size: 16),
                          ],
                        ),
                        onTap: () {
                          ref.read(editorProvider.notifier).clearSelection();
                          ref.read(editorProvider.notifier).selectElement(element.id);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  IconData _getIconForElement(VxElement element) {
    return element.map(
      rect: (e) => Icons.crop_square,
      ellipse: (e) => Icons.circle_outlined,
      path: (e) => Icons.timeline,
      text: (e) => Icons.text_fields,
      group: (e) => Icons.folder_open,
      compound: (e) => Icons.category,
      use: (e) => Icons.insert_link,
      symbol: (e) => Icons.diamond,
    );
  }

  String _getNameForElement(VxElement element) {
    return element.map(
      rect: (e) => 'Rectangle',
      ellipse: (e) => 'Ellipse',
      path: (e) => 'Path',
      text: (e) => e.content.isEmpty ? 'Text' : e.content,
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
      use: (e) => 'Use ()',
      symbol: (e) => 'Symbol',
    );
  }
}

final _layersSearchProvider = StateProvider<String>((ref) => '');

