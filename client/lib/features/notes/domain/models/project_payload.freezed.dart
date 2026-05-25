// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectPayload {

 String get title; String get emoji;@ColorConverter() Color get colorValue;
/// Create a copy of ProjectPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectPayloadCopyWith<ProjectPayload> get copyWith => _$ProjectPayloadCopyWithImpl<ProjectPayload>(this as ProjectPayload, _$identity);

  /// Serializes this ProjectPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectPayload&&(identical(other.title, title) || other.title == title)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,emoji,colorValue);

@override
String toString() {
  return 'ProjectPayload(title: $title, emoji: $emoji, colorValue: $colorValue)';
}


}

/// @nodoc
abstract mixin class $ProjectPayloadCopyWith<$Res>  {
  factory $ProjectPayloadCopyWith(ProjectPayload value, $Res Function(ProjectPayload) _then) = _$ProjectPayloadCopyWithImpl;
@useResult
$Res call({
 String title, String emoji,@ColorConverter() Color colorValue
});




}
/// @nodoc
class _$ProjectPayloadCopyWithImpl<$Res>
    implements $ProjectPayloadCopyWith<$Res> {
  _$ProjectPayloadCopyWithImpl(this._self, this._then);

  final ProjectPayload _self;
  final $Res Function(ProjectPayload) _then;

/// Create a copy of ProjectPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? emoji = null,Object? colorValue = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectPayload].
extension ProjectPayloadPatterns on ProjectPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectPayload value)  $default,){
final _that = this;
switch (_that) {
case _ProjectPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectPayload value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String emoji, @ColorConverter()  Color colorValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectPayload() when $default != null:
return $default(_that.title,_that.emoji,_that.colorValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String emoji, @ColorConverter()  Color colorValue)  $default,) {final _that = this;
switch (_that) {
case _ProjectPayload():
return $default(_that.title,_that.emoji,_that.colorValue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String emoji, @ColorConverter()  Color colorValue)?  $default,) {final _that = this;
switch (_that) {
case _ProjectPayload() when $default != null:
return $default(_that.title,_that.emoji,_that.colorValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectPayload implements ProjectPayload {
  const _ProjectPayload({required this.title, required this.emoji, @ColorConverter() required this.colorValue});
  factory _ProjectPayload.fromJson(Map<String, dynamic> json) => _$ProjectPayloadFromJson(json);

@override final  String title;
@override final  String emoji;
@override@ColorConverter() final  Color colorValue;

/// Create a copy of ProjectPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectPayloadCopyWith<_ProjectPayload> get copyWith => __$ProjectPayloadCopyWithImpl<_ProjectPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectPayload&&(identical(other.title, title) || other.title == title)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,emoji,colorValue);

@override
String toString() {
  return 'ProjectPayload(title: $title, emoji: $emoji, colorValue: $colorValue)';
}


}

/// @nodoc
abstract mixin class _$ProjectPayloadCopyWith<$Res> implements $ProjectPayloadCopyWith<$Res> {
  factory _$ProjectPayloadCopyWith(_ProjectPayload value, $Res Function(_ProjectPayload) _then) = __$ProjectPayloadCopyWithImpl;
@override @useResult
$Res call({
 String title, String emoji,@ColorConverter() Color colorValue
});




}
/// @nodoc
class __$ProjectPayloadCopyWithImpl<$Res>
    implements _$ProjectPayloadCopyWith<$Res> {
  __$ProjectPayloadCopyWithImpl(this._self, this._then);

  final _ProjectPayload _self;
  final $Res Function(_ProjectPayload) _then;

/// Create a copy of ProjectPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? emoji = null,Object? colorValue = null,}) {
  return _then(_ProjectPayload(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}


}

// dart format on
