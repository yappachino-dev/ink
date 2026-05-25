// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'encrypted_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EncryptedNote {

 String get id; Uint8List get encryptedTitle; Uint8List get encryptedContent; int get localVersion; int get lastSyncedVersion; SyncStatus get syncStatus; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; String? get projectId;
/// Create a copy of EncryptedNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncryptedNoteCopyWith<EncryptedNote> get copyWith => _$EncryptedNoteCopyWithImpl<EncryptedNote>(this as EncryptedNote, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncryptedNote&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.encryptedTitle, encryptedTitle)&&const DeepCollectionEquality().equals(other.encryptedContent, encryptedContent)&&(identical(other.localVersion, localVersion) || other.localVersion == localVersion)&&(identical(other.lastSyncedVersion, lastSyncedVersion) || other.lastSyncedVersion == lastSyncedVersion)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.projectId, projectId) || other.projectId == projectId));
}


@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(encryptedTitle),const DeepCollectionEquality().hash(encryptedContent),localVersion,lastSyncedVersion,syncStatus,createdAt,updatedAt,deletedAt,projectId);

@override
String toString() {
  return 'EncryptedNote(id: $id, encryptedTitle: $encryptedTitle, encryptedContent: $encryptedContent, localVersion: $localVersion, lastSyncedVersion: $lastSyncedVersion, syncStatus: $syncStatus, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, projectId: $projectId)';
}


}

/// @nodoc
abstract mixin class $EncryptedNoteCopyWith<$Res>  {
  factory $EncryptedNoteCopyWith(EncryptedNote value, $Res Function(EncryptedNote) _then) = _$EncryptedNoteCopyWithImpl;
@useResult
$Res call({
 String id, Uint8List encryptedTitle, Uint8List encryptedContent, int localVersion, int lastSyncedVersion, SyncStatus syncStatus, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String? projectId
});




}
/// @nodoc
class _$EncryptedNoteCopyWithImpl<$Res>
    implements $EncryptedNoteCopyWith<$Res> {
  _$EncryptedNoteCopyWithImpl(this._self, this._then);

  final EncryptedNote _self;
  final $Res Function(EncryptedNote) _then;

/// Create a copy of EncryptedNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? encryptedTitle = null,Object? encryptedContent = null,Object? localVersion = null,Object? lastSyncedVersion = null,Object? syncStatus = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? projectId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,encryptedTitle: null == encryptedTitle ? _self.encryptedTitle : encryptedTitle // ignore: cast_nullable_to_non_nullable
as Uint8List,encryptedContent: null == encryptedContent ? _self.encryptedContent : encryptedContent // ignore: cast_nullable_to_non_nullable
as Uint8List,localVersion: null == localVersion ? _self.localVersion : localVersion // ignore: cast_nullable_to_non_nullable
as int,lastSyncedVersion: null == lastSyncedVersion ? _self.lastSyncedVersion : lastSyncedVersion // ignore: cast_nullable_to_non_nullable
as int,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EncryptedNote].
extension EncryptedNotePatterns on EncryptedNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EncryptedNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EncryptedNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EncryptedNote value)  $default,){
final _that = this;
switch (_that) {
case _EncryptedNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EncryptedNote value)?  $default,){
final _that = this;
switch (_that) {
case _EncryptedNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Uint8List encryptedTitle,  Uint8List encryptedContent,  int localVersion,  int lastSyncedVersion,  SyncStatus syncStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String? projectId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EncryptedNote() when $default != null:
return $default(_that.id,_that.encryptedTitle,_that.encryptedContent,_that.localVersion,_that.lastSyncedVersion,_that.syncStatus,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.projectId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Uint8List encryptedTitle,  Uint8List encryptedContent,  int localVersion,  int lastSyncedVersion,  SyncStatus syncStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String? projectId)  $default,) {final _that = this;
switch (_that) {
case _EncryptedNote():
return $default(_that.id,_that.encryptedTitle,_that.encryptedContent,_that.localVersion,_that.lastSyncedVersion,_that.syncStatus,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.projectId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Uint8List encryptedTitle,  Uint8List encryptedContent,  int localVersion,  int lastSyncedVersion,  SyncStatus syncStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String? projectId)?  $default,) {final _that = this;
switch (_that) {
case _EncryptedNote() when $default != null:
return $default(_that.id,_that.encryptedTitle,_that.encryptedContent,_that.localVersion,_that.lastSyncedVersion,_that.syncStatus,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.projectId);case _:
  return null;

}
}

}

/// @nodoc


class _EncryptedNote extends EncryptedNote {
  const _EncryptedNote({required this.id, required this.encryptedTitle, required this.encryptedContent, required this.localVersion, required this.lastSyncedVersion, required this.syncStatus, required this.createdAt, required this.updatedAt, this.deletedAt, this.projectId}): super._();
  

@override final  String id;
@override final  Uint8List encryptedTitle;
@override final  Uint8List encryptedContent;
@override final  int localVersion;
@override final  int lastSyncedVersion;
@override final  SyncStatus syncStatus;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
@override final  String? projectId;

/// Create a copy of EncryptedNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncryptedNoteCopyWith<_EncryptedNote> get copyWith => __$EncryptedNoteCopyWithImpl<_EncryptedNote>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EncryptedNote&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.encryptedTitle, encryptedTitle)&&const DeepCollectionEquality().equals(other.encryptedContent, encryptedContent)&&(identical(other.localVersion, localVersion) || other.localVersion == localVersion)&&(identical(other.lastSyncedVersion, lastSyncedVersion) || other.lastSyncedVersion == lastSyncedVersion)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.projectId, projectId) || other.projectId == projectId));
}


@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(encryptedTitle),const DeepCollectionEquality().hash(encryptedContent),localVersion,lastSyncedVersion,syncStatus,createdAt,updatedAt,deletedAt,projectId);

