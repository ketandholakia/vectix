import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart';
import '../models/vx_element.dart';
import '../state/editor_notifier.dart';
import 'command.dart';
import 'element_splice.dart';

class GroupCommand implements Command {
  final List<VxElement> oldElements;
  late VxGroup newGroup;

  List<int> _originalIndices = const [];
  int _groupIndex = 0;

  GroupCommand(this.oldElements) {
    newGroup = VxGroup(
      id: const Uuid().v4(),
      children: oldElements,
      transform: Matrix4.identity(),
    );
  }

  @override
  void execute(EditorNotifier editor) {
    final elements = editor.elements;
    _originalIndices = indicesOf(elements, oldElements.map((e) => e.id));
    _groupIndex = containerInsertIndex(_originalIndices, elements);
    editor.replaceElements(
      spliceElements(
        elements,
        removedIds: oldElements.map((e) => e.id).toSet(),
        index: _groupIndex,
        inserted: [newGroup],
      ),
    );
    editor.setSelection({newGroup.id});
  }

  @override
  void undo(EditorNotifier editor) {
    // Restore the members at their original indices, not appended to the end:
    // appending silently reordered the layers (found by the C1 undo test).
    final restored = reinsertElements(
      withoutIds(editor.elements, {newGroup.id}),
      [
        for (var i = 0; i < oldElements.length; i++)
          MapEntry(_originalIndices[i], oldElements[i]),
      ],
    );
    editor.replaceElements(restored);
    editor.setSelection(oldElements.map((e) => e.id).toSet());
  }

  @override
  String get description => 'Group elements';
}
