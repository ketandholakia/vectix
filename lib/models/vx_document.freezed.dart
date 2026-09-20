// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vx_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VxArtboard {

 String get id; String get name; double get x; double get y; double get width; double get height; bool get visible;
/// Create a copy of VxArtboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VxArtboardCopyWith<VxArtboard> get copyWith => _$VxArtboardCopyWithImpl<VxArtboard>(this as VxArtboard, _$identity);

  /// Serializes this VxArtboard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VxArtboard&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.visible, visible) || other.visible == visible));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,x,y,width,height,visible);

@override
String toString() {
  return 'VxArtboard(id: $id, name: $name, x: $x, y: $y, width: $width, height: $height, visible: $visible)';
}


}

/// @nodoc
abstract mixin class $VxArtboardCopyWith<$Res>  {
  factory $VxArtboardCopyWith(VxArtboard value, $Res Function(VxArtboard) _then) = _$VxArtboardCopyWithImpl;
@useResult
$Res call({
 String id, String name, double x, double y, double width, double height, bool visible
});




}
/// @nodoc
class _$VxArtboardCopyWithImpl<$Res>
    implements $VxArtboardCopyWith<$Res> {
  _$VxArtboardCopyWithImpl(this._self, this._then);

  final VxArtboard _self;
  final $Res Function(VxArtboard) _then;

/// Create a copy of VxArtboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? x = null,Object? y = null,Object? width = null,Object? height = null,Object? visible = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VxArtboard].
extension VxArtboardPatterns on VxArtboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VxArtboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VxArtboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VxArtboard value)  $default,){
final _that = this;
switch (_that) {
case _VxArtboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VxArtboard value)?  $default,){
final _that = this;
switch (_that) {
case _VxArtboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double x,  double y,  double width,  double height,  bool visible)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VxArtboard() when $default != null:
return $default(_that.id,_that.name,_that.x,_that.y,_that.width,_that.height,_that.visible);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double x,  double y,  double width,  double height,  bool visible)  $default,) {final _that = this;
switch (_that) {
case _VxArtboard():
return $default(_that.id,_that.name,_that.x,_that.y,_that.width,_that.height,_that.visible);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double x,  double y,  double width,  double height,  bool visible)?  $default,) {final _that = this;
switch (_that) {
case _VxArtboard() when $default != null:
return $default(_that.id,_that.name,_that.x,_that.y,_that.width,_that.height,_that.visible);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VxArtboard implements VxArtboard {
  const _VxArtboard({required this.id, required this.name, required this.x, required this.y, required this.width, required this.height, this.visible = true});
  factory _VxArtboard.fromJson(Map<String, dynamic> json) => _$VxArtboardFromJson(json);

@override final  String id;
@override final  String name;
@override final  double x;
@override final  double y;
@override final  double width;
@override final  double height;
@override@JsonKey() final  bool visible;

/// Create a copy of VxArtboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VxArtboardCopyWith<_VxArtboard> get copyWith => __$VxArtboardCopyWithImpl<_VxArtboard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VxArtboardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VxArtboard&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.visible, visible) || other.visible == visible));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,x,y,width,height,visible);

@override
String toString() {
  return 'VxArtboard(id: $id, name: $name, x: $x, y: $y, width: $width, height: $height, visible: $visible)';
}


}

/// @nodoc
abstract mixin class _$VxArtboardCopyWith<$Res> implements $VxArtboardCopyWith<$Res> {
  factory _$VxArtboardCopyWith(_VxArtboard value, $Res Function(_VxArtboard) _then) = __$VxArtboardCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double x, double y, double width, double height, bool visible
});




}
/// @nodoc
class __$VxArtboardCopyWithImpl<$Res>
    implements _$VxArtboardCopyWith<$Res> {
  __$VxArtboardCopyWithImpl(this._self, this._then);

  final _VxArtboard _self;
  final $Res Function(_VxArtboard) _then;

/// Create a copy of VxArtboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? x = null,Object? y = null,Object? width = null,Object? height = null,Object? visible = null,}) {
  return _then(_VxArtboard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$VxDocument {

 String get id; int get version; double get width; double get height; List<VxElement> get elements; List<VxArtboard> get artboards; String get title; Map<String, dynamic> get metadata; int get pageCount; int get activePageIndex; String get artboardMode;
/// Create a copy of VxDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VxDocumentCopyWith<VxDocument> get copyWith => _$VxDocumentCopyWithImpl<VxDocument>(this as VxDocument, _$identity);

  /// Serializes this VxDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VxDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.version, version) || other.version == version)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&const DeepCollectionEquality().equals(other.elements, elements)&&const DeepCollectionEquality().equals(other.artboards, artboards)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.pageCount, pageCount) || other.pageCount == pageCount)&&(identical(other.activePageIndex, activePageIndex) || other.activePageIndex == activePageIndex)&&(identical(other.artboardMode, artboardMode) || other.artboardMode == artboardMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,version,width,height,const DeepCollectionEquality().hash(elements),const DeepCollectionEquality().hash(artboards),title,const DeepCollectionEquality().hash(metadata),pageCount,activePageIndex,artboardMode);

@override
String toString() {
  return 'VxDocument(id: $id, version: $version, width: $width, height: $height, elements: $elements, artboards: $artboards, title: $title, metadata: $metadata, pageCount: $pageCount, activePageIndex: $activePageIndex, artboardMode: $artboardMode)';
}


}

/// @nodoc
abstract mixin class $VxDocumentCopyWith<$Res>  {
  factory $VxDocumentCopyWith(VxDocument value, $Res Function(VxDocument) _then) = _$VxDocumentCopyWithImpl;
@useResult
$Res call({
 String id, int version, double width, double height, List<VxElement> elements, List<VxArtboard> artboards, String title, Map<String, dynamic> metadata, int pageCount, int activePageIndex, String artboardMode
});




}
/// @nodoc
class _$VxDocumentCopyWithImpl<$Res>
    implements $VxDocumentCopyWith<$Res> {
  _$VxDocumentCopyWithImpl(this._self, this._then);

  final VxDocument _self;
  final $Res Function(VxDocument) _then;

/// Create a copy of VxDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? version = null,Object? width = null,Object? height = null,Object? elements = null,Object? artboards = null,Object? title = null,Object? metadata = null,Object? pageCount = null,Object? activePageIndex = null,Object? artboardMode = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,elements: null == elements ? _self.elements : elements // ignore: cast_nullable_to_non_nullable
as List<VxElement>,artboards: null == artboards ? _self.artboards : artboards // ignore: cast_nullable_to_non_nullable
as List<VxArtboard>,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,pageCount: null == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int,activePageIndex: null == activePageIndex ? _self.activePageIndex : activePageIndex // ignore: cast_nullable_to_non_nullable
as int,artboardMode: null == artboardMode ? _self.artboardMode : artboardMode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VxDocument].
extension VxDocumentPatterns on VxDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VxDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VxDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VxDocument value)  $default,){
final _that = this;
switch (_that) {
case _VxDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VxDocument value)?  $default,){
final _that = this;
switch (_that) {
case _VxDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int version,  double width,  double height,  List<VxElement> elements,  List<VxArtboard> artboards,  String title,  Map<String, dynamic> metadata,  int pageCount,  int activePageIndex,  String artboardMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VxDocument() when $default != null:
return $default(_that.id,_that.version,_that.width,_that.height,_that.elements,_that.artboards,_that.title,_that.metadata,_that.pageCount,_that.activePageIndex,_that.artboardMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int version,  double width,  double height,  List<VxElement> elements,  List<VxArtboard> artboards,  String title,  Map<String, dynamic> metadata,  int pageCount,  int activePageIndex,  String artboardMode)  $default,) {final _that = this;
switch (_that) {
case _VxDocument():
return $default(_that.id,_that.version,_that.width,_that.height,_that.elements,_that.artboards,_that.title,_that.metadata,_that.pageCount,_that.activePageIndex,_that.artboardMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int version,  double width,  double height,  List<VxElement> elements,  List<VxArtboard> artboards,  String title,  Map<String, dynamic> metadata,  int pageCount,  int activePageIndex,  String artboardMode)?  $default,) {final _that = this;
switch (_that) {
case _VxDocument() when $default != null:
return $default(_that.id,_that.version,_that.width,_that.height,_that.elements,_that.artboards,_that.title,_that.metadata,_that.pageCount,_that.activePageIndex,_that.artboardMode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VxDocument implements VxDocument {
  const _VxDocument({required this.id, this.version = 1, required this.width, required this.height, required final  List<VxElement> elements, final  List<VxArtboard> artboards = const <VxArtboard>[], required this.title, final  Map<String, dynamic> metadata = const <String, dynamic>{}, this.pageCount = 1, this.activePageIndex = 0, this.artboardMode = 'single'}): _elements = elements,_artboards = artboards,_metadata = metadata;
  factory _VxDocument.fromJson(Map<String, dynamic> json) => _$VxDocumentFromJson(json);

@override final  String id;
@override@JsonKey() final  int version;
@override final  double width;
@override final  double height;
 final  List<VxElement> _elements;
@override List<VxElement> get elements {
  if (_elements is EqualUnmodifiableListView) return _elements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_elements);
}

 final  List<VxArtboard> _artboards;
@override@JsonKey() List<VxArtboard> get artboards {
  if (_artboards is EqualUnmodifiableListView) return _artboards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_artboards);
}

@override final  String title;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

@override@JsonKey() final  int pageCount;
@override@JsonKey() final  int activePageIndex;
@override@JsonKey() final  String artboardMode;

/// Create a copy of VxDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VxDocumentCopyWith<_VxDocument> get copyWith => __$VxDocumentCopyWithImpl<_VxDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VxDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VxDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.version, version) || other.version == version)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&const DeepCollectionEquality().equals(other._elements, _elements)&&const DeepCollectionEquality().equals(other._artboards, _artboards)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.pageCount, pageCount) || other.pageCount == pageCount)&&(identical(other.activePageIndex, activePageIndex) || other.activePageIndex == activePageIndex)&&(identical(other.artboardMode, artboardMode) || other.artboardMode == artboardMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,version,width,height,const DeepCollectionEquality().hash(_elements),const DeepCollectionEquality().hash(_artboards),title,const DeepCollectionEquality().hash(_metadata),pageCount,activePageIndex,artboardMode);

@override
String toString() {
  return 'VxDocument(id: $id, version: $version, width: $width, height: $height, elements: $elements, artboards: $artboards, title: $title, metadata: $metadata, pageCount: $pageCount, activePageIndex: $activePageIndex, artboardMode: $artboardMode)';
}


}

/// @nodoc
abstract mixin class _$VxDocumentCopyWith<$Res> implements $VxDocumentCopyWith<$Res> {
  factory _$VxDocumentCopyWith(_VxDocument value, $Res Function(_VxDocument) _then) = __$VxDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, int version, double width, double height, List<VxElement> elements, List<VxArtboard> artboards, String title, Map<String, dynamic> metadata, int pageCount, int activePageIndex, String artboardMode
});




}
/// @nodoc
class __$VxDocumentCopyWithImpl<$Res>
    implements _$VxDocumentCopyWith<$Res> {
  __$VxDocumentCopyWithImpl(this._self, this._then);

  final _VxDocument _self;
  final $Res Function(_VxDocument) _then;

/// Create a copy of VxDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? version = null,Object? width = null,Object? height = null,Object? elements = null,Object? artboards = null,Object? title = null,Object? metadata = null,Object? pageCount = null,Object? activePageIndex = null,Object? artboardMode = null,}) {
  return _then(_VxDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,elements: null == elements ? _self._elements : elements // ignore: cast_nullable_to_non_nullable
as List<VxElement>,artboards: null == artboards ? _self._artboards : artboards // ignore: cast_nullable_to_non_nullable
as List<VxArtboard>,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,pageCount: null == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int,activePageIndex: null == activePageIndex ? _self.activePageIndex : activePageIndex // ignore: cast_nullable_to_non_nullable
as int,artboardMode: null == artboardMode ? _self.artboardMode : artboardMode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
