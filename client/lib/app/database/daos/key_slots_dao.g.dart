// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_slots_dao.dart';

// ignore_for_file: type=lint
mixin _$KeySlotsDaoMixin on DatabaseAccessor<AppDatabase> {
  $KeySlotsTable get keySlots => attachedDatabase.keySlots;
  KeySlotsDaoManager get managers => KeySlotsDaoManager(this);
}

class KeySlotsDaoManager {
  final _$KeySlotsDaoMixin _db;
  KeySlotsDaoManager(this._db);
  $$KeySlotsTableTableManager get keySlots =>
      $$KeySlotsTableTableManager(_db.attachedDatabase, _db.keySlots);
}
