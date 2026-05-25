// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'key_slot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KeySlot implements DiagnosticableTreeMixin {

 KeyType get type; Uint8List get salt; Uint8List get wrappedMasterKey; DateTime get updatedAt; SyncStatus get syncStatus;
/// Create a copy of KeySlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeySlotCopyWith<KeySlot> get copyWith => _$KeySlotCopyWithImpl<KeySlot>(this as KeySlot, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'KeySlot'))
    ..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('salt', salt))..add(DiagnosticsProperty('wrappedMasterKey', wrappedMasterKey))..add(DiagnosticsProperty('updatedAt', updatedAt))..add(DiagnosticsProperty('syncStatus', syncStatus));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeySlot&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.salt, salt)&&const DeepCollectionEquality().equals(other.wrappedMasterKey, wrappedMasterKey)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}


@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(salt),const DeepCollectionEquality().hash(wrappedMasterKey),updatedAt,syncStatus);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'KeySlot(type: $type, salt: $salt, wrappedMasterKey: $wrappedMasterKey, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $KeySlotCopyWith<$Res>  {
  factory $KeySlotCopyWith(KeySlot value, $Res Function(KeySlot) _then) = _$KeySlotCopyWithImpl;
@useResult
$Res call({
 KeyType type, Uint8List salt, Uint8List wrappedMasterKey, DateTime updatedAt, SyncStatus syncStatus
});




}
/// @nodoc
class _$KeySlotCopyWithImpl<$Res>
    implements $KeySlotCopyWith<$Res> {
  _$KeySlotCopyWithImpl(this._self, this._then);

  final KeySlot _self;
  final $Res Function(KeySlot) _then;

/// Create a copy of KeySlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? salt = null,Object? wrappedMasterKey = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as KeyType,salt: null == salt ? _self.salt : salt // ignore: cast_nullable_to_non_nullable
as Uint8List,wrappedMasterKey: null == wrappedMasterKey ? _self.wrappedMasterKey : wrappedMasterKey // ignore: cast_nullable_to_non_nullable
as Uint8List,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [KeySlot].
extension KeySlotPatterns on KeySlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeySlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeySlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeySlot value)  $default,){
final _that = this;
switch (_that) {
case _KeySlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeySlot value)?  $default,){
final _that = this;
switch (_that) {
case _KeySlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( KeyType type,  Uint8List salt,  Uint8List wrappedMasterKey,  DateTime updatedAt,  SyncStatus syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeySlot() when $default != null:
return $default(_that.type,_that.salt,_that.wrappedMasterKey,_that.updatedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( KeyType type,  Uint8List salt,  Uint8List wrappedMasterKey,  DateTime updatedAt,  SyncStatus syncStatus)  $default,) {final _that = this;
switch (_that) {
case _KeySlot():
return $default(_that.type,_that.salt,_that.wrappedMasterKey,_that.updatedAt,_that.syncStatus);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( KeyType type,  Uint8List salt,  Uint8List wrappedMasterKey,  DateTime updatedAt,  SyncStatus syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _KeySlot() when $default != null:
return $default(_that.type,_that.salt,_that.wrappedMasterKey,_that.updatedAt,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc


class _KeySlot with DiagnosticableTreeMixin implements KeySlot {
  const _KeySlot({required this.type, required this.salt, required this.wrappedMasterKey, required this.updatedAt, this.syncStatus = SyncStatus.modified});
  

@override final  KeyType type;
@override final  Uint8List salt;
@override final  Uint8List wrappedMasterKey;
@override final  DateTime updatedAt;
@override@JsonKey() final  SyncStatus syncStatus;

/// Create a copy of KeySlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeySlotCopyWith<_KeySlot> get copyWith => __$KeySlotCopyWithImpl<_KeySlot>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'KeySlot'))
    ..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('salt', salt))..add(DiagnosticsProperty('wrappedMasterKey', wrappedMasterKey))..add(DiagnosticsProperty('updatedAt', updatedAt))..add(DiagnosticsProperty('syncStatus', syncStatus));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeySlot&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.salt, salt)&&const DeepCollectionEquality().equals(other.wrappedMasterKey, wrappedMasterKey)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}


@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(salt),const DeepCollectionEquality().hash(wrappedMasterKey),updatedAt,syncStatus);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'KeySlot(type: $type, salt: $salt, wrappedMasterKey: $wrappedMasterKey, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$KeySlotCopyWith<$Res> implements $KeySlotCopyWith<$Res> {
  factory _$KeySlotCopyWith(_KeySlot value, $Res Function(_KeySlot) _then) = __$KeySlotCopyWithImpl;
@override @useResult
$Res call({
 KeyType type, Uint8List salt, Uint8List wrappedMasterKey, DateTime updatedAt, SyncStatus syncStatus
});




}
/// @nodoc
class __$KeySlotCopyWithImpl<$Res>
    implements _$KeySlotCopyWith<$Res> {
  __$KeySlotCopyWithImpl(this._self, this._then);

  final _KeySlot _self;
  final $Res Function(_KeySlot) _then;

/// Create a copy of KeySlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? salt = null,Object? wrappedMasterKey = null,Object? updatedAt = null,Object? syncStatus = null,}) {
  return _then(_KeySlot(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as KeyType,salt: null == salt ? _self.salt : salt // ignore: cast_nullable_to_non_nullable
as Uint8List,wrappedMasterKey: null == wrappedMasterKey ? _self.wrappedMasterKey : wrappedMasterKey // ignore: cast_nullable_to_non_nullable
as Uint8List,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,
  ));
}


}

// dart format on
