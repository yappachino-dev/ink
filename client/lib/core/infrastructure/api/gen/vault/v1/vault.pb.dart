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
    as $0;

import 'vault.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'vault.pbenum.dart';

class KeySlot extends $pb.GeneratedMessage {
  factory KeySlot({
    KeyType? type,
    $core.List<$core.int>? salt,
    $core.List<$core.int>? wrappedMasterKey,
    $0.Timestamp? updatedAt,
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
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
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
  $0.Timestamp get updatedAt => $_getN(3);
  @$pb.TagNumber(4)
  set updatedAt($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasUpdatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearUpdatedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureUpdatedAt() => $_ensure(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
