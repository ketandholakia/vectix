import 'command.dart';
import '../models/vx_element.dart';
import '../state/editor_notifier.dart';

class DeletePathNodeCommand implements Command {
  final VxElement oldElement;
  final VxElement newElement;

  const DeletePathNodeCommand({
    required this.oldElement,
    required this.newElement,
  });

  @override
  void execute(EditorNotifier editor) {
    editor.replaceElements(
      _replace(editor.elements, newElement),
    );
  }

  @override
  void undo(EditorNotifier editor) {
    editor.replaceElements(
      _replace(editor.elements, oldElement),
    );
  }

  @override
  String get description => 'Delete path node';

  List<VxElement> _replace(List<VxElement> current, VxElement updated) {
    return current.map((e) => e.id == updated.id ? updated : e).toList();
  }
}
