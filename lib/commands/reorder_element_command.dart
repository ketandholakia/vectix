import 'command.dart';
import '../state/editor_notifier.dart';
import '../models/vx_element.dart';

class ReorderElementsCommand implements Command {
  final List<VxElement> oldElements;
  final List<VxElement> newElements;
  
  const ReorderElementsCommand({
    required this.oldElements,
    required this.newElements,
  });

  @override
  void execute(EditorNotifier editor) {
    editor.replaceElements(newElements);
  }

  @override
  void undo(EditorNotifier editor) {
    editor.replaceElements(oldElements);
  }

  @override
  String get description => 'Reorder layers';
}
