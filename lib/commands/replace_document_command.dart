import '../models/vx_document.dart';
import '../state/editor_notifier.dart';
import 'command.dart';

/// Records a whole-document transition as one undoable step.
///
/// Document-level operations (artboards, document size, metadata, element
/// flags) each rewrite the document through a notifier method. Wrapping them
/// with a before/after snapshot makes them undoable without duplicating the
/// tree-walking logic those methods already contain — and without a fine-grained
/// command per operation.
///
/// The snapshot is cheap to hold: documents are immutable value objects and the
/// undo stack is capped at 100 entries. Prefer a specific command where one
/// exists; use this for operations that legitimately rewrite the document.
class ReplaceDocumentCommand implements Command {
  const ReplaceDocumentCommand({
    required this.oldDocument,
    required this.newDocument,
    required this.actionName,
  });

  final VxDocument oldDocument;
  final VxDocument newDocument;
  final String actionName;

  @override
  void execute(EditorNotifier editor) =>
      editor.applyDocumentSnapshot(newDocument);

  @override
  void undo(EditorNotifier editor) => editor.applyDocumentSnapshot(oldDocument);

  @override
  String get description => actionName;
}
