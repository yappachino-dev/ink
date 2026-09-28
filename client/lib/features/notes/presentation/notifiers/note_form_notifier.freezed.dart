// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_form_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NoteDraftState {

 String? get notebookId; DateTime? get dueDate; TimeOfDay? get dueTime; int? get reminderMinutes; TaskPriority get priority;
/// Create a copy of NoteDraftState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteDraftStateCopyWith<NoteDraftState> get copyWith => _$NoteDraftStateCopyWithImpl<NoteDraftState>(this as NoteDraftState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NoteDraftState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteDraftState&&(identical(other.notebookId, _this.notebookId) || other.notebookId == _this.notebookId)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.dueTime, _this.dueTime) || other.dueTime == _this.dueTime)&&(identical(other.reminderMinutes, _this.reminderMinutes) || other.reminderMinutes == _this.reminderMinutes)&&(identical(other.priority, _this.priority) || other.priority == _this.priority));
}


@override
int get hashCode {
  final _this = this as NoteDraftState;
  return Object.hash(runtimeType,_this.notebookId,_this.dueDate,_this.dueTime,_this.reminderMinutes,_this.priority);
}

@override
String toString() {
  final _this = this as NoteDraftState;
  return 'NoteDraftState(notebookId: ${_this.notebookId}, dueDate: ${_this.dueDate}, dueTime: ${_this.dueTime}, reminderMinutes: ${_this.reminderMinutes}, priority: ${_this.priority})';
}


}

/// @nodoc
abstract mixin class $NoteDraftStateCopyWith<$Res>  {
  factory $NoteDraftStateCopyWith(NoteDraftState value, $Res Function(NoteDraftState) _then) = _$NoteDraftStateCopyWithImpl;
@useResult
$Res call({
 String? notebookId, DateTime? dueDate, TimeOfDay? dueTime, int? reminderMinutes, TaskPriority priority
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
@pragma('vm:prefer-inline') @override $Res call({Object? notebookId = freezed,Object? dueDate = freezed,Object? dueTime = freezed,Object? reminderMinutes = freezed,Object? priority = null,}) {
  return _then(NoteDraftState(
notebookId: freezed == notebookId ? _self.notebookId : notebookId // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? notebookId,  DateTime? dueDate,  TimeOfDay? dueTime,  int? reminderMinutes,  TaskPriority priority)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteDraftState() when $default != null:
return $default(_that.notebookId,_that.dueDate,_that.dueTime,_that.reminderMinutes,_that.priority);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? notebookId,  DateTime? dueDate,  TimeOfDay? dueTime,  int? reminderMinutes,  TaskPriority priority)  $default,) {final _that = this;
switch (_that) {
case _NoteDraftState():
return $default(_that.notebookId,_that.dueDate,_that.dueTime,_that.reminderMinutes,_that.priority);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? notebookId,  DateTime? dueDate,  TimeOfDay? dueTime,  int? reminderMinutes,  TaskPriority priority)?  $default,) {final _that = this;
switch (_that) {
case _NoteDraftState() when $default != null:
return $default(_that.notebookId,_that.dueDate,_that.dueTime,_that.reminderMinutes,_that.priority);case _:
  return null;

}
}

}

/// @nodoc


class _NoteDraftState implements NoteDraftState {
  const _NoteDraftState({this.notebookId, this.dueDate, this.dueTime, this.reminderMinutes, this.priority = TaskPriority.none});
  

@override final  String? notebookId;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteDraftState&&(identical(other.notebookId, notebookId) || other.notebookId == notebookId)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.dueTime, dueTime) || other.dueTime == dueTime)&&(identical(other.reminderMinutes, reminderMinutes) || other.reminderMinutes == reminderMinutes)&&(identical(other.priority, priority) || other.priority == priority));
}


@override
int get hashCode {
    return Object.hash(runtimeType,notebookId,dueDate,dueTime,reminderMinutes,priority);
}

@override
String toString() {
    return 'NoteDraftState(notebookId: $notebookId, dueDate: $dueDate, dueTime: $dueTime, reminderMinutes: $reminderMinutes, priority: $priority)';
}


}

/// @nodoc
abstract mixin class _$NoteDraftStateCopyWith<$Res> implements $NoteDraftStateCopyWith<$Res> {
  factory _$NoteDraftStateCopyWith(_NoteDraftState value, $Res Function(_NoteDraftState) _then) = __$NoteDraftStateCopyWithImpl;
@override @useResult
$Res call({
 String? notebookId, DateTime? dueDate, TimeOfDay? dueTime, int? reminderMinutes, TaskPriority priority
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
@override @pragma('vm:prefer-inline') $Res call({Object? notebookId = freezed,Object? dueDate = freezed,Object? dueTime = freezed,Object? reminderMinutes = freezed,Object? priority = null,}) {
  return _then(_NoteDraftState(
notebookId: freezed == notebookId ? _self.notebookId : notebookId // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dueTime: freezed == dueTime ? _self.dueTime : dueTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,reminderMinutes: freezed == reminderMinutes ? _self.reminderMinutes : reminderMinutes // ignore: cast_nullable_to_non_nullable
as int?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,
  ));
}


}

// dart format on
