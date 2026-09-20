// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vx_element.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
PathSegment _$PathSegmentFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'moveTo':
          return MoveToSegment.fromJson(
            json
          );
                case 'lineTo':
          return LineToSegment.fromJson(
            json
          );
                case 'quadraticBezierTo':
          return QuadraticBezierToSegment.fromJson(
            json
          );
                case 'cubicBezierTo':
          return CubicBezierToSegment.fromJson(
            json
          );
                case 'close':
          return CloseSegment.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'PathSegment',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$PathSegment {



  /// Serializes this PathSegment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PathSegment);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PathSegment()';
}


}

/// @nodoc
class $PathSegmentCopyWith<$Res>  {
$PathSegmentCopyWith(PathSegment _, $Res Function(PathSegment) __);
}


/// Adds pattern-matching-related methods to [PathSegment].
extension PathSegmentPatterns on PathSegment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MoveToSegment value)?  moveTo,TResult Function( LineToSegment value)?  lineTo,TResult Function( QuadraticBezierToSegment value)?  quadraticBezierTo,TResult Function( CubicBezierToSegment value)?  cubicBezierTo,TResult Function( CloseSegment value)?  close,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MoveToSegment() when moveTo != null:
return moveTo(_that);case LineToSegment() when lineTo != null:
return lineTo(_that);case QuadraticBezierToSegment() when quadraticBezierTo != null:
return quadraticBezierTo(_that);case CubicBezierToSegment() when cubicBezierTo != null:
return cubicBezierTo(_that);case CloseSegment() when close != null:
return close(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MoveToSegment value)  moveTo,required TResult Function( LineToSegment value)  lineTo,required TResult Function( QuadraticBezierToSegment value)  quadraticBezierTo,required TResult Function( CubicBezierToSegment value)  cubicBezierTo,required TResult Function( CloseSegment value)  close,}){
final _that = this;
switch (_that) {
case MoveToSegment():
return moveTo(_that);case LineToSegment():
return lineTo(_that);case QuadraticBezierToSegment():
return quadraticBezierTo(_that);case CubicBezierToSegment():
return cubicBezierTo(_that);case CloseSegment():
return close(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MoveToSegment value)?  moveTo,TResult? Function( LineToSegment value)?  lineTo,TResult? Function( QuadraticBezierToSegment value)?  quadraticBezierTo,TResult? Function( CubicBezierToSegment value)?  cubicBezierTo,TResult? Function( CloseSegment value)?  close,}){
final _that = this;
switch (_that) {
case MoveToSegment() when moveTo != null:
return moveTo(_that);case LineToSegment() when lineTo != null:
return lineTo(_that);case QuadraticBezierToSegment() when quadraticBezierTo != null:
return quadraticBezierTo(_that);case CubicBezierToSegment() when cubicBezierTo != null:
return cubicBezierTo(_that);case CloseSegment() when close != null:
return close(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function(@OffsetConverter()  Offset point)?  moveTo,TResult Function(@OffsetConverter()  Offset point)?  lineTo,TResult Function(@OffsetConverter()  Offset control, @OffsetConverter()  Offset point)?  quadraticBezierTo,TResult Function(@OffsetConverter()  Offset control1, @OffsetConverter()  Offset control2, @OffsetConverter()  Offset point)?  cubicBezierTo,TResult Function()?  close,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MoveToSegment() when moveTo != null:
return moveTo(_that.point);case LineToSegment() when lineTo != null:
return lineTo(_that.point);case QuadraticBezierToSegment() when quadraticBezierTo != null:
return quadraticBezierTo(_that.control,_that.point);case CubicBezierToSegment() when cubicBezierTo != null:
return cubicBezierTo(_that.control1,_that.control2,_that.point);case CloseSegment() when close != null:
return close();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function(@OffsetConverter()  Offset point)  moveTo,required TResult Function(@OffsetConverter()  Offset point)  lineTo,required TResult Function(@OffsetConverter()  Offset control, @OffsetConverter()  Offset point)  quadraticBezierTo,required TResult Function(@OffsetConverter()  Offset control1, @OffsetConverter()  Offset control2, @OffsetConverter()  Offset point)  cubicBezierTo,required TResult Function()  close,}) {final _that = this;
switch (_that) {
case MoveToSegment():
return moveTo(_that.point);case LineToSegment():
return lineTo(_that.point);case QuadraticBezierToSegment():
return quadraticBezierTo(_that.control,_that.point);case CubicBezierToSegment():
return cubicBezierTo(_that.control1,_that.control2,_that.point);case CloseSegment():
return close();case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function(@OffsetConverter()  Offset point)?  moveTo,TResult? Function(@OffsetConverter()  Offset point)?  lineTo,TResult? Function(@OffsetConverter()  Offset control, @OffsetConverter()  Offset point)?  quadraticBezierTo,TResult? Function(@OffsetConverter()  Offset control1, @OffsetConverter()  Offset control2, @OffsetConverter()  Offset point)?  cubicBezierTo,TResult? Function()?  close,}) {final _that = this;
switch (_that) {
case MoveToSegment() when moveTo != null:
return moveTo(_that.point);case LineToSegment() when lineTo != null:
return lineTo(_that.point);case QuadraticBezierToSegment() when quadraticBezierTo != null:
return quadraticBezierTo(_that.control,_that.point);case CubicBezierToSegment() when cubicBezierTo != null:
return cubicBezierTo(_that.control1,_that.control2,_that.point);case CloseSegment() when close != null:
return close();case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class MoveToSegment implements PathSegment {
  const MoveToSegment(@OffsetConverter() this.point, {final  String? $type}): $type = $type ?? 'moveTo';
  factory MoveToSegment.fromJson(Map<String, dynamic> json) => _$MoveToSegmentFromJson(json);

@OffsetConverter() final  Offset point;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of PathSegment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveToSegmentCopyWith<MoveToSegment> get copyWith => _$MoveToSegmentCopyWithImpl<MoveToSegment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoveToSegmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveToSegment&&(identical(other.point, point) || other.point == point));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,point);

@override
String toString() {
  return 'PathSegment.moveTo(point: $point)';
}


}

/// @nodoc
abstract mixin class $MoveToSegmentCopyWith<$Res> implements $PathSegmentCopyWith<$Res> {
  factory $MoveToSegmentCopyWith(MoveToSegment value, $Res Function(MoveToSegment) _then) = _$MoveToSegmentCopyWithImpl;
@useResult
$Res call({
@OffsetConverter() Offset point
});




}
/// @nodoc
class _$MoveToSegmentCopyWithImpl<$Res>
    implements $MoveToSegmentCopyWith<$Res> {
  _$MoveToSegmentCopyWithImpl(this._self, this._then);

  final MoveToSegment _self;
  final $Res Function(MoveToSegment) _then;

/// Create a copy of PathSegment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? point = null,}) {
  return _then(MoveToSegment(
null == point ? _self.point : point // ignore: cast_nullable_to_non_nullable
as Offset,
  ));
}


}

/// @nodoc
@JsonSerializable()

class LineToSegment implements PathSegment {
  const LineToSegment(@OffsetConverter() this.point, {final  String? $type}): $type = $type ?? 'lineTo';
  factory LineToSegment.fromJson(Map<String, dynamic> json) => _$LineToSegmentFromJson(json);

@OffsetConverter() final  Offset point;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of PathSegment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineToSegmentCopyWith<LineToSegment> get copyWith => _$LineToSegmentCopyWithImpl<LineToSegment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LineToSegmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineToSegment&&(identical(other.point, point) || other.point == point));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,point);

@override
String toString() {
  return 'PathSegment.lineTo(point: $point)';
}


}

/// @nodoc
abstract mixin class $LineToSegmentCopyWith<$Res> implements $PathSegmentCopyWith<$Res> {
  factory $LineToSegmentCopyWith(LineToSegment value, $Res Function(LineToSegment) _then) = _$LineToSegmentCopyWithImpl;
@useResult
$Res call({
@OffsetConverter() Offset point
});




}
/// @nodoc
class _$LineToSegmentCopyWithImpl<$Res>
    implements $LineToSegmentCopyWith<$Res> {
  _$LineToSegmentCopyWithImpl(this._self, this._then);

  final LineToSegment _self;
  final $Res Function(LineToSegment) _then;

/// Create a copy of PathSegment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? point = null,}) {
  return _then(LineToSegment(
null == point ? _self.point : point // ignore: cast_nullable_to_non_nullable
as Offset,
  ));
}


}

/// @nodoc
@JsonSerializable()

class QuadraticBezierToSegment implements PathSegment {
  const QuadraticBezierToSegment(@OffsetConverter() this.control, @OffsetConverter() this.point, {final  String? $type}): $type = $type ?? 'quadraticBezierTo';
  factory QuadraticBezierToSegment.fromJson(Map<String, dynamic> json) => _$QuadraticBezierToSegmentFromJson(json);

@OffsetConverter() final  Offset control;
@OffsetConverter() final  Offset point;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of PathSegment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuadraticBezierToSegmentCopyWith<QuadraticBezierToSegment> get copyWith => _$QuadraticBezierToSegmentCopyWithImpl<QuadraticBezierToSegment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuadraticBezierToSegmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuadraticBezierToSegment&&(identical(other.control, control) || other.control == control)&&(identical(other.point, point) || other.point == point));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,control,point);

@override
String toString() {
  return 'PathSegment.quadraticBezierTo(control: $control, point: $point)';
}


}

