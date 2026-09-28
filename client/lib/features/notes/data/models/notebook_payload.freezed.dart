// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notebook_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotebookPayload {

 String get title; String get emoji;@ColorConverter() Color get colorValue;
/// Create a copy of NotebookPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotebookPayloadCopyWith<NotebookPayload> get copyWith => _$NotebookPayloadCopyWithImpl<NotebookPayload>(this as NotebookPayload, _$identity);

  /// Serializes this NotebookPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NotebookPayload;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotebookPayload&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.emoji, _this.emoji) || other.emoji == _this.emoji)&&(identical(other.colorValue, _this.colorValue) || other.colorValue == _this.colorValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotebookPayload;
  return Object.hash(runtimeType,_this.title,_this.emoji,_this.colorValue);
}

@override
String toString() {
  final _this = this as NotebookPayload;
  return 'NotebookPayload(title: ${_this.title}, emoji: ${_this.emoji}, colorValue: ${_this.colorValue})';
}


}

/// @nodoc
abstract mixin class $NotebookPayloadCopyWith<$Res>  {
  factory $NotebookPayloadCopyWith(NotebookPayload value, $Res Function(NotebookPayload) _then) = _$NotebookPayloadCopyWithImpl;
@useResult
$Res call({
 String title, String emoji,@ColorConverter() Color colorValue
});




}
/// @nodoc
class _$NotebookPayloadCopyWithImpl<$Res>
    implements $NotebookPayloadCopyWith<$Res> {
  _$NotebookPayloadCopyWithImpl(this._self, this._then);

  final NotebookPayload _self;
  final $Res Function(NotebookPayload) _then;

/// Create a copy of NotebookPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? emoji = null,Object? colorValue = null,}) {
  return _then(NotebookPayload(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}

}


/// Adds pattern-matching-related methods to [NotebookPayload].
extension NotebookPayloadPatterns on NotebookPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotebookPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotebookPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotebookPayload value)  $default,){
final _that = this;
switch (_that) {
case _NotebookPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotebookPayload value)?  $default,){
final _that = this;
switch (_that) {
case _NotebookPayload() when $default != null:
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
case _NotebookPayload() when $default != null:
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
case _NotebookPayload():
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
case _NotebookPayload() when $default != null:
return $default(_that.title,_that.emoji,_that.colorValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotebookPayload implements NotebookPayload {
  const _NotebookPayload({required this.title, required this.emoji, @ColorConverter() required this.colorValue});
  factory _NotebookPayload.fromJson(Map<String, dynamic> json) => _$NotebookPayloadFromJson(json);

@override final  String title;
@override final  String emoji;
@override@ColorConverter() final  Color colorValue;

/// Create a copy of NotebookPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotebookPayloadCopyWith<_NotebookPayload> get copyWith => __$NotebookPayloadCopyWithImpl<_NotebookPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotebookPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotebookPayload&&(identical(other.title, title) || other.title == title)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,title,emoji,colorValue);
}

@override
String toString() {
    return 'NotebookPayload(title: $title, emoji: $emoji, colorValue: $colorValue)';
}


}

/// @nodoc
abstract mixin class _$NotebookPayloadCopyWith<$Res> implements $NotebookPayloadCopyWith<$Res> {
  factory _$NotebookPayloadCopyWith(_NotebookPayload value, $Res Function(_NotebookPayload) _then) = __$NotebookPayloadCopyWithImpl;
@override @useResult
$Res call({
 String title, String emoji,@ColorConverter() Color colorValue
});




}
/// @nodoc
class __$NotebookPayloadCopyWithImpl<$Res>
    implements _$NotebookPayloadCopyWith<$Res> {
  __$NotebookPayloadCopyWithImpl(this._self, this._then);

  final _NotebookPayload _self;
  final $Res Function(_NotebookPayload) _then;

/// Create a copy of NotebookPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? emoji = null,Object? colorValue = null,}) {
  return _then(_NotebookPayload(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}


}

// dart format on
