import 'package:flutter_test/flutter_test.dart';
import 'package:vectix/models/vx_document.dart';
import 'package:vectix/models/vx_element.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:flutter/material.dart';
import 'dart:convert';

void main() {
  group('VxDocument and VxElement Serialization', () {
    test('serializes and deserializes a basic document correctly', () {
      final doc = VxDocument(
        id: 'doc_1',
        title: 'Test Doc',
        width: 800,
        height: 600,
        elements: [
          VxElement.rect(
            id: 'rect_1',
            x: 10,
            y: 20,
            width: 100,
            height: 200,
            transform: Matrix4.identity()..translate(5.0, 5.0),
            fill: const VxFill.solid(color: Colors.red),
            stroke: const VxStroke(
              color: Colors.blue,
              width: 2.0,
              cap: StrokeCap.round,
              join: StrokeJoin.bevel,
            ),
          ),
        ],
      );

      final jsonMap = jsonDecode(jsonEncode(doc.toJson()));
      final deserializedDoc = VxDocument.fromJson(jsonMap);

      expect(deserializedDoc.id, 'doc_1');
      expect(deserializedDoc.title, 'Test Doc');
      expect(deserializedDoc.elements.length, 1);

      final rect = deserializedDoc.elements.first as VxRect;
      expect(rect.id, 'rect_1');
      expect(rect.x, 10);
      expect(rect.y, 20);
      expect(rect.width, 100);
      expect(rect.height, 200);

      // Verify custom converters
      expect(
        rect.transform.storage.toList(),
        (Matrix4.identity()..translate(5.0, 5.0)).storage.toList(),
      );

      expect(rect.fill, isA<SolidFill>());
      expect((rect.fill as SolidFill).color.value, Colors.red.value);

      expect(rect.stroke.color.value, Colors.blue.value);
      expect(rect.stroke.width, 2.0);
      expect(rect.stroke.cap, StrokeCap.round);
      expect(rect.stroke.join, StrokeJoin.bevel);
    });

    test(
      'serializes and deserializes a text element with TextStyle correctly',
      () {
        final textElement = VxElement.text(
          id: 't1',
          content: 'Hello Vectix',
          x: 50,
          y: 50,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.green,
            fontFamily: 'Arial',
          ),
          transform: Matrix4.identity(),
        );

        final doc = VxDocument(
          id: 'doc_2',
          title: 'Text Doc',
          width: 100,
          height: 100,
          elements: [textElement],
        );

        final jsonMap = jsonDecode(jsonEncode(doc.toJson()));
        final deserializedDoc = VxDocument.fromJson(jsonMap);

        final deserializedText = deserializedDoc.elements.first as VxText;
        expect(deserializedText.content, 'Hello Vectix');
        expect(deserializedText.style.fontSize, 24);
        expect(deserializedText.style.color?.value, Colors.green.value);
        expect(deserializedText.style.fontFamily, 'Arial');
      },
    );

    test('preserves mask and grouped elements through serialization', () {
      final maskedRect = VxElement.rect(
        id: 'rect_masked',
        x: 10,
        y: 10,
        width: 80,
        height: 80,
        transform: Matrix4.identity(),
        fill: const VxFill.solid(color: Colors.blue),
        stroke: const VxStroke(
          color: Colors.transparent,
          width: 0,
          cap: StrokeCap.butt,
          join: StrokeJoin.miter,
        ),
        maskId: 'mask_1',
      );
      final maskSource = VxElement.rect(
        id: 'mask_1',
        x: 0,
        y: 0,
        width: 40,
        height: 40,
        transform: Matrix4.identity(),
        fill: const VxFill.solid(color: Colors.white),
        stroke: const VxStroke(
          color: Colors.transparent,
          width: 0,
          cap: StrokeCap.butt,
          join: StrokeJoin.miter,
        ),
      );
      final grouped = VxElement.group(
        id: 'group_1',
        children: [maskSource, maskedRect],
        transform: Matrix4.identity(),
      );
      final doc = VxDocument(
        id: 'doc_3',
        title: 'Mask Doc',
        width: 100,
        height: 100,
        elements: [grouped],
      );

      final jsonMap = jsonDecode(jsonEncode(doc.toJson()));
      final deserializedDoc = VxDocument.fromJson(jsonMap);
      final group = deserializedDoc.elements.first as VxGroup;
      expect(group.children.length, 2);
      final deserializedMaskedRect = group.children[1] as VxRect;
      expect(deserializedMaskedRect.maskId, 'mask_1');
    });
  });
}