/// @nodoc
abstract mixin class $QuadraticBezierToSegmentCopyWith<$Res> implements $PathSegmentCopyWith<$Res> {
  factory $QuadraticBezierToSegmentCopyWith(QuadraticBezierToSegment value, $Res Function(QuadraticBezierToSegment) _then) = _$QuadraticBezierToSegmentCopyWithImpl;
@useResult
$Res call({
@OffsetConverter() Offset control,@OffsetConverter() Offset point
});




}
/// @nodoc
class _$QuadraticBezierToSegmentCopyWithImpl<$Res>
    implements $QuadraticBezierToSegmentCopyWith<$Res> {
  _$QuadraticBezierToSegmentCopyWithImpl(this._self, this._then);

  final QuadraticBezierToSegment _self;
  final $Res Function(QuadraticBezierToSegment) _then;

/// Create a copy of PathSegment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? control = null,Object? point = null,}) {
  return _then(QuadraticBezierToSegment(
null == control ? _self.control : control // ignore: cast_nullable_to_non_nullable
as Offset,null == point ? _self.point : point // ignore: cast_nullable_to_non_nullable
as Offset,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CubicBezierToSegment implements PathSegment {
  const CubicBezierToSegment(@OffsetConverter() this.control1, @OffsetConverter() this.control2, @OffsetConverter() this.point, {final  String? $type}): $type = $type ?? 'cubicBezierTo';
  factory CubicBezierToSegment.fromJson(Map<String, dynamic> json) => _$CubicBezierToSegmentFromJson(json);

@OffsetConverter() final  Offset control1;
@OffsetConverter() final  Offset control2;
@OffsetConverter() final  Offset point;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of PathSegment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CubicBezierToSegmentCopyWith<CubicBezierToSegment> get copyWith => _$CubicBezierToSegmentCopyWithImpl<CubicBezierToSegment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CubicBezierToSegmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CubicBezierToSegment&&(identical(other.control1, control1) || other.control1 == control1)&&(identical(other.control2, control2) || other.control2 == control2)&&(identical(other.point, point) || other.point == point));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,control1,control2,point);

@override
String toString() {
  return 'PathSegment.cubicBezierTo(control1: $control1, control2: $control2, point: $point)';
}


}

/// @nodoc
abstract mixin class $CubicBezierToSegmentCopyWith<$Res> implements $PathSegmentCopyWith<$Res> {
  factory $CubicBezierToSegmentCopyWith(CubicBezierToSegment value, $Res Function(CubicBezierToSegment) _then) = _$CubicBezierToSegmentCopyWithImpl;
@useResult
$Res call({
@OffsetConverter() Offset control1,@OffsetConverter() Offset control2,@OffsetConverter() Offset point
});




}
/// @nodoc
class _$CubicBezierToSegmentCopyWithImpl<$Res>
    implements $CubicBezierToSegmentCopyWith<$Res> {
  _$CubicBezierToSegmentCopyWithImpl(this._self, this._then);

  final CubicBezierToSegment _self;
  final $Res Function(CubicBezierToSegment) _then;

/// Create a copy of PathSegment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? control1 = null,Object? control2 = null,Object? point = null,}) {
  return _then(CubicBezierToSegment(
null == control1 ? _self.control1 : control1 // ignore: cast_nullable_to_non_nullable
as Offset,null == control2 ? _self.control2 : control2 // ignore: cast_nullable_to_non_nullable
as Offset,null == point ? _self.point : point // ignore: cast_nullable_to_non_nullable
as Offset,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CloseSegment implements PathSegment {
  const CloseSegment({final  String? $type}): $type = $type ?? 'close';
  factory CloseSegment.fromJson(Map<String, dynamic> json) => _$CloseSegmentFromJson(json);



@JsonKey(name: 'runtimeType')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$CloseSegmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CloseSegment);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PathSegment.close()';
}


}





/// @nodoc
mixin _$ColorStop {

 double get offset;@ColorConverter() Color get color;
/// Create a copy of ColorStop
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColorStopCopyWith<ColorStop> get copyWith => _$ColorStopCopyWithImpl<ColorStop>(this as ColorStop, _$identity);

  /// Serializes this ColorStop to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ColorStop&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,offset,color);

@override
String toString() {
  return 'ColorStop(offset: $offset, color: $color)';
}


}

/// @nodoc
abstract mixin class $ColorStopCopyWith<$Res>  {
  factory $ColorStopCopyWith(ColorStop value, $Res Function(ColorStop) _then) = _$ColorStopCopyWithImpl;
@useResult
$Res call({
 double offset,@ColorConverter() Color color
});




}
/// @nodoc
class _$ColorStopCopyWithImpl<$Res>
    implements $ColorStopCopyWith<$Res> {
  _$ColorStopCopyWithImpl(this._self, this._then);

  final ColorStop _self;
  final $Res Function(ColorStop) _then;

/// Create a copy of ColorStop
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offset = null,Object? color = null,}) {
  return _then(_self.copyWith(
offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}

}


/// Adds pattern-matching-related methods to [ColorStop].
extension ColorStopPatterns on ColorStop {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ColorStop value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ColorStop() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ColorStop value)  $default,){
final _that = this;
switch (_that) {
case _ColorStop():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ColorStop value)?  $default,){
final _that = this;
switch (_that) {
case _ColorStop() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double offset, @ColorConverter()  Color color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ColorStop() when $default != null:
return $default(_that.offset,_that.color);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double offset, @ColorConverter()  Color color)  $default,) {final _that = this;
switch (_that) {
case _ColorStop():
return $default(_that.offset,_that.color);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double offset, @ColorConverter()  Color color)?  $default,) {final _that = this;
switch (_that) {
case _ColorStop() when $default != null:
return $default(_that.offset,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ColorStop implements ColorStop {
  const _ColorStop({required this.offset, @ColorConverter() required this.color});
  factory _ColorStop.fromJson(Map<String, dynamic> json) => _$ColorStopFromJson(json);

@override final  double offset;
@override@ColorConverter() final  Color color;

/// Create a copy of ColorStop
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ColorStopCopyWith<_ColorStop> get copyWith => __$ColorStopCopyWithImpl<_ColorStop>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ColorStopToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ColorStop&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,offset,color);

@override
String toString() {
  return 'ColorStop(offset: $offset, color: $color)';
}


}

/// @nodoc
abstract mixin class _$ColorStopCopyWith<$Res> implements $ColorStopCopyWith<$Res> {
  factory _$ColorStopCopyWith(_ColorStop value, $Res Function(_ColorStop) _then) = __$ColorStopCopyWithImpl;
@override @useResult
$Res call({
 double offset,@ColorConverter() Color color
});




}
/// @nodoc
class __$ColorStopCopyWithImpl<$Res>
    implements _$ColorStopCopyWith<$Res> {
  __$ColorStopCopyWithImpl(this._self, this._then);

  final _ColorStop _self;
  final $Res Function(_ColorStop) _then;

/// Create a copy of ColorStop
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offset = null,Object? color = null,}) {
  return _then(_ColorStop(
offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}


}

VxFill _$VxFillFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'solid':
          return SolidFill.fromJson(
            json
          );
                case 'linear':
          return LinearFill.fromJson(
            json
          );
                case 'radial':
          return RadialFill.fromJson(
            json
          );
                case 'none':
          return NoFill.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'VxFill',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$VxFill {



  /// Serializes this VxFill to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VxFill);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VxFill()';
}


}

/// @nodoc
class $VxFillCopyWith<$Res>  {
$VxFillCopyWith(VxFill _, $Res Function(VxFill) __);
}


/// Adds pattern-matching-related methods to [VxFill].
extension VxFillPatterns on VxFill {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SolidFill value)?  solid,TResult Function( LinearFill value)?  linear,TResult Function( RadialFill value)?  radial,TResult Function( NoFill value)?  none,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SolidFill() when solid != null:
return solid(_that);case LinearFill() when linear != null:
return linear(_that);case RadialFill() when radial != null:
return radial(_that);case NoFill() when none != null:
return none(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SolidFill value)  solid,required TResult Function( LinearFill value)  linear,required TResult Function( RadialFill value)  radial,required TResult Function( NoFill value)  none,}){
final _that = this;
switch (_that) {
case SolidFill():
return solid(_that);case LinearFill():
return linear(_that);case RadialFill():
return radial(_that);case NoFill():
return none(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SolidFill value)?  solid,TResult? Function( LinearFill value)?  linear,TResult? Function( RadialFill value)?  radial,TResult? Function( NoFill value)?  none,}){
final _that = this;
switch (_that) {
case SolidFill() when solid != null:
return solid(_that);case LinearFill() when linear != null:
return linear(_that);case RadialFill() when radial != null:
return radial(_that);case NoFill() when none != null:
return none(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function(@ColorConverter()  Color color)?  solid,TResult Function(@OffsetConverter()  Offset start, @OffsetConverter()  Offset end,  List<ColorStop> stops)?  linear,TResult Function(@OffsetConverter()  Offset center,  double radius,  List<ColorStop> stops)?  radial,TResult Function()?  none,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SolidFill() when solid != null:
return solid(_that.color);case LinearFill() when linear != null:
return linear(_that.start,_that.end,_that.stops);case RadialFill() when radial != null:
return radial(_that.center,_that.radius,_that.stops);case NoFill() when none != null:
return none();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function(@ColorConverter()  Color color)  solid,required TResult Function(@OffsetConverter()  Offset start, @OffsetConverter()  Offset end,  List<ColorStop> stops)  linear,required TResult Function(@OffsetConverter()  Offset center,  double radius,  List<ColorStop> stops)  radial,required TResult Function()  none,}) {final _that = this;
switch (_that) {
case SolidFill():
return solid(_that.color);case LinearFill():
return linear(_that.start,_that.end,_that.stops);case RadialFill():
return radial(_that.center,_that.radius,_that.stops);case NoFill():
return none();case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function(@ColorConverter()  Color color)?  solid,TResult? Function(@OffsetConverter()  Offset start, @OffsetConverter()  Offset end,  List<ColorStop> stops)?  linear,TResult? Function(@OffsetConverter()  Offset center,  double radius,  List<ColorStop> stops)?  radial,TResult? Function()?  none,}) {final _that = this;
switch (_that) {
case SolidFill() when solid != null:
return solid(_that.color);case LinearFill() when linear != null:
return linear(_that.start,_that.end,_that.stops);case RadialFill() when radial != null:
return radial(_that.center,_that.radius,_that.stops);case NoFill() when none != null:
return none();case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class SolidFill implements VxFill {
  const SolidFill({@ColorConverter() required this.color, final  String? $type}): $type = $type ?? 'solid';
  factory SolidFill.fromJson(Map<String, dynamic> json) => _$SolidFillFromJson(json);

@ColorConverter() final  Color color;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of VxFill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SolidFillCopyWith<SolidFill> get copyWith => _$SolidFillCopyWithImpl<SolidFill>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SolidFillToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SolidFill&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color);

@override
String toString() {
  return 'VxFill.solid(color: $color)';
}


}

/// @nodoc
abstract mixin class $SolidFillCopyWith<$Res> implements $VxFillCopyWith<$Res> {
  factory $SolidFillCopyWith(SolidFill value, $Res Function(SolidFill) _then) = _$SolidFillCopyWithImpl;
@useResult
$Res call({
@ColorConverter() Color color
});




}
/// @nodoc
class _$SolidFillCopyWithImpl<$Res>
    implements $SolidFillCopyWith<$Res> {
  _$SolidFillCopyWithImpl(this._self, this._then);

  final SolidFill _self;
  final $Res Function(SolidFill) _then;

/// Create a copy of VxFill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? color = null,}) {
  return _then(SolidFill(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}


}

/// @nodoc
@JsonSerializable()

class LinearFill implements VxFill {
  const LinearFill({@OffsetConverter() required this.start, @OffsetConverter() required this.end, required final  List<ColorStop> stops, final  String? $type}): _stops = stops,$type = $type ?? 'linear';
  factory LinearFill.fromJson(Map<String, dynamic> json) => _$LinearFillFromJson(json);

@OffsetConverter() final  Offset start;
@OffsetConverter() final  Offset end;
 final  List<ColorStop> _stops;
 List<ColorStop> get stops {
  if (_stops is EqualUnmodifiableListView) return _stops;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stops);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of VxFill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinearFillCopyWith<LinearFill> get copyWith => _$LinearFillCopyWithImpl<LinearFill>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LinearFillToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinearFill&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&const DeepCollectionEquality().equals(other._stops, _stops));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,start,end,const DeepCollectionEquality().hash(_stops));

@override
String toString() {
  return 'VxFill.linear(start: $start, end: $end, stops: $stops)';
}


}

/// @nodoc
abstract mixin class $LinearFillCopyWith<$Res> implements $VxFillCopyWith<$Res> {
  factory $LinearFillCopyWith(LinearFill value, $Res Function(LinearFill) _then) = _$LinearFillCopyWithImpl;
@useResult
$Res call({
@OffsetConverter() Offset start,@OffsetConverter() Offset end, List<ColorStop> stops
});




}
/// @nodoc
class _$LinearFillCopyWithImpl<$Res>
    implements $LinearFillCopyWith<$Res> {
  _$LinearFillCopyWithImpl(this._self, this._then);

  final LinearFill _self;
  final $Res Function(LinearFill) _then;

/// Create a copy of VxFill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? start = null,Object? end = null,Object? stops = null,}) {
  return _then(LinearFill(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as Offset,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as Offset,stops: null == stops ? _self._stops : stops // ignore: cast_nullable_to_non_nullable
as List<ColorStop>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class RadialFill implements VxFill {
  const RadialFill({@OffsetConverter() required this.center, required this.radius, required final  List<ColorStop> stops, final  String? $type}): _stops = stops,$type = $type ?? 'radial';
  factory RadialFill.fromJson(Map<String, dynamic> json) => _$RadialFillFromJson(json);

@OffsetConverter() final  Offset center;
 final  double radius;
 final  List<ColorStop> _stops;
 List<ColorStop> get stops {
  if (_stops is EqualUnmodifiableListView) return _stops;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stops);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of VxFill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RadialFillCopyWith<RadialFill> get copyWith => _$RadialFillCopyWithImpl<RadialFill>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RadialFillToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RadialFill&&(identical(other.center, center) || other.center == center)&&(identical(other.radius, radius) || other.radius == radius)&&const DeepCollectionEquality().equals(other._stops, _stops));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,center,radius,const DeepCollectionEquality().hash(_stops));

@override
String toString() {
  return 'VxFill.radial(center: $center, radius: $radius, stops: $stops)';
}


}

/// @nodoc
abstract mixin class $RadialFillCopyWith<$Res> implements $VxFillCopyWith<$Res> {
  factory $RadialFillCopyWith(RadialFill value, $Res Function(RadialFill) _then) = _$RadialFillCopyWithImpl;
@useResult
$Res call({
@OffsetConverter() Offset center, double radius, List<ColorStop> stops
});




}
/// @nodoc
class _$RadialFillCopyWithImpl<$Res>
    implements $RadialFillCopyWith<$Res> {
  _$RadialFillCopyWithImpl(this._self, this._then);

  final RadialFill _self;
  final $Res Function(RadialFill) _then;

/// Create a copy of VxFill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? center = null,Object? radius = null,Object? stops = null,}) {
  return _then(RadialFill(
center: null == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as Offset,radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as double,stops: null == stops ? _self._stops : stops // ignore: cast_nullable_to_non_nullable
as List<ColorStop>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class NoFill implements VxFill {
  const NoFill({final  String? $type}): $type = $type ?? 'none';
  factory NoFill.fromJson(Map<String, dynamic> json) => _$NoFillFromJson(json);



@JsonKey(name: 'runtimeType')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$NoFillToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoFill);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VxFill.none()';
}


}





/// @nodoc
mixin _$VxStroke {

@ColorConverter() Color get color; double get width; StrokeCap get cap; StrokeJoin get join; double get opacity; double get miterLimit; List<double>? get dashArray;
/// Create a copy of VxStroke
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VxStrokeCopyWith<VxStroke> get copyWith => _$VxStrokeCopyWithImpl<VxStroke>(this as VxStroke, _$identity);

  /// Serializes this VxStroke to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VxStroke&&(identical(other.color, color) || other.color == color)&&(identical(other.width, width) || other.width == width)&&(identical(other.cap, cap) || other.cap == cap)&&(identical(other.join, join) || other.join == join)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.miterLimit, miterLimit) || other.miterLimit == miterLimit)&&const DeepCollectionEquality().equals(other.dashArray, dashArray));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,width,cap,join,opacity,miterLimit,const DeepCollectionEquality().hash(dashArray));

@override
String toString() {
  return 'VxStroke(color: $color, width: $width, cap: $cap, join: $join, opacity: $opacity, miterLimit: $miterLimit, dashArray: $dashArray)';
}


}

/// @nodoc
abstract mixin class $VxStrokeCopyWith<$Res>  {
  factory $VxStrokeCopyWith(VxStroke value, $Res Function(VxStroke) _then) = _$VxStrokeCopyWithImpl;
@useResult
$Res call({
@ColorConverter() Color color, double width, StrokeCap cap, StrokeJoin join, double opacity, double miterLimit, List<double>? dashArray
});




}
/// @nodoc
class _$VxStrokeCopyWithImpl<$Res>
    implements $VxStrokeCopyWith<$Res> {
  _$VxStrokeCopyWithImpl(this._self, this._then);

  final VxStroke _self;
  final $Res Function(VxStroke) _then;

/// Create a copy of VxStroke
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = null,Object? width = null,Object? cap = null,Object? join = null,Object? opacity = null,Object? miterLimit = null,Object? dashArray = freezed,}) {
  return _then(_self.copyWith(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,cap: null == cap ? _self.cap : cap // ignore: cast_nullable_to_non_nullable
as StrokeCap,join: null == join ? _self.join : join // ignore: cast_nullable_to_non_nullable
as StrokeJoin,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,miterLimit: null == miterLimit ? _self.miterLimit : miterLimit // ignore: cast_nullable_to_non_nullable
as double,dashArray: freezed == dashArray ? _self.dashArray : dashArray // ignore: cast_nullable_to_non_nullable
as List<double>?,
  ));
}

}


/// Adds pattern-matching-related methods to [VxStroke].
extension VxStrokePatterns on VxStroke {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VxStroke value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VxStroke() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VxStroke value)  $default,){
final _that = this;
switch (_that) {
case _VxStroke():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VxStroke value)?  $default,){
final _that = this;
switch (_that) {
case _VxStroke() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@ColorConverter()  Color color,  double width,  StrokeCap cap,  StrokeJoin join,  double opacity,  double miterLimit,  List<double>? dashArray)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VxStroke() when $default != null:
return $default(_that.color,_that.width,_that.cap,_that.join,_that.opacity,_that.miterLimit,_that.dashArray);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@ColorConverter()  Color color,  double width,  StrokeCap cap,  StrokeJoin join,  double opacity,  double miterLimit,  List<double>? dashArray)  $default,) {final _that = this;
switch (_that) {
case _VxStroke():
return $default(_that.color,_that.width,_that.cap,_that.join,_that.opacity,_that.miterLimit,_that.dashArray);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@ColorConverter()  Color color,  double width,  StrokeCap cap,  StrokeJoin join,  double opacity,  double miterLimit,  List<double>? dashArray)?  $default,) {final _that = this;
switch (_that) {
case _VxStroke() when $default != null:
return $default(_that.color,_that.width,_that.cap,_that.join,_that.opacity,_that.miterLimit,_that.dashArray);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VxStroke implements VxStroke {
  const _VxStroke({@ColorConverter() required this.color, required this.width, required this.cap, required this.join, this.opacity = 1.0, this.miterLimit = 1.0, final  List<double>? dashArray}): _dashArray = dashArray;
  factory _VxStroke.fromJson(Map<String, dynamic> json) => _$VxStrokeFromJson(json);

@override@ColorConverter() final  Color color;
@override final  double width;
@override final  StrokeCap cap;
@override final  StrokeJoin join;
@override@JsonKey() final  double opacity;
@override@JsonKey() final  double miterLimit;
 final  List<double>? _dashArray;
@override List<double>? get dashArray {
  final value = _dashArray;
  if (value == null) return null;
  if (_dashArray is EqualUnmodifiableListView) return _dashArray;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of VxStroke
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VxStrokeCopyWith<_VxStroke> get copyWith => __$VxStrokeCopyWithImpl<_VxStroke>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VxStrokeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VxStroke&&(identical(other.color, color) || other.color == color)&&(identical(other.width, width) || other.width == width)&&(identical(other.cap, cap) || other.cap == cap)&&(identical(other.join, join) || other.join == join)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.miterLimit, miterLimit) || other.miterLimit == miterLimit)&&const DeepCollectionEquality().equals(other._dashArray, _dashArray));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,width,cap,join,opacity,miterLimit,const DeepCollectionEquality().hash(_dashArray));

