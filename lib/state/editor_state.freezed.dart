// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'editor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ViewportState {

 double get zoom; Offset get pan;
/// Create a copy of ViewportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ViewportStateCopyWith<ViewportState> get copyWith => _$ViewportStateCopyWithImpl<ViewportState>(this as ViewportState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ViewportState&&(identical(other.zoom, zoom) || other.zoom == zoom)&&(identical(other.pan, pan) || other.pan == pan));
}


@override
int get hashCode => Object.hash(runtimeType,zoom,pan);

@override
String toString() {
  return 'ViewportState(zoom: $zoom, pan: $pan)';
}


}

/// @nodoc
abstract mixin class $ViewportStateCopyWith<$Res>  {
  factory $ViewportStateCopyWith(ViewportState value, $Res Function(ViewportState) _then) = _$ViewportStateCopyWithImpl;
@useResult
$Res call({
 double zoom, Offset pan
});




}
/// @nodoc
class _$ViewportStateCopyWithImpl<$Res>
    implements $ViewportStateCopyWith<$Res> {
  _$ViewportStateCopyWithImpl(this._self, this._then);

  final ViewportState _self;
  final $Res Function(ViewportState) _then;

/// Create a copy of ViewportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? zoom = null,Object? pan = null,}) {
  return _then(_self.copyWith(
zoom: null == zoom ? _self.zoom : zoom // ignore: cast_nullable_to_non_nullable
as double,pan: null == pan ? _self.pan : pan // ignore: cast_nullable_to_non_nullable
as Offset,
  ));
}

}


/// Adds pattern-matching-related methods to [ViewportState].
extension ViewportStatePatterns on ViewportState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ViewportState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ViewportState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ViewportState value)  $default,){
final _that = this;
switch (_that) {
case _ViewportState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ViewportState value)?  $default,){
final _that = this;
switch (_that) {
case _ViewportState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double zoom,  Offset pan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ViewportState() when $default != null:
return $default(_that.zoom,_that.pan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double zoom,  Offset pan)  $default,) {final _that = this;
switch (_that) {
case _ViewportState():
return $default(_that.zoom,_that.pan);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double zoom,  Offset pan)?  $default,) {final _that = this;
switch (_that) {
case _ViewportState() when $default != null:
return $default(_that.zoom,_that.pan);case _:
  return null;

}
}

}

/// @nodoc


class _ViewportState implements ViewportState {
  const _ViewportState({required this.zoom, required this.pan});
  

@override final  double zoom;
@override final  Offset pan;

/// Create a copy of ViewportState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewportStateCopyWith<_ViewportState> get copyWith => __$ViewportStateCopyWithImpl<_ViewportState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewportState&&(identical(other.zoom, zoom) || other.zoom == zoom)&&(identical(other.pan, pan) || other.pan == pan));
}


@override
int get hashCode => Object.hash(runtimeType,zoom,pan);

@override
String toString() {
  return 'ViewportState(zoom: $zoom, pan: $pan)';
}


}

/// @nodoc
abstract mixin class _$ViewportStateCopyWith<$Res> implements $ViewportStateCopyWith<$Res> {
  factory _$ViewportStateCopyWith(_ViewportState value, $Res Function(_ViewportState) _then) = __$ViewportStateCopyWithImpl;
@override @useResult
$Res call({
 double zoom, Offset pan
});




}
/// @nodoc
class __$ViewportStateCopyWithImpl<$Res>
    implements _$ViewportStateCopyWith<$Res> {
  __$ViewportStateCopyWithImpl(this._self, this._then);

  final _ViewportState _self;
  final $Res Function(_ViewportState) _then;

/// Create a copy of ViewportState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? zoom = null,Object? pan = null,}) {
  return _then(_ViewportState(
zoom: null == zoom ? _self.zoom : zoom // ignore: cast_nullable_to_non_nullable
as double,pan: null == pan ? _self.pan : pan // ignore: cast_nullable_to_non_nullable
as Offset,
  ));
}


}

