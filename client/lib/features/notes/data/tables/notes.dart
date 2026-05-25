import 'package:drift/drift.dart';
import 'package:ink/core/services/sync/sync_status.dart';
import 'package:ink/features/notes/data/tables/projects.dart';
import 'package:uuid/v7.dart';

@DataClassName('NoteModel')
class Notes extends Table {
  TextColumn get id => text().clientDefault(const UuidV7().generate)();
  BlobColumn get encryptedTitle => blob()();
  BlobColumn get encryptedContent => blob()();

  IntColumn get localVersion => integer().withDefault(const Constant(1))();
  IntColumn get lastSyncedVersion => integer().withDefault(const Constant(0))();
  IntColumn get syncStatus =>
      intEnum<SyncStatus>().withDefault(const Constant(1))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  TextColumn get projectId => text().nullable().references(
    Projects,
    #id,
    onDelete: KeyAction.setNull,
    onUpdate: KeyAction.cascade,
  )();

  @override
  Set<Column> get primaryKey => {id};
}
