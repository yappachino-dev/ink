// This is a generated file - do not edit.
//
// Generated from vault/v1/vault.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use keyTypeDescriptor instead')
const KeyType$json = {
  '1': 'KeyType',
  '2': [
    {'1': 'KEY_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'KEY_TYPE_PIN', '2': 1},
    {'1': 'KEY_TYPE_PATTERN', '2': 2},
    {'1': 'KEY_TYPE_RECOVERY', '2': 3},
  ],
};

/// Descriptor for `KeyType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List keyTypeDescriptor = $convert.base64Decode(
    'CgdLZXlUeXBlEhgKFEtFWV9UWVBFX1VOU1BFQ0lGSUVEEAASEAoMS0VZX1RZUEVfUElOEAESFA'
    'oQS0VZX1RZUEVfUEFUVEVSThACEhUKEUtFWV9UWVBFX1JFQ09WRVJZEAM=');

@$core.Deprecated('Use keySlotDescriptor instead')
const KeySlot$json = {
  '1': 'KeySlot',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.vault.v1.KeyType',
      '10': 'type'
    },
    {'1': 'salt', '3': 2, '4': 1, '5': 12, '10': 'salt'},
    {
      '1': 'wrapped_master_key',
      '3': 3,
      '4': 1,
      '5': 12,
      '10': 'wrappedMasterKey'
    },
    {
      '1': 'updated_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `KeySlot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keySlotDescriptor = $convert.base64Decode(
    'CgdLZXlTbG90EiUKBHR5cGUYASABKA4yES52YXVsdC52MS5LZXlUeXBlUgR0eXBlEhIKBHNhbH'
    'QYAiABKAxSBHNhbHQSLAoSd3JhcHBlZF9tYXN0ZXJfa2V5GAMgASgMUhB3cmFwcGVkTWFzdGVy'
    'S2V5EjkKCnVwZGF0ZWRfYXQYBCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cG'
    'RhdGVkQXQ=');

@$core.Deprecated('Use getKeySlotsRequestDescriptor instead')
const GetKeySlotsRequest$json = {
  '1': 'GetKeySlotsRequest',
};

/// Descriptor for `GetKeySlotsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getKeySlotsRequestDescriptor =
    $convert.base64Decode('ChJHZXRLZXlTbG90c1JlcXVlc3Q=');

@$core.Deprecated('Use getKeySlotsResponseDescriptor instead')
const GetKeySlotsResponse$json = {
  '1': 'GetKeySlotsResponse',
  '2': [
    {
      '1': 'key_slots',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.vault.v1.KeySlot',
      '10': 'keySlots'
    },
  ],
};

/// Descriptor for `GetKeySlotsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getKeySlotsResponseDescriptor = $convert.base64Decode(
    'ChNHZXRLZXlTbG90c1Jlc3BvbnNlEi4KCWtleV9zbG90cxgBIAMoCzIRLnZhdWx0LnYxLktleV'
    'Nsb3RSCGtleVNsb3Rz');

@$core.Deprecated('Use saveKeySlotsRequestDescriptor instead')
const SaveKeySlotsRequest$json = {
  '1': 'SaveKeySlotsRequest',
  '2': [
    {
      '1': 'key_slots',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.vault.v1.KeySlot',
      '10': 'keySlots'
    },
  ],
};

/// Descriptor for `SaveKeySlotsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List saveKeySlotsRequestDescriptor = $convert.base64Decode(
    'ChNTYXZlS2V5U2xvdHNSZXF1ZXN0Ei4KCWtleV9zbG90cxgBIAMoCzIRLnZhdWx0LnYxLktleV'
    'Nsb3RSCGtleVNsb3Rz');

@$core.Deprecated('Use saveKeySlotsResponseDescriptor instead')
const SaveKeySlotsResponse$json = {
  '1': 'SaveKeySlotsResponse',
};

/// Descriptor for `SaveKeySlotsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List saveKeySlotsResponseDescriptor =
    $convert.base64Decode('ChRTYXZlS2V5U2xvdHNSZXNwb25zZQ==');