/// @nodoc
mixin _$EditorState {

 VxDocument get document; Set<String> get selectedIds; ActiveTool get activeTool; ViewportState get viewport; bool get showGrid; bool get snapToGrid; double get gridSize; String? get editingTextId; int get polygonSides; int get starSpikes; double get starInnerRatio; double get freehandSmoothing; double get lineStrokeWidth;
/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorStateCopyWith<EditorState> get copyWith => _$EditorStateCopyWithImpl<EditorState>(this as EditorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorState&&(identical(other.document, document) || other.document == document)&&const DeepCollectionEquality().equals(other.selectedIds, selectedIds)&&(identical(other.activeTool, activeTool) || other.activeTool == activeTool)&&(identical(other.viewport, viewport) || other.viewport == viewport)&&(identical(other.showGrid, showGrid) || other.showGrid == showGrid)&&(identical(other.snapToGrid, snapToGrid) || other.snapToGrid == snapToGrid)&&(identical(other.gridSize, gridSize) || other.gridSize == gridSize)&&(identical(other.editingTextId, editingTextId) || other.editingTextId == editingTextId)&&(identical(other.polygonSides, polygonSides) || other.polygonSides == polygonSides)&&(identical(other.starSpikes, starSpikes) || other.starSpikes == starSpikes)&&(identical(other.starInnerRatio, starInnerRatio) || other.starInnerRatio == starInnerRatio)&&(identical(other.freehandSmoothing, freehandSmoothing) || other.freehandSmoothing == freehandSmoothing)&&(identical(other.lineStrokeWidth, lineStrokeWidth) || other.lineStrokeWidth == lineStrokeWidth));
}


@override
int get hashCode => Object.hash(runtimeType,document,const DeepCollectionEquality().hash(selectedIds),activeTool,viewport,showGrid,snapToGrid,gridSize,editingTextId,polygonSides,starSpikes,starInnerRatio,freehandSmoothing,lineStrokeWidth);

@override
String toString() {
  return 'EditorState(document: $document, selectedIds: $selectedIds, activeTool: $activeTool, viewport: $viewport, showGrid: $showGrid, snapToGrid: $snapToGrid, gridSize: $gridSize, editingTextId: $editingTextId, polygonSides: $polygonSides, starSpikes: $starSpikes, starInnerRatio: $starInnerRatio, freehandSmoothing: $freehandSmoothing, lineStrokeWidth: $lineStrokeWidth)';
}


}