@override
String toString() {
  return 'VxStroke(color: $color, width: $width, cap: $cap, join: $join, opacity: $opacity, miterLimit: $miterLimit, dashArray: $dashArray)';
}


}

/// @nodoc
abstract mixin class _$VxStrokeCopyWith<$Res> implements $VxStrokeCopyWith<$Res> {
  factory _$VxStrokeCopyWith(_VxStroke value, $Res Function(_VxStroke) _then) = __$VxStrokeCopyWithImpl;
@override @useResult
$Res call({
@ColorConverter() Color color, double width, StrokeCap cap, StrokeJoin join, double opacity, double miterLimit, List<double>? dashArray
});




}
/// @nodoc
class __$VxStrokeCopyWithImpl<$Res>
    implements _$VxStrokeCopyWith<$Res> {
  __$VxStrokeCopyWithImpl(this._self, this._then);

  final _VxStroke _self;
  final $Res Function(_VxStroke) _then;

/// Create a copy of VxStroke
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = null,Object? width = null,Object? cap = null,Object? join = null,Object? opacity = null,Object? miterLimit = null,Object? dashArray = freezed,}) {
  return _then(_VxStroke(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,cap: null == cap ? _self.cap : cap // ignore: cast_nullable_to_non_nullable
as StrokeCap,join: null == join ? _self.join : join // ignore: cast_nullable_to_non_nullable
as StrokeJoin,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,miterLimit: null == miterLimit ? _self.miterLimit : miterLimit // ignore: cast_nullable_to_non_nullable
as double,dashArray: freezed == dashArray ? _self._dashArray : dashArray // ignore: cast_nullable_to_non_nullable
as List<double>?,
  ));
}


}

