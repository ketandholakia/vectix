import 'package:freezed_annotation/freezed_annotation.dart';
import 'vx_element.dart';

part 'vx_document.freezed.dart';
part 'vx_document.g.dart';

@freezed
abstract class VxArtboard with _$VxArtboard {
  const factory VxArtboard({
    required String id,
    required String name,
    required double x,
    required double y,
    required double width,
    required double height,
    @Default(true) bool visible,
  }) = _VxArtboard;

  factory VxArtboard.fromJson(Map<String, dynamic> json) => _$VxArtboardFromJson(json);
}

@freezed
abstract class VxDocument with _$VxDocument {
  const factory VxDocument({
    required String id,
    @Default(1) int version,
    required double width,
    required double height,
    required List<VxElement> elements,
    @Default(<VxArtboard>[]) List<VxArtboard> artboards,
    required String title,
    @Default(<String, dynamic>{}) Map<String, dynamic> metadata,
    @Default(1) int pageCount,
    @Default(0) int activePageIndex,
    @Default('single') String artboardMode,
  }) = _VxDocument;

  factory VxDocument.fromJson(Map<String, dynamic> json) => _$VxDocumentFromJson(json);
}
