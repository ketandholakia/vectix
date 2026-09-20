import '../models/vx_element.dart';
import '../state/editor_notifier.dart';
import 'command.dart';
import 'element_splice.dart';

class UngroupCommand implements Command {
  final VxGroup oldGroup;
  late List<VxElement> newElements;

  int _groupIndex = 0;

  UngroupCommand(this.oldGroup) {
    // When ungrouping, we must apply the group's transform to each child
    final groupTransform = oldGroup.transform;
    newElements = oldGroup.children.map((child) {
      final combinedTransform = groupTransform.clone()..multiply(child.transform);
      return child.copyWith(transform: combinedTransform);
    }).toList();
  }

  @override
  void execute(EditorNotifier editor) {
    final elements = editor.state.document.elements;
    _groupIndex = elements.indexWhere((e) => e.id == oldGroup.id);
    editor.replaceElements(
      spliceElements(
        elements,
        removedIds: {oldGroup.id},
        // Put the children where the group was rather than at the end, so
        // ungrouping does not drop the artwork behind everything else.
        index: _groupIndex < 0 ? elements.length : _groupIndex,
        inserted: newElements,
      ),
    );
    editor.setSelection(newElements.map((e) => e.id).toSet());
  }

  @override
  void undo(EditorNotifier editor) {
    editor.replaceElements(
      spliceElements(
        editor.state.document.elements,
        removedIds: newElements.map((e) => e.id).toSet(),
        index: _groupIndex < 0 ? 0 : _groupIndex,
        inserted: [oldGroup],
      ),
    );
    editor.setSelection({oldGroup.id});
  }

  @override
  String get description => 'Ungroup elements';
}