VxElement _$VxElementFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'rect':
          return VxRect.fromJson(
            json
          );
                case 'ellipse':
          return VxEllipse.fromJson(
            json
          );
                case 'path':
          return VxPath.fromJson(
            json
          );
                case 'text':
          return VxText.fromJson(
            json
          );
                case 'group':
          return VxGroup.fromJson(
            json
          );
                case 'compound':
          return VxCompound.fromJson(
            json
          );
                case 'use':
          return VxUse.fromJson(
            json
          );
                case 'symbol':
          return VxSymbol.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'VxElement',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$VxElement {

 String get id; String? get artboardId;@Matrix4Converter() Matrix4 get transform; double get opacity; bool get locked; bool get visible; String? get clipPathId; String? get maskId;
/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VxElementCopyWith<VxElement> get copyWith => _$VxElementCopyWithImpl<VxElement>(this as VxElement, _$identity);

  /// Serializes this VxElement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VxElement&&(identical(other.id, id) || other.id == id)&&(identical(other.artboardId, artboardId) || other.artboardId == artboardId)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.visible, visible) || other.visible == visible)&&(identical(other.clipPathId, clipPathId) || other.clipPathId == clipPathId)&&(identical(other.maskId, maskId) || other.maskId == maskId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,artboardId,transform,opacity,locked,visible,clipPathId,maskId);

@override
String toString() {
  return 'VxElement(id: $id, artboardId: $artboardId, transform: $transform, opacity: $opacity, locked: $locked, visible: $visible, clipPathId: $clipPathId, maskId: $maskId)';
}


}

