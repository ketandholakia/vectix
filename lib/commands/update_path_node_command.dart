import 'command.dart';
import '../models/vx_element.dart';
import '../state/editor_notifier.dart';

class UpdatePathNodeCommand implements Command {
  final VxElement oldElement;
  final VxElement newElement;
  final String descriptionText;

  const UpdatePathNodeCommand({
    required this.oldElement,
    required this.newElement,
    this.descriptionText = 'Edit path node',
  });

  @override
  void execute(EditorNotifier editor) {
    editor.replaceElements(
      _replace(editor.state.document.elements, newElement),
    );
  }

  @override
  void undo(EditorNotifier editor) {
    editor.replaceElements(
      _replace(editor.state.document.elements, oldElement),
    );
  }

  @override
  String get description => descriptionText;

  List<VxElement> _replace(List<VxElement> current, VxElement updated) {
    return current.map((e) => e.id == updated.id ? updated : e).toList();
  }
}