/// @nodoc
abstract mixin class $EditorStateCopyWith<$Res>  {
  factory $EditorStateCopyWith(EditorState value, $Res Function(EditorState) _then) = _$EditorStateCopyWithImpl;
@useResult
$Res call({
 VxDocument document, Set<String> selectedIds, ActiveTool activeTool, ViewportState viewport, bool showGrid, bool snapToGrid, double gridSize, String? editingTextId, int polygonSides, int starSpikes, double starInnerRatio, double freehandSmoothing, double lineStrokeWidth
});


$VxDocumentCopyWith<$Res> get document;$ViewportStateCopyWith<$Res> get viewport;

}
/// @nodoc
class _$EditorStateCopyWithImpl<$Res>
    implements $EditorStateCopyWith<$Res> {
  _$EditorStateCopyWithImpl(this._self, this._then);

  final EditorState _self;
  final $Res Function(EditorState) _then;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? document = null,Object? selectedIds = null,Object? activeTool = null,Object? viewport = null,Object? showGrid = null,Object? snapToGrid = null,Object? gridSize = null,Object? editingTextId = freezed,Object? polygonSides = null,Object? starSpikes = null,Object? starInnerRatio = null,Object? freehandSmoothing = null,Object? lineStrokeWidth = null,}) {
  return _then(_self.copyWith(
document: null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as VxDocument,selectedIds: null == selectedIds ? _self.selectedIds : selectedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,activeTool: null == activeTool ? _self.activeTool : activeTool // ignore: cast_nullable_to_non_nullable
as ActiveTool,viewport: null == viewport ? _self.viewport : viewport // ignore: cast_nullable_to_non_nullable
as ViewportState,showGrid: null == showGrid ? _self.showGrid : showGrid // ignore: cast_nullable_to_non_nullable
as bool,snapToGrid: null == snapToGrid ? _self.snapToGrid : snapToGrid // ignore: cast_nullable_to_non_nullable
as bool,gridSize: null == gridSize ? _self.gridSize : gridSize // ignore: cast_nullable_to_non_nullable
as double,editingTextId: freezed == editingTextId ? _self.editingTextId : editingTextId // ignore: cast_nullable_to_non_nullable
as String?,polygonSides: null == polygonSides ? _self.polygonSides : polygonSides // ignore: cast_nullable_to_non_nullable
as int,starSpikes: null == starSpikes ? _self.starSpikes : starSpikes // ignore: cast_nullable_to_non_nullable
as int,starInnerRatio: null == starInnerRatio ? _self.starInnerRatio : starInnerRatio // ignore: cast_nullable_to_non_nullable
as double,freehandSmoothing: null == freehandSmoothing ? _self.freehandSmoothing : freehandSmoothing // ignore: cast_nullable_to_non_nullable
as double,lineStrokeWidth: null == lineStrokeWidth ? _self.lineStrokeWidth : lineStrokeWidth // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VxDocumentCopyWith<$Res> get document {
  
  return $VxDocumentCopyWith<$Res>(_self.document, (value) {
    return _then(_self.copyWith(document: value));
  });
}/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ViewportStateCopyWith<$Res> get viewport {
  
  return $ViewportStateCopyWith<$Res>(_self.viewport, (value) {
    return _then(_self.copyWith(viewport: value));
  });
}
}


/// Adds pattern-matching-related methods to [EditorState].
extension EditorStatePatterns on EditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditorState value)  $default,){
final _that = this;
switch (_that) {
case _EditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditorState value)?  $default,){
final _that = this;
switch (_that) {
case _EditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VxDocument document,  Set<String> selectedIds,  ActiveTool activeTool,  ViewportState viewport,  bool showGrid,  bool snapToGrid,  double gridSize,  String? editingTextId,  int polygonSides,  int starSpikes,  double starInnerRatio,  double freehandSmoothing,  double lineStrokeWidth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditorState() when $default != null:
return $default(_that.document,_that.selectedIds,_that.activeTool,_that.viewport,_that.showGrid,_that.snapToGrid,_that.gridSize,_that.editingTextId,_that.polygonSides,_that.starSpikes,_that.starInnerRatio,_that.freehandSmoothing,_that.lineStrokeWidth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VxDocument document,  Set<String> selectedIds,  ActiveTool activeTool,  ViewportState viewport,  bool showGrid,  bool snapToGrid,  double gridSize,  String? editingTextId,  int polygonSides,  int starSpikes,  double starInnerRatio,  double freehandSmoothing,  double lineStrokeWidth)  $default,) {final _that = this;
switch (_that) {
case _EditorState():
return $default(_that.document,_that.selectedIds,_that.activeTool,_that.viewport,_that.showGrid,_that.snapToGrid,_that.gridSize,_that.editingTextId,_that.polygonSides,_that.starSpikes,_that.starInnerRatio,_that.freehandSmoothing,_that.lineStrokeWidth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VxDocument document,  Set<String> selectedIds,  ActiveTool activeTool,  ViewportState viewport,  bool showGrid,  bool snapToGrid,  double gridSize,  String? editingTextId,  int polygonSides,  int starSpikes,  double starInnerRatio,  double freehandSmoothing,  double lineStrokeWidth)?  $default,) {final _that = this;
switch (_that) {
case _EditorState() when $default != null:
return $default(_that.document,_that.selectedIds,_that.activeTool,_that.viewport,_that.showGrid,_that.snapToGrid,_that.gridSize,_that.editingTextId,_that.polygonSides,_that.starSpikes,_that.starInnerRatio,_that.freehandSmoothing,_that.lineStrokeWidth);case _:
  return null;

}
}

}

/// @nodoc


class _EditorState implements EditorState {
  const _EditorState({required this.document, required final  Set<String> selectedIds, required this.activeTool, required this.viewport, required this.showGrid, required this.snapToGrid, required this.gridSize, this.editingTextId, this.polygonSides = 6, this.starSpikes = 5, this.starInnerRatio = 0.45, this.freehandSmoothing = 0.7, this.lineStrokeWidth = 1.5}): _selectedIds = selectedIds;
  

@override final  VxDocument document;
 final  Set<String> _selectedIds;
@override Set<String> get selectedIds {
  if (_selectedIds is EqualUnmodifiableSetView) return _selectedIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedIds);
}

@override final  ActiveTool activeTool;
@override final  ViewportState viewport;
@override final  bool showGrid;
@override final  bool snapToGrid;
@override final  double gridSize;
@override final  String? editingTextId;
@override@JsonKey() final  int polygonSides;
@override@JsonKey() final  int starSpikes;
@override@JsonKey() final  double starInnerRatio;
@override@JsonKey() final  double freehandSmoothing;
@override@JsonKey() final  double lineStrokeWidth;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditorStateCopyWith<_EditorState> get copyWith => __$EditorStateCopyWithImpl<_EditorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditorState&&(identical(other.document, document) || other.document == document)&&const DeepCollectionEquality().equals(other._selectedIds, _selectedIds)&&(identical(other.activeTool, activeTool) || other.activeTool == activeTool)&&(identical(other.viewport, viewport) || other.viewport == viewport)&&(identical(other.showGrid, showGrid) || other.showGrid == showGrid)&&(identical(other.snapToGrid, snapToGrid) || other.snapToGrid == snapToGrid)&&(identical(other.gridSize, gridSize) || other.gridSize == gridSize)&&(identical(other.editingTextId, editingTextId) || other.editingTextId == editingTextId)&&(identical(other.polygonSides, polygonSides) || other.polygonSides == polygonSides)&&(identical(other.starSpikes, starSpikes) || other.starSpikes == starSpikes)&&(identical(other.starInnerRatio, starInnerRatio) || other.starInnerRatio == starInnerRatio)&&(identical(other.freehandSmoothing, freehandSmoothing) || other.freehandSmoothing == freehandSmoothing)&&(identical(other.lineStrokeWidth, lineStrokeWidth) || other.lineStrokeWidth == lineStrokeWidth));
}


