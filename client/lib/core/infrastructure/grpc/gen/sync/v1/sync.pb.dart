// This is a generated file - do not edit.
//
// Generated from sync/v1/sync.proto.

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

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class SyncRequest extends $pb.GeneratedMessage {
  factory SyncRequest({
    $core.int? cursor,
    SyncChanges? changes,
  }) {
    final result = create();
    if (cursor != null) result.cursor = cursor;
    if (changes != null) result.changes = changes;
    return result;
  }

  SyncRequest._();

  factory SyncRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SyncRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sync.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'cursor')
    ..aOM<SyncChanges>(2, _omitFieldNames ? '' : 'changes',
        subBuilder: SyncChanges.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncRequest copyWith(void Function(SyncRequest) updates) =>
      super.copyWith((message) => updates(message as SyncRequest))
          as SyncRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncRequest create() => SyncRequest._();
  @$core.override
  SyncRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SyncRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SyncRequest>(create);
  static SyncRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get cursor => $_getIZ(0);
  @$pb.TagNumber(1)
  set cursor($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCursor() => $_has(0);
  @$pb.TagNumber(1)
  void clearCursor() => $_clearField(1);

  @$pb.TagNumber(2)
  SyncChanges get changes => $_getN(1);
  @$pb.TagNumber(2)
  set changes(SyncChanges value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasChanges() => $_has(1);
  @$pb.TagNumber(2)
  void clearChanges() => $_clearField(2);
  @$pb.TagNumber(2)
  SyncChanges ensureChanges() => $_ensure(1);
}

class SyncResponse extends $pb.GeneratedMessage {
  factory SyncResponse({
    $core.int? nextCursor,
    SyncChanges? changes,
  }) {
    final result = create();
    if (nextCursor != null) result.nextCursor = nextCursor;
    if (changes != null) result.changes = changes;
    return result;
  }

  SyncResponse._();

  factory SyncResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SyncResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sync.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'nextCursor')
    ..aOM<SyncChanges>(2, _omitFieldNames ? '' : 'changes',
        subBuilder: SyncChanges.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncResponse copyWith(void Function(SyncResponse) updates) =>
      super.copyWith((message) => updates(message as SyncResponse))
          as SyncResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncResponse create() => SyncResponse._();
  @$core.override
  SyncResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SyncResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SyncResponse>(create);
  static SyncResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get nextCursor => $_getIZ(0);
  @$pb.TagNumber(1)
  set nextCursor($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNextCursor() => $_has(0);
  @$pb.TagNumber(1)
  void clearNextCursor() => $_clearField(1);

  @$pb.TagNumber(2)
  SyncChanges get changes => $_getN(1);
  @$pb.TagNumber(2)
  set changes(SyncChanges value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasChanges() => $_has(1);
  @$pb.TagNumber(2)
  void clearChanges() => $_clearField(2);
  @$pb.TagNumber(2)
  SyncChanges ensureChanges() => $_ensure(1);
}

class SyncChanges extends $pb.GeneratedMessage {
  factory SyncChanges({
    $core.Iterable<Notebook>? notebooks,
    $core.Iterable<Note>? notes,
  }) {
    final result = create();
    if (notebooks != null) result.notebooks.addAll(notebooks);
    if (notes != null) result.notes.addAll(notes);
    return result;
  }

  SyncChanges._();

  factory SyncChanges.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SyncChanges.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncChanges',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sync.v1'),
      createEmptyInstance: create)
    ..pPM<Notebook>(1, _omitFieldNames ? '' : 'notebooks',
        subBuilder: Notebook.create)
    ..pPM<Note>(2, _omitFieldNames ? '' : 'notes', subBuilder: Note.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncChanges clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncChanges copyWith(void Function(SyncChanges) updates) =>
      super.copyWith((message) => updates(message as SyncChanges))
          as SyncChanges;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncChanges create() => SyncChanges._();
  @$core.override
  SyncChanges createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SyncChanges getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SyncChanges>(create);
  static SyncChanges? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Notebook> get notebooks => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<Note> get notes => $_getList(1);
}

class Notebook extends $pb.GeneratedMessage {
  factory Notebook({
    $core.String? id,
    $core.List<$core.int>? encryptedContent,
    $core.int? version,
    $1.Timestamp? createdAt,
    $1.Timestamp? updatedAt,
    $1.Timestamp? deletedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (encryptedContent != null) result.encryptedContent = encryptedContent;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    return result;
  }

  Notebook._();

  factory Notebook.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Notebook.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Notebook',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sync.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'encryptedContent', $pb.PbFieldType.OY)
    ..aI(3, _omitFieldNames ? '' : 'version')
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(5, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(6, _omitFieldNames ? '' : 'deletedAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notebook clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notebook copyWith(void Function(Notebook) updates) =>
      super.copyWith((message) => updates(message as Notebook)) as Notebook;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Notebook create() => Notebook._();
  @$core.override
  Notebook createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Notebook getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Notebook>(create);
  static Notebook? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get encryptedContent => $_getN(1);
  @$pb.TagNumber(2)
  set encryptedContent($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEncryptedContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptedContent() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get version => $_getIZ(2);
  @$pb.TagNumber(3)
  set version($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Timestamp get createdAt => $_getN(3);
  @$pb.TagNumber(4)
  set createdAt($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureCreatedAt() => $_ensure(3);

  @$pb.TagNumber(5)
  $1.Timestamp get updatedAt => $_getN(4);
  @$pb.TagNumber(5)
  set updatedAt($1.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasUpdatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearUpdatedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.Timestamp ensureUpdatedAt() => $_ensure(4);

  @$pb.TagNumber(6)
  $1.Timestamp get deletedAt => $_getN(5);
  @$pb.TagNumber(6)
  set deletedAt($1.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasDeletedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearDeletedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $1.Timestamp ensureDeletedAt() => $_ensure(5);
}

class Note extends $pb.GeneratedMessage {
  factory Note({
    $core.String? id,
    $core.String? notebookId,
    $core.List<$core.int>? encryptedTitle,
    $core.List<$core.int>? encryptedContent,
    $core.int? version,
    $1.Timestamp? createdAt,
    $1.Timestamp? updatedAt,
    $1.Timestamp? deletedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (notebookId != null) result.notebookId = notebookId;
    if (encryptedTitle != null) result.encryptedTitle = encryptedTitle;
    if (encryptedContent != null) result.encryptedContent = encryptedContent;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    return result;
  }

  Note._();

  factory Note.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Note.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Note',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sync.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'notebookId')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'encryptedTitle', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'encryptedContent', $pb.PbFieldType.OY)
    ..aI(5, _omitFieldNames ? '' : 'version')
    ..aOM<$1.Timestamp>(6, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(7, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(8, _omitFieldNames ? '' : 'deletedAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Note clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Note copyWith(void Function(Note) updates) =>
      super.copyWith((message) => updates(message as Note)) as Note;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Note create() => Note._();
  @$core.override
  Note createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Note getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Note>(create);
  static Note? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get notebookId => $_getSZ(1);
  @$pb.TagNumber(2)
  set notebookId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNotebookId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNotebookId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get encryptedTitle => $_getN(2);
  @$pb.TagNumber(3)
  set encryptedTitle($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEncryptedTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncryptedTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get encryptedContent => $_getN(3);
  @$pb.TagNumber(4)
  set encryptedContent($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEncryptedContent() => $_has(3);
  @$pb.TagNumber(4)
  void clearEncryptedContent() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get version => $_getIZ(4);
  @$pb.TagNumber(5)
  set version($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $1.Timestamp get createdAt => $_getN(5);
  @$pb.TagNumber(6)
  set createdAt($1.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $1.Timestamp ensureCreatedAt() => $_ensure(5);

  @$pb.TagNumber(7)
  $1.Timestamp get updatedAt => $_getN(6);
  @$pb.TagNumber(7)
  set updatedAt($1.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasUpdatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearUpdatedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.Timestamp ensureUpdatedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $1.Timestamp get deletedAt => $_getN(7);
  @$pb.TagNumber(8)
  set deletedAt($1.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasDeletedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearDeletedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $1.Timestamp ensureDeletedAt() => $_ensure(7);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
