// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'key_slots_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KeySlotsDto {

 List<KeySlotDto> get keys;
/// Create a copy of KeySlotsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeySlotsDtoCopyWith<KeySlotsDto> get copyWith => _$KeySlotsDtoCopyWithImpl<KeySlotsDto>(this as KeySlotsDto, _$identity);

  /// Serializes this KeySlotsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeySlotsDto&&const DeepCollectionEquality().equals(other.keys, keys));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(keys));

@override
String toString() {
  return 'KeySlotsDto(keys: $keys)';
}


}

/// @nodoc
abstract mixin class $KeySlotsDtoCopyWith<$Res>  {
  factory $KeySlotsDtoCopyWith(KeySlotsDto value, $Res Function(KeySlotsDto) _then) = _$KeySlotsDtoCopyWithImpl;
@useResult
$Res call({
 List<KeySlotDto> keys
});




}
/// @nodoc
class _$KeySlotsDtoCopyWithImpl<$Res>
    implements $KeySlotsDtoCopyWith<$Res> {
  _$KeySlotsDtoCopyWithImpl(this._self, this._then);

  final KeySlotsDto _self;
  final $Res Function(KeySlotsDto) _then;

/// Create a copy of KeySlotsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? keys = null,}) {
  return _then(_self.copyWith(
keys: null == keys ? _self.keys : keys // ignore: cast_nullable_to_non_nullable
as List<KeySlotDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [KeySlotsDto].
extension KeySlotsDtoPatterns on KeySlotsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeySlotsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeySlotsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeySlotsDto value)  $default,){
final _that = this;
switch (_that) {
case _KeySlotsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeySlotsDto value)?  $default,){
final _that = this;
switch (_that) {
case _KeySlotsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<KeySlotDto> keys)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeySlotsDto() when $default != null:
return $default(_that.keys);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<KeySlotDto> keys)  $default,) {final _that = this;
switch (_that) {
case _KeySlotsDto():
return $default(_that.keys);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<KeySlotDto> keys)?  $default,) {final _that = this;
switch (_that) {
case _KeySlotsDto() when $default != null:
return $default(_that.keys);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KeySlotsDto implements KeySlotsDto {
  const _KeySlotsDto({required final  List<KeySlotDto> keys}): _keys = keys;
  factory _KeySlotsDto.fromJson(Map<String, dynamic> json) => _$KeySlotsDtoFromJson(json);

 final  List<KeySlotDto> _keys;
@override List<KeySlotDto> get keys {
  if (_keys is EqualUnmodifiableListView) return _keys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keys);
}


/// Create a copy of KeySlotsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeySlotsDtoCopyWith<_KeySlotsDto> get copyWith => __$KeySlotsDtoCopyWithImpl<_KeySlotsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KeySlotsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeySlotsDto&&const DeepCollectionEquality().equals(other._keys, _keys));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_keys));

@override
String toString() {
  return 'KeySlotsDto(keys: $keys)';
}


}

/// @nodoc
abstract mixin class _$KeySlotsDtoCopyWith<$Res> implements $KeySlotsDtoCopyWith<$Res> {
  factory _$KeySlotsDtoCopyWith(_KeySlotsDto value, $Res Function(_KeySlotsDto) _then) = __$KeySlotsDtoCopyWithImpl;
@override @useResult
$Res call({
 List<KeySlotDto> keys
});




}
/// @nodoc
class __$KeySlotsDtoCopyWithImpl<$Res>
    implements _$KeySlotsDtoCopyWith<$Res> {
  __$KeySlotsDtoCopyWithImpl(this._self, this._then);

  final _KeySlotsDto _self;
  final $Res Function(_KeySlotsDto) _then;

/// Create a copy of KeySlotsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? keys = null,}) {
  return _then(_KeySlotsDto(
keys: null == keys ? _self._keys : keys // ignore: cast_nullable_to_non_nullable
as List<KeySlotDto>,
  ));
}


}

// dart format on
