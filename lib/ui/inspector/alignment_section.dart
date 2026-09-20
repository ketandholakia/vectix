import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/editor_notifier.dart';
import '../../state/history_manager.dart';
import '../../commands/update_element_command.dart';

class AlignmentSection extends ConsumerWidget {
  const AlignmentSection({super.key});

  void _align(WidgetRef ref, Alignment alignment) {
    final notifier = ref.read(editorProvider.notifier);
    final state = ref.read(editorProvider);
    final oldElements = state.selectedIds.map((id) => state.document.elements.firstWhere((e) => e.id == id)).toList();
    final newElements = notifier.computeAlignment(alignment);
    
    if (newElements.isNotEmpty) {
      ref.read(historyProvider).execute(UpdateElementCommand(
        oldElements: oldElements,
        newElements: newElements,
        actionName: 'Align elements',
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Align', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.align_horizontal_left, color: Colors.white),
              onPressed: () => _align(ref, Alignment.centerLeft),
            ),
            IconButton(
              icon: const Icon(Icons.align_horizontal_center, color: Colors.white),
              onPressed: () => _align(ref, Alignment.center),
            ),
            IconButton(
              icon: const Icon(Icons.align_horizontal_right, color: Colors.white),
              onPressed: () => _align(ref, Alignment.centerRight),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.align_vertical_top, color: Colors.white),
              onPressed: () => _align(ref, Alignment.topCenter),
            ),
            IconButton(
              icon: const Icon(Icons.align_vertical_center, color: Colors.white),
              onPressed: () => _align(ref, Alignment.center),
            ),
            IconButton(
              icon: const Icon(Icons.align_vertical_bottom, color: Colors.white),
              onPressed: () => _align(ref, Alignment.bottomCenter),
            ),
          ],
        ),
      ],
    );
  }
}
