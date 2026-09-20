import 'dart:convert';
import 'dart:io';

/// A snapshot of unsaved work, written so that a crash or a force-quit does not
/// cost the user their drawing.
class RecoverySnapshot {
  const RecoverySnapshot({
    required this.json,
    required this.savedAt,
    this.projectPath,
  });

  /// The document, serialised exactly as a `.vxp` file would be.
  final String json;
  final DateTime savedAt;

  /// Where the project was last saved or opened from, so a restored session can
  /// keep quick-saving to the same file.
  final String? projectPath;

  Map<String, dynamic> toJson() => {
    'json': json,
    'savedAt': savedAt.toIso8601String(),
    if (projectPath != null) 'projectPath': projectPath,
  };

  static RecoverySnapshot? fromJson(Map<String, dynamic> json) {
    final document = json['json'];
    final savedAt = json['savedAt'];
    if (document is! String || savedAt is! String) return null;
    final time = DateTime.tryParse(savedAt);
    if (time == null) return null;
    final path = json['projectPath'];
    return RecoverySnapshot(
      json: document,
      savedAt: time,
      projectPath: path is String ? path : null,
    );
  }
}

/// Reads and writes the autosave snapshot.
///
/// The directory is injected so the behaviour can be tested against a temporary
/// directory rather than the platform's documents folder.
///
/// The file's mere existence means "the previous session ended with unsaved
/// work": it is deleted whenever the project is saved, opened, or discarded, so
/// a leftover snapshot is a reliable crash signal (finding P1-12).
class AutosaveStore {
  AutosaveStore({required this.directory});

  final Future<Directory> Function() directory;

  static const String _fileName = 'vectix_recovery.json';

  Future<File> _file() async {
    final dir = await directory();
    return File('${dir.path}${Platform.pathSeparator}$_fileName');
  }

  /// Writes [json] as the current recovery snapshot.
  Future<void> write(String json, {String? projectPath}) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode(
        RecoverySnapshot(
          json: json,
          savedAt: DateTime.now(),
          projectPath: projectPath,
        ).toJson(),
      ),
    );
  }

  /// The snapshot left behind by a previous session, or null when there is none
  /// or it cannot be read.
  Future<RecoverySnapshot?> read() async {
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return null;
      return RecoverySnapshot.fromJson(decoded);
    } catch (_) {
      // A corrupt or unreadable snapshot must never block startup.
      return null;
    }
  }

  Future<void> clear() async {
    try {
      final file = await _file();
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Best effort: failing to delete a recovery file is not worth surfacing.
    }
  }
}
