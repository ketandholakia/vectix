import '../models/vx_element.dart';
import '../state/editor_notifier.dart';
import 'command.dart';

class TextEditCommand implements Command {
  final VxText oldElement;
  final VxText newElement;
  final String actionName;

  const TextEditCommand({
    required this.oldElement,
    required this.newElement,
    this.actionName = 'Edit text',
  });

  @override
  void execute(EditorNotifier editor) {
    editor.updateElement(newElement);
  }

  @override
  void undo(EditorNotifier editor) {
    editor.updateElement(oldElement);
  }

  @override
  String get description => actionName;
}
