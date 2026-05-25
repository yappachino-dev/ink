import 'package:drift/drift.dart';
import 'package:ink/features/notes/data/tables/notes.dart';
import 'package:ink/features/notes/data/tables/projects.dart';

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

  TextColumn get projectId => text().nullable().references(
    Projects,
    #id,
    onDelete: KeyAction.setNull,
    onUpdate: KeyAction.cascade,
  )();

  @override
  Set<Column> get primaryKey => {id};
}
