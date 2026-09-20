import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart';
import '../models/vx_element.dart';
import '../state/editor_notifier.dart';
import 'command.dart';

class GroupCommand implements Command {
  final List<VxElement> oldElements;
  late VxGroup newGroup;

  GroupCommand(this.oldElements) {
    newGroup = VxGroup(
      id: const Uuid().v4(),
      children: oldElements,
      transform: Matrix4.identity(),
    );
  }

  @override
  void execute(EditorNotifier editor) {
    final remaining = editor.state.document.elements.where((e) => !oldElements.any((old) => old.id == e.id)).toList();
    editor.replaceElements([...remaining, newGroup]);
    editor.setSelection({newGroup.id});
  }

  @override
  void undo(EditorNotifier editor) {
    final remaining = editor.state.document.elements.where((e) => e.id != newGroup.id).toList();
    editor.replaceElements([...remaining, ...oldElements]);
    editor.setSelection(oldElements.map((e) => e.id).toSet());
  }

  @override
  String get description => 'Group elements';
}
