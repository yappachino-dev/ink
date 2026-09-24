// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotePayload {

 List<dynamic> get quillData; bool get isCompleted; DateTime? get dueDate;@TimeOfDayConverter() TimeOfDay? get dueTime; TaskPriority get priority; int? get reminderMinutesBefore;
/// Create a copy of NotePayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotePayloadCopyWith<NotePayload> get copyWith => _$NotePayloadCopyWithImpl<NotePayload>(this as NotePayload, _$identity);

  /// Serializes this NotePayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotePayload&&const DeepCollectionEquality().equals(other.quillData, quillData)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.dueTime, dueTime) || other.dueTime == dueTime)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.reminderMinutesBefore, reminderMinutesBefore) || other.reminderMinutesBefore == reminderMinutesBefore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(quillData),isCompleted,dueDate,dueTime,priority,reminderMinutesBefore);

@override
String toString() {
  return 'NotePayload(quillData: $quillData, isCompleted: $isCompleted, dueDate: $dueDate, dueTime: $dueTime, priority: $priority, reminderMinutesBefore: $reminderMinutesBefore)';
}


}

/// @nodoc
abstract mixin class $NotePayloadCopyWith<$Res>  {
  factory $NotePayloadCopyWith(NotePayload value, $Res Function(NotePayload) _then) = _$NotePayloadCopyWithImpl;
@useResult
$Res call({
 List<dynamic> quillData, bool isCompleted, DateTime? dueDate,@TimeOfDayConverter() TimeOfDay? dueTime, TaskPriority priority, int? reminderMinutesBefore
});




}
/// @nodoc
class _$NotePayloadCopyWithImpl<$Res>
    implements $NotePayloadCopyWith<$Res> {
  _$NotePayloadCopyWithImpl(this._self, this._then);

  final NotePayload _self;
  final $Res Function(NotePayload) _then;

/// Create a copy of NotePayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quillData = null,Object? isCompleted = null,Object? dueDate = freezed,Object? dueTime = freezed,Object? priority = null,Object? reminderMinutesBefore = freezed,}) {
  return _then(_self.copyWith(
quillData: null == quillData ? _self.quillData : quillData // ignore: cast_nullable_to_non_nullable
as List<dynamic>,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dueTime: freezed == dueTime ? _self.dueTime : dueTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,reminderMinutesBefore: freezed == reminderMinutesBefore ? _self.reminderMinutesBefore : reminderMinutesBefore // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotePayload].
extension NotePayloadPatterns on NotePayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotePayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotePayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotePayload value)  $default,){
final _that = this;
switch (_that) {
case _NotePayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotePayload value)?  $default,){
final _that = this;
switch (_that) {
case _NotePayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<dynamic> quillData,  bool isCompleted,  DateTime? dueDate, @TimeOfDayConverter()  TimeOfDay? dueTime,  TaskPriority priority,  int? reminderMinutesBefore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotePayload() when $default != null:
return $default(_that.quillData,_that.isCompleted,_that.dueDate,_that.dueTime,_that.priority,_that.reminderMinutesBefore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<dynamic> quillData,  bool isCompleted,  DateTime? dueDate, @TimeOfDayConverter()  TimeOfDay? dueTime,  TaskPriority priority,  int? reminderMinutesBefore)  $default,) {final _that = this;
switch (_that) {
case _NotePayload():
return $default(_that.quillData,_that.isCompleted,_that.dueDate,_that.dueTime,_that.priority,_that.reminderMinutesBefore);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<dynamic> quillData,  bool isCompleted,  DateTime? dueDate, @TimeOfDayConverter()  TimeOfDay? dueTime,  TaskPriority priority,  int? reminderMinutesBefore)?  $default,) {final _that = this;
switch (_that) {
case _NotePayload() when $default != null:
return $default(_that.quillData,_that.isCompleted,_that.dueDate,_that.dueTime,_that.priority,_that.reminderMinutesBefore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotePayload implements NotePayload {
  const _NotePayload({required final  List<dynamic> quillData, this.isCompleted = false, this.dueDate, @TimeOfDayConverter() this.dueTime, this.priority = TaskPriority.none, this.reminderMinutesBefore}): _quillData = quillData;
  factory _NotePayload.fromJson(Map<String, dynamic> json) => _$NotePayloadFromJson(json);

 final  List<dynamic> _quillData;
@override List<dynamic> get quillData {
  if (_quillData is EqualUnmodifiableListView) return _quillData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quillData);
}

@override@JsonKey() final  bool isCompleted;
@override final  DateTime? dueDate;
@override@TimeOfDayConverter() final  TimeOfDay? dueTime;
@override@JsonKey() final  TaskPriority priority;
@override final  int? reminderMinutesBefore;

/// Create a copy of NotePayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotePayloadCopyWith<_NotePayload> get copyWith => __$NotePayloadCopyWithImpl<_NotePayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotePayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotePayload&&const DeepCollectionEquality().equals(other._quillData, _quillData)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.dueTime, dueTime) || other.dueTime == dueTime)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.reminderMinutesBefore, reminderMinutesBefore) || other.reminderMinutesBefore == reminderMinutesBefore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_quillData),isCompleted,dueDate,dueTime,priority,reminderMinutesBefore);

@override
String toString() {
  return 'NotePayload(quillData: $quillData, isCompleted: $isCompleted, dueDate: $dueDate, dueTime: $dueTime, priority: $priority, reminderMinutesBefore: $reminderMinutesBefore)';
}


}

/// @nodoc
abstract mixin class _$NotePayloadCopyWith<$Res> implements $NotePayloadCopyWith<$Res> {
  factory _$NotePayloadCopyWith(_NotePayload value, $Res Function(_NotePayload) _then) = __$NotePayloadCopyWithImpl;
@override @useResult
$Res call({
 List<dynamic> quillData, bool isCompleted, DateTime? dueDate,@TimeOfDayConverter() TimeOfDay? dueTime, TaskPriority priority, int? reminderMinutesBefore
});




}
/// @nodoc
class __$NotePayloadCopyWithImpl<$Res>
    implements _$NotePayloadCopyWith<$Res> {
  __$NotePayloadCopyWithImpl(this._self, this._then);

  final _NotePayload _self;
  final $Res Function(_NotePayload) _then;

/// Create a copy of NotePayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? quillData = null,Object? isCompleted = null,Object? dueDate = freezed,Object? dueTime = freezed,Object? priority = null,Object? reminderMinutesBefore = freezed,}) {
  return _then(_NotePayload(
quillData: null == quillData ? _self._quillData : quillData // ignore: cast_nullable_to_non_nullable
as List<dynamic>,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dueTime: freezed == dueTime ? _self.dueTime : dueTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,reminderMinutesBefore: freezed == reminderMinutesBefore ? _self.reminderMinutesBefore : reminderMinutesBefore // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