@override
String toString() {
  return 'EncryptedNote(id: $id, encryptedTitle: $encryptedTitle, encryptedContent: $encryptedContent, localVersion: $localVersion, lastSyncedVersion: $lastSyncedVersion, syncStatus: $syncStatus, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, projectId: $projectId)';
}


}

/// @nodoc
abstract mixin class _$EncryptedNoteCopyWith<$Res> implements $EncryptedNoteCopyWith<$Res> {
  factory _$EncryptedNoteCopyWith(_EncryptedNote value, $Res Function(_EncryptedNote) _then) = __$EncryptedNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, Uint8List encryptedTitle, Uint8List encryptedContent, int localVersion, int lastSyncedVersion, SyncStatus syncStatus, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String? projectId
});




}
/// @nodoc
class __$EncryptedNoteCopyWithImpl<$Res>
    implements _$EncryptedNoteCopyWith<$Res> {
  __$EncryptedNoteCopyWithImpl(this._self, this._then);

  final _EncryptedNote _self;
  final $Res Function(_EncryptedNote) _then;

/// Create a copy of EncryptedNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? encryptedTitle = null,Object? encryptedContent = null,Object? localVersion = null,Object? lastSyncedVersion = null,Object? syncStatus = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? projectId = freezed,}) {
  return _then(_EncryptedNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,encryptedTitle: null == encryptedTitle ? _self.encryptedTitle : encryptedTitle // ignore: cast_nullable_to_non_nullable
as Uint8List,encryptedContent: null == encryptedContent ? _self.encryptedContent : encryptedContent // ignore: cast_nullable_to_non_nullable
as Uint8List,localVersion: null == localVersion ? _self.localVersion : localVersion // ignore: cast_nullable_to_non_nullable
as int,lastSyncedVersion: null == lastSyncedVersion ? _self.lastSyncedVersion : lastSyncedVersion // ignore: cast_nullable_to_non_nullable
as int,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