@override
int get hashCode => Object.hash(runtimeType,document,const DeepCollectionEquality().hash(_selectedIds),activeTool,viewport,showGrid,snapToGrid,gridSize,editingTextId,polygonSides,starSpikes,starInnerRatio,freehandSmoothing,lineStrokeWidth);

@override
String toString() {
  return 'EditorState(document: $document, selectedIds: $selectedIds, activeTool: $activeTool, viewport: $viewport, showGrid: $showGrid, snapToGrid: $snapToGrid, gridSize: $gridSize, editingTextId: $editingTextId, polygonSides: $polygonSides, starSpikes: $starSpikes, starInnerRatio: $starInnerRatio, freehandSmoothing: $freehandSmoothing, lineStrokeWidth: $lineStrokeWidth)';
}


}

/// @nodoc
abstract mixin class _$EditorStateCopyWith<$Res> implements $EditorStateCopyWith<$Res> {
  factory _$EditorStateCopyWith(_EditorState value, $Res Function(_EditorState) _then) = __$EditorStateCopyWithImpl;
@override @useResult
$Res call({
 VxDocument document, Set<String> selectedIds, ActiveTool activeTool, ViewportState viewport, bool showGrid, bool snapToGrid, double gridSize, String? editingTextId, int polygonSides, int starSpikes, double starInnerRatio, double freehandSmoothing, double lineStrokeWidth
});


@override $VxDocumentCopyWith<$Res> get document;@override $ViewportStateCopyWith<$Res> get viewport;

}
/// @nodoc
class __$EditorStateCopyWithImpl<$Res>
    implements _$EditorStateCopyWith<$Res> {
  __$EditorStateCopyWithImpl(this._self, this._then);

  final _EditorState _self;
  final $Res Function(_EditorState) _then;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? document = null,Object? selectedIds = null,Object? activeTool = null,Object? viewport = null,Object? showGrid = null,Object? snapToGrid = null,Object? gridSize = null,Object? editingTextId = freezed,Object? polygonSides = null,Object? starSpikes = null,Object? starInnerRatio = null,Object? freehandSmoothing = null,Object? lineStrokeWidth = null,}) {
  return _then(_EditorState(
document: null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as VxDocument,selectedIds: null == selectedIds ? _self._selectedIds : selectedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,activeTool: null == activeTool ? _self.activeTool : activeTool // ignore: cast_nullable_to_non_nullable
as ActiveTool,viewport: null == viewport ? _self.viewport : viewport // ignore: cast_nullable_to_non_nullable
as ViewportState,showGrid: null == showGrid ? _self.showGrid : showGrid // ignore: cast_nullable_to_non_nullable
as bool,snapToGrid: null == snapToGrid ? _self.snapToGrid : snapToGrid // ignore: cast_nullable_to_non_nullable
as bool,gridSize: null == gridSize ? _self.gridSize : gridSize // ignore: cast_nullable_to_non_nullable
as double,editingTextId: freezed == editingTextId ? _self.editingTextId : editingTextId // ignore: cast_nullable_to_non_nullable
as String?,polygonSides: null == polygonSides ? _self.polygonSides : polygonSides // ignore: cast_nullable_to_non_nullable
as int,starSpikes: null == starSpikes ? _self.starSpikes : starSpikes // ignore: cast_nullable_to_non_nullable
as int,starInnerRatio: null == starInnerRatio ? _self.starInnerRatio : starInnerRatio // ignore: cast_nullable_to_non_nullable
as double,freehandSmoothing: null == freehandSmoothing ? _self.freehandSmoothing : freehandSmoothing // ignore: cast_nullable_to_non_nullable
as double,lineStrokeWidth: null == lineStrokeWidth ? _self.lineStrokeWidth : lineStrokeWidth // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VxDocumentCopyWith<$Res> get document {
  
  return $VxDocumentCopyWith<$Res>(_self.document, (value) {
    return _then(_self.copyWith(document: value));
  });
}/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ViewportStateCopyWith<$Res> get viewport {
  
  return $ViewportStateCopyWith<$Res>(_self.viewport, (value) {
    return _then(_self.copyWith(viewport: value));
  });
}
}

// dart format on
