import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../commands/command.dart';
import 'editor_notifier.dart';

final historyProvider = ChangeNotifierProvider((ref) => HistoryManager(ref.read(editorProvider.notifier)));

class HistoryManager extends ChangeNotifier {
  final EditorNotifier _editor;
  final List<Command> _history = [];
  int _cursor = -1;
  static const _maxHistory = 100;

  HistoryManager(this._editor);

  bool get canUndo => _cursor >= 0;
  bool get canRedo => _cursor < _history.length - 1;

  void execute(Command cmd) {
    // Discard redo history if we're not at the end
    if (_cursor < _history.length - 1) {
      _history.removeRange(_cursor + 1, _history.length);
    }
    
    cmd.execute(_editor);
    
    _history.add(cmd);
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
    } else {
      _cursor++;
    }
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;
    _history[_cursor].undo(_editor);
    _cursor--;
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    _cursor++;
    _history[_cursor].execute(_editor);
    notifyListeners();
  }
}
