// This is a generated file - do not edit.
//
// Generated from sync/v1/sync.proto.

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

@$core.Deprecated('Use syncRequestDescriptor instead')
const SyncRequest$json = {
  '1': 'SyncRequest',
  '2': [
    {'1': 'cursor', '3': 1, '4': 1, '5': 5, '10': 'cursor'},
    {
      '1': 'changes',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.sync.v1.SyncChanges',
      '10': 'changes'
    },
  ],
};

/// Descriptor for `SyncRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncRequestDescriptor = $convert.base64Decode(
    'CgtTeW5jUmVxdWVzdBIWCgZjdXJzb3IYASABKAVSBmN1cnNvchIuCgdjaGFuZ2VzGAIgASgLMh'
    'Quc3luYy52MS5TeW5jQ2hhbmdlc1IHY2hhbmdlcw==');

@$core.Deprecated('Use syncResponseDescriptor instead')
const SyncResponse$json = {
  '1': 'SyncResponse',
  '2': [
    {'1': 'next_cursor', '3': 1, '4': 1, '5': 5, '10': 'nextCursor'},
    {
      '1': 'changes',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.sync.v1.SyncChanges',
      '10': 'changes'
    },
  ],
};

/// Descriptor for `SyncResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncResponseDescriptor = $convert.base64Decode(
    'CgxTeW5jUmVzcG9uc2USHwoLbmV4dF9jdXJzb3IYASABKAVSCm5leHRDdXJzb3ISLgoHY2hhbm'
    'dlcxgCIAEoCzIULnN5bmMudjEuU3luY0NoYW5nZXNSB2NoYW5nZXM=');

@$core.Deprecated('Use syncChangesDescriptor instead')
const SyncChanges$json = {
  '1': 'SyncChanges',
  '2': [
    {
      '1': 'notebooks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.sync.v1.Notebook',
      '10': 'notebooks'
    },
    {
      '1': 'notes',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.sync.v1.Note',
      '10': 'notes'
    },
  ],
};

/// Descriptor for `SyncChanges`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncChangesDescriptor = $convert.base64Decode(
    'CgtTeW5jQ2hhbmdlcxIvCglub3RlYm9va3MYASADKAsyES5zeW5jLnYxLk5vdGVib29rUglub3'
    'RlYm9va3MSIwoFbm90ZXMYAiADKAsyDS5zeW5jLnYxLk5vdGVSBW5vdGVz');

@$core.Deprecated('Use notebookDescriptor instead')
const Notebook$json = {
  '1': 'Notebook',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'encrypted_content',
      '3': 2,
      '4': 1,
      '5': 12,
      '10': 'encryptedContent'
    },
    {'1': 'version', '3': 3, '4': 1, '5': 5, '10': 'version'},
    {
      '1': 'created_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
    {
      '1': 'deleted_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'deletedAt'
    },
  ],
};

/// Descriptor for `Notebook`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notebookDescriptor = $convert.base64Decode(
    'CghOb3RlYm9vaxIOCgJpZBgBIAEoCVICaWQSKwoRZW5jcnlwdGVkX2NvbnRlbnQYAiABKAxSEG'
    'VuY3J5cHRlZENvbnRlbnQSGAoHdmVyc2lvbhgDIAEoBVIHdmVyc2lvbhI5CgpjcmVhdGVkX2F0'
    'GAQgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZW'
    'RfYXQYBSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQSOQoKZGVs'
    'ZXRlZF9hdBgGIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWRlbGV0ZWRBdA==');

@$core.Deprecated('Use noteDescriptor instead')
const Note$json = {
  '1': 'Note',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'notebook_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'notebookId',
      '17': true
    },
    {'1': 'encrypted_title', '3': 3, '4': 1, '5': 12, '10': 'encryptedTitle'},
    {
      '1': 'encrypted_content',
      '3': 4,
      '4': 1,
      '5': 12,
      '10': 'encryptedContent'
    },
    {'1': 'version', '3': 5, '4': 1, '5': 5, '10': 'version'},
    {
      '1': 'created_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
    {
      '1': 'deleted_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'deletedAt'
    },
  ],
  '8': [
    {'1': '_notebook_id'},
  ],
};

/// Descriptor for `Note`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List noteDescriptor = $convert.base64Decode(
    'CgROb3RlEg4KAmlkGAEgASgJUgJpZBIkCgtub3RlYm9va19pZBgCIAEoCUgAUgpub3RlYm9va0'
    'lkiAEBEicKD2VuY3J5cHRlZF90aXRsZRgDIAEoDFIOZW5jcnlwdGVkVGl0bGUSKwoRZW5jcnlw'
    'dGVkX2NvbnRlbnQYBCABKAxSEGVuY3J5cHRlZENvbnRlbnQSGAoHdmVyc2lvbhgFIAEoBVIHdm'
    'Vyc2lvbhI5CgpjcmVhdGVkX2F0GAYgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJ'
    'Y3JlYXRlZEF0EjkKCnVwZGF0ZWRfYXQYByABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW'
    '1wUgl1cGRhdGVkQXQSOQoKZGVsZXRlZF9hdBgIIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1l'
    'c3RhbXBSCWRlbGV0ZWRBdEIOCgxfbm90ZWJvb2tfaWQ=');
