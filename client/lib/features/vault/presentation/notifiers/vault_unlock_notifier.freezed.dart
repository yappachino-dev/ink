// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vault_unlock_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VaultUnlockData {

 bool get isUnlocking; VaultFailure? get failure;
/// Create a copy of VaultUnlockData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VaultUnlockDataCopyWith<VaultUnlockData> get copyWith => _$VaultUnlockDataCopyWithImpl<VaultUnlockData>(this as VaultUnlockData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VaultUnlockData&&(identical(other.isUnlocking, isUnlocking) || other.isUnlocking == isUnlocking)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,isUnlocking,failure);

@override
String toString() {
  return 'VaultUnlockData(isUnlocking: $isUnlocking, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $VaultUnlockDataCopyWith<$Res>  {
  factory $VaultUnlockDataCopyWith(VaultUnlockData value, $Res Function(VaultUnlockData) _then) = _$VaultUnlockDataCopyWithImpl;
@useResult
$Res call({
 bool isUnlocking, VaultFailure? failure
});




}
/// @nodoc
class _$VaultUnlockDataCopyWithImpl<$Res>
    implements $VaultUnlockDataCopyWith<$Res> {
  _$VaultUnlockDataCopyWithImpl(this._self, this._then);

  final VaultUnlockData _self;
  final $Res Function(VaultUnlockData) _then;

/// Create a copy of VaultUnlockData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isUnlocking = null,Object? failure = freezed,}) {
  return _then(_self.copyWith(
isUnlocking: null == isUnlocking ? _self.isUnlocking : isUnlocking // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as VaultFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [VaultUnlockData].
extension VaultUnlockDataPatterns on VaultUnlockData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VaultUnlockData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VaultUnlockData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VaultUnlockData value)  $default,){
final _that = this;
switch (_that) {
case _VaultUnlockData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VaultUnlockData value)?  $default,){
final _that = this;
switch (_that) {
case _VaultUnlockData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isUnlocking,  VaultFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VaultUnlockData() when $default != null:
return $default(_that.isUnlocking,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isUnlocking,  VaultFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _VaultUnlockData():
return $default(_that.isUnlocking,_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isUnlocking,  VaultFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _VaultUnlockData() when $default != null:
return $default(_that.isUnlocking,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _VaultUnlockData implements VaultUnlockData {
  const _VaultUnlockData({this.isUnlocking = false, this.failure});
  

@override@JsonKey() final  bool isUnlocking;
@override final  VaultFailure? failure;

/// Create a copy of VaultUnlockData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VaultUnlockDataCopyWith<_VaultUnlockData> get copyWith => __$VaultUnlockDataCopyWithImpl<_VaultUnlockData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VaultUnlockData&&(identical(other.isUnlocking, isUnlocking) || other.isUnlocking == isUnlocking)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,isUnlocking,failure);

@override
String toString() {
  return 'VaultUnlockData(isUnlocking: $isUnlocking, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$VaultUnlockDataCopyWith<$Res> implements $VaultUnlockDataCopyWith<$Res> {
  factory _$VaultUnlockDataCopyWith(_VaultUnlockData value, $Res Function(_VaultUnlockData) _then) = __$VaultUnlockDataCopyWithImpl;
@override @useResult
$Res call({
 bool isUnlocking, VaultFailure? failure
});




}
/// @nodoc
class __$VaultUnlockDataCopyWithImpl<$Res>
    implements _$VaultUnlockDataCopyWith<$Res> {
  __$VaultUnlockDataCopyWithImpl(this._self, this._then);

  final _VaultUnlockData _self;
  final $Res Function(_VaultUnlockData) _then;

/// Create a copy of VaultUnlockData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isUnlocking = null,Object? failure = freezed,}) {
  return _then(_VaultUnlockData(
isUnlocking: null == isUnlocking ? _self.isUnlocking : isUnlocking // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as VaultFailure?,
  ));
}


}

// dart format on
