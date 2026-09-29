import 'package:drift/drift.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/services/sync/sync_indexes.dart';
import 'package:ink/features/notes/data/tables/notebooks.dart';
import 'package:uuid/v7.dart';

@DataClassName('NoteModel')
@TableIndex(name: 'notes_metadata_version', columns: {#metadataVersion})
class Notes extends Table {
  TextColumn get id => text().clientDefault(const UuidV7().generate)();
  BlobColumn get encryptedTitle => blob()();
  BlobColumn get encryptedContent => blob()();

  // Local plaintext cache of facts already inside the encrypted payload. Never
  // synced. See NoteMetadata for why these exist and what they may not be used
  // for.
  TextColumn get titlePreview => text().withDefault(const Constant(''))();
  TextColumn get bodyPreview => text().withDefault(const Constant(''))();
  DateTimeColumn get dueDateDay => dateTime().nullable()();
  // Indexed because `findStaleMetadataNoteIds` runs on every notes read, and it
  // scans the whole table without this. `dueDateDay` is deliberately *not*
  // indexed: no query reads it yet, and an index on a column nothing filters
  // only costs write amplification and storage. Add it with the Today/Overdue
  // work that first filters on it.
  IntColumn get metadataVersion => integer().withDefault(const Constant(0))();

  IntColumn get localVersion => integer().withDefault(const Constant(1))();
  IntColumn get lastSyncedVersion => integer().withDefault(const Constant(0))();
  IntColumn get syncStatus =>
      intEnum<SyncStatus>().withDefault(const Constant(syncModifiedIndex))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  TextColumn get notebookId => text().nullable().references(
    Notebooks,
    #id,
    onDelete: KeyAction.setNull,
    onUpdate: KeyAction.cascade,
  )();

  @override
  Set<Column> get primaryKey => {id};
}
