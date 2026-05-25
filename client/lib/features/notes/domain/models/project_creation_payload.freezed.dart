// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_creation_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProjectCreationPayload {

 String get title; String get emoji; Color get color;
/// Create a copy of ProjectCreationPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectCreationPayloadCopyWith<ProjectCreationPayload> get copyWith => _$ProjectCreationPayloadCopyWithImpl<ProjectCreationPayload>(this as ProjectCreationPayload, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectCreationPayload&&(identical(other.title, title) || other.title == title)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,title,emoji,color);

@override
String toString() {
  return 'ProjectCreationPayload(title: $title, emoji: $emoji, color: $color)';
}


}

/// @nodoc
abstract mixin class $ProjectCreationPayloadCopyWith<$Res>  {
  factory $ProjectCreationPayloadCopyWith(ProjectCreationPayload value, $Res Function(ProjectCreationPayload) _then) = _$ProjectCreationPayloadCopyWithImpl;
@useResult
$Res call({
 String title, String emoji, Color color
});




}
/// @nodoc
class _$ProjectCreationPayloadCopyWithImpl<$Res>
    implements $ProjectCreationPayloadCopyWith<$Res> {
  _$ProjectCreationPayloadCopyWithImpl(this._self, this._then);

  final ProjectCreationPayload _self;
  final $Res Function(ProjectCreationPayload) _then;

/// Create a copy of ProjectCreationPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? emoji = null,Object? color = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectCreationPayload].
extension ProjectCreationPayloadPatterns on ProjectCreationPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectCreationPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectCreationPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectCreationPayload value)  $default,){
final _that = this;
switch (_that) {
case _ProjectCreationPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectCreationPayload value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectCreationPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String emoji,  Color color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectCreationPayload() when $default != null:
return $default(_that.title,_that.emoji,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String emoji,  Color color)  $default,) {final _that = this;
switch (_that) {
case _ProjectCreationPayload():
return $default(_that.title,_that.emoji,_that.color);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String emoji,  Color color)?  $default,) {final _that = this;
switch (_that) {
case _ProjectCreationPayload() when $default != null:
return $default(_that.title,_that.emoji,_that.color);case _:
  return null;

}
}

}

/// @nodoc


class _ProjectCreationPayload implements ProjectCreationPayload {
  const _ProjectCreationPayload({required this.title, required this.emoji, required this.color});
  

@override final  String title;
@override final  String emoji;
@override final  Color color;

/// Create a copy of ProjectCreationPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectCreationPayloadCopyWith<_ProjectCreationPayload> get copyWith => __$ProjectCreationPayloadCopyWithImpl<_ProjectCreationPayload>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectCreationPayload&&(identical(other.title, title) || other.title == title)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,title,emoji,color);

@override
String toString() {
  return 'ProjectCreationPayload(title: $title, emoji: $emoji, color: $color)';
}


}

/// @nodoc
abstract mixin class _$ProjectCreationPayloadCopyWith<$Res> implements $ProjectCreationPayloadCopyWith<$Res> {
  factory _$ProjectCreationPayloadCopyWith(_ProjectCreationPayload value, $Res Function(_ProjectCreationPayload) _then) = __$ProjectCreationPayloadCopyWithImpl;
@override @useResult
$Res call({
 String title, String emoji, Color color
});




}
/// @nodoc
class __$ProjectCreationPayloadCopyWithImpl<$Res>
    implements _$ProjectCreationPayloadCopyWith<$Res> {
  __$ProjectCreationPayloadCopyWithImpl(this._self, this._then);

  final _ProjectCreationPayload _self;
  final $Res Function(_ProjectCreationPayload) _then;

/// Create a copy of ProjectCreationPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? emoji = null,Object? color = null,}) {
  return _then(_ProjectCreationPayload(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}


}

// dart format on
