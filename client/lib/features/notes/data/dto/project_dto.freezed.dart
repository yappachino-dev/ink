// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectDto {

 String get id;@Uint8ListConverter() Uint8List get encryptedContent; int get version;@DateTimeUtcConverter() DateTime get createdAt;@DateTimeUtcConverter() DateTime get updatedAt;@DateTimeUtcConverter() DateTime? get deletedAt;
/// Create a copy of ProjectDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectDtoCopyWith<ProjectDto> get copyWith => _$ProjectDtoCopyWithImpl<ProjectDto>(this as ProjectDto, _$identity);

  /// Serializes this ProjectDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectDto&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.encryptedContent, encryptedContent)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(encryptedContent),version,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'ProjectDto(id: $id, encryptedContent: $encryptedContent, version: $version, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $ProjectDtoCopyWith<$Res>  {
  factory $ProjectDtoCopyWith(ProjectDto value, $Res Function(ProjectDto) _then) = _$ProjectDtoCopyWithImpl;
@useResult
$Res call({
 String id,@Uint8ListConverter() Uint8List encryptedContent, int version,@DateTimeUtcConverter() DateTime createdAt,@DateTimeUtcConverter() DateTime updatedAt,@DateTimeUtcConverter() DateTime? deletedAt
});




}
/// @nodoc
class _$ProjectDtoCopyWithImpl<$Res>
    implements $ProjectDtoCopyWith<$Res> {
  _$ProjectDtoCopyWithImpl(this._self, this._then);

  final ProjectDto _self;
  final $Res Function(ProjectDto) _then;

/// Create a copy of ProjectDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? encryptedContent = null,Object? version = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,encryptedContent: null == encryptedContent ? _self.encryptedContent : encryptedContent // ignore: cast_nullable_to_non_nullable
as Uint8List,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectDto].
extension ProjectDtoPatterns on ProjectDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectDto value)  $default,){
final _that = this;
switch (_that) {
case _ProjectDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @Uint8ListConverter()  Uint8List encryptedContent,  int version, @DateTimeUtcConverter()  DateTime createdAt, @DateTimeUtcConverter()  DateTime updatedAt, @DateTimeUtcConverter()  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectDto() when $default != null:
return $default(_that.id,_that.encryptedContent,_that.version,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @Uint8ListConverter()  Uint8List encryptedContent,  int version, @DateTimeUtcConverter()  DateTime createdAt, @DateTimeUtcConverter()  DateTime updatedAt, @DateTimeUtcConverter()  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _ProjectDto():
return $default(_that.id,_that.encryptedContent,_that.version,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @Uint8ListConverter()  Uint8List encryptedContent,  int version, @DateTimeUtcConverter()  DateTime createdAt, @DateTimeUtcConverter()  DateTime updatedAt, @DateTimeUtcConverter()  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProjectDto() when $default != null:
return $default(_that.id,_that.encryptedContent,_that.version,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectDto implements ProjectDto {
  const _ProjectDto({required this.id, @Uint8ListConverter() required this.encryptedContent, required this.version, @DateTimeUtcConverter() required this.createdAt, @DateTimeUtcConverter() required this.updatedAt, @DateTimeUtcConverter() this.deletedAt});
  factory _ProjectDto.fromJson(Map<String, dynamic> json) => _$ProjectDtoFromJson(json);

@override final  String id;
@override@Uint8ListConverter() final  Uint8List encryptedContent;
@override final  int version;
@override@DateTimeUtcConverter() final  DateTime createdAt;
@override@DateTimeUtcConverter() final  DateTime updatedAt;
@override@DateTimeUtcConverter() final  DateTime? deletedAt;

/// Create a copy of ProjectDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectDtoCopyWith<_ProjectDto> get copyWith => __$ProjectDtoCopyWithImpl<_ProjectDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectDto&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.encryptedContent, encryptedContent)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(encryptedContent),version,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'ProjectDto(id: $id, encryptedContent: $encryptedContent, version: $version, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$ProjectDtoCopyWith<$Res> implements $ProjectDtoCopyWith<$Res> {
  factory _$ProjectDtoCopyWith(_ProjectDto value, $Res Function(_ProjectDto) _then) = __$ProjectDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@Uint8ListConverter() Uint8List encryptedContent, int version,@DateTimeUtcConverter() DateTime createdAt,@DateTimeUtcConverter() DateTime updatedAt,@DateTimeUtcConverter() DateTime? deletedAt
});




}
/// @nodoc
class __$ProjectDtoCopyWithImpl<$Res>
    implements _$ProjectDtoCopyWith<$Res> {
  __$ProjectDtoCopyWithImpl(this._self, this._then);

  final _ProjectDto _self;
  final $Res Function(_ProjectDto) _then;

/// Create a copy of ProjectDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? encryptedContent = null,Object? version = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_ProjectDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,encryptedContent: null == encryptedContent ? _self.encryptedContent : encryptedContent // ignore: cast_nullable_to_non_nullable
as Uint8List,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
