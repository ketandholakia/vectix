// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vx_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VxArtboard _$VxArtboardFromJson(Map<String, dynamic> json) => _VxArtboard(
  id: json['id'] as String,
  name: json['name'] as String,
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  width: (json['width'] as num).toDouble(),
  height: (json['height'] as num).toDouble(),
  visible: json['visible'] as bool? ?? true,
);

Map<String, dynamic> _$VxArtboardToJson(_VxArtboard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'visible': instance.visible,
    };

_VxDocument _$VxDocumentFromJson(Map<String, dynamic> json) => _VxDocument(
  id: json['id'] as String,
  version: (json['version'] as num?)?.toInt() ?? 1,
  width: (json['width'] as num).toDouble(),
  height: (json['height'] as num).toDouble(),
  elements: (json['elements'] as List<dynamic>)
      .map((e) => VxElement.fromJson(e as Map<String, dynamic>))
      .toList(),
  artboards:
      (json['artboards'] as List<dynamic>?)
          ?.map((e) => VxArtboard.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <VxArtboard>[],
  title: json['title'] as String,
  metadata:
      json['metadata'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  pageCount: (json['pageCount'] as num?)?.toInt() ?? 1,
  activePageIndex: (json['activePageIndex'] as num?)?.toInt() ?? 0,
  artboardMode: json['artboardMode'] as String? ?? 'single',
  defs:
      (json['defs'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, VxElement.fromJson(e as Map<String, dynamic>)),
      ) ??
      const <String, VxElement>{},
);

Map<String, dynamic> _$VxDocumentToJson(_VxDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'version': instance.version,
      'width': instance.width,
      'height': instance.height,
      'elements': instance.elements,
      'artboards': instance.artboards,
      'title': instance.title,
      'metadata': instance.metadata,
      'pageCount': instance.pageCount,
      'activePageIndex': instance.activePageIndex,
      'artboardMode': instance.artboardMode,
      'defs': instance.defs,
    };
