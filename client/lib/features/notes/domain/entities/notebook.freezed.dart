// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notebook.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Notebook {

 String get id; String get title; String get emoji; int get colorValue; int get localVersion; int get lastSyncedVersion; SyncStatus get syncStatus; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of Notebook
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotebookCopyWith<Notebook> get copyWith => _$NotebookCopyWithImpl<Notebook>(this as Notebook, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Notebook;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Notebook&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.emoji, _this.emoji) || other.emoji == _this.emoji)&&(identical(other.colorValue, _this.colorValue) || other.colorValue == _this.colorValue)&&(identical(other.localVersion, _this.localVersion) || other.localVersion == _this.localVersion)&&(identical(other.lastSyncedVersion, _this.lastSyncedVersion) || other.lastSyncedVersion == _this.lastSyncedVersion)&&(identical(other.syncStatus, _this.syncStatus) || other.syncStatus == _this.syncStatus)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}


@override
int get hashCode {
  final _this = this as Notebook;
  return Object.hash(runtimeType,_this.id,_this.title,_this.emoji,_this.colorValue,_this.localVersion,_this.lastSyncedVersion,_this.syncStatus,_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as Notebook;
  return 'Notebook(id: ${_this.id}, title: ${_this.title}, emoji: ${_this.emoji}, colorValue: ${_this.colorValue}, localVersion: ${_this.localVersion}, lastSyncedVersion: ${_this.lastSyncedVersion}, syncStatus: ${_this.syncStatus}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $NotebookCopyWith<$Res>  {
  factory $NotebookCopyWith(Notebook value, $Res Function(Notebook) _then) = _$NotebookCopyWithImpl;
@useResult
$Res call({
 String id, String title, String emoji, int colorValue, int localVersion, int lastSyncedVersion, SyncStatus syncStatus, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$NotebookCopyWithImpl<$Res>
    implements $NotebookCopyWith<$Res> {
  _$NotebookCopyWithImpl(this._self, this._then);

  final Notebook _self;
  final $Res Function(Notebook) _then;

/// Create a copy of Notebook
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? emoji = null,Object? colorValue = null,Object? localVersion = null,Object? lastSyncedVersion = null,Object? syncStatus = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(Notebook(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,localVersion: null == localVersion ? _self.localVersion : localVersion // ignore: cast_nullable_to_non_nullable
as int,lastSyncedVersion: null == lastSyncedVersion ? _self.lastSyncedVersion : lastSyncedVersion // ignore: cast_nullable_to_non_nullable
as int,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Notebook].
extension NotebookPatterns on Notebook {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Notebook value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Notebook() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Notebook value)  $default,){
final _that = this;
switch (_that) {
case _Notebook():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Notebook value)?  $default,){
final _that = this;
switch (_that) {
case _Notebook() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String emoji,  int colorValue,  int localVersion,  int lastSyncedVersion,  SyncStatus syncStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Notebook() when $default != null:
return $default(_that.id,_that.title,_that.emoji,_that.colorValue,_that.localVersion,_that.lastSyncedVersion,_that.syncStatus,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String emoji,  int colorValue,  int localVersion,  int lastSyncedVersion,  SyncStatus syncStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Notebook():
return $default(_that.id,_that.title,_that.emoji,_that.colorValue,_that.localVersion,_that.lastSyncedVersion,_that.syncStatus,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String emoji,  int colorValue,  int localVersion,  int lastSyncedVersion,  SyncStatus syncStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Notebook() when $default != null:
return $default(_that.id,_that.title,_that.emoji,_that.colorValue,_that.localVersion,_that.lastSyncedVersion,_that.syncStatus,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Notebook extends Notebook {
  const _Notebook({required this.id, required this.title, required this.emoji, required this.colorValue, required this.localVersion, required this.lastSyncedVersion, required this.syncStatus, required this.createdAt, required this.updatedAt, this.deletedAt}): super._();
  

@override final  String id;
@override final  String title;
@override final  String emoji;
@override final  int colorValue;
@override final  int localVersion;
@override final  int lastSyncedVersion;
@override final  SyncStatus syncStatus;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of Notebook
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotebookCopyWith<_Notebook> get copyWith => __$NotebookCopyWithImpl<_Notebook>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Notebook&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.localVersion, localVersion) || other.localVersion == localVersion)&&(identical(other.lastSyncedVersion, lastSyncedVersion) || other.lastSyncedVersion == lastSyncedVersion)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,emoji,colorValue,localVersion,lastSyncedVersion,syncStatus,createdAt,updatedAt,deletedAt);
}

@override
String toString() {
    return 'Notebook(id: $id, title: $title, emoji: $emoji, colorValue: $colorValue, localVersion: $localVersion, lastSyncedVersion: $lastSyncedVersion, syncStatus: $syncStatus, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$NotebookCopyWith<$Res> implements $NotebookCopyWith<$Res> {
  factory _$NotebookCopyWith(_Notebook value, $Res Function(_Notebook) _then) = __$NotebookCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String emoji, int colorValue, int localVersion, int lastSyncedVersion, SyncStatus syncStatus, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$NotebookCopyWithImpl<$Res>
    implements _$NotebookCopyWith<$Res> {
  __$NotebookCopyWithImpl(this._self, this._then);

  final _Notebook _self;
  final $Res Function(_Notebook) _then;

/// Create a copy of Notebook
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? emoji = null,Object? colorValue = null,Object? localVersion = null,Object? lastSyncedVersion = null,Object? syncStatus = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_Notebook(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,localVersion: null == localVersion ? _self.localVersion : localVersion // ignore: cast_nullable_to_non_nullable
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
