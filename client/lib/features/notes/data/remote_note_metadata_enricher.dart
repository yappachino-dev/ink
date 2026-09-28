import 'dart:typed_data';

import 'package:ink/core/domain/result.dart';
import 'package:ink/core/services/session/crypto_session.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/data/note_decryptor.dart';
import 'package:ink/features/notes/data/notes_sync_engine.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/note_metadata.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';

/// Fills the derived-metadata cache for notes that arrive by sync.
///
/// Local writes derive metadata in `Note.toEncrypted`, where plaintext and
/// ciphertext coexist. Remote writes have no such moment: the sync pipeline
/// carries only `EncryptedNote`, so the cache has to be filled here. Without it
/// synced notes land in the database with an empty title preview and no
/// filterable day, and every list filter silently misses them — the exact
/// failure these columns exist to prevent, just on the other write path.
///
/// This sits in front of the repository rather than inside the local store
/// because `app/database` has no key, and must not be handed one to fill a
/// cache. The repository stays a pure persistence concern.
class RemoteNoteMetadataEnricher implements NotesSyncEngine {
  RemoteNoteMetadataEnricher({
    required NotesSyncEngine inner,
    required CryptoSession cryptoSession,
    required NoteDecryptor decryptor,
  }) : _inner = inner,
       _cryptoSession = cryptoSession,
       _decryptor = decryptor;

  final NotesSyncEngine _inner;
  final CryptoSession _cryptoSession;
  final NoteDecryptor _decryptor;

  @override
  Future<Result<void, NotesFailure>> applyRemoteNotes(
    List<EncryptedNote> remoteData,
  ) async {
    if (remoteData.isEmpty) return _inner.applyRemoteNotes(remoteData);

    final enriched = <EncryptedNote>[];

    // A locked vault is not a reason to refuse the batch. The ciphertext is
    // valid and the server already sent it; only the *derivation* needs the
    // key. Storing it with a stale metadata tag means the note is present the
    // moment the user unlocks, and _backfillMetadata fills the columns then.
    //
    // Throwing instead would stall the entire sync - notebooks included,
    // and the cursor with it - for as long as the vault stayed locked.
    if (!_cryptoSession.hasKey) {
      for (final note in remoteData) {
        enriched.add(note.copyWith(metadata: deferredNoteMetadata));
      }
      return _inner.applyRemoteNotes(enriched);
    }

    // Read once for the whole batch. A batch is bounded by what one sync can
    // carry, so a single read matters more here than throughput.
    final key = _cryptoSession.masterKey;

    // Sequential on purpose: this runs under the session's key, and one read
    // per batch is the property worth keeping.
    for (final note in remoteData) {
      enriched.add(note.copyWith(metadata: await _metadataFor(note, key)));
    }

    return _inner.applyRemoteNotes(enriched);
  }

  Future<NoteMetadata> _metadataFor(EncryptedNote note, Uint8List key) async {
    try {
      final decrypted = await _decryptor.decrypt(note, key);

      return NoteMetadataDerivation.derive(
        title: decrypted.title,
        content: decrypted.content,
        dueDate: decrypted.dueDate,
      );
    } on Object {
      // Distinct from a locked vault: there the vault is fine and the work is
      // merely early, so it is deferred. Here the content is unreadable even
      // with the key in hand, so the row is marked current — retrying it on
      // every future read would never succeed. The note must still land, or it
      // vanishes from the user's view entirely, and the payload is left
      // untouched either way.
      return const NoteMetadata();
    }
  }

  @override
  Future<Result<List<EncryptedNote>, NotesFailure>> getPendingNotes() =>
      _inner.getPendingNotes();

  @override
  Future<Result<void, NotesFailure>> acknowledgePushedNotes(
    List<SyncAck> acknowledgements,
  ) => _inner.acknowledgePushedNotes(acknowledgements);
}
