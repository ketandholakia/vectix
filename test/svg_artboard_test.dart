import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:vectix/models/vx_document.dart';
import 'package:vectix/models/vx_element.dart';
import 'package:vectix/svg/svg_exporter.dart';
import 'package:vectix/svg/svg_importer.dart';

import 'corpus/corpus_support.dart';

/// Regression tests for **B5** — finding P1-9.
///
/// `SvgExporter` wrote every element in the document into one file while using
/// the active artboard's size as the `viewBox`, so a multi-artboard document
/// exported as one flat, overlapping image. PNG and PDF had their own artboard
/// filters; SVG had none. The rule now lives in `SceneIndex` and every path
/// shares it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  VxElement rectOn(
    String id,
    String? artboardId,
    Color color, {
    double x = 0,
    double y = 0,
  }) => VxElement.rect(
    id: id,
    artboardId: artboardId,
    x: x,
    y: y,
    width: 20,
    height: 20,
    transform: Matrix4.identity(),
    fill: VxFill.solid(color: color),
    stroke: const VxStroke(
      color: Colors.transparent,
      width: 0,
      cap: StrokeCap.butt,
      join: StrokeJoin.miter,
    ),
  );

  VxDocument twoArtboards({int active = 0}) => VxDocument(
    id: 'doc',
    title: 't',
    width: 100,
    height: 100,
    artboards: const [
      VxArtboard(id: 'a1', name: 'One', x: 0, y: 0, width: 100, height: 100),
      VxArtboard(id: 'a2', name: 'Two', x: 0, y: 0, width: 60, height: 40),
    ],
    activePageIndex: active,
    elements: [
      rectOn('on_a1', 'a1', Colors.red),
      rectOn('on_a2', 'a2', Colors.blue),
      rectOn('on_every_artboard', null, Colors.green, x: 60, y: 60),
    ],
  );

  group('artboard scoping', () {
    test('only the active artboard is written', () {
      final exported = SvgExporter.export(twoArtboards());

      expect(exported, contains('on_a1'));
      expect(exported, contains('on_every_artboard'));
      expect(
        exported,
        isNot(contains('on_a2')),
        reason: 'artwork from other artboards must not leak in',
      );
    });

    test('the viewBox is the artboard size, not the document size', () {
      expect(
        SvgExporter.export(twoArtboards()),
        contains('viewBox="0 0 100.0 100.0"'),
      );
      expect(
        SvgExporter.export(twoArtboards(), artboardId: 'a2'),
        contains('viewBox="0 0 60.0 40.0"'),
      );
    });

    test('an explicit artboardId exports that artboard', () {
      final exported = SvgExporter.export(twoArtboards(), artboardId: 'a2');

      expect(exported, contains('on_a2'));
      expect(exported, contains('on_every_artboard'));
      expect(exported, isNot(contains('on_a1')));
    });

    test('switching the active artboard switches the export', () {
      final exported = SvgExporter.export(twoArtboards(active: 1));

      expect(exported, contains('on_a2'));
      expect(exported, isNot(contains('on_a1')));
    });

    test('an unknown artboardId falls back to the document size', () {
      final exported = SvgExporter.export(twoArtboards(), artboardId: 'nope');

      // No artboard matches, so nothing belongs to it except global elements.
      expect(exported, contains('on_every_artboard'));
      expect(exported, isNot(contains('on_a1')));
      expect(exported, isNot(contains('on_a2')));
      expect(exported, contains('viewBox="0 0 100.0 100.0"'));
    });

    test('a document without artboards still exports everything', () {
      final single = VxDocument(
        id: 'doc',
        title: 't',
        width: 50,
        height: 50,
        elements: [rectOn('only', null, Colors.red)],
      );
      final exported = SvgExporter.export(single);

      expect(exported, contains('only'));
      expect(exported, contains('viewBox="0 0 50.0 50.0"'));
    });
  });

  group('export matches what the canvas shows', () {
    // The strongest check available: render the editor's view of the document,
    // render the exported file re-imported, and compare pixels. Before B5 these
    // differed because the export contained the other artboard's artwork.
    test('active artboard', () async {
      final doc = twoArtboards();
      final reimported = SvgImporter.import(SvgExporter.export(doc))!;

      expect(
        fidelity(await renderRaw(doc), await renderRaw(reimported)),
        1.0,
        reason: 'exported SVG should render exactly like the canvas',
      );
    });

    test('a non-active artboard', () async {
      final doc = twoArtboards();
      final reimported = SvgImporter.import(
        SvgExporter.export(doc, artboardId: 'a2'),
      )!;

      // The exported file's viewBox is the artboard size (60x40) while the
      // canvas render is fitted to the document (100x100), so normalise the
      // re-imported document to compare the same region at the same zoom.
      final comparable = reimported.copyWith(
        width: doc.width,
        height: doc.height,
      );
      final canvasSide = twoArtboards(active: 1);

      expect(
        fidelity(await renderRaw(canvasSide), await renderRaw(comparable)),
        1.0,
        reason: 'exporting artboard a2 should match the canvas on a2',
      );
    });

    test('artwork extending beyond the artboard is preserved', () async {
      // Vectix does not clip artwork to the artboard, so an element that pokes
      // outside is part of the document and must survive the export. Note that
      // the exported file's viewBox is the artboard size, so an SVG *consumer*
      // will crop it: that is correct SVG viewport behaviour, and a difference
      // from the editor worth knowing about rather than a bug.
      final doc = VxDocument(
        id: 'doc',
        title: 't',
        width: 100,
        height: 100,
        artboards: const [
          VxArtboard(id: 'a1', name: 'One', x: 0, y: 0, width: 50, height: 50),
        ],
        activePageIndex: 0,
        elements: [rectOn('overflowing', 'a1', Colors.red, x: 40, y: 40)],
      );

      final reimported = SvgImporter.import(SvgExporter.export(doc))!;
      expect(reimported.elements.length, 1, reason: 'element must not be dropped');

      // Normalise the fitted zoom (viewBox is 50x50, the document was 100x100)
      // so the two renders cover the same coordinates.
      final comparable = reimported.copyWith(
        width: doc.width,
        height: doc.height,
      );
      expect(fidelity(await renderRaw(doc), await renderRaw(comparable)), 1.0);
    });
  });
}
