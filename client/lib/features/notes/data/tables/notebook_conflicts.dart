import 'package:drift/drift.dart';
import 'package:ink/features/notes/data/tables/notebooks.dart';

@DataClassName('NotebookConflictModel')
class NotebookConflicts extends Table {
  TextColumn get id => text().references(
    Notebooks,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();

  BlobColumn get encryptedContent => blob()();

  IntColumn get version => integer()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
