import 'command.dart';
import '../models/vx_element.dart';
import '../state/editor_notifier.dart';

class TransformCommand implements Command {
  final List<VxElement> oldElements;
  final List<VxElement> newElements;
  final String actionName;

  const TransformCommand({
    required this.oldElements,
    required this.newElements,
    this.actionName = 'Transform elements',
  });

  @override
  void execute(EditorNotifier editor) {
    editor.replaceElements(_replace(editor.elements, newElements));
  }

  @override
  void undo(EditorNotifier editor) {
    editor.replaceElements(_replace(editor.elements, oldElements));
  }

  @override
  String get description => actionName;

  List<VxElement> _replace(List<VxElement> current, List<VxElement> updates) {
    final map = {for (final e in updates) e.id: e};
    return current.map((e) => map[e.id] ?? e).toList();
  }
}
