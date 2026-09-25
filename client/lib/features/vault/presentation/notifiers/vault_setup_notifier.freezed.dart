// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vault_setup_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VaultSetupData {

 List<String> get generatedRecoveryPhrase; List<int> get verifyIndices; KeyType? get selectedType; String? get temporarySecret; bool get isSubmitting; VaultFailure? get failure;
/// Create a copy of VaultSetupData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VaultSetupDataCopyWith<VaultSetupData> get copyWith => _$VaultSetupDataCopyWithImpl<VaultSetupData>(this as VaultSetupData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VaultSetupData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VaultSetupData&&const DeepCollectionEquality().equals(other.generatedRecoveryPhrase, _this.generatedRecoveryPhrase)&&const DeepCollectionEquality().equals(other.verifyIndices, _this.verifyIndices)&&(identical(other.selectedType, _this.selectedType) || other.selectedType == _this.selectedType)&&(identical(other.temporarySecret, _this.temporarySecret) || other.temporarySecret == _this.temporarySecret)&&(identical(other.isSubmitting, _this.isSubmitting) || other.isSubmitting == _this.isSubmitting)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as VaultSetupData;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.generatedRecoveryPhrase),const DeepCollectionEquality().hash(_this.verifyIndices),_this.selectedType,_this.temporarySecret,_this.isSubmitting,_this.failure);
}

