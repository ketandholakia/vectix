import 'command.dart';
import '../models/vx_element.dart';
import '../state/editor_notifier.dart';

class AddElementCommand implements Command {
  final VxElement element;
  
  const AddElementCommand(this.element);

  @override
  void execute(EditorNotifier editor) {
    editor.addElement(element);
  }

  @override
  void undo(EditorNotifier editor) {
    editor.removeElement(element.id);
  }

  @override
  String get description => 'Add element';
}
