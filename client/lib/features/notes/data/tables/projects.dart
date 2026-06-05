import 'package:drift/drift.dart';
import 'package:ink/core/services/sync/sync_status.dart';
import 'package:uuid/v7.dart';

@DataClassName('ProjectModel')
class Projects extends Table {
  TextColumn get id => text().clientDefault(const UuidV7().generate)();
  BlobColumn get encryptedContent => blob()();

  IntColumn get localVersion => integer().withDefault(const Constant(1))();
  IntColumn get lastSyncedVersion => integer().withDefault(const Constant(0))();
  IntColumn get syncStatus =>
      intEnum<SyncStatus>().withDefault(const Constant(syncModifiedIndex))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
