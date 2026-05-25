// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_creation_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NoteCreationPayload {

 String get title; Document get content; String? get projectId; DateTime? get dueDate; TimeOfDay? get dueTime; TaskPriority get priority; int? get reminderMinutesBefore;
/// Create a copy of NoteCreationPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteCreationPayloadCopyWith<NoteCreationPayload> get copyWith => _$NoteCreationPayloadCopyWithImpl<NoteCreationPayload>(this as NoteCreationPayload, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteCreationPayload&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.dueTime, dueTime) || other.dueTime == dueTime)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.reminderMinutesBefore, reminderMinutesBefore) || other.reminderMinutesBefore == reminderMinutesBefore));
}


@override
int get hashCode => Object.hash(runtimeType,title,content,projectId,dueDate,dueTime,priority,reminderMinutesBefore);

@override
String toString() {
  return 'NoteCreationPayload(title: $title, content: $content, projectId: $projectId, dueDate: $dueDate, dueTime: $dueTime, priority: $priority, reminderMinutesBefore: $reminderMinutesBefore)';
}


}

/// @nodoc
abstract mixin class $NoteCreationPayloadCopyWith<$Res>  {
  factory $NoteCreationPayloadCopyWith(NoteCreationPayload value, $Res Function(NoteCreationPayload) _then) = _$NoteCreationPayloadCopyWithImpl;
@useResult
$Res call({
 String title, Document content, String? projectId, DateTime? dueDate, TimeOfDay? dueTime, TaskPriority priority, int? reminderMinutesBefore
});




}
/// @nodoc
class _$NoteCreationPayloadCopyWithImpl<$Res>
    implements $NoteCreationPayloadCopyWith<$Res> {
  _$NoteCreationPayloadCopyWithImpl(this._self, this._then);

  final NoteCreationPayload _self;
  final $Res Function(NoteCreationPayload) _then;

/// Create a copy of NoteCreationPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? content = null,Object? projectId = freezed,Object? dueDate = freezed,Object? dueTime = freezed,Object? priority = null,Object? reminderMinutesBefore = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as Document,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dueTime: freezed == dueTime ? _self.dueTime : dueTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,reminderMinutesBefore: freezed == reminderMinutesBefore ? _self.reminderMinutesBefore : reminderMinutesBefore // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [NoteCreationPayload].
extension NoteCreationPayloadPatterns on NoteCreationPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoteCreationPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoteCreationPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteCreationPayload value)  $default,){
final _that = this;
switch (_that) {
case _NoteCreationPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteCreationPayload value)?  $default,){
final _that = this;
switch (_that) {
case _NoteCreationPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  Document content,  String? projectId,  DateTime? dueDate,  TimeOfDay? dueTime,  TaskPriority priority,  int? reminderMinutesBefore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteCreationPayload() when $default != null:
return $default(_that.title,_that.content,_that.projectId,_that.dueDate,_that.dueTime,_that.priority,_that.reminderMinutesBefore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  Document content,  String? projectId,  DateTime? dueDate,  TimeOfDay? dueTime,  TaskPriority priority,  int? reminderMinutesBefore)  $default,) {final _that = this;
switch (_that) {
case _NoteCreationPayload():
return $default(_that.title,_that.content,_that.projectId,_that.dueDate,_that.dueTime,_that.priority,_that.reminderMinutesBefore);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  Document content,  String? projectId,  DateTime? dueDate,  TimeOfDay? dueTime,  TaskPriority priority,  int? reminderMinutesBefore)?  $default,) {final _that = this;
switch (_that) {
case _NoteCreationPayload() when $default != null:
return $default(_that.title,_that.content,_that.projectId,_that.dueDate,_that.dueTime,_that.priority,_that.reminderMinutesBefore);case _:
  return null;

}
}

}

/// @nodoc


class _NoteCreationPayload implements NoteCreationPayload {
  const _NoteCreationPayload({required this.title, required this.content, this.projectId, this.dueDate, this.dueTime, this.priority = TaskPriority.none, this.reminderMinutesBefore});
  

@override final  String title;
@override final  Document content;
@override final  String? projectId;
@override final  DateTime? dueDate;
@override final  TimeOfDay? dueTime;
@override@JsonKey() final  TaskPriority priority;
@override final  int? reminderMinutesBefore;

/// Create a copy of NoteCreationPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteCreationPayloadCopyWith<_NoteCreationPayload> get copyWith => __$NoteCreationPayloadCopyWithImpl<_NoteCreationPayload>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteCreationPayload&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.dueTime, dueTime) || other.dueTime == dueTime)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.reminderMinutesBefore, reminderMinutesBefore) || other.reminderMinutesBefore == reminderMinutesBefore));
}


@override
int get hashCode => Object.hash(runtimeType,title,content,projectId,dueDate,dueTime,priority,reminderMinutesBefore);

@override
String toString() {
  return 'NoteCreationPayload(title: $title, content: $content, projectId: $projectId, dueDate: $dueDate, dueTime: $dueTime, priority: $priority, reminderMinutesBefore: $reminderMinutesBefore)';
}


}

/// @nodoc
abstract mixin class _$NoteCreationPayloadCopyWith<$Res> implements $NoteCreationPayloadCopyWith<$Res> {
  factory _$NoteCreationPayloadCopyWith(_NoteCreationPayload value, $Res Function(_NoteCreationPayload) _then) = __$NoteCreationPayloadCopyWithImpl;
@override @useResult
$Res call({
 String title, Document content, String? projectId, DateTime? dueDate, TimeOfDay? dueTime, TaskPriority priority, int? reminderMinutesBefore
});




}
/// @nodoc
class __$NoteCreationPayloadCopyWithImpl<$Res>
    implements _$NoteCreationPayloadCopyWith<$Res> {
  __$NoteCreationPayloadCopyWithImpl(this._self, this._then);

  final _NoteCreationPayload _self;
  final $Res Function(_NoteCreationPayload) _then;

/// Create a copy of NoteCreationPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? content = null,Object? projectId = freezed,Object? dueDate = freezed,Object? dueTime = freezed,Object? priority = null,Object? reminderMinutesBefore = freezed,}) {
  return _then(_NoteCreationPayload(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as Document,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dueTime: freezed == dueTime ? _self.dueTime : dueTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,reminderMinutesBefore: freezed == reminderMinutesBefore ? _self.reminderMinutesBefore : reminderMinutesBefore // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
