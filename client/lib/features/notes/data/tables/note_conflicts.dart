import 'package:drift/drift.dart';
import 'package:ink/features/notes/data/tables/notebooks.dart';
import 'package:ink/features/notes/data/tables/notes.dart';

@DataClassName('NoteConflictModel')
class NoteConflicts extends Table {
  TextColumn get id => text().references(
    Notes,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();

  BlobColumn get encryptedTitle => blob()();
  BlobColumn get encryptedContent => blob()();

  IntColumn get version => integer()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
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
