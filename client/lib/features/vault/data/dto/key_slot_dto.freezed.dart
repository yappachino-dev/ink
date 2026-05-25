// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'key_slot_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KeySlotDto {

 KeyType get type;@Uint8ListConverter() Uint8List get salt;@Uint8ListConverter() Uint8List get wrappedMasterKey;@DateTimeUtcConverter() DateTime get updatedAt;
/// Create a copy of KeySlotDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeySlotDtoCopyWith<KeySlotDto> get copyWith => _$KeySlotDtoCopyWithImpl<KeySlotDto>(this as KeySlotDto, _$identity);

  /// Serializes this KeySlotDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeySlotDto&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.salt, salt)&&const DeepCollectionEquality().equals(other.wrappedMasterKey, wrappedMasterKey)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(salt),const DeepCollectionEquality().hash(wrappedMasterKey),updatedAt);

@override
String toString() {
  return 'KeySlotDto(type: $type, salt: $salt, wrappedMasterKey: $wrappedMasterKey, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $KeySlotDtoCopyWith<$Res>  {
  factory $KeySlotDtoCopyWith(KeySlotDto value, $Res Function(KeySlotDto) _then) = _$KeySlotDtoCopyWithImpl;
@useResult
$Res call({
 KeyType type,@Uint8ListConverter() Uint8List salt,@Uint8ListConverter() Uint8List wrappedMasterKey,@DateTimeUtcConverter() DateTime updatedAt
});




}
/// @nodoc
class _$KeySlotDtoCopyWithImpl<$Res>
    implements $KeySlotDtoCopyWith<$Res> {
  _$KeySlotDtoCopyWithImpl(this._self, this._then);

  final KeySlotDto _self;
  final $Res Function(KeySlotDto) _then;

/// Create a copy of KeySlotDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? salt = null,Object? wrappedMasterKey = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as KeyType,salt: null == salt ? _self.salt : salt // ignore: cast_nullable_to_non_nullable
as Uint8List,wrappedMasterKey: null == wrappedMasterKey ? _self.wrappedMasterKey : wrappedMasterKey // ignore: cast_nullable_to_non_nullable
as Uint8List,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [KeySlotDto].
extension KeySlotDtoPatterns on KeySlotDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeySlotDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeySlotDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeySlotDto value)  $default,){
final _that = this;
switch (_that) {
case _KeySlotDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeySlotDto value)?  $default,){
final _that = this;
switch (_that) {
case _KeySlotDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( KeyType type, @Uint8ListConverter()  Uint8List salt, @Uint8ListConverter()  Uint8List wrappedMasterKey, @DateTimeUtcConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeySlotDto() when $default != null:
return $default(_that.type,_that.salt,_that.wrappedMasterKey,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( KeyType type, @Uint8ListConverter()  Uint8List salt, @Uint8ListConverter()  Uint8List wrappedMasterKey, @DateTimeUtcConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _KeySlotDto():
return $default(_that.type,_that.salt,_that.wrappedMasterKey,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( KeyType type, @Uint8ListConverter()  Uint8List salt, @Uint8ListConverter()  Uint8List wrappedMasterKey, @DateTimeUtcConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _KeySlotDto() when $default != null:
return $default(_that.type,_that.salt,_that.wrappedMasterKey,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeySlotDto implements KeySlotDto {
  const _KeySlotDto({required this.type, @Uint8ListConverter() required this.salt, @Uint8ListConverter() required this.wrappedMasterKey, @DateTimeUtcConverter() required this.updatedAt});
  factory _KeySlotDto.fromJson(Map<String, dynamic> json) => _$KeySlotDtoFromJson(json);

@override final  KeyType type;
@override@Uint8ListConverter() final  Uint8List salt;
@override@Uint8ListConverter() final  Uint8List wrappedMasterKey;
@override@DateTimeUtcConverter() final  DateTime updatedAt;

/// Create a copy of KeySlotDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeySlotDtoCopyWith<_KeySlotDto> get copyWith => __$KeySlotDtoCopyWithImpl<_KeySlotDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeySlotDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeySlotDto&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.salt, salt)&&const DeepCollectionEquality().equals(other.wrappedMasterKey, wrappedMasterKey)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(salt),const DeepCollectionEquality().hash(wrappedMasterKey),updatedAt);

@override
String toString() {
  return 'KeySlotDto(type: $type, salt: $salt, wrappedMasterKey: $wrappedMasterKey, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$KeySlotDtoCopyWith<$Res> implements $KeySlotDtoCopyWith<$Res> {
  factory _$KeySlotDtoCopyWith(_KeySlotDto value, $Res Function(_KeySlotDto) _then) = __$KeySlotDtoCopyWithImpl;
@override @useResult
$Res call({
 KeyType type,@Uint8ListConverter() Uint8List salt,@Uint8ListConverter() Uint8List wrappedMasterKey,@DateTimeUtcConverter() DateTime updatedAt
});




}
/// @nodoc
class __$KeySlotDtoCopyWithImpl<$Res>
    implements _$KeySlotDtoCopyWith<$Res> {
  __$KeySlotDtoCopyWithImpl(this._self, this._then);

  final _KeySlotDto _self;
  final $Res Function(_KeySlotDto) _then;

/// Create a copy of KeySlotDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? salt = null,Object? wrappedMasterKey = null,Object? updatedAt = null,}) {
  return _then(_KeySlotDto(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as KeyType,salt: null == salt ? _self.salt : salt // ignore: cast_nullable_to_non_nullable
as Uint8List,wrappedMasterKey: null == wrappedMasterKey ? _self.wrappedMasterKey : wrappedMasterKey // ignore: cast_nullable_to_non_nullable
as Uint8List,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
