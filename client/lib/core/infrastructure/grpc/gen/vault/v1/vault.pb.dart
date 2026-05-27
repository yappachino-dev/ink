// This is a generated file - do not edit.
//
// Generated from vault/v1/vault.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $1;

import 'vault.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'vault.pbenum.dart';

class KeySlot extends $pb.GeneratedMessage {
  factory KeySlot({
    KeyType? type,
    $core.List<$core.int>? salt,
    $core.List<$core.int>? wrappedMasterKey,
    $1.Timestamp? updatedAt,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (salt != null) result.salt = salt;
    if (wrappedMasterKey != null) result.wrappedMasterKey = wrappedMasterKey;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  KeySlot._();

  factory KeySlot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory KeySlot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'KeySlot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vault.v1'),
      createEmptyInstance: create)
    ..aE<KeyType>(1, _omitFieldNames ? '' : 'type', enumValues: KeyType.values)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'salt', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'wrappedMasterKey', $pb.PbFieldType.OY)
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeySlot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeySlot copyWith(void Function(KeySlot) updates) =>
      super.copyWith((message) => updates(message as KeySlot)) as KeySlot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KeySlot create() => KeySlot._();
  @$core.override
  KeySlot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static KeySlot getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KeySlot>(create);
  static KeySlot? _defaultInstance;

  @$pb.TagNumber(1)
  KeyType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(KeyType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get salt => $_getN(1);
  @$pb.TagNumber(2)
  set salt($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSalt() => $_has(1);
  @$pb.TagNumber(2)
  void clearSalt() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get wrappedMasterKey => $_getN(2);
  @$pb.TagNumber(3)
  set wrappedMasterKey($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWrappedMasterKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearWrappedMasterKey() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Timestamp get updatedAt => $_getN(3);
  @$pb.TagNumber(4)
  set updatedAt($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasUpdatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearUpdatedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureUpdatedAt() => $_ensure(3);
}

class GetKeySlotsRequest extends $pb.GeneratedMessage {
  factory GetKeySlotsRequest() => create();

  GetKeySlotsRequest._();

  factory GetKeySlotsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetKeySlotsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetKeySlotsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vault.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetKeySlotsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetKeySlotsRequest copyWith(void Function(GetKeySlotsRequest) updates) =>
      super.copyWith((message) => updates(message as GetKeySlotsRequest))
          as GetKeySlotsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetKeySlotsRequest create() => GetKeySlotsRequest._();
  @$core.override
  GetKeySlotsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetKeySlotsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetKeySlotsRequest>(create);
  static GetKeySlotsRequest? _defaultInstance;
}

class GetKeySlotsResponse extends $pb.GeneratedMessage {
  factory GetKeySlotsResponse({
    $core.Iterable<KeySlot>? keySlots,
  }) {
    final result = create();
    if (keySlots != null) result.keySlots.addAll(keySlots);
    return result;
  }

  GetKeySlotsResponse._();

  factory GetKeySlotsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetKeySlotsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetKeySlotsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vault.v1'),
      createEmptyInstance: create)
    ..pPM<KeySlot>(1, _omitFieldNames ? '' : 'keySlots',
        subBuilder: KeySlot.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetKeySlotsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetKeySlotsResponse copyWith(void Function(GetKeySlotsResponse) updates) =>
      super.copyWith((message) => updates(message as GetKeySlotsResponse))
          as GetKeySlotsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetKeySlotsResponse create() => GetKeySlotsResponse._();
  @$core.override
  GetKeySlotsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetKeySlotsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetKeySlotsResponse>(create);
  static GetKeySlotsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<KeySlot> get keySlots => $_getList(0);
}

class SaveKeySlotsRequest extends $pb.GeneratedMessage {
  factory SaveKeySlotsRequest({
    $core.Iterable<KeySlot>? keySlots,
  }) {
    final result = create();
    if (keySlots != null) result.keySlots.addAll(keySlots);
    return result;
  }

  SaveKeySlotsRequest._();

  factory SaveKeySlotsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SaveKeySlotsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SaveKeySlotsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vault.v1'),
      createEmptyInstance: create)
    ..pPM<KeySlot>(1, _omitFieldNames ? '' : 'keySlots',
        subBuilder: KeySlot.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveKeySlotsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveKeySlotsRequest copyWith(void Function(SaveKeySlotsRequest) updates) =>
      super.copyWith((message) => updates(message as SaveKeySlotsRequest))
          as SaveKeySlotsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SaveKeySlotsRequest create() => SaveKeySlotsRequest._();
  @$core.override
  SaveKeySlotsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SaveKeySlotsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SaveKeySlotsRequest>(create);
  static SaveKeySlotsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<KeySlot> get keySlots => $_getList(0);
}

class SaveKeySlotsResponse extends $pb.GeneratedMessage {
  factory SaveKeySlotsResponse() => create();

  SaveKeySlotsResponse._();

  factory SaveKeySlotsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SaveKeySlotsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SaveKeySlotsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vault.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveKeySlotsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveKeySlotsResponse copyWith(void Function(SaveKeySlotsResponse) updates) =>
      super.copyWith((message) => updates(message as SaveKeySlotsResponse))
          as SaveKeySlotsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SaveKeySlotsResponse create() => SaveKeySlotsResponse._();
  @$core.override
  SaveKeySlotsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SaveKeySlotsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SaveKeySlotsResponse>(create);
  static SaveKeySlotsResponse? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
