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
      '1': 'projects',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.sync.v1.Project',
      '10': 'projects'
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
    'CgtTeW5jQ2hhbmdlcxIsCghwcm9qZWN0cxgBIAMoCzIQLnN5bmMudjEuUHJvamVjdFIIcHJvam'
    'VjdHMSIwoFbm90ZXMYAiADKAsyDS5zeW5jLnYxLk5vdGVSBW5vdGVz');

@$core.Deprecated('Use projectDescriptor instead')
const Project$json = {
  '1': 'Project',
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

/// Descriptor for `Project`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectDescriptor = $convert.base64Decode(
    'CgdQcm9qZWN0Eg4KAmlkGAEgASgJUgJpZBIrChFlbmNyeXB0ZWRfY29udGVudBgCIAEoDFIQZW'
    '5jcnlwdGVkQ29udGVudBIYCgd2ZXJzaW9uGAMgASgFUgd2ZXJzaW9uEjkKCmNyZWF0ZWRfYXQY'
    'BCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdXBkYXRlZF'
    '9hdBgFIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdBI5CgpkZWxl'
    'dGVkX2F0GAYgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJZGVsZXRlZEF0');

@$core.Deprecated('Use noteDescriptor instead')
const Note$json = {
  '1': 'Note',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'project_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'projectId',
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
    {'1': '_project_id'},
  ],
};

/// Descriptor for `Note`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List noteDescriptor = $convert.base64Decode(
    'CgROb3RlEg4KAmlkGAEgASgJUgJpZBIiCgpwcm9qZWN0X2lkGAIgASgJSABSCXByb2plY3RJZI'
    'gBARInCg9lbmNyeXB0ZWRfdGl0bGUYAyABKAxSDmVuY3J5cHRlZFRpdGxlEisKEWVuY3J5cHRl'
    'ZF9jb250ZW50GAQgASgMUhBlbmNyeXB0ZWRDb250ZW50EhgKB3ZlcnNpb24YBSABKAVSB3Zlcn'
    'Npb24SOQoKY3JlYXRlZF9hdBgGIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNy'
    'ZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GAcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcF'
    'IJdXBkYXRlZEF0EjkKCmRlbGV0ZWRfYXQYCCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0'
    'YW1wUglkZWxldGVkQXRCDQoLX3Byb2plY3RfaWQ=');
