import 'command.dart';
import '../models/vx_element.dart';
import '../state/editor_notifier.dart';

class DeleteElementCommand implements Command {
  final List<VxElement> elements;
  final List<int> _originalIndices = [];
  
  DeleteElementCommand(this.elements);

  @override
  void execute(EditorNotifier editor) {
    _originalIndices
      ..clear()
      ..addAll(elements.map((el) => editor.elements.indexWhere((e) => e.id == el.id)));
    final ids = elements.map((e) => e.id).toSet();
    editor.replaceElements(editor.elements.where((e) => !ids.contains(e.id)).toList());
    
    final newSelection = editor.selectedIds.where((id) => !ids.contains(id)).toSet();
    editor.setSelection(newSelection);
  }

  @override
  void undo(EditorNotifier editor) {
    final restored = List<VxElement>.from(editor.elements);
    final pairs = List.generate(elements.length, (i) => MapEntry(_originalIndices[i], elements[i]))
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final pair in pairs.reversed) {
      if (pair.key >= 0 && pair.key <= restored.length) {
        restored.insert(pair.key, pair.value);
      } else {
        restored.add(pair.value);
      }
    }
    editor.replaceElements(restored);
    
    final restoredSelection = Set<String>.from(editor.selectedIds)..addAll(elements.map((e) => e.id));
    editor.setSelection(restoredSelection);
  }

  @override
  String get description => 'Delete element(s)';
}
