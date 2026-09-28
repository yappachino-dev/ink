// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notebooks_dao.dart';

// ignore_for_file: type=lint
mixin _$NotebooksDaoMixin on DatabaseAccessor<AppDatabase> {
  $NotebooksTable get notebooks => attachedDatabase.notebooks;
  $NotebookConflictsTable get notebookConflicts =>
      attachedDatabase.notebookConflicts;
  NotebooksDaoManager get managers => NotebooksDaoManager(this);
}

class NotebooksDaoManager {
  final _$NotebooksDaoMixin _db;
  NotebooksDaoManager(this._db);
  $$NotebooksTableTableManager get notebooks =>
      $$NotebooksTableTableManager(_db.attachedDatabase, _db.notebooks);
  $$NotebookConflictsTableTableManager get notebookConflicts =>
      $$NotebookConflictsTableTableManager(
        _db.attachedDatabase,
        _db.notebookConflicts,
      );
}
