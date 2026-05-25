// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_verification_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RequestVerificationDto {

 String get email;
/// Create a copy of RequestVerificationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestVerificationDtoCopyWith<RequestVerificationDto> get copyWith => _$RequestVerificationDtoCopyWithImpl<RequestVerificationDto>(this as RequestVerificationDto, _$identity);

  /// Serializes this RequestVerificationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestVerificationDto&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'RequestVerificationDto(email: $email)';
}


}

/// @nodoc
abstract mixin class $RequestVerificationDtoCopyWith<$Res>  {
  factory $RequestVerificationDtoCopyWith(RequestVerificationDto value, $Res Function(RequestVerificationDto) _then) = _$RequestVerificationDtoCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$RequestVerificationDtoCopyWithImpl<$Res>
    implements $RequestVerificationDtoCopyWith<$Res> {
  _$RequestVerificationDtoCopyWithImpl(this._self, this._then);

  final RequestVerificationDto _self;
  final $Res Function(RequestVerificationDto) _then;

/// Create a copy of RequestVerificationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestVerificationDto].
extension RequestVerificationDtoPatterns on RequestVerificationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestVerificationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestVerificationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestVerificationDto value)  $default,){
final _that = this;
switch (_that) {
case _RequestVerificationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestVerificationDto value)?  $default,){
final _that = this;
switch (_that) {
case _RequestVerificationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestVerificationDto() when $default != null:
return $default(_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email)  $default,) {final _that = this;
switch (_that) {
case _RequestVerificationDto():
return $default(_that.email);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email)?  $default,) {final _that = this;
switch (_that) {
case _RequestVerificationDto() when $default != null:
return $default(_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestVerificationDto implements RequestVerificationDto {
  const _RequestVerificationDto({required this.email});
  factory _RequestVerificationDto.fromJson(Map<String, dynamic> json) => _$RequestVerificationDtoFromJson(json);

@override final  String email;

/// Create a copy of RequestVerificationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestVerificationDtoCopyWith<_RequestVerificationDto> get copyWith => __$RequestVerificationDtoCopyWithImpl<_RequestVerificationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestVerificationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestVerificationDto&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'RequestVerificationDto(email: $email)';
}


}

/// @nodoc
abstract mixin class _$RequestVerificationDtoCopyWith<$Res> implements $RequestVerificationDtoCopyWith<$Res> {
  factory _$RequestVerificationDtoCopyWith(_RequestVerificationDto value, $Res Function(_RequestVerificationDto) _then) = __$RequestVerificationDtoCopyWithImpl;
@override @useResult
$Res call({
 String email
});




}
/// @nodoc
class __$RequestVerificationDtoCopyWithImpl<$Res>
    implements _$RequestVerificationDtoCopyWith<$Res> {
  __$RequestVerificationDtoCopyWithImpl(this._self, this._then);

  final _RequestVerificationDto _self;
  final $Res Function(_RequestVerificationDto) _then;

/// Create a copy of RequestVerificationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(_RequestVerificationDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
