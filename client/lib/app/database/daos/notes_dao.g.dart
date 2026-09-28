// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_dao.dart';

// ignore_for_file: type=lint
mixin _$NotesDaoMixin on DatabaseAccessor<AppDatabase> {
  $NotebooksTable get notebooks => attachedDatabase.notebooks;
  $NotesTable get notes => attachedDatabase.notes;
  $NoteConflictsTable get noteConflicts => attachedDatabase.noteConflicts;
  NotesDaoManager get managers => NotesDaoManager(this);
}

class NotesDaoManager {
  final _$NotesDaoMixin _db;
  NotesDaoManager(this._db);
  $$NotebooksTableTableManager get notebooks =>
      $$NotebooksTableTableManager(_db.attachedDatabase, _db.notebooks);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db.attachedDatabase, _db.notes);
  $$NoteConflictsTableTableManager get noteConflicts =>
      $$NoteConflictsTableTableManager(_db.attachedDatabase, _db.noteConflicts);
}
