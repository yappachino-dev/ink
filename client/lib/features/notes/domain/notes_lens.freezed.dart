// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notes_lens.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotesLens {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NotesLens);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'NotesLens()';
}


}

/// @nodoc
class $NotesLensCopyWith<$Res>  {
$NotesLensCopyWith(NotesLens _, $Res Function(NotesLens) __);
}


/// Adds pattern-matching-related methods to [NotesLens].
extension NotesLensPatterns on NotesLens {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AllNotesLens value)?  all,TResult Function( TodayLens value)?  today,TResult Function( NotebookLens value)?  notebook,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AllNotesLens() when all != null:
return all(_that);case TodayLens() when today != null:
return today(_that);case NotebookLens() when notebook != null:
return notebook(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AllNotesLens value)  all,required TResult Function( TodayLens value)  today,required TResult Function( NotebookLens value)  notebook,}){
final _that = this;
switch (_that) {
case AllNotesLens():
return all(_that);case TodayLens():
return today(_that);case NotebookLens():
return notebook(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AllNotesLens value)?  all,TResult? Function( TodayLens value)?  today,TResult? Function( NotebookLens value)?  notebook,}){
final _that = this;
switch (_that) {
case AllNotesLens() when all != null:
return all(_that);case TodayLens() when today != null:
return today(_that);case NotebookLens() when notebook != null:
return notebook(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  all,TResult Function()?  today,TResult Function( String notebookId)?  notebook,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AllNotesLens() when all != null:
return all();case TodayLens() when today != null:
return today();case NotebookLens() when notebook != null:
return notebook(_that.notebookId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  all,required TResult Function()  today,required TResult Function( String notebookId)  notebook,}) {final _that = this;
switch (_that) {
case AllNotesLens():
return all();case TodayLens():
return today();case NotebookLens():
return notebook(_that.notebookId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  all,TResult? Function()?  today,TResult? Function( String notebookId)?  notebook,}) {final _that = this;
switch (_that) {
case AllNotesLens() when all != null:
return all();case TodayLens() when today != null:
return today();case NotebookLens() when notebook != null:
return notebook(_that.notebookId);case _:
  return null;

}
}

}

/// @nodoc


class AllNotesLens implements NotesLens {
  const AllNotesLens();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AllNotesLens);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'NotesLens.all()';
}


}




/// @nodoc


class TodayLens implements NotesLens {
  const TodayLens();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayLens);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'NotesLens.today()';
}


}




/// @nodoc


class NotebookLens implements NotesLens {
  const NotebookLens(this.notebookId);
  

 final  String notebookId;

/// Create a copy of NotesLens
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotebookLensCopyWith<NotebookLens> get copyWith => _$NotebookLensCopyWithImpl<NotebookLens>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NotebookLens&&(identical(other.notebookId, notebookId) || other.notebookId == notebookId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,notebookId);
}

@override
String toString() {
    return 'NotesLens.notebook(notebookId: $notebookId)';
}


}

/// @nodoc
abstract mixin class $NotebookLensCopyWith<$Res> implements $NotesLensCopyWith<$Res> {
  factory $NotebookLensCopyWith(NotebookLens value, $Res Function(NotebookLens) _then) = _$NotebookLensCopyWithImpl;
@useResult
$Res call({
 String notebookId
});




}
/// @nodoc
class _$NotebookLensCopyWithImpl<$Res>
    implements $NotebookLensCopyWith<$Res> {
  _$NotebookLensCopyWithImpl(this._self, this._then);

  final NotebookLens _self;
  final $Res Function(NotebookLens) _then;

/// Create a copy of NotesLens
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? notebookId = null,}) {
  return _then(NotebookLens(
null == notebookId ? _self.notebookId : notebookId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
