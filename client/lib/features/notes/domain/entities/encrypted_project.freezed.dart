// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'encrypted_project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EncryptedProject {

 String get id; Uint8List get encryptedContent; int get localVersion; int get lastSyncedVersion; SyncStatus get syncStatus; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of EncryptedProject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncryptedProjectCopyWith<EncryptedProject> get copyWith => _$EncryptedProjectCopyWithImpl<EncryptedProject>(this as EncryptedProject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncryptedProject&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.encryptedContent, encryptedContent)&&(identical(other.localVersion, localVersion) || other.localVersion == localVersion)&&(identical(other.lastSyncedVersion, lastSyncedVersion) || other.lastSyncedVersion == lastSyncedVersion)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(encryptedContent),localVersion,lastSyncedVersion,syncStatus,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'EncryptedProject(id: $id, encryptedContent: $encryptedContent, localVersion: $localVersion, lastSyncedVersion: $lastSyncedVersion, syncStatus: $syncStatus, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $EncryptedProjectCopyWith<$Res>  {
  factory $EncryptedProjectCopyWith(EncryptedProject value, $Res Function(EncryptedProject) _then) = _$EncryptedProjectCopyWithImpl;
@useResult
$Res call({
 String id, Uint8List encryptedContent, int localVersion, int lastSyncedVersion, SyncStatus syncStatus, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$EncryptedProjectCopyWithImpl<$Res>
    implements $EncryptedProjectCopyWith<$Res> {
  _$EncryptedProjectCopyWithImpl(this._self, this._then);

  final EncryptedProject _self;
  final $Res Function(EncryptedProject) _then;

/// Create a copy of EncryptedProject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? encryptedContent = null,Object? localVersion = null,Object? lastSyncedVersion = null,Object? syncStatus = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,encryptedContent: null == encryptedContent ? _self.encryptedContent : encryptedContent // ignore: cast_nullable_to_non_nullable
as Uint8List,localVersion: null == localVersion ? _self.localVersion : localVersion // ignore: cast_nullable_to_non_nullable
as int,lastSyncedVersion: null == lastSyncedVersion ? _self.lastSyncedVersion : lastSyncedVersion // ignore: cast_nullable_to_non_nullable
as int,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EncryptedProject].
extension EncryptedProjectPatterns on EncryptedProject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EncryptedProject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EncryptedProject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EncryptedProject value)  $default,){
final _that = this;
switch (_that) {
case _EncryptedProject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EncryptedProject value)?  $default,){
final _that = this;
switch (_that) {
case _EncryptedProject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Uint8List encryptedContent,  int localVersion,  int lastSyncedVersion,  SyncStatus syncStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EncryptedProject() when $default != null:
return $default(_that.id,_that.encryptedContent,_that.localVersion,_that.lastSyncedVersion,_that.syncStatus,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Uint8List encryptedContent,  int localVersion,  int lastSyncedVersion,  SyncStatus syncStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _EncryptedProject():
return $default(_that.id,_that.encryptedContent,_that.localVersion,_that.lastSyncedVersion,_that.syncStatus,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Uint8List encryptedContent,  int localVersion,  int lastSyncedVersion,  SyncStatus syncStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _EncryptedProject() when $default != null:
return $default(_that.id,_that.encryptedContent,_that.localVersion,_that.lastSyncedVersion,_that.syncStatus,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _EncryptedProject extends EncryptedProject {
  const _EncryptedProject({required this.id, required this.encryptedContent, required this.localVersion, required this.lastSyncedVersion, required this.syncStatus, required this.createdAt, required this.updatedAt, this.deletedAt}): super._();
  

@override final  String id;
@override final  Uint8List encryptedContent;
@override final  int localVersion;
@override final  int lastSyncedVersion;
@override final  SyncStatus syncStatus;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of EncryptedProject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncryptedProjectCopyWith<_EncryptedProject> get copyWith => __$EncryptedProjectCopyWithImpl<_EncryptedProject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EncryptedProject&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.encryptedContent, encryptedContent)&&(identical(other.localVersion, localVersion) || other.localVersion == localVersion)&&(identical(other.lastSyncedVersion, lastSyncedVersion) || other.lastSyncedVersion == lastSyncedVersion)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(encryptedContent),localVersion,lastSyncedVersion,syncStatus,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'EncryptedProject(id: $id, encryptedContent: $encryptedContent, localVersion: $localVersion, lastSyncedVersion: $lastSyncedVersion, syncStatus: $syncStatus, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$EncryptedProjectCopyWith<$Res> implements $EncryptedProjectCopyWith<$Res> {
  factory _$EncryptedProjectCopyWith(_EncryptedProject value, $Res Function(_EncryptedProject) _then) = __$EncryptedProjectCopyWithImpl;
@override @useResult
$Res call({
 String id, Uint8List encryptedContent, int localVersion, int lastSyncedVersion, SyncStatus syncStatus, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$EncryptedProjectCopyWithImpl<$Res>
    implements _$EncryptedProjectCopyWith<$Res> {
  __$EncryptedProjectCopyWithImpl(this._self, this._then);

  final _EncryptedProject _self;
  final $Res Function(_EncryptedProject) _then;

/// Create a copy of EncryptedProject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? encryptedContent = null,Object? localVersion = null,Object? lastSyncedVersion = null,Object? syncStatus = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_EncryptedProject(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,encryptedContent: null == encryptedContent ? _self.encryptedContent : encryptedContent // ignore: cast_nullable_to_non_nullable
as Uint8List,localVersion: null == localVersion ? _self.localVersion : localVersion // ignore: cast_nullable_to_non_nullable
as int,lastSyncedVersion: null == lastSyncedVersion ? _self.lastSyncedVersion : lastSyncedVersion // ignore: cast_nullable_to_non_nullable
as int,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