@override
String toString() {
  final _this = this as VaultSetupData;
  return 'VaultSetupData(generatedRecoveryPhrase: ${_this.generatedRecoveryPhrase}, verifyIndices: ${_this.verifyIndices}, selectedType: ${_this.selectedType}, temporarySecret: ${_this.temporarySecret}, isSubmitting: ${_this.isSubmitting}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $VaultSetupDataCopyWith<$Res>  {
  factory $VaultSetupDataCopyWith(VaultSetupData value, $Res Function(VaultSetupData) _then) = _$VaultSetupDataCopyWithImpl;
@useResult
$Res call({
 List<String> generatedRecoveryPhrase, List<int> verifyIndices, KeyType? selectedType, String? temporarySecret, bool isSubmitting, VaultFailure? failure
});




}
/// @nodoc
class _$VaultSetupDataCopyWithImpl<$Res>
    implements $VaultSetupDataCopyWith<$Res> {
  _$VaultSetupDataCopyWithImpl(this._self, this._then);

  final VaultSetupData _self;
  final $Res Function(VaultSetupData) _then;

/// Create a copy of VaultSetupData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? generatedRecoveryPhrase = null,Object? verifyIndices = null,Object? selectedType = freezed,Object? temporarySecret = freezed,Object? isSubmitting = null,Object? failure = freezed,}) {
  return _then(VaultSetupData(
generatedRecoveryPhrase: null == generatedRecoveryPhrase ? _self.generatedRecoveryPhrase : generatedRecoveryPhrase // ignore: cast_nullable_to_non_nullable
as List<String>,verifyIndices: null == verifyIndices ? _self.verifyIndices : verifyIndices // ignore: cast_nullable_to_non_nullable
as List<int>,selectedType: freezed == selectedType ? _self.selectedType : selectedType // ignore: cast_nullable_to_non_nullable
as KeyType?,temporarySecret: freezed == temporarySecret ? _self.temporarySecret : temporarySecret // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as VaultFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [VaultSetupData].
extension VaultSetupDataPatterns on VaultSetupData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VaultSetupData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VaultSetupData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VaultSetupData value)  $default,){
final _that = this;
switch (_that) {
case _VaultSetupData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VaultSetupData value)?  $default,){
final _that = this;
switch (_that) {
case _VaultSetupData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> generatedRecoveryPhrase,  List<int> verifyIndices,  KeyType? selectedType,  String? temporarySecret,  bool isSubmitting,  VaultFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VaultSetupData() when $default != null:
return $default(_that.generatedRecoveryPhrase,_that.verifyIndices,_that.selectedType,_that.temporarySecret,_that.isSubmitting,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> generatedRecoveryPhrase,  List<int> verifyIndices,  KeyType? selectedType,  String? temporarySecret,  bool isSubmitting,  VaultFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _VaultSetupData():
return $default(_that.generatedRecoveryPhrase,_that.verifyIndices,_that.selectedType,_that.temporarySecret,_that.isSubmitting,_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> generatedRecoveryPhrase,  List<int> verifyIndices,  KeyType? selectedType,  String? temporarySecret,  bool isSubmitting,  VaultFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _VaultSetupData() when $default != null:
return $default(_that.generatedRecoveryPhrase,_that.verifyIndices,_that.selectedType,_that.temporarySecret,_that.isSubmitting,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _VaultSetupData implements VaultSetupData {
  const _VaultSetupData({required  List<String> generatedRecoveryPhrase, required  List<int> verifyIndices, this.selectedType, this.temporarySecret, this.isSubmitting = false, this.failure}): _generatedRecoveryPhrase = generatedRecoveryPhrase,_verifyIndices = verifyIndices;
  

 final  List<String> _generatedRecoveryPhrase;
@override List<String> get generatedRecoveryPhrase {
  if (_generatedRecoveryPhrase is EqualUnmodifiableListView) return _generatedRecoveryPhrase;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_generatedRecoveryPhrase);
}

 final  List<int> _verifyIndices;
@override List<int> get verifyIndices {
  if (_verifyIndices is EqualUnmodifiableListView) return _verifyIndices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_verifyIndices);
}

@override final  KeyType? selectedType;
@override final  String? temporarySecret;
@override@JsonKey() final  bool isSubmitting;
@override final  VaultFailure? failure;

/// Create a copy of VaultSetupData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VaultSetupDataCopyWith<_VaultSetupData> get copyWith => __$VaultSetupDataCopyWithImpl<_VaultSetupData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VaultSetupData&&const DeepCollectionEquality().equals(other.generatedRecoveryPhrase, _generatedRecoveryPhrase)&&const DeepCollectionEquality().equals(other.verifyIndices, _verifyIndices)&&(identical(other.selectedType, selectedType) || other.selectedType == selectedType)&&(identical(other.temporarySecret, temporarySecret) || other.temporarySecret == temporarySecret)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_generatedRecoveryPhrase),const DeepCollectionEquality().hash(_verifyIndices),selectedType,temporarySecret,isSubmitting,failure);
}

@override
String toString() {
    return 'VaultSetupData(generatedRecoveryPhrase: $generatedRecoveryPhrase, verifyIndices: $verifyIndices, selectedType: $selectedType, temporarySecret: $temporarySecret, isSubmitting: $isSubmitting, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$VaultSetupDataCopyWith<$Res> implements $VaultSetupDataCopyWith<$Res> {
  factory _$VaultSetupDataCopyWith(_VaultSetupData value, $Res Function(_VaultSetupData) _then) = __$VaultSetupDataCopyWithImpl;
@override @useResult
$Res call({
 List<String> generatedRecoveryPhrase, List<int> verifyIndices, KeyType? selectedType, String? temporarySecret, bool isSubmitting, VaultFailure? failure
});




}
/// @nodoc
class __$VaultSetupDataCopyWithImpl<$Res>
    implements _$VaultSetupDataCopyWith<$Res> {
  __$VaultSetupDataCopyWithImpl(this._self, this._then);

  final _VaultSetupData _self;
  final $Res Function(_VaultSetupData) _then;

/// Create a copy of VaultSetupData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? generatedRecoveryPhrase = null,Object? verifyIndices = null,Object? selectedType = freezed,Object? temporarySecret = freezed,Object? isSubmitting = null,Object? failure = freezed,}) {
  return _then(_VaultSetupData(
generatedRecoveryPhrase: null == generatedRecoveryPhrase ? _self._generatedRecoveryPhrase : generatedRecoveryPhrase // ignore: cast_nullable_to_non_nullable
as List<String>,verifyIndices: null == verifyIndices ? _self._verifyIndices : verifyIndices // ignore: cast_nullable_to_non_nullable
as List<int>,selectedType: freezed == selectedType ? _self.selectedType : selectedType // ignore: cast_nullable_to_non_nullable
as KeyType?,temporarySecret: freezed == temporarySecret ? _self.temporarySecret : temporarySecret // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as VaultFailure?,
  ));
}


}

// dart format on
