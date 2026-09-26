import 'dart:convert';
import 'dart:typed_data';

import 'package:ink/core/infrastructure/crypto/crypto.dart';
import 'package:ink/features/notes/data/models/note_payload.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/mappers/notes_mapper.dart';

/// Turns an encrypted note row back into a plaintext [Note].
///
/// Extracted from `SecureNotesService` so that the sync path and the ordinary
/// read path cannot drift apart. Both must agree on how a `NotePayload` maps
/// back onto a note; a second copy of that mapping would be a silent
/// correctness hazard the first time the payload format changed.
class NoteDecryptor {
  const NoteDecryptor(this._encryption);

  final EncryptionService _encryption;

  /// Decrypts [encryptedNote]. Throws if the payload is unreadable, which the
  /// caller decides how to handle: a read surfaces the failure, while a sync
  /// apply substitutes degraded metadata so the note still lands.
  Future<Note> decrypt(EncryptedNote encryptedNote, Uint8List masterKey) async {
    final title = await _encryption.decryptString(
      encryptedNote.encryptedTitle,
      masterKey,
    );
    final plainContent = await _encryption.decryptString(
      encryptedNote.encryptedContent,
      masterKey,
    );

    final payload = NotePayload.fromJson(
      jsonDecode(plainContent) as Map<String, dynamic>,
    );

    return encryptedNote.toNote(
      title: title,
      content: payload.quillData,
      isCompleted: payload.isCompleted,
      priority: payload.priority,
      dueDate: payload.dueDate,
      dueTime: payload.dueTime == null
          ? null
          : (
              hour: payload.dueTime!.hour,
              minute: payload.dueTime!.minute,
            ),
      reminderMinutesBefore: payload.reminderMinutesBefore,
    );
  }
}
