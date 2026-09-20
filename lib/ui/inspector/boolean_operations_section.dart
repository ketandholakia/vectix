import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/editor_notifier.dart';
import '../../state/history_manager.dart';
import '../../commands/boolean_operation_command.dart';

class BooleanOperationsSection extends ConsumerWidget {
  const BooleanOperationsSection({super.key});

  void _applyBoolean(WidgetRef ref, int operation) {
    final state = ref.read(editorProvider);
    if (state.selectedIds.length < 2) return;

    final elements = state.selectedIds.map((id) => state.document.elements.firstWhere((e) => e.id == id)).toList();
    
    ref.read(historyProvider).execute(BooleanOperationCommand(
      oldElements: elements,
      operation: operation,
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Boolean Operations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.flip_to_back, color: Colors.white),
              tooltip: 'Difference',
              onPressed: () => _applyBoolean(ref, 0),
            ),
            IconButton(
              icon: const Icon(Icons.compare, color: Colors.white),
              tooltip: 'Intersect',
              onPressed: () => _applyBoolean(ref, 1),
            ),
            IconButton(
              icon: const Icon(Icons.merge_type, color: Colors.white),
              tooltip: 'Union',
              onPressed: () => _applyBoolean(ref, 2),
            ),
            IconButton(
              icon: const Icon(Icons.filter_b_and_w, color: Colors.white),
              tooltip: 'XOR',
              onPressed: () => _applyBoolean(ref, 3),
            ),
          ],
        ),
      ],
    );
  }
}
