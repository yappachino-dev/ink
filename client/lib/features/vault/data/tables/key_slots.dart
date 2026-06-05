import 'package:drift/drift.dart';
import 'package:ink/core/services/sync/sync_status.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';

@DataClassName('KeySlotModel')
class KeySlots extends Table {
  IntColumn get type => intEnum<KeyType>()();
  BlobColumn get salt => blob()();
  BlobColumn get wrappedMasterKey => blob()();

  IntColumn get syncStatus =>
      intEnum<SyncStatus>().withDefault(const Constant(syncModifiedIndex))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {type};
}
