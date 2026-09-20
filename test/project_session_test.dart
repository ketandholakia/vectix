import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:vectix/commands/add_element_command.dart';
import 'package:vectix/models/vx_element.dart';
import 'package:vectix/services/autosave_store.dart';
import 'package:vectix/services/project_session.dart';
import 'package:vectix/state/editor_notifier.dart';
import 'package:vectix/state/history_manager.dart';

/// Regression tests for **C5** — finding P1-12.
///
/// Opening a project or importing an SVG replaced the document with no warning
/// and no way back, there was no autosave, and every save re-prompted for a
/// file name because the open file was never remembered.
void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('vectix_autosave_test');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  AutosaveStore tempStore() => AutosaveStore(directory: () async => tempDir);

  group('AutosaveStore', () {
    test('write then read round trips the document and project path', () async {
      final store = tempStore();
      await store.write('{"doc":1}', projectPath: '/tmp/drawing.vxp');

      final snapshot = await store.read();

      expect(snapshot, isNotNull);
      expect(snapshot!.json, '{"doc":1}');
      expect(snapshot.projectPath, '/tmp/drawing.vxp');
      expect(
        snapshot.savedAt.isBefore(DateTime.now().add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('read returns null when nothing was ever written', () async {
      expect(await tempStore().read(), isNull);
    });

    test('clear removes the snapshot', () async {
      final store = tempStore();
      await store.write('{}');
      expect(await store.read(), isNotNull);

      await store.clear();

      expect(await store.read(), isNull);
    });

    test('a corrupt snapshot reads as null rather than throwing', () async {
      final store = tempStore();
      final file = File('${tempDir.path}${Platform.pathSeparator}vectix_recovery.json');
      await file.writeAsString('this is not json');

      expect(await store.read(), isNull);
    });

    test('the file existing is the crash signal', () async {
      final store = tempStore();
      final file = File('${tempDir.path}${Platform.pathSeparator}vectix_recovery.json');
      expect(await file.exists(), isFalse, reason: 'nothing written yet');

      await store.write('{}');
      expect(await file.exists(), isTrue);

      await store.clear();
      expect(
        await file.exists(),
        isFalse,
        reason: 'a clean save must remove the recovery file',
      );
    });
  });

  group('ProjectSession', () {
    late ProviderContainer container;

    ProviderContainer makeContainer({Duration debounce = const Duration(seconds: 3)}) {
      final c = ProviderContainer(
        overrides: [
          autosaveStoreProvider.overrideWithValue(tempStore()),
          autosaveDebounceProvider.overrideWithValue(debounce),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    VxElement box(String id) => VxElement.rect(
      id: id,
      x: 0,
      y: 0,
      width: 5,
      height: 5,
      transform: Matrix4.identity(),
      fill: const VxFill.solid(color: Colors.red),
      stroke: const VxStroke(
        color: Colors.transparent,
        width: 0,
        cap: StrokeCap.butt,
        join: StrokeJoin.miter,
      ),
    );

    test('starts clean and unsaved', () {
      container = makeContainer();
      final session = container.read(projectSessionProvider);

      expect(session.path, isNull);
      expect(session.dirty, isFalse);
      expect(session.displayTitle, 'Untitled');
    });

    test('an edit marks the session dirty', () {
      container = makeContainer();
      container.read(projectSessionProvider); // start listening

      container.read(historyProvider).execute(AddElementCommand(box('r1')));

      expect(container.read(projectSessionProvider).dirty, isTrue);
    });

    test('saving clears the dirty flag and remembers the path', () {
      container = makeContainer();
      container.read(projectSessionProvider);
      container.read(historyProvider).execute(AddElementCommand(box('r1')));

      container.read(projectSessionProvider.notifier).markSaved('/tmp/a.vxp');

      final session = container.read(projectSessionProvider);
      expect(session.dirty, isFalse);
      expect(session.path, '/tmp/a.vxp');
      expect(session.fileName, 'a.vxp');
      expect(session.displayTitle, 'a.vxp');
    });

    test('editing again after a save marks it dirty once more', () {
      container = makeContainer();
      container.read(projectSessionProvider);
      final history = container.read(historyProvider);

      history.execute(AddElementCommand(box('r1')));
      container.read(projectSessionProvider.notifier).markSaved('/tmp/a.vxp');
      expect(container.read(projectSessionProvider).dirty, isFalse);

      history.execute(AddElementCommand(box('r2')));

      expect(container.read(projectSessionProvider).dirty, isTrue);
      expect(container.read(projectSessionProvider).displayTitle, 'a.vxp •');
    });

    test('a restored session keeps its path but stays dirty', () {
      container = makeContainer();
      container.read(projectSessionProvider);

      container.read(projectSessionProvider.notifier).markRestored('/tmp/a.vxp');

      final session = container.read(projectSessionProvider);
      expect(session.path, '/tmp/a.vxp');
      expect(
        session.dirty,
        isTrue,
        reason: 'recovered content is newer than the file on disk',
      );
    });

    test('autosave writes a snapshot after the debounce', () async {
      container = makeContainer(debounce: const Duration(milliseconds: 10));
      container.read(projectSessionProvider);

      container.read(historyProvider).execute(AddElementCommand(box('r1')));
      expect(await tempStore().read(), isNull, reason: 'debounced, not immediate');

      await Future<void>.delayed(const Duration(milliseconds: 120));

      final snapshot = await tempStore().read();
      expect(snapshot, isNotNull);
      final decoded = jsonDecode(snapshot!.json) as Map<String, dynamic>;
      expect((decoded['elements'] as List).length, 1);
    });

    test('snapshotNow writes immediately and records the project path', () async {
      container = makeContainer();
      final notifier = container.read(projectSessionProvider.notifier);
      notifier.markSaved('/tmp/a.vxp');

      await notifier.snapshotNow();

      expect((await tempStore().read())!.projectPath, '/tmp/a.vxp');
    });

    test('pendingRecovery surfaces a snapshot from a previous session', () async {
      await tempStore().write('{"id":"restored"}', projectPath: '/tmp/a.vxp');

      container = makeContainer();
      final snapshot = await container
          .read(projectSessionProvider.notifier)
          .pendingRecovery();

      expect(snapshot, isNotNull);
      expect(snapshot!.json, '{"id":"restored"}');
      expect(container.read(projectSessionProvider).recoveryAvailable, isTrue);
    });
  });

  group('unsaved-changes guard', () {
    test('proceeds without asking when there is nothing to lose', () async {
      var asked = false;
      final proceed = await resolveUnsavedChanges(
        dirty: false,
        ask: () async {
          asked = true;
          return UnsavedChoice.discard;
        },
        save: () async => true,
      );

      expect(proceed, isTrue);
      expect(asked, isFalse);
    });

    test('discarding proceeds', () async {
      final proceed = await resolveUnsavedChanges(
        dirty: true,
        ask: () async => UnsavedChoice.discard,
        save: () async => true,
      );
      expect(proceed, isTrue);
    });

    test('saving proceeds only when the save succeeded', () async {
      expect(
        await resolveUnsavedChanges(
          dirty: true,
          ask: () async => UnsavedChoice.save,
          save: () async => true,
        ),
        isTrue,
      );
      expect(
        await resolveUnsavedChanges(
          dirty: true,
          ask: () async => UnsavedChoice.save,
          save: () async => false,
        ),
        isFalse,
        reason: 'a cancelled or failed save must cancel the action',
      );
    });

    test('cancelling blocks the action', () async {
      final proceed = await resolveUnsavedChanges(
        dirty: true,
        ask: () async => null,
        save: () async => true,
      );
      expect(proceed, isFalse);
    });
  });
}
