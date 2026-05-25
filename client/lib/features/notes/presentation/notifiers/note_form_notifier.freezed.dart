// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_form_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NoteDraftState {

 String? get projectId; DateTime? get dueDate; TimeOfDay? get dueTime; int? get reminderMinutes; TaskPriority get priority;
/// Create a copy of NoteDraftState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteDraftStateCopyWith<NoteDraftState> get copyWith => _$NoteDraftStateCopyWithImpl<NoteDraftState>(this as NoteDraftState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteDraftState&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.dueTime, dueTime) || other.dueTime == dueTime)&&(identical(other.reminderMinutes, reminderMinutes) || other.reminderMinutes == reminderMinutes)&&(identical(other.priority, priority) || other.priority == priority));
}


@override
int get hashCode => Object.hash(runtimeType,projectId,dueDate,dueTime,reminderMinutes,priority);

@override
String toString() {
  return 'NoteDraftState(projectId: $projectId, dueDate: $dueDate, dueTime: $dueTime, reminderMinutes: $reminderMinutes, priority: $priority)';
}


}

/// @nodoc
abstract mixin class $NoteDraftStateCopyWith<$Res>  {
  factory $NoteDraftStateCopyWith(NoteDraftState value, $Res Function(NoteDraftState) _then) = _$NoteDraftStateCopyWithImpl;
@useResult
$Res call({
 String? projectId, DateTime? dueDate, TimeOfDay? dueTime, int? reminderMinutes, TaskPriority priority
});




}
/// @nodoc
class _$NoteDraftStateCopyWithImpl<$Res>
    implements $NoteDraftStateCopyWith<$Res> {
  _$NoteDraftStateCopyWithImpl(this._self, this._then);

  final NoteDraftState _self;
  final $Res Function(NoteDraftState) _then;

/// Create a copy of NoteDraftState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? projectId = freezed,Object? dueDate = freezed,Object? dueTime = freezed,Object? reminderMinutes = freezed,Object? priority = null,}) {
  return _then(_self.copyWith(
projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dueTime: freezed == dueTime ? _self.dueTime : dueTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,reminderMinutes: freezed == reminderMinutes ? _self.reminderMinutes : reminderMinutes // ignore: cast_nullable_to_non_nullable
as int?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,
  ));
}

}


/// Adds pattern-matching-related methods to [NoteDraftState].
extension NoteDraftStatePatterns on NoteDraftState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoteDraftState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoteDraftState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteDraftState value)  $default,){
final _that = this;
switch (_that) {
case _NoteDraftState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteDraftState value)?  $default,){
final _that = this;
switch (_that) {
case _NoteDraftState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? projectId,  DateTime? dueDate,  TimeOfDay? dueTime,  int? reminderMinutes,  TaskPriority priority)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteDraftState() when $default != null:
return $default(_that.projectId,_that.dueDate,_that.dueTime,_that.reminderMinutes,_that.priority);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? projectId,  DateTime? dueDate,  TimeOfDay? dueTime,  int? reminderMinutes,  TaskPriority priority)  $default,) {final _that = this;
switch (_that) {
case _NoteDraftState():
return $default(_that.projectId,_that.dueDate,_that.dueTime,_that.reminderMinutes,_that.priority);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? projectId,  DateTime? dueDate,  TimeOfDay? dueTime,  int? reminderMinutes,  TaskPriority priority)?  $default,) {final _that = this;
switch (_that) {
case _NoteDraftState() when $default != null:
return $default(_that.projectId,_that.dueDate,_that.dueTime,_that.reminderMinutes,_that.priority);case _:
  return null;

}
}

}

/// @nodoc


class _NoteDraftState implements NoteDraftState {
  const _NoteDraftState({this.projectId, this.dueDate, this.dueTime, this.reminderMinutes, this.priority = TaskPriority.none});
  

@override final  String? projectId;
@override final  DateTime? dueDate;
@override final  TimeOfDay? dueTime;
@override final  int? reminderMinutes;
@override@JsonKey() final  TaskPriority priority;

/// Create a copy of NoteDraftState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteDraftStateCopyWith<_NoteDraftState> get copyWith => __$NoteDraftStateCopyWithImpl<_NoteDraftState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteDraftState&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.dueTime, dueTime) || other.dueTime == dueTime)&&(identical(other.reminderMinutes, reminderMinutes) || other.reminderMinutes == reminderMinutes)&&(identical(other.priority, priority) || other.priority == priority));
}


@override
int get hashCode => Object.hash(runtimeType,projectId,dueDate,dueTime,reminderMinutes,priority);

@override
String toString() {
  return 'NoteDraftState(projectId: $projectId, dueDate: $dueDate, dueTime: $dueTime, reminderMinutes: $reminderMinutes, priority: $priority)';
}


}

/// @nodoc
abstract mixin class _$NoteDraftStateCopyWith<$Res> implements $NoteDraftStateCopyWith<$Res> {
  factory _$NoteDraftStateCopyWith(_NoteDraftState value, $Res Function(_NoteDraftState) _then) = __$NoteDraftStateCopyWithImpl;
@override @useResult
$Res call({
 String? projectId, DateTime? dueDate, TimeOfDay? dueTime, int? reminderMinutes, TaskPriority priority
});




}
/// @nodoc
class __$NoteDraftStateCopyWithImpl<$Res>
    implements _$NoteDraftStateCopyWith<$Res> {
  __$NoteDraftStateCopyWithImpl(this._self, this._then);

  final _NoteDraftState _self;
  final $Res Function(_NoteDraftState) _then;

/// Create a copy of NoteDraftState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? projectId = freezed,Object? dueDate = freezed,Object? dueTime = freezed,Object? reminderMinutes = freezed,Object? priority = null,}) {
  return _then(_NoteDraftState(
projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dueTime: freezed == dueTime ? _self.dueTime : dueTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,reminderMinutes: freezed == reminderMinutes ? _self.reminderMinutes : reminderMinutes // ignore: cast_nullable_to_non_nullable
as int?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,
  ));
}


}

// dart format on
