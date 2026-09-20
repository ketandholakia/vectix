import 'package:flutter_test/flutter_test.dart';

import 'corpus/corpus.dart';
import 'corpus/corpus_support.dart';

/// The SVG fidelity corpus — task **B6**.
///
/// Two independent nets:
///
/// 1. **Render hashes.** Every corpus file is rendered and hashed; the hashes
///    are committed to `test/corpus/render_hashes.json`. Any change in what
///    Vectix draws fails the build. Regenerate deliberately:
///    `flutter test --dart-define=UPDATE_CORPUS_HASHES=true test/svg_corpus_test.dart`
///    and review the manifest diff.
/// 2. **Round-trip fidelity.** Import -> export -> import, both renders
///    compared. Relative to the same machine, so it needs no committed
///    baseline and catches lossy or asymmetric conversion.
///
/// See `test/corpus/corpus.dart` for what the corpus does *not* claim.
const bool _updateHashes = bool.fromEnvironment('UPDATE_CORPUS_HASHES');

/// Minimum fraction of identical pixels after an export -> import cycle.
///
/// Held at 1.0: the corpus is geometry-only and the comparison is between two
/// renders on the same machine, so a lossless round trip is achievable and any
/// loss is either a bug or a decision that has to be written down here.
const double _roundTripFloor = 1.0;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final corpus = loadCorpus();

  test('corpus is not empty and every entry imports', () async {
    expect(corpus, isNotEmpty);

    final failures = <String>[];
    for (final entry in corpus.entries) {
      final result = await evaluateCorpus(entry.key, entry.value);
      if (!result.imported) {
        failures.add('${entry.key}: ${result.error}');
      }
      if (result.error != null && result.imported) {
        failures.add('${entry.key}: ${result.error}');
      }
    }
    expect(failures, isEmpty, reason: 'corpus entries failed:\n${failures.join('\n')}');
  });

  test('render hashes match the committed manifest', () async {
    final manifest = readManifest();
    final updated = <String, dynamic>{};
    final regressions = <String>[];
    final added = <String>[];

    for (final entry in corpus.entries) {
      final result = await evaluateCorpus(entry.key, entry.value);
      updated[entry.key] = result.toJson();

      final expected = manifest[entry.key];
      if (expected == null) {
        added.add(entry.key);
        continue;
      }
      if (expected['pixelHash'] != result.pixelHash) {
        regressions.add(
          '${entry.key}: ${expected['pixelHash']} -> ${result.pixelHash}',
        );
      }
    }

    if (_updateHashes) {
      writeManifest(updated);
      return;
    }

    expect(
      added,
      isEmpty,
      reason:
          'new corpus entries without a committed hash: ${added.join(', ')}\n'
          'Run with --dart-define=UPDATE_CORPUS_HASHES=true and review the diff.',
    );
    expect(
      regressions,
      isEmpty,
      reason:
          'rendered output changed for:\n${regressions.join('\n')}\n'
          'If the change is intended, regenerate with\n'
          '  flutter test --dart-define=UPDATE_CORPUS_HASHES=true test/svg_corpus_test.dart\n'
          'and review the manifest diff carefully.',
    );
  });

  test('round-trip fidelity stays above the floor', () async {
    final rows = <List<String>>[];
    final failures = <String>[];

    for (final entry in corpus.entries) {
      final result = await evaluateCorpus(entry.key, entry.value);
      if (!result.imported) continue;

      rows.add([
        entry.key,
        '${(result.roundTripFidelity * 100).toStringAsFixed(2)}%',
        result.diffBounds == null
            ? ''
            : 'differs at ${result.diffBounds!.left.toInt()},${result.diffBounds!.top.toInt()}'
                  '..${result.diffBounds!.right.toInt()},${result.diffBounds!.bottom.toInt()}',
      ]);
      if (result.roundTripFidelity < _roundTripFloor) {
        failures.add(
          '${entry.key}: ${(result.roundTripFidelity * 100).toStringAsFixed(2)}%',
        );
      }
    }

    // Printed so CI logs carry the score, not just a pass/fail.
    final width = rows.fold<int>(0, (w, r) => r[0].length > w ? r[0].length : w);
    final report = StringBuffer('round-trip fidelity (import -> export -> import)\n');
    for (final row in rows) {
      report.writeln(
        '  ${row[0].padRight(width)}  ${row[1].padLeft(7)}  ${row[2]}',
      );
    }
    final score = rows.isEmpty
        ? 0.0
        : rows
                  .map(
                    (r) =>
                        double.parse(r[1].replaceAll('%', '')) / 100,
                  )
                  .reduce((a, b) => a + b) /
              rows.length;
    report.writeln(
      '  mean ${(score * 100).toStringAsFixed(2)}% over ${rows.length} files, '
      'floor ${(_roundTripFloor * 100).toStringAsFixed(0)}%',
    );
    // ignore: avoid_print
    print(report.toString());

    expect(
      failures,
      isEmpty,
      reason: 'below the fidelity floor:\n${failures.join('\n')}',
    );
  });
}
