// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NoteDto {

 String get id;@Uint8ListConverter() Uint8List get encryptedTitle;@Uint8ListConverter() Uint8List get encryptedContent; int get version;@DateTimeUtcConverter() DateTime get createdAt;@DateTimeUtcConverter() DateTime get updatedAt;@DateTimeUtcConverter() DateTime? get deletedAt; String? get projectId;
/// Create a copy of NoteDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteDtoCopyWith<NoteDto> get copyWith => _$NoteDtoCopyWithImpl<NoteDto>(this as NoteDto, _$identity);

  /// Serializes this NoteDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteDto&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.encryptedTitle, encryptedTitle)&&const DeepCollectionEquality().equals(other.encryptedContent, encryptedContent)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.projectId, projectId) || other.projectId == projectId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(encryptedTitle),const DeepCollectionEquality().hash(encryptedContent),version,createdAt,updatedAt,deletedAt,projectId);

@override
String toString() {
  return 'NoteDto(id: $id, encryptedTitle: $encryptedTitle, encryptedContent: $encryptedContent, version: $version, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, projectId: $projectId)';
}


}

/// @nodoc
abstract mixin class $NoteDtoCopyWith<$Res>  {
  factory $NoteDtoCopyWith(NoteDto value, $Res Function(NoteDto) _then) = _$NoteDtoCopyWithImpl;
@useResult
$Res call({
 String id,@Uint8ListConverter() Uint8List encryptedTitle,@Uint8ListConverter() Uint8List encryptedContent, int version,@DateTimeUtcConverter() DateTime createdAt,@DateTimeUtcConverter() DateTime updatedAt,@DateTimeUtcConverter() DateTime? deletedAt, String? projectId
});




}
/// @nodoc
class _$NoteDtoCopyWithImpl<$Res>
    implements $NoteDtoCopyWith<$Res> {
  _$NoteDtoCopyWithImpl(this._self, this._then);

  final NoteDto _self;
  final $Res Function(NoteDto) _then;

/// Create a copy of NoteDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? encryptedTitle = null,Object? encryptedContent = null,Object? version = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? projectId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,encryptedTitle: null == encryptedTitle ? _self.encryptedTitle : encryptedTitle // ignore: cast_nullable_to_non_nullable
as Uint8List,encryptedContent: null == encryptedContent ? _self.encryptedContent : encryptedContent // ignore: cast_nullable_to_non_nullable
as Uint8List,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NoteDto].
extension NoteDtoPatterns on NoteDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoteDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoteDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteDto value)  $default,){
final _that = this;
switch (_that) {
case _NoteDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteDto value)?  $default,){
final _that = this;
switch (_that) {
case _NoteDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @Uint8ListConverter()  Uint8List encryptedTitle, @Uint8ListConverter()  Uint8List encryptedContent,  int version, @DateTimeUtcConverter()  DateTime createdAt, @DateTimeUtcConverter()  DateTime updatedAt, @DateTimeUtcConverter()  DateTime? deletedAt,  String? projectId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteDto() when $default != null:
return $default(_that.id,_that.encryptedTitle,_that.encryptedContent,_that.version,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.projectId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @Uint8ListConverter()  Uint8List encryptedTitle, @Uint8ListConverter()  Uint8List encryptedContent,  int version, @DateTimeUtcConverter()  DateTime createdAt, @DateTimeUtcConverter()  DateTime updatedAt, @DateTimeUtcConverter()  DateTime? deletedAt,  String? projectId)  $default,) {final _that = this;
switch (_that) {
case _NoteDto():
return $default(_that.id,_that.encryptedTitle,_that.encryptedContent,_that.version,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.projectId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @Uint8ListConverter()  Uint8List encryptedTitle, @Uint8ListConverter()  Uint8List encryptedContent,  int version, @DateTimeUtcConverter()  DateTime createdAt, @DateTimeUtcConverter()  DateTime updatedAt, @DateTimeUtcConverter()  DateTime? deletedAt,  String? projectId)?  $default,) {final _that = this;
switch (_that) {
case _NoteDto() when $default != null:
return $default(_that.id,_that.encryptedTitle,_that.encryptedContent,_that.version,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.projectId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NoteDto implements NoteDto {
  const _NoteDto({required this.id, @Uint8ListConverter() required this.encryptedTitle, @Uint8ListConverter() required this.encryptedContent, required this.version, @DateTimeUtcConverter() required this.createdAt, @DateTimeUtcConverter() required this.updatedAt, @DateTimeUtcConverter() this.deletedAt, this.projectId});
  factory _NoteDto.fromJson(Map<String, dynamic> json) => _$NoteDtoFromJson(json);

@override final  String id;
@override@Uint8ListConverter() final  Uint8List encryptedTitle;
@override@Uint8ListConverter() final  Uint8List encryptedContent;
@override final  int version;
@override@DateTimeUtcConverter() final  DateTime createdAt;
@override@DateTimeUtcConverter() final  DateTime updatedAt;
@override@DateTimeUtcConverter() final  DateTime? deletedAt;
@override final  String? projectId;

/// Create a copy of NoteDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteDtoCopyWith<_NoteDto> get copyWith => __$NoteDtoCopyWithImpl<_NoteDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NoteDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteDto&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.encryptedTitle, encryptedTitle)&&const DeepCollectionEquality().equals(other.encryptedContent, encryptedContent)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.projectId, projectId) || other.projectId == projectId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(encryptedTitle),const DeepCollectionEquality().hash(encryptedContent),version,createdAt,updatedAt,deletedAt,projectId);

@override
String toString() {
  return 'NoteDto(id: $id, encryptedTitle: $encryptedTitle, encryptedContent: $encryptedContent, version: $version, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, projectId: $projectId)';
}


}

/// @nodoc
abstract mixin class _$NoteDtoCopyWith<$Res> implements $NoteDtoCopyWith<$Res> {
  factory _$NoteDtoCopyWith(_NoteDto value, $Res Function(_NoteDto) _then) = __$NoteDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@Uint8ListConverter() Uint8List encryptedTitle,@Uint8ListConverter() Uint8List encryptedContent, int version,@DateTimeUtcConverter() DateTime createdAt,@DateTimeUtcConverter() DateTime updatedAt,@DateTimeUtcConverter() DateTime? deletedAt, String? projectId
});




}
/// @nodoc
class __$NoteDtoCopyWithImpl<$Res>
    implements _$NoteDtoCopyWith<$Res> {
  __$NoteDtoCopyWithImpl(this._self, this._then);

  final _NoteDto _self;
  final $Res Function(_NoteDto) _then;

/// Create a copy of NoteDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? encryptedTitle = null,Object? encryptedContent = null,Object? version = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? projectId = freezed,}) {
  return _then(_NoteDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,encryptedTitle: null == encryptedTitle ? _self.encryptedTitle : encryptedTitle // ignore: cast_nullable_to_non_nullable
as Uint8List,encryptedContent: null == encryptedContent ? _self.encryptedContent : encryptedContent // ignore: cast_nullable_to_non_nullable
as Uint8List,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
