import '../models/vx_element.dart';
import '../state/editor_notifier.dart';
import 'command.dart';

class UngroupCommand implements Command {
  final VxGroup oldGroup;
  late List<VxElement> newElements;

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
    final remaining = editor.state.document.elements.where((e) => e.id != oldGroup.id).toList();
    editor.replaceElements([...remaining, ...newElements]);
    editor.setSelection(newElements.map((e) => e.id).toSet());
  }

  @override
  void undo(EditorNotifier editor) {
    final remaining = editor.state.document.elements.where((e) => !newElements.any((n) => n.id == e.id)).toList();
    editor.replaceElements([...remaining, oldGroup]);
    editor.setSelection({oldGroup.id});
  }

  @override
  String get description => 'Ungroup elements';
}