/// @nodoc
abstract mixin class $VxElementCopyWith<$Res>  {
  factory $VxElementCopyWith(VxElement value, $Res Function(VxElement) _then) = _$VxElementCopyWithImpl;
@useResult
$Res call({
 String id, String? artboardId,@Matrix4Converter() Matrix4 transform, double opacity, bool locked, bool visible, String? clipPathId, String? maskId
});




}
/// @nodoc
class _$VxElementCopyWithImpl<$Res>
    implements $VxElementCopyWith<$Res> {
  _$VxElementCopyWithImpl(this._self, this._then);

  final VxElement _self;
  final $Res Function(VxElement) _then;

/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? artboardId = freezed,Object? transform = null,Object? opacity = null,Object? locked = null,Object? visible = null,Object? clipPathId = freezed,Object? maskId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,artboardId: freezed == artboardId ? _self.artboardId : artboardId // ignore: cast_nullable_to_non_nullable
as String?,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as Matrix4,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,clipPathId: freezed == clipPathId ? _self.clipPathId : clipPathId // ignore: cast_nullable_to_non_nullable
as String?,maskId: freezed == maskId ? _self.maskId : maskId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VxElement].
extension VxElementPatterns on VxElement {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( VxRect value)?  rect,TResult Function( VxEllipse value)?  ellipse,TResult Function( VxPath value)?  path,TResult Function( VxText value)?  text,TResult Function( VxGroup value)?  group,TResult Function( VxCompound value)?  compound,TResult Function( VxUse value)?  use,TResult Function( VxSymbol value)?  symbol,required TResult orElse(),}){
final _that = this;
switch (_that) {
case VxRect() when rect != null:
return rect(_that);case VxEllipse() when ellipse != null:
return ellipse(_that);case VxPath() when path != null:
return path(_that);case VxText() when text != null:
return text(_that);case VxGroup() when group != null:
return group(_that);case VxCompound() when compound != null:
return compound(_that);case VxUse() when use != null:
return use(_that);case VxSymbol() when symbol != null:
return symbol(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( VxRect value)  rect,required TResult Function( VxEllipse value)  ellipse,required TResult Function( VxPath value)  path,required TResult Function( VxText value)  text,required TResult Function( VxGroup value)  group,required TResult Function( VxCompound value)  compound,required TResult Function( VxUse value)  use,required TResult Function( VxSymbol value)  symbol,}){
final _that = this;
switch (_that) {
case VxRect():
return rect(_that);case VxEllipse():
return ellipse(_that);case VxPath():
return path(_that);case VxText():
return text(_that);case VxGroup():
return group(_that);case VxCompound():
return compound(_that);case VxUse():
return use(_that);case VxSymbol():
return symbol(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( VxRect value)?  rect,TResult? Function( VxEllipse value)?  ellipse,TResult? Function( VxPath value)?  path,TResult? Function( VxText value)?  text,TResult? Function( VxGroup value)?  group,TResult? Function( VxCompound value)?  compound,TResult? Function( VxUse value)?  use,TResult? Function( VxSymbol value)?  symbol,}){
final _that = this;
switch (_that) {
case VxRect() when rect != null:
return rect(_that);case VxEllipse() when ellipse != null:
return ellipse(_that);case VxPath() when path != null:
return path(_that);case VxText() when text != null:
return text(_that);case VxGroup() when group != null:
return group(_that);case VxCompound() when compound != null:
return compound(_that);case VxUse() when use != null:
return use(_that);case VxSymbol() when symbol != null:
return symbol(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String? artboardId,  double x,  double y,  double width,  double height, @Matrix4Converter()  Matrix4 transform,  VxFill fill,  VxStroke stroke,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)?  rect,TResult Function( String id,  String? artboardId,  double cx,  double cy,  double rx,  double ry, @Matrix4Converter()  Matrix4 transform,  VxFill fill,  VxStroke stroke,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)?  ellipse,TResult Function( String id,  String? artboardId,  List<PathSegment> segments, @Matrix4Converter()  Matrix4 transform,  VxFill fill,  VxStroke stroke,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)?  path,TResult Function( String id,  String? artboardId,  String content,  double x,  double y, @TextStyleConverter()  TextStyle style,  TextAlign align,  double? letterSpacing,  double? wordSpacing,  double? lineHeight,  int? fontWeightValue,  FontStyle? fontStyle,  int maxLines, @Matrix4Converter()  Matrix4 transform,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)?  text,TResult Function( String id,  String? artboardId,  List<VxElement> children, @Matrix4Converter()  Matrix4 transform,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)?  group,TResult Function( String id,  String? artboardId,  int operation,  List<VxElement> children, @Matrix4Converter()  Matrix4 transform,  VxFill fill,  VxStroke stroke,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)?  compound,TResult Function( String id,  String? artboardId,  String href, @Matrix4Converter()  Matrix4 transform,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)?  use,TResult Function( String id,  String? artboardId,  List<VxElement> children, @Matrix4Converter()  Matrix4 transform,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)?  symbol,required TResult orElse(),}) {final _that = this;
switch (_that) {
case VxRect() when rect != null:
return rect(_that.id,_that.artboardId,_that.x,_that.y,_that.width,_that.height,_that.transform,_that.fill,_that.stroke,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxEllipse() when ellipse != null:
return ellipse(_that.id,_that.artboardId,_that.cx,_that.cy,_that.rx,_that.ry,_that.transform,_that.fill,_that.stroke,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxPath() when path != null:
return path(_that.id,_that.artboardId,_that.segments,_that.transform,_that.fill,_that.stroke,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxText() when text != null:
return text(_that.id,_that.artboardId,_that.content,_that.x,_that.y,_that.style,_that.align,_that.letterSpacing,_that.wordSpacing,_that.lineHeight,_that.fontWeightValue,_that.fontStyle,_that.maxLines,_that.transform,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxGroup() when group != null:
return group(_that.id,_that.artboardId,_that.children,_that.transform,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxCompound() when compound != null:
return compound(_that.id,_that.artboardId,_that.operation,_that.children,_that.transform,_that.fill,_that.stroke,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxUse() when use != null:
return use(_that.id,_that.artboardId,_that.href,_that.transform,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxSymbol() when symbol != null:
return symbol(_that.id,_that.artboardId,_that.children,_that.transform,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String? artboardId,  double x,  double y,  double width,  double height, @Matrix4Converter()  Matrix4 transform,  VxFill fill,  VxStroke stroke,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)  rect,required TResult Function( String id,  String? artboardId,  double cx,  double cy,  double rx,  double ry, @Matrix4Converter()  Matrix4 transform,  VxFill fill,  VxStroke stroke,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)  ellipse,required TResult Function( String id,  String? artboardId,  List<PathSegment> segments, @Matrix4Converter()  Matrix4 transform,  VxFill fill,  VxStroke stroke,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)  path,required TResult Function( String id,  String? artboardId,  String content,  double x,  double y, @TextStyleConverter()  TextStyle style,  TextAlign align,  double? letterSpacing,  double? wordSpacing,  double? lineHeight,  int? fontWeightValue,  FontStyle? fontStyle,  int maxLines, @Matrix4Converter()  Matrix4 transform,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)  text,required TResult Function( String id,  String? artboardId,  List<VxElement> children, @Matrix4Converter()  Matrix4 transform,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)  group,required TResult Function( String id,  String? artboardId,  int operation,  List<VxElement> children, @Matrix4Converter()  Matrix4 transform,  VxFill fill,  VxStroke stroke,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)  compound,required TResult Function( String id,  String? artboardId,  String href, @Matrix4Converter()  Matrix4 transform,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)  use,required TResult Function( String id,  String? artboardId,  List<VxElement> children, @Matrix4Converter()  Matrix4 transform,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)  symbol,}) {final _that = this;
switch (_that) {
case VxRect():
return rect(_that.id,_that.artboardId,_that.x,_that.y,_that.width,_that.height,_that.transform,_that.fill,_that.stroke,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxEllipse():
return ellipse(_that.id,_that.artboardId,_that.cx,_that.cy,_that.rx,_that.ry,_that.transform,_that.fill,_that.stroke,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxPath():
return path(_that.id,_that.artboardId,_that.segments,_that.transform,_that.fill,_that.stroke,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxText():
return text(_that.id,_that.artboardId,_that.content,_that.x,_that.y,_that.style,_that.align,_that.letterSpacing,_that.wordSpacing,_that.lineHeight,_that.fontWeightValue,_that.fontStyle,_that.maxLines,_that.transform,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxGroup():
return group(_that.id,_that.artboardId,_that.children,_that.transform,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxCompound():
return compound(_that.id,_that.artboardId,_that.operation,_that.children,_that.transform,_that.fill,_that.stroke,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxUse():
return use(_that.id,_that.artboardId,_that.href,_that.transform,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxSymbol():
return symbol(_that.id,_that.artboardId,_that.children,_that.transform,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String? artboardId,  double x,  double y,  double width,  double height, @Matrix4Converter()  Matrix4 transform,  VxFill fill,  VxStroke stroke,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)?  rect,TResult? Function( String id,  String? artboardId,  double cx,  double cy,  double rx,  double ry, @Matrix4Converter()  Matrix4 transform,  VxFill fill,  VxStroke stroke,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)?  ellipse,TResult? Function( String id,  String? artboardId,  List<PathSegment> segments, @Matrix4Converter()  Matrix4 transform,  VxFill fill,  VxStroke stroke,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)?  path,TResult? Function( String id,  String? artboardId,  String content,  double x,  double y, @TextStyleConverter()  TextStyle style,  TextAlign align,  double? letterSpacing,  double? wordSpacing,  double? lineHeight,  int? fontWeightValue,  FontStyle? fontStyle,  int maxLines, @Matrix4Converter()  Matrix4 transform,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)?  text,TResult? Function( String id,  String? artboardId,  List<VxElement> children, @Matrix4Converter()  Matrix4 transform,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)?  group,TResult? Function( String id,  String? artboardId,  int operation,  List<VxElement> children, @Matrix4Converter()  Matrix4 transform,  VxFill fill,  VxStroke stroke,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)?  compound,TResult? Function( String id,  String? artboardId,  String href, @Matrix4Converter()  Matrix4 transform,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)?  use,TResult? Function( String id,  String? artboardId,  List<VxElement> children, @Matrix4Converter()  Matrix4 transform,  double opacity,  bool locked,  bool visible,  String? clipPathId,  String? maskId)?  symbol,}) {final _that = this;
switch (_that) {
case VxRect() when rect != null:
return rect(_that.id,_that.artboardId,_that.x,_that.y,_that.width,_that.height,_that.transform,_that.fill,_that.stroke,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxEllipse() when ellipse != null:
return ellipse(_that.id,_that.artboardId,_that.cx,_that.cy,_that.rx,_that.ry,_that.transform,_that.fill,_that.stroke,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxPath() when path != null:
return path(_that.id,_that.artboardId,_that.segments,_that.transform,_that.fill,_that.stroke,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxText() when text != null:
return text(_that.id,_that.artboardId,_that.content,_that.x,_that.y,_that.style,_that.align,_that.letterSpacing,_that.wordSpacing,_that.lineHeight,_that.fontWeightValue,_that.fontStyle,_that.maxLines,_that.transform,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxGroup() when group != null:
return group(_that.id,_that.artboardId,_that.children,_that.transform,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxCompound() when compound != null:
return compound(_that.id,_that.artboardId,_that.operation,_that.children,_that.transform,_that.fill,_that.stroke,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxUse() when use != null:
return use(_that.id,_that.artboardId,_that.href,_that.transform,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case VxSymbol() when symbol != null:
return symbol(_that.id,_that.artboardId,_that.children,_that.transform,_that.opacity,_that.locked,_that.visible,_that.clipPathId,_that.maskId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class VxRect implements VxElement {
  const VxRect({required this.id, this.artboardId, required this.x, required this.y, required this.width, required this.height, @Matrix4Converter() required this.transform, required this.fill, required this.stroke, this.opacity = 1.0, this.locked = false, this.visible = true, this.clipPathId, this.maskId, final  String? $type}): $type = $type ?? 'rect';
  factory VxRect.fromJson(Map<String, dynamic> json) => _$VxRectFromJson(json);

@override final  String id;
@override final  String? artboardId;
 final  double x;
 final  double y;
 final  double width;
 final  double height;
@override@Matrix4Converter() final  Matrix4 transform;
 final  VxFill fill;
 final  VxStroke stroke;
@override@JsonKey() final  double opacity;
@override@JsonKey() final  bool locked;
@override@JsonKey() final  bool visible;
@override final  String? clipPathId;
@override final  String? maskId;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VxRectCopyWith<VxRect> get copyWith => _$VxRectCopyWithImpl<VxRect>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VxRectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VxRect&&(identical(other.id, id) || other.id == id)&&(identical(other.artboardId, artboardId) || other.artboardId == artboardId)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.fill, fill) || other.fill == fill)&&(identical(other.stroke, stroke) || other.stroke == stroke)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.visible, visible) || other.visible == visible)&&(identical(other.clipPathId, clipPathId) || other.clipPathId == clipPathId)&&(identical(other.maskId, maskId) || other.maskId == maskId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,artboardId,x,y,width,height,transform,fill,stroke,opacity,locked,visible,clipPathId,maskId);

@override
String toString() {
  return 'VxElement.rect(id: $id, artboardId: $artboardId, x: $x, y: $y, width: $width, height: $height, transform: $transform, fill: $fill, stroke: $stroke, opacity: $opacity, locked: $locked, visible: $visible, clipPathId: $clipPathId, maskId: $maskId)';
}


}

/// @nodoc
abstract mixin class $VxRectCopyWith<$Res> implements $VxElementCopyWith<$Res> {
  factory $VxRectCopyWith(VxRect value, $Res Function(VxRect) _then) = _$VxRectCopyWithImpl;
@override @useResult
$Res call({
 String id, String? artboardId, double x, double y, double width, double height,@Matrix4Converter() Matrix4 transform, VxFill fill, VxStroke stroke, double opacity, bool locked, bool visible, String? clipPathId, String? maskId
});


$VxFillCopyWith<$Res> get fill;$VxStrokeCopyWith<$Res> get stroke;

}
/// @nodoc
class _$VxRectCopyWithImpl<$Res>
    implements $VxRectCopyWith<$Res> {
  _$VxRectCopyWithImpl(this._self, this._then);

  final VxRect _self;
  final $Res Function(VxRect) _then;

/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? artboardId = freezed,Object? x = null,Object? y = null,Object? width = null,Object? height = null,Object? transform = null,Object? fill = null,Object? stroke = null,Object? opacity = null,Object? locked = null,Object? visible = null,Object? clipPathId = freezed,Object? maskId = freezed,}) {
  return _then(VxRect(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,artboardId: freezed == artboardId ? _self.artboardId : artboardId // ignore: cast_nullable_to_non_nullable
as String?,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as Matrix4,fill: null == fill ? _self.fill : fill // ignore: cast_nullable_to_non_nullable
as VxFill,stroke: null == stroke ? _self.stroke : stroke // ignore: cast_nullable_to_non_nullable
as VxStroke,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,clipPathId: freezed == clipPathId ? _self.clipPathId : clipPathId // ignore: cast_nullable_to_non_nullable
as String?,maskId: freezed == maskId ? _self.maskId : maskId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VxFillCopyWith<$Res> get fill {
  
  return $VxFillCopyWith<$Res>(_self.fill, (value) {
    return _then(_self.copyWith(fill: value));
  });
}/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VxStrokeCopyWith<$Res> get stroke {
  
  return $VxStrokeCopyWith<$Res>(_self.stroke, (value) {
    return _then(_self.copyWith(stroke: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class VxEllipse implements VxElement {
  const VxEllipse({required this.id, this.artboardId, required this.cx, required this.cy, required this.rx, required this.ry, @Matrix4Converter() required this.transform, required this.fill, required this.stroke, this.opacity = 1.0, this.locked = false, this.visible = true, this.clipPathId, this.maskId, final  String? $type}): $type = $type ?? 'ellipse';
  factory VxEllipse.fromJson(Map<String, dynamic> json) => _$VxEllipseFromJson(json);

@override final  String id;
@override final  String? artboardId;
 final  double cx;
 final  double cy;
 final  double rx;
 final  double ry;
@override@Matrix4Converter() final  Matrix4 transform;
 final  VxFill fill;
 final  VxStroke stroke;
@override@JsonKey() final  double opacity;
@override@JsonKey() final  bool locked;
@override@JsonKey() final  bool visible;
@override final  String? clipPathId;
@override final  String? maskId;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VxEllipseCopyWith<VxEllipse> get copyWith => _$VxEllipseCopyWithImpl<VxEllipse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VxEllipseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VxEllipse&&(identical(other.id, id) || other.id == id)&&(identical(other.artboardId, artboardId) || other.artboardId == artboardId)&&(identical(other.cx, cx) || other.cx == cx)&&(identical(other.cy, cy) || other.cy == cy)&&(identical(other.rx, rx) || other.rx == rx)&&(identical(other.ry, ry) || other.ry == ry)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.fill, fill) || other.fill == fill)&&(identical(other.stroke, stroke) || other.stroke == stroke)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.visible, visible) || other.visible == visible)&&(identical(other.clipPathId, clipPathId) || other.clipPathId == clipPathId)&&(identical(other.maskId, maskId) || other.maskId == maskId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,artboardId,cx,cy,rx,ry,transform,fill,stroke,opacity,locked,visible,clipPathId,maskId);

@override
String toString() {
  return 'VxElement.ellipse(id: $id, artboardId: $artboardId, cx: $cx, cy: $cy, rx: $rx, ry: $ry, transform: $transform, fill: $fill, stroke: $stroke, opacity: $opacity, locked: $locked, visible: $visible, clipPathId: $clipPathId, maskId: $maskId)';
}


}

/// @nodoc
abstract mixin class $VxEllipseCopyWith<$Res> implements $VxElementCopyWith<$Res> {
  factory $VxEllipseCopyWith(VxEllipse value, $Res Function(VxEllipse) _then) = _$VxEllipseCopyWithImpl;
@override @useResult
$Res call({
 String id, String? artboardId, double cx, double cy, double rx, double ry,@Matrix4Converter() Matrix4 transform, VxFill fill, VxStroke stroke, double opacity, bool locked, bool visible, String? clipPathId, String? maskId
});


$VxFillCopyWith<$Res> get fill;$VxStrokeCopyWith<$Res> get stroke;

}
/// @nodoc
class _$VxEllipseCopyWithImpl<$Res>
    implements $VxEllipseCopyWith<$Res> {
  _$VxEllipseCopyWithImpl(this._self, this._then);

  final VxEllipse _self;
  final $Res Function(VxEllipse) _then;

/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? artboardId = freezed,Object? cx = null,Object? cy = null,Object? rx = null,Object? ry = null,Object? transform = null,Object? fill = null,Object? stroke = null,Object? opacity = null,Object? locked = null,Object? visible = null,Object? clipPathId = freezed,Object? maskId = freezed,}) {
  return _then(VxEllipse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,artboardId: freezed == artboardId ? _self.artboardId : artboardId // ignore: cast_nullable_to_non_nullable
as String?,cx: null == cx ? _self.cx : cx // ignore: cast_nullable_to_non_nullable
as double,cy: null == cy ? _self.cy : cy // ignore: cast_nullable_to_non_nullable
as double,rx: null == rx ? _self.rx : rx // ignore: cast_nullable_to_non_nullable
as double,ry: null == ry ? _self.ry : ry // ignore: cast_nullable_to_non_nullable
as double,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as Matrix4,fill: null == fill ? _self.fill : fill // ignore: cast_nullable_to_non_nullable
as VxFill,stroke: null == stroke ? _self.stroke : stroke // ignore: cast_nullable_to_non_nullable
as VxStroke,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,clipPathId: freezed == clipPathId ? _self.clipPathId : clipPathId // ignore: cast_nullable_to_non_nullable
as String?,maskId: freezed == maskId ? _self.maskId : maskId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VxFillCopyWith<$Res> get fill {
  
  return $VxFillCopyWith<$Res>(_self.fill, (value) {
    return _then(_self.copyWith(fill: value));
  });
}/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VxStrokeCopyWith<$Res> get stroke {
  
  return $VxStrokeCopyWith<$Res>(_self.stroke, (value) {
    return _then(_self.copyWith(stroke: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class VxPath implements VxElement {
  const VxPath({required this.id, this.artboardId, required final  List<PathSegment> segments, @Matrix4Converter() required this.transform, required this.fill, required this.stroke, this.opacity = 1.0, this.locked = false, this.visible = true, this.clipPathId, this.maskId, final  String? $type}): _segments = segments,$type = $type ?? 'path';
  factory VxPath.fromJson(Map<String, dynamic> json) => _$VxPathFromJson(json);

@override final  String id;
@override final  String? artboardId;
 final  List<PathSegment> _segments;
 List<PathSegment> get segments {
  if (_segments is EqualUnmodifiableListView) return _segments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_segments);
}

@override@Matrix4Converter() final  Matrix4 transform;
 final  VxFill fill;
 final  VxStroke stroke;
@override@JsonKey() final  double opacity;
@override@JsonKey() final  bool locked;
@override@JsonKey() final  bool visible;
@override final  String? clipPathId;
@override final  String? maskId;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VxPathCopyWith<VxPath> get copyWith => _$VxPathCopyWithImpl<VxPath>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VxPathToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VxPath&&(identical(other.id, id) || other.id == id)&&(identical(other.artboardId, artboardId) || other.artboardId == artboardId)&&const DeepCollectionEquality().equals(other._segments, _segments)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.fill, fill) || other.fill == fill)&&(identical(other.stroke, stroke) || other.stroke == stroke)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.visible, visible) || other.visible == visible)&&(identical(other.clipPathId, clipPathId) || other.clipPathId == clipPathId)&&(identical(other.maskId, maskId) || other.maskId == maskId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,artboardId,const DeepCollectionEquality().hash(_segments),transform,fill,stroke,opacity,locked,visible,clipPathId,maskId);

@override
String toString() {
  return 'VxElement.path(id: $id, artboardId: $artboardId, segments: $segments, transform: $transform, fill: $fill, stroke: $stroke, opacity: $opacity, locked: $locked, visible: $visible, clipPathId: $clipPathId, maskId: $maskId)';
}


}

/// @nodoc
abstract mixin class $VxPathCopyWith<$Res> implements $VxElementCopyWith<$Res> {
  factory $VxPathCopyWith(VxPath value, $Res Function(VxPath) _then) = _$VxPathCopyWithImpl;
@override @useResult
$Res call({
 String id, String? artboardId, List<PathSegment> segments,@Matrix4Converter() Matrix4 transform, VxFill fill, VxStroke stroke, double opacity, bool locked, bool visible, String? clipPathId, String? maskId
});


$VxFillCopyWith<$Res> get fill;$VxStrokeCopyWith<$Res> get stroke;

}
/// @nodoc
class _$VxPathCopyWithImpl<$Res>
    implements $VxPathCopyWith<$Res> {
  _$VxPathCopyWithImpl(this._self, this._then);

  final VxPath _self;
  final $Res Function(VxPath) _then;

/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? artboardId = freezed,Object? segments = null,Object? transform = null,Object? fill = null,Object? stroke = null,Object? opacity = null,Object? locked = null,Object? visible = null,Object? clipPathId = freezed,Object? maskId = freezed,}) {
  return _then(VxPath(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,artboardId: freezed == artboardId ? _self.artboardId : artboardId // ignore: cast_nullable_to_non_nullable
as String?,segments: null == segments ? _self._segments : segments // ignore: cast_nullable_to_non_nullable
as List<PathSegment>,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as Matrix4,fill: null == fill ? _self.fill : fill // ignore: cast_nullable_to_non_nullable
as VxFill,stroke: null == stroke ? _self.stroke : stroke // ignore: cast_nullable_to_non_nullable
as VxStroke,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,clipPathId: freezed == clipPathId ? _self.clipPathId : clipPathId // ignore: cast_nullable_to_non_nullable
as String?,maskId: freezed == maskId ? _self.maskId : maskId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VxFillCopyWith<$Res> get fill {
  
  return $VxFillCopyWith<$Res>(_self.fill, (value) {
    return _then(_self.copyWith(fill: value));
  });
}/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VxStrokeCopyWith<$Res> get stroke {
  
  return $VxStrokeCopyWith<$Res>(_self.stroke, (value) {
    return _then(_self.copyWith(stroke: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class VxText implements VxElement {
  const VxText({required this.id, this.artboardId, required this.content, required this.x, required this.y, @TextStyleConverter() required this.style, this.align = TextAlign.start, this.letterSpacing, this.wordSpacing, this.lineHeight, this.fontWeightValue, this.fontStyle, this.maxLines = 1, @Matrix4Converter() required this.transform, this.opacity = 1.0, this.locked = false, this.visible = true, this.clipPathId, this.maskId, final  String? $type}): $type = $type ?? 'text';
  factory VxText.fromJson(Map<String, dynamic> json) => _$VxTextFromJson(json);

@override final  String id;
@override final  String? artboardId;
 final  String content;
 final  double x;
 final  double y;
@TextStyleConverter() final  TextStyle style;
@JsonKey() final  TextAlign align;
 final  double? letterSpacing;
 final  double? wordSpacing;
 final  double? lineHeight;
 final  int? fontWeightValue;
 final  FontStyle? fontStyle;
@JsonKey() final  int maxLines;
@override@Matrix4Converter() final  Matrix4 transform;
@override@JsonKey() final  double opacity;
@override@JsonKey() final  bool locked;
@override@JsonKey() final  bool visible;
@override final  String? clipPathId;
@override final  String? maskId;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VxTextCopyWith<VxText> get copyWith => _$VxTextCopyWithImpl<VxText>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VxTextToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VxText&&(identical(other.id, id) || other.id == id)&&(identical(other.artboardId, artboardId) || other.artboardId == artboardId)&&(identical(other.content, content) || other.content == content)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.style, style) || other.style == style)&&(identical(other.align, align) || other.align == align)&&(identical(other.letterSpacing, letterSpacing) || other.letterSpacing == letterSpacing)&&(identical(other.wordSpacing, wordSpacing) || other.wordSpacing == wordSpacing)&&(identical(other.lineHeight, lineHeight) || other.lineHeight == lineHeight)&&(identical(other.fontWeightValue, fontWeightValue) || other.fontWeightValue == fontWeightValue)&&(identical(other.fontStyle, fontStyle) || other.fontStyle == fontStyle)&&(identical(other.maxLines, maxLines) || other.maxLines == maxLines)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.visible, visible) || other.visible == visible)&&(identical(other.clipPathId, clipPathId) || other.clipPathId == clipPathId)&&(identical(other.maskId, maskId) || other.maskId == maskId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,artboardId,content,x,y,style,align,letterSpacing,wordSpacing,lineHeight,fontWeightValue,fontStyle,maxLines,transform,opacity,locked,visible,clipPathId,maskId]);

@override
String toString() {
  return 'VxElement.text(id: $id, artboardId: $artboardId, content: $content, x: $x, y: $y, style: $style, align: $align, letterSpacing: $letterSpacing, wordSpacing: $wordSpacing, lineHeight: $lineHeight, fontWeightValue: $fontWeightValue, fontStyle: $fontStyle, maxLines: $maxLines, transform: $transform, opacity: $opacity, locked: $locked, visible: $visible, clipPathId: $clipPathId, maskId: $maskId)';
}


}

/// @nodoc
abstract mixin class $VxTextCopyWith<$Res> implements $VxElementCopyWith<$Res> {
  factory $VxTextCopyWith(VxText value, $Res Function(VxText) _then) = _$VxTextCopyWithImpl;
@override @useResult
$Res call({
 String id, String? artboardId, String content, double x, double y,@TextStyleConverter() TextStyle style, TextAlign align, double? letterSpacing, double? wordSpacing, double? lineHeight, int? fontWeightValue, FontStyle? fontStyle, int maxLines,@Matrix4Converter() Matrix4 transform, double opacity, bool locked, bool visible, String? clipPathId, String? maskId
});




}
/// @nodoc
class _$VxTextCopyWithImpl<$Res>
    implements $VxTextCopyWith<$Res> {
  _$VxTextCopyWithImpl(this._self, this._then);

  final VxText _self;
  final $Res Function(VxText) _then;

/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? artboardId = freezed,Object? content = null,Object? x = null,Object? y = null,Object? style = null,Object? align = null,Object? letterSpacing = freezed,Object? wordSpacing = freezed,Object? lineHeight = freezed,Object? fontWeightValue = freezed,Object? fontStyle = freezed,Object? maxLines = null,Object? transform = null,Object? opacity = null,Object? locked = null,Object? visible = null,Object? clipPathId = freezed,Object? maskId = freezed,}) {
  return _then(VxText(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,artboardId: freezed == artboardId ? _self.artboardId : artboardId // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as TextStyle,align: null == align ? _self.align : align // ignore: cast_nullable_to_non_nullable
as TextAlign,letterSpacing: freezed == letterSpacing ? _self.letterSpacing : letterSpacing // ignore: cast_nullable_to_non_nullable
as double?,wordSpacing: freezed == wordSpacing ? _self.wordSpacing : wordSpacing // ignore: cast_nullable_to_non_nullable
as double?,lineHeight: freezed == lineHeight ? _self.lineHeight : lineHeight // ignore: cast_nullable_to_non_nullable
as double?,fontWeightValue: freezed == fontWeightValue ? _self.fontWeightValue : fontWeightValue // ignore: cast_nullable_to_non_nullable
as int?,fontStyle: freezed == fontStyle ? _self.fontStyle : fontStyle // ignore: cast_nullable_to_non_nullable
as FontStyle?,maxLines: null == maxLines ? _self.maxLines : maxLines // ignore: cast_nullable_to_non_nullable
as int,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as Matrix4,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,clipPathId: freezed == clipPathId ? _self.clipPathId : clipPathId // ignore: cast_nullable_to_non_nullable
as String?,maskId: freezed == maskId ? _self.maskId : maskId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class VxGroup implements VxElement {
  const VxGroup({required this.id, this.artboardId, required final  List<VxElement> children, @Matrix4Converter() required this.transform, this.opacity = 1.0, this.locked = false, this.visible = true, this.clipPathId, this.maskId, final  String? $type}): _children = children,$type = $type ?? 'group';
  factory VxGroup.fromJson(Map<String, dynamic> json) => _$VxGroupFromJson(json);

@override final  String id;
@override final  String? artboardId;
 final  List<VxElement> _children;
 List<VxElement> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}

@override@Matrix4Converter() final  Matrix4 transform;
@override@JsonKey() final  double opacity;
@override@JsonKey() final  bool locked;
@override@JsonKey() final  bool visible;
@override final  String? clipPathId;
@override final  String? maskId;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VxGroupCopyWith<VxGroup> get copyWith => _$VxGroupCopyWithImpl<VxGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VxGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VxGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.artboardId, artboardId) || other.artboardId == artboardId)&&const DeepCollectionEquality().equals(other._children, _children)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.visible, visible) || other.visible == visible)&&(identical(other.clipPathId, clipPathId) || other.clipPathId == clipPathId)&&(identical(other.maskId, maskId) || other.maskId == maskId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,artboardId,const DeepCollectionEquality().hash(_children),transform,opacity,locked,visible,clipPathId,maskId);

@override
String toString() {
  return 'VxElement.group(id: $id, artboardId: $artboardId, children: $children, transform: $transform, opacity: $opacity, locked: $locked, visible: $visible, clipPathId: $clipPathId, maskId: $maskId)';
}


}

/// @nodoc
abstract mixin class $VxGroupCopyWith<$Res> implements $VxElementCopyWith<$Res> {
  factory $VxGroupCopyWith(VxGroup value, $Res Function(VxGroup) _then) = _$VxGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String? artboardId, List<VxElement> children,@Matrix4Converter() Matrix4 transform, double opacity, bool locked, bool visible, String? clipPathId, String? maskId
});




}
/// @nodoc
class _$VxGroupCopyWithImpl<$Res>
    implements $VxGroupCopyWith<$Res> {
  _$VxGroupCopyWithImpl(this._self, this._then);

  final VxGroup _self;
  final $Res Function(VxGroup) _then;

/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? artboardId = freezed,Object? children = null,Object? transform = null,Object? opacity = null,Object? locked = null,Object? visible = null,Object? clipPathId = freezed,Object? maskId = freezed,}) {
  return _then(VxGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,artboardId: freezed == artboardId ? _self.artboardId : artboardId // ignore: cast_nullable_to_non_nullable
as String?,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<VxElement>,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as Matrix4,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,clipPathId: freezed == clipPathId ? _self.clipPathId : clipPathId // ignore: cast_nullable_to_non_nullable
as String?,maskId: freezed == maskId ? _self.maskId : maskId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class VxCompound implements VxElement {
  const VxCompound({required this.id, this.artboardId, required this.operation, required final  List<VxElement> children, @Matrix4Converter() required this.transform, required this.fill, required this.stroke, this.opacity = 1.0, this.locked = false, this.visible = true, this.clipPathId, this.maskId, final  String? $type}): _children = children,$type = $type ?? 'compound';
  factory VxCompound.fromJson(Map<String, dynamic> json) => _$VxCompoundFromJson(json);

@override final  String id;
@override final  String? artboardId;
 final  int operation;
 final  List<VxElement> _children;
 List<VxElement> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}

@override@Matrix4Converter() final  Matrix4 transform;
 final  VxFill fill;
 final  VxStroke stroke;
@override@JsonKey() final  double opacity;
@override@JsonKey() final  bool locked;
@override@JsonKey() final  bool visible;
@override final  String? clipPathId;
@override final  String? maskId;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VxCompoundCopyWith<VxCompound> get copyWith => _$VxCompoundCopyWithImpl<VxCompound>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VxCompoundToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VxCompound&&(identical(other.id, id) || other.id == id)&&(identical(other.artboardId, artboardId) || other.artboardId == artboardId)&&(identical(other.operation, operation) || other.operation == operation)&&const DeepCollectionEquality().equals(other._children, _children)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.fill, fill) || other.fill == fill)&&(identical(other.stroke, stroke) || other.stroke == stroke)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.visible, visible) || other.visible == visible)&&(identical(other.clipPathId, clipPathId) || other.clipPathId == clipPathId)&&(identical(other.maskId, maskId) || other.maskId == maskId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,artboardId,operation,const DeepCollectionEquality().hash(_children),transform,fill,stroke,opacity,locked,visible,clipPathId,maskId);

@override
String toString() {
  return 'VxElement.compound(id: $id, artboardId: $artboardId, operation: $operation, children: $children, transform: $transform, fill: $fill, stroke: $stroke, opacity: $opacity, locked: $locked, visible: $visible, clipPathId: $clipPathId, maskId: $maskId)';
}


}

/// @nodoc
abstract mixin class $VxCompoundCopyWith<$Res> implements $VxElementCopyWith<$Res> {
  factory $VxCompoundCopyWith(VxCompound value, $Res Function(VxCompound) _then) = _$VxCompoundCopyWithImpl;
@override @useResult
$Res call({
 String id, String? artboardId, int operation, List<VxElement> children,@Matrix4Converter() Matrix4 transform, VxFill fill, VxStroke stroke, double opacity, bool locked, bool visible, String? clipPathId, String? maskId
});


$VxFillCopyWith<$Res> get fill;$VxStrokeCopyWith<$Res> get stroke;

}
/// @nodoc
class _$VxCompoundCopyWithImpl<$Res>
    implements $VxCompoundCopyWith<$Res> {
  _$VxCompoundCopyWithImpl(this._self, this._then);

  final VxCompound _self;
  final $Res Function(VxCompound) _then;

/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? artboardId = freezed,Object? operation = null,Object? children = null,Object? transform = null,Object? fill = null,Object? stroke = null,Object? opacity = null,Object? locked = null,Object? visible = null,Object? clipPathId = freezed,Object? maskId = freezed,}) {
  return _then(VxCompound(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,artboardId: freezed == artboardId ? _self.artboardId : artboardId // ignore: cast_nullable_to_non_nullable
as String?,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as int,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<VxElement>,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as Matrix4,fill: null == fill ? _self.fill : fill // ignore: cast_nullable_to_non_nullable
as VxFill,stroke: null == stroke ? _self.stroke : stroke // ignore: cast_nullable_to_non_nullable
as VxStroke,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,clipPathId: freezed == clipPathId ? _self.clipPathId : clipPathId // ignore: cast_nullable_to_non_nullable
as String?,maskId: freezed == maskId ? _self.maskId : maskId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VxFillCopyWith<$Res> get fill {
  
  return $VxFillCopyWith<$Res>(_self.fill, (value) {
    return _then(_self.copyWith(fill: value));
  });
}/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VxStrokeCopyWith<$Res> get stroke {
  
  return $VxStrokeCopyWith<$Res>(_self.stroke, (value) {
    return _then(_self.copyWith(stroke: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class VxUse implements VxElement {
  const VxUse({required this.id, this.artboardId, required this.href, @Matrix4Converter() required this.transform, this.opacity = 1.0, this.locked = false, this.visible = true, this.clipPathId, this.maskId, final  String? $type}): $type = $type ?? 'use';
  factory VxUse.fromJson(Map<String, dynamic> json) => _$VxUseFromJson(json);

@override final  String id;
@override final  String? artboardId;
 final  String href;
@override@Matrix4Converter() final  Matrix4 transform;
@override@JsonKey() final  double opacity;
@override@JsonKey() final  bool locked;
@override@JsonKey() final  bool visible;
@override final  String? clipPathId;
@override final  String? maskId;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VxUseCopyWith<VxUse> get copyWith => _$VxUseCopyWithImpl<VxUse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VxUseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VxUse&&(identical(other.id, id) || other.id == id)&&(identical(other.artboardId, artboardId) || other.artboardId == artboardId)&&(identical(other.href, href) || other.href == href)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.visible, visible) || other.visible == visible)&&(identical(other.clipPathId, clipPathId) || other.clipPathId == clipPathId)&&(identical(other.maskId, maskId) || other.maskId == maskId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,artboardId,href,transform,opacity,locked,visible,clipPathId,maskId);

@override
String toString() {
  return 'VxElement.use(id: $id, artboardId: $artboardId, href: $href, transform: $transform, opacity: $opacity, locked: $locked, visible: $visible, clipPathId: $clipPathId, maskId: $maskId)';
}


}

/// @nodoc
abstract mixin class $VxUseCopyWith<$Res> implements $VxElementCopyWith<$Res> {
  factory $VxUseCopyWith(VxUse value, $Res Function(VxUse) _then) = _$VxUseCopyWithImpl;
@override @useResult
$Res call({
 String id, String? artboardId, String href,@Matrix4Converter() Matrix4 transform, double opacity, bool locked, bool visible, String? clipPathId, String? maskId
});




}
/// @nodoc
class _$VxUseCopyWithImpl<$Res>
    implements $VxUseCopyWith<$Res> {
  _$VxUseCopyWithImpl(this._self, this._then);

  final VxUse _self;
  final $Res Function(VxUse) _then;

/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? artboardId = freezed,Object? href = null,Object? transform = null,Object? opacity = null,Object? locked = null,Object? visible = null,Object? clipPathId = freezed,Object? maskId = freezed,}) {
  return _then(VxUse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,artboardId: freezed == artboardId ? _self.artboardId : artboardId // ignore: cast_nullable_to_non_nullable
as String?,href: null == href ? _self.href : href // ignore: cast_nullable_to_non_nullable
as String,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as Matrix4,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,clipPathId: freezed == clipPathId ? _self.clipPathId : clipPathId // ignore: cast_nullable_to_non_nullable
as String?,maskId: freezed == maskId ? _self.maskId : maskId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class VxSymbol implements VxElement {
  const VxSymbol({required this.id, this.artboardId, required final  List<VxElement> children, @Matrix4Converter() required this.transform, this.opacity = 1.0, this.locked = false, this.visible = true, this.clipPathId, this.maskId, final  String? $type}): _children = children,$type = $type ?? 'symbol';
  factory VxSymbol.fromJson(Map<String, dynamic> json) => _$VxSymbolFromJson(json);

@override final  String id;
@override final  String? artboardId;
 final  List<VxElement> _children;
 List<VxElement> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}

@override@Matrix4Converter() final  Matrix4 transform;
@override@JsonKey() final  double opacity;
@override@JsonKey() final  bool locked;
@override@JsonKey() final  bool visible;
@override final  String? clipPathId;
@override final  String? maskId;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VxSymbolCopyWith<VxSymbol> get copyWith => _$VxSymbolCopyWithImpl<VxSymbol>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VxSymbolToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VxSymbol&&(identical(other.id, id) || other.id == id)&&(identical(other.artboardId, artboardId) || other.artboardId == artboardId)&&const DeepCollectionEquality().equals(other._children, _children)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.visible, visible) || other.visible == visible)&&(identical(other.clipPathId, clipPathId) || other.clipPathId == clipPathId)&&(identical(other.maskId, maskId) || other.maskId == maskId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,artboardId,const DeepCollectionEquality().hash(_children),transform,opacity,locked,visible,clipPathId,maskId);

@override
String toString() {
  return 'VxElement.symbol(id: $id, artboardId: $artboardId, children: $children, transform: $transform, opacity: $opacity, locked: $locked, visible: $visible, clipPathId: $clipPathId, maskId: $maskId)';
}


}

/// @nodoc
abstract mixin class $VxSymbolCopyWith<$Res> implements $VxElementCopyWith<$Res> {
  factory $VxSymbolCopyWith(VxSymbol value, $Res Function(VxSymbol) _then) = _$VxSymbolCopyWithImpl;
@override @useResult
$Res call({
 String id, String? artboardId, List<VxElement> children,@Matrix4Converter() Matrix4 transform, double opacity, bool locked, bool visible, String? clipPathId, String? maskId
});




}
/// @nodoc
class _$VxSymbolCopyWithImpl<$Res>
    implements $VxSymbolCopyWith<$Res> {
  _$VxSymbolCopyWithImpl(this._self, this._then);

  final VxSymbol _self;
  final $Res Function(VxSymbol) _then;

/// Create a copy of VxElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? artboardId = freezed,Object? children = null,Object? transform = null,Object? opacity = null,Object? locked = null,Object? visible = null,Object? clipPathId = freezed,Object? maskId = freezed,}) {
  return _then(VxSymbol(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,artboardId: freezed == artboardId ? _self.artboardId : artboardId // ignore: cast_nullable_to_non_nullable
as String?,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<VxElement>,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as Matrix4,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,clipPathId: freezed == clipPathId ? _self.clipPathId : clipPathId // ignore: cast_nullable_to_non_nullable
as String?,maskId: freezed == maskId ? _self.maskId : maskId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
