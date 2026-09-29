// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NoteMetadata {

 String get titlePreview; String get bodyPreview; DateTime? get dueDateDay; int get version;
/// Create a copy of NoteMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteMetadataCopyWith<NoteMetadata> get copyWith => _$NoteMetadataCopyWithImpl<NoteMetadata>(this as NoteMetadata, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NoteMetadata;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteMetadata&&(identical(other.titlePreview, _this.titlePreview) || other.titlePreview == _this.titlePreview)&&(identical(other.bodyPreview, _this.bodyPreview) || other.bodyPreview == _this.bodyPreview)&&(identical(other.dueDateDay, _this.dueDateDay) || other.dueDateDay == _this.dueDateDay)&&(identical(other.version, _this.version) || other.version == _this.version));
}


@override
int get hashCode {
  final _this = this as NoteMetadata;
  return Object.hash(runtimeType,_this.titlePreview,_this.bodyPreview,_this.dueDateDay,_this.version);
}

@override
String toString() {
  final _this = this as NoteMetadata;
  return 'NoteMetadata(titlePreview: ${_this.titlePreview}, bodyPreview: ${_this.bodyPreview}, dueDateDay: ${_this.dueDateDay}, version: ${_this.version})';
}


}

/// @nodoc
abstract mixin class $NoteMetadataCopyWith<$Res>  {
  factory $NoteMetadataCopyWith(NoteMetadata value, $Res Function(NoteMetadata) _then) = _$NoteMetadataCopyWithImpl;
@useResult
$Res call({
 String titlePreview, String bodyPreview, DateTime? dueDateDay, int version
});




}
/// @nodoc
class _$NoteMetadataCopyWithImpl<$Res>
    implements $NoteMetadataCopyWith<$Res> {
  _$NoteMetadataCopyWithImpl(this._self, this._then);

  final NoteMetadata _self;
  final $Res Function(NoteMetadata) _then;

/// Create a copy of NoteMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? titlePreview = null,Object? bodyPreview = null,Object? dueDateDay = freezed,Object? version = null,}) {
  return _then(NoteMetadata(
titlePreview: null == titlePreview ? _self.titlePreview : titlePreview // ignore: cast_nullable_to_non_nullable
as String,bodyPreview: null == bodyPreview ? _self.bodyPreview : bodyPreview // ignore: cast_nullable_to_non_nullable
as String,dueDateDay: freezed == dueDateDay ? _self.dueDateDay : dueDateDay // ignore: cast_nullable_to_non_nullable
as DateTime?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NoteMetadata].
extension NoteMetadataPatterns on NoteMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoteMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoteMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteMetadata value)  $default,){
final _that = this;
switch (_that) {
case _NoteMetadata():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _NoteMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String titlePreview,  String bodyPreview,  DateTime? dueDateDay,  int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteMetadata() when $default != null:
return $default(_that.titlePreview,_that.bodyPreview,_that.dueDateDay,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String titlePreview,  String bodyPreview,  DateTime? dueDateDay,  int version)  $default,) {final _that = this;
switch (_that) {
case _NoteMetadata():
return $default(_that.titlePreview,_that.bodyPreview,_that.dueDateDay,_that.version);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String titlePreview,  String bodyPreview,  DateTime? dueDateDay,  int version)?  $default,) {final _that = this;
switch (_that) {
case _NoteMetadata() when $default != null:
return $default(_that.titlePreview,_that.bodyPreview,_that.dueDateDay,_that.version);case _:
  return null;

}
}

}

/// @nodoc


class _NoteMetadata extends NoteMetadata {
  const _NoteMetadata({this.titlePreview = '', this.bodyPreview = '', this.dueDateDay, this.version = noteMetadataVersion}): super._();
  

@override@JsonKey() final  String titlePreview;
@override@JsonKey() final  String bodyPreview;
@override final  DateTime? dueDateDay;
@override@JsonKey() final  int version;

/// Create a copy of NoteMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteMetadataCopyWith<_NoteMetadata> get copyWith => __$NoteMetadataCopyWithImpl<_NoteMetadata>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteMetadata&&(identical(other.titlePreview, titlePreview) || other.titlePreview == titlePreview)&&(identical(other.bodyPreview, bodyPreview) || other.bodyPreview == bodyPreview)&&(identical(other.dueDateDay, dueDateDay) || other.dueDateDay == dueDateDay)&&(identical(other.version, version) || other.version == version));
}


@override
int get hashCode {
    return Object.hash(runtimeType,titlePreview,bodyPreview,dueDateDay,version);
}

@override
String toString() {
    return 'NoteMetadata(titlePreview: $titlePreview, bodyPreview: $bodyPreview, dueDateDay: $dueDateDay, version: $version)';
}


}

/// @nodoc
abstract mixin class _$NoteMetadataCopyWith<$Res> implements $NoteMetadataCopyWith<$Res> {
  factory _$NoteMetadataCopyWith(_NoteMetadata value, $Res Function(_NoteMetadata) _then) = __$NoteMetadataCopyWithImpl;
@override @useResult
$Res call({
 String titlePreview, String bodyPreview, DateTime? dueDateDay, int version
});




}
/// @nodoc
class __$NoteMetadataCopyWithImpl<$Res>
    implements _$NoteMetadataCopyWith<$Res> {
  __$NoteMetadataCopyWithImpl(this._self, this._then);

  final _NoteMetadata _self;
  final $Res Function(_NoteMetadata) _then;

/// Create a copy of NoteMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? titlePreview = null,Object? bodyPreview = null,Object? dueDateDay = freezed,Object? version = null,}) {
  return _then(_NoteMetadata(
titlePreview: null == titlePreview ? _self.titlePreview : titlePreview // ignore: cast_nullable_to_non_nullable
as String,bodyPreview: null == bodyPreview ? _self.bodyPreview : bodyPreview // ignore: cast_nullable_to_non_nullable
as String,dueDateDay: freezed == dueDateDay ? _self.dueDateDay : dueDateDay // ignore: cast_nullable_to_non_nullable
as DateTime?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
