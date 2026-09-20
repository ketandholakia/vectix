// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vx_element.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoveToSegment _$MoveToSegmentFromJson(Map<String, dynamic> json) =>
    MoveToSegment(
      const OffsetConverter().fromJson(json['point'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$MoveToSegmentToJson(MoveToSegment instance) =>
    <String, dynamic>{
      'point': const OffsetConverter().toJson(instance.point),
      'runtimeType': instance.$type,
    };

LineToSegment _$LineToSegmentFromJson(Map<String, dynamic> json) =>
    LineToSegment(
      const OffsetConverter().fromJson(json['point'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$LineToSegmentToJson(LineToSegment instance) =>
    <String, dynamic>{
      'point': const OffsetConverter().toJson(instance.point),
      'runtimeType': instance.$type,
    };

QuadraticBezierToSegment _$QuadraticBezierToSegmentFromJson(
  Map<String, dynamic> json,
) => QuadraticBezierToSegment(
  const OffsetConverter().fromJson(json['control'] as Map<String, dynamic>),
  const OffsetConverter().fromJson(json['point'] as Map<String, dynamic>),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$QuadraticBezierToSegmentToJson(
  QuadraticBezierToSegment instance,
) => <String, dynamic>{
  'control': const OffsetConverter().toJson(instance.control),
  'point': const OffsetConverter().toJson(instance.point),
  'runtimeType': instance.$type,
};

CubicBezierToSegment _$CubicBezierToSegmentFromJson(
  Map<String, dynamic> json,
) => CubicBezierToSegment(
  const OffsetConverter().fromJson(json['control1'] as Map<String, dynamic>),
  const OffsetConverter().fromJson(json['control2'] as Map<String, dynamic>),
  const OffsetConverter().fromJson(json['point'] as Map<String, dynamic>),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$CubicBezierToSegmentToJson(
  CubicBezierToSegment instance,
) => <String, dynamic>{
  'control1': const OffsetConverter().toJson(instance.control1),
  'control2': const OffsetConverter().toJson(instance.control2),
  'point': const OffsetConverter().toJson(instance.point),
  'runtimeType': instance.$type,
};

CloseSegment _$CloseSegmentFromJson(Map<String, dynamic> json) =>
    CloseSegment($type: json['runtimeType'] as String?);

Map<String, dynamic> _$CloseSegmentToJson(CloseSegment instance) =>
    <String, dynamic>{'runtimeType': instance.$type};

_ColorStop _$ColorStopFromJson(Map<String, dynamic> json) => _ColorStop(
  offset: (json['offset'] as num).toDouble(),
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
);

Map<String, dynamic> _$ColorStopToJson(_ColorStop instance) =>
    <String, dynamic>{
      'offset': instance.offset,
      'color': const ColorConverter().toJson(instance.color),
    };

SolidFill _$SolidFillFromJson(Map<String, dynamic> json) => SolidFill(
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$SolidFillToJson(SolidFill instance) => <String, dynamic>{
  'color': const ColorConverter().toJson(instance.color),
  'runtimeType': instance.$type,
};

LinearFill _$LinearFillFromJson(Map<String, dynamic> json) => LinearFill(
  start: const OffsetConverter().fromJson(
    json['start'] as Map<String, dynamic>,
  ),
  end: const OffsetConverter().fromJson(json['end'] as Map<String, dynamic>),
  stops: (json['stops'] as List<dynamic>)
      .map((e) => ColorStop.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$LinearFillToJson(LinearFill instance) =>
    <String, dynamic>{
      'start': const OffsetConverter().toJson(instance.start),
      'end': const OffsetConverter().toJson(instance.end),
      'stops': instance.stops,
      'runtimeType': instance.$type,
    };

RadialFill _$RadialFillFromJson(Map<String, dynamic> json) => RadialFill(
  center: const OffsetConverter().fromJson(
    json['center'] as Map<String, dynamic>,
  ),
  radius: (json['radius'] as num).toDouble(),
  stops: (json['stops'] as List<dynamic>)
      .map((e) => ColorStop.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$RadialFillToJson(RadialFill instance) =>
    <String, dynamic>{
      'center': const OffsetConverter().toJson(instance.center),
      'radius': instance.radius,
      'stops': instance.stops,
      'runtimeType': instance.$type,
    };

NoFill _$NoFillFromJson(Map<String, dynamic> json) =>
    NoFill($type: json['runtimeType'] as String?);

Map<String, dynamic> _$NoFillToJson(NoFill instance) => <String, dynamic>{
  'runtimeType': instance.$type,
};

_VxStroke _$VxStrokeFromJson(Map<String, dynamic> json) => _VxStroke(
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
  width: (json['width'] as num).toDouble(),
  cap: $enumDecode(_$StrokeCapEnumMap, json['cap']),
  join: $enumDecode(_$StrokeJoinEnumMap, json['join']),
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
  miterLimit: (json['miterLimit'] as num?)?.toDouble() ?? 4.0,
  dashArray: (json['dashArray'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
);

Map<String, dynamic> _$VxStrokeToJson(_VxStroke instance) => <String, dynamic>{
  'color': const ColorConverter().toJson(instance.color),
  'width': instance.width,
  'cap': _$StrokeCapEnumMap[instance.cap]!,
  'join': _$StrokeJoinEnumMap[instance.join]!,
  'opacity': instance.opacity,
  'miterLimit': instance.miterLimit,
  'dashArray': instance.dashArray,
};

const _$StrokeCapEnumMap = {
  StrokeCap.butt: 'butt',
  StrokeCap.round: 'round',
  StrokeCap.square: 'square',
};

const _$StrokeJoinEnumMap = {
  StrokeJoin.miter: 'miter',
  StrokeJoin.round: 'round',
  StrokeJoin.bevel: 'bevel',
};

VxRect _$VxRectFromJson(Map<String, dynamic> json) => VxRect(
  id: json['id'] as String,
  artboardId: json['artboardId'] as String?,
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  width: (json['width'] as num).toDouble(),
  height: (json['height'] as num).toDouble(),
  transform: const Matrix4Converter().fromJson(json['transform'] as List),
  fill: VxFill.fromJson(json['fill'] as Map<String, dynamic>),
  stroke: VxStroke.fromJson(json['stroke'] as Map<String, dynamic>),
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
  locked: json['locked'] as bool? ?? false,
  visible: json['visible'] as bool? ?? true,
  clipPathId: json['clipPathId'] as String?,
  maskId: json['maskId'] as String?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$VxRectToJson(VxRect instance) => <String, dynamic>{
  'id': instance.id,
  'artboardId': instance.artboardId,
  'x': instance.x,
  'y': instance.y,
  'width': instance.width,
  'height': instance.height,
  'transform': const Matrix4Converter().toJson(instance.transform),
  'fill': instance.fill,
  'stroke': instance.stroke,
  'opacity': instance.opacity,
  'locked': instance.locked,
  'visible': instance.visible,
  'clipPathId': instance.clipPathId,
  'maskId': instance.maskId,
  'runtimeType': instance.$type,
};

VxEllipse _$VxEllipseFromJson(Map<String, dynamic> json) => VxEllipse(
  id: json['id'] as String,
  artboardId: json['artboardId'] as String?,
  cx: (json['cx'] as num).toDouble(),
  cy: (json['cy'] as num).toDouble(),
  rx: (json['rx'] as num).toDouble(),
  ry: (json['ry'] as num).toDouble(),
  transform: const Matrix4Converter().fromJson(json['transform'] as List),
  fill: VxFill.fromJson(json['fill'] as Map<String, dynamic>),
  stroke: VxStroke.fromJson(json['stroke'] as Map<String, dynamic>),
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
  locked: json['locked'] as bool? ?? false,
  visible: json['visible'] as bool? ?? true,
  clipPathId: json['clipPathId'] as String?,
  maskId: json['maskId'] as String?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$VxEllipseToJson(VxEllipse instance) => <String, dynamic>{
  'id': instance.id,
  'artboardId': instance.artboardId,
  'cx': instance.cx,
  'cy': instance.cy,
  'rx': instance.rx,
  'ry': instance.ry,
  'transform': const Matrix4Converter().toJson(instance.transform),
  'fill': instance.fill,
  'stroke': instance.stroke,
  'opacity': instance.opacity,
  'locked': instance.locked,
  'visible': instance.visible,
  'clipPathId': instance.clipPathId,
  'maskId': instance.maskId,
  'runtimeType': instance.$type,
};

VxPath _$VxPathFromJson(Map<String, dynamic> json) => VxPath(
  id: json['id'] as String,
  artboardId: json['artboardId'] as String?,
  segments: (json['segments'] as List<dynamic>)
      .map((e) => PathSegment.fromJson(e as Map<String, dynamic>))
      .toList(),
  transform: const Matrix4Converter().fromJson(json['transform'] as List),
  fill: VxFill.fromJson(json['fill'] as Map<String, dynamic>),
  stroke: VxStroke.fromJson(json['stroke'] as Map<String, dynamic>),
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
  locked: json['locked'] as bool? ?? false,
  visible: json['visible'] as bool? ?? true,
  clipPathId: json['clipPathId'] as String?,
  maskId: json['maskId'] as String?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$VxPathToJson(VxPath instance) => <String, dynamic>{
  'id': instance.id,
  'artboardId': instance.artboardId,
  'segments': instance.segments,
  'transform': const Matrix4Converter().toJson(instance.transform),
  'fill': instance.fill,
  'stroke': instance.stroke,
  'opacity': instance.opacity,
  'locked': instance.locked,
  'visible': instance.visible,
  'clipPathId': instance.clipPathId,
  'maskId': instance.maskId,
  'runtimeType': instance.$type,
};

VxText _$VxTextFromJson(Map<String, dynamic> json) => VxText(
  id: json['id'] as String,
  artboardId: json['artboardId'] as String?,
  content: json['content'] as String,
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  style: const TextStyleConverter().fromJson(
    json['style'] as Map<String, dynamic>,
  ),
  align:
      $enumDecodeNullable(_$TextAlignEnumMap, json['align']) ?? TextAlign.start,
  letterSpacing: (json['letterSpacing'] as num?)?.toDouble(),
  wordSpacing: (json['wordSpacing'] as num?)?.toDouble(),
  lineHeight: (json['lineHeight'] as num?)?.toDouble(),
  fontWeightValue: (json['fontWeightValue'] as num?)?.toInt(),
  fontStyle: $enumDecodeNullable(_$FontStyleEnumMap, json['fontStyle']),
  maxLines: (json['maxLines'] as num?)?.toInt() ?? 1,
  transform: const Matrix4Converter().fromJson(json['transform'] as List),
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
  locked: json['locked'] as bool? ?? false,
  visible: json['visible'] as bool? ?? true,
  clipPathId: json['clipPathId'] as String?,
  maskId: json['maskId'] as String?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$VxTextToJson(VxText instance) => <String, dynamic>{
  'id': instance.id,
  'artboardId': instance.artboardId,
  'content': instance.content,
  'x': instance.x,
  'y': instance.y,
  'style': const TextStyleConverter().toJson(instance.style),
  'align': _$TextAlignEnumMap[instance.align]!,
  'letterSpacing': instance.letterSpacing,
  'wordSpacing': instance.wordSpacing,
  'lineHeight': instance.lineHeight,
  'fontWeightValue': instance.fontWeightValue,
  'fontStyle': _$FontStyleEnumMap[instance.fontStyle],
  'maxLines': instance.maxLines,
  'transform': const Matrix4Converter().toJson(instance.transform),
  'opacity': instance.opacity,
  'locked': instance.locked,
  'visible': instance.visible,
  'clipPathId': instance.clipPathId,
  'maskId': instance.maskId,
  'runtimeType': instance.$type,
};

const _$TextAlignEnumMap = {
  TextAlign.left: 'left',
  TextAlign.right: 'right',
  TextAlign.center: 'center',
  TextAlign.justify: 'justify',
  TextAlign.start: 'start',
  TextAlign.end: 'end',
};

const _$FontStyleEnumMap = {
  FontStyle.normal: 'normal',
  FontStyle.italic: 'italic',
};

VxGroup _$VxGroupFromJson(Map<String, dynamic> json) => VxGroup(
  id: json['id'] as String,
  artboardId: json['artboardId'] as String?,
  children: (json['children'] as List<dynamic>)
      .map((e) => VxElement.fromJson(e as Map<String, dynamic>))
      .toList(),
  transform: const Matrix4Converter().fromJson(json['transform'] as List),
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
  locked: json['locked'] as bool? ?? false,
  visible: json['visible'] as bool? ?? true,
  clipPathId: json['clipPathId'] as String?,
  maskId: json['maskId'] as String?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$VxGroupToJson(VxGroup instance) => <String, dynamic>{
  'id': instance.id,
  'artboardId': instance.artboardId,
  'children': instance.children,
  'transform': const Matrix4Converter().toJson(instance.transform),
  'opacity': instance.opacity,
  'locked': instance.locked,
  'visible': instance.visible,
  'clipPathId': instance.clipPathId,
  'maskId': instance.maskId,
  'runtimeType': instance.$type,
};

VxCompound _$VxCompoundFromJson(Map<String, dynamic> json) => VxCompound(
  id: json['id'] as String,
  artboardId: json['artboardId'] as String?,
  operation: (json['operation'] as num).toInt(),
  children: (json['children'] as List<dynamic>)
      .map((e) => VxElement.fromJson(e as Map<String, dynamic>))
      .toList(),
  transform: const Matrix4Converter().fromJson(json['transform'] as List),
  fill: VxFill.fromJson(json['fill'] as Map<String, dynamic>),
  stroke: VxStroke.fromJson(json['stroke'] as Map<String, dynamic>),
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
  locked: json['locked'] as bool? ?? false,
  visible: json['visible'] as bool? ?? true,
  clipPathId: json['clipPathId'] as String?,
  maskId: json['maskId'] as String?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$VxCompoundToJson(VxCompound instance) =>
    <String, dynamic>{
      'id': instance.id,
      'artboardId': instance.artboardId,
      'operation': instance.operation,
      'children': instance.children,
      'transform': const Matrix4Converter().toJson(instance.transform),
      'fill': instance.fill,
      'stroke': instance.stroke,
      'opacity': instance.opacity,
      'locked': instance.locked,
      'visible': instance.visible,
      'clipPathId': instance.clipPathId,
      'maskId': instance.maskId,
      'runtimeType': instance.$type,
    };

VxUse _$VxUseFromJson(Map<String, dynamic> json) => VxUse(
  id: json['id'] as String,
  artboardId: json['artboardId'] as String?,
  href: json['href'] as String,
  transform: const Matrix4Converter().fromJson(json['transform'] as List),
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
  locked: json['locked'] as bool? ?? false,
  visible: json['visible'] as bool? ?? true,
  clipPathId: json['clipPathId'] as String?,
  maskId: json['maskId'] as String?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$VxUseToJson(VxUse instance) => <String, dynamic>{
  'id': instance.id,
  'artboardId': instance.artboardId,
  'href': instance.href,
  'transform': const Matrix4Converter().toJson(instance.transform),
  'opacity': instance.opacity,
  'locked': instance.locked,
  'visible': instance.visible,
  'clipPathId': instance.clipPathId,
  'maskId': instance.maskId,
  'runtimeType': instance.$type,
};

VxSymbol _$VxSymbolFromJson(Map<String, dynamic> json) => VxSymbol(
  id: json['id'] as String,
  artboardId: json['artboardId'] as String?,
  children: (json['children'] as List<dynamic>)
      .map((e) => VxElement.fromJson(e as Map<String, dynamic>))
      .toList(),
  transform: const Matrix4Converter().fromJson(json['transform'] as List),
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
  locked: json['locked'] as bool? ?? false,
  visible: json['visible'] as bool? ?? true,
  clipPathId: json['clipPathId'] as String?,
  maskId: json['maskId'] as String?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$VxSymbolToJson(VxSymbol instance) => <String, dynamic>{
  'id': instance.id,
  'artboardId': instance.artboardId,
  'children': instance.children,
  'transform': const Matrix4Converter().toJson(instance.transform),
  'opacity': instance.opacity,
  'locked': instance.locked,
  'visible': instance.visible,
  'clipPathId': instance.clipPathId,
  'maskId': instance.maskId,
  'runtimeType': instance.$type,
};
