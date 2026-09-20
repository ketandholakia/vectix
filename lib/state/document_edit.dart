import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../commands/replace_document_command.dart';
import 'editor_notifier.dart';
import 'history_manager.dart';

/// Runs a document-level edit and records the before/after documents as a single
/// undoable step.
///
/// [mutate] performs the change through the notifier (for example
/// `notifier.addPage()`). If it leaves the document unchanged, nothing is
/// recorded, so a no-op never pollutes the undo stack.
///
/// This is how artboard operations, document size, element flags and metadata
/// become undoable without a bespoke command each (finding P1-6: those paths
/// wrote state directly and were invisible to undo).
void recordDocumentEdit({
  required EditorNotifier editor,
  required HistoryManager history,
  required String actionName,
  required void Function() mutate,
}) {
  final before = editor.state.document;
  mutate();
  final after = editor.state.document;
  if (identical(before, after) || before == after) return;
  history.execute(
    ReplaceDocumentCommand(
      oldDocument: before,
      newDocument: after,
      actionName: actionName,
    ),
  );
}

/// Widget-side sugar so a call site reads as one line:
/// `ref.recordEdit('Add artboard', () => notifier.addPage());`
extension DocumentEditRef on WidgetRef {
  void recordEdit(String actionName, void Function() mutate) =>
      recordDocumentEdit(
        editor: read(editorProvider.notifier),
        history: read(historyProvider),
        actionName: actionName,
        mutate: mutate,
      );
}
