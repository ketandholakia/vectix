import 'command.dart';
import '../state/editor_notifier.dart';

class BatchCommand implements Command {
  final List<Command> commands;
  final String actionName;

  const BatchCommand({
    required this.commands,
    this.actionName = 'Batch update',
  });

  @override
  void execute(EditorNotifier editor) {
    for (final command in commands) {
      command.execute(editor);
    }
  }

  @override
  void undo(EditorNotifier editor) {
    for (final command in commands.reversed) {
      command.undo(editor);
    }
  }

  @override
  String get description => actionName;
}
