import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'autosave_store.dart';
import '../state/editor_notifier.dart';

/// What the user is working on and whether it has changed since it was written.
///
/// A plain immutable value: the dirty and recovery rules can be unit tested
/// without a UI or a file system.
@immutable
class ProjectSession {
  const ProjectSession({
    this.path,
    this.dirty = false,
    this.recoveryAvailable = false,
  });

  /// The project file, or null when it has never been saved.
  final String? path;

  /// True when the document has changed since it was last saved or opened.
  final bool dirty;

  /// True when a recovery snapshot is waiting from a previous session.
  final bool recoveryAvailable;

  /// File name without directories, for window titles and messages.
  String get fileName {
    final full = path;
    if (full == null) return 'Untitled';
    final parts = full.split(RegExp(r'[\\/]'));
    return parts.isEmpty ? full : parts.last;
  }

  String get displayTitle => fileName + (dirty ? ' •' : '');

  ProjectSession copyWith({
    String? path,
    bool? dirty,
    bool? recoveryAvailable,
  }) => ProjectSession(
    path: path ?? this.path,
    dirty: dirty ?? this.dirty,
    recoveryAvailable: recoveryAvailable ?? this.recoveryAvailable,
  );
}

/// Where the editor writes its autosave snapshot. Overridden in tests.
final autosaveStoreProvider = Provider<AutosaveStore>(
  (ref) => AutosaveStore(directory: getApplicationDocumentsDirectory),
);

/// How long the editor waits after the last edit before snapshotting.
/// Overridable so tests do not have to wait three seconds.
final autosaveDebounceProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 3),
);

class ProjectSessionNotifier extends Notifier<ProjectSession> {
  Timer? _autosave;

  AutosaveStore get _store => ref.read(autosaveStoreProvider);

  @override
  ProjectSession build() {
    ref.onDispose(() => _autosave?.cancel());

    // Every document change marks the session dirty and schedules an autosave.
    // Comparing identity is exact here: the document is an immutable value that
    // is replaced on every edit.
    ref.listen(editorProvider.select((state) => state.document), (
      previous,
      next,
    ) {
      if (identical(previous, next)) return;
      state = state.copyWith(dirty: true);
      _scheduleAutosave();
    });

    return const ProjectSession();
  }

  void _scheduleAutosave() {
    _autosave?.cancel();
    _autosave = Timer(
      ref.read(autosaveDebounceProvider),
      () => unawaited(snapshotNow()),
    );
  }

  /// Writes a recovery snapshot of the current document immediately.
  Future<void> snapshotNow() async {
    final document = ref.read(editorProvider).document;
    await _store.write(
      jsonEncode(document.toJson()),
      projectPath: state.path,
    );
  }

  /// Records that the document now matches [path].
  void markSaved(String path) {
    state = state.copyWith(path: path, dirty: false);
  }

  /// Records that the document was just loaded from [path] unchanged.
  void markOpened(String path) {
    state = state.copyWith(path: path, dirty: false);
  }

  /// Records the file a *restored* session came from, leaving the dirty flag
  /// set: the recovered content is newer than what is on disk.
  void markRestored(String path) {
    state = state.copyWith(path: path, dirty: true);
  }

  /// Forgets the file association (a new, unsaved document).
  void markNew() {
    state = const ProjectSession();
  }

  Future<void> clearRecovery() async {
    await _store.clear();
    state = state.copyWith(recoveryAvailable: false);
  }

  /// Checks for a snapshot left behind by a previous session.
  Future<RecoverySnapshot?> pendingRecovery() async {
    final snapshot = await _store.read();
    if (snapshot != null && !state.recoveryAvailable) {
      state = state.copyWith(recoveryAvailable: true);
    }
    return snapshot;
  }
}

final projectSessionProvider =
    NotifierProvider<ProjectSessionNotifier, ProjectSession>(
      ProjectSessionNotifier.new,
    );

/// What the user chose when told there are unsaved changes.
enum UnsavedChoice { save, discard }

/// Decides whether a destructive action (open, import, new) may proceed.
///
/// [ask] presents the choice and returns null when the user cancelled, so this
/// stays a pure decision that can be tested without a dialog.
Future<bool> resolveUnsavedChanges({
  required bool dirty,
  required Future<UnsavedChoice?> Function() ask,
  required Future<bool> Function() save,
}) async {
  if (!dirty) return true;
  final choice = await ask();
  switch (choice) {
    case UnsavedChoice.discard:
      return true;
    case UnsavedChoice.save:
      return save();
    case null:
      return false;
  }
}
