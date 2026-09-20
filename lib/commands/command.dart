import '../state/editor_notifier.dart';

abstract class Command {
  /// Applies the command to the editor
  void execute(EditorNotifier editor);

  /// Reverses the command
  void undo(EditorNotifier editor);

  /// User-facing description of what this command did
  String get description;
}
