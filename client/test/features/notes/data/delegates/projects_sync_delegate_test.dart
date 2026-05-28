import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/data/delegates/projects_sync_delegate.dart';
import 'package:ink/features/notes/data/unified_notes_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/notes_fixtures.dart';

class MockUnifiedNotesRepository extends Mock
    implements UnifiedNotesRepository {}

void main() {
  late MockUnifiedNotesRepository mockRepo;
  late ProjectsSyncDelegate delegate;

  setUp(() {
    mockRepo = MockUnifiedNotesRepository();
    delegate = ProjectsSyncDelegate(engine: mockRepo);
  });

  group('ProjectsSyncDelegate', () {
    test('syncKey and syncPriority are correctly defined', () {
      expect(delegate.syncKey, equals('projects'));
      expect(delegate.syncPriority, equals(100));
    });

    test('getLocalChanges maps DTOs to raw JSON lists', () async {
      final dto = NotesFixtures.buildProjectDto(id: 'note_1');

      when(
        () => mockRepo.getPendingProjects(),
      ).thenAnswer((_) async => Success([dto]));

      final result = await delegate.getLocalChanges();
      final jsonList = result.unwrap;

      expect(jsonList.length, 1);
      expect(jsonList.first['id'], equals('note_1'));
      verify(() => mockRepo.getPendingProjects()).called(1);
    });

    test('acknowledgePush correctly formats SyncAcknowledgements', () async {
      when(
        () => mockRepo.acknowledgePushedProjects(any()),
      ).thenAnswer((_) async => const Success(null));

      final pushedData = [
        NotesFixtures.buildProjectDto(id: 'ack_1', version: 3).toJson(),
        NotesFixtures.buildProjectDto(
          id: 'ack_del',
          version: 2,
          deletedAt: DateTime.now(),
        ).toJson(),
      ];

      await delegate.acknowledgePush(pushedData);

      final captured = verify(
        () => mockRepo.acknowledgePushedProjects(captureAny()),
      ).captured;
      final acks = captured.first as List<SyncAck>;

      expect(acks.length, 2);
      expect(acks[0].id, 'ack_1');
      expect(acks[0].version, 3);
      expect(acks[0].isDeleted, false);

      expect(acks[1].id, 'ack_del');
      expect(acks[1].isDeleted, true);
    });

    test(
      'applyRemoteChanges decodes JSON and passes DTOs to repository',
      () async {
        when(
          () => mockRepo.applyRemoteProjects(any()),
        ).thenAnswer((_) async => const Success(null));

        final remoteData = [
          NotesFixtures.buildProjectDto(id: 'remote_1').toJson(),
        ];

        await delegate.applyRemoteChanges(remoteData);

        final captured = verify(
          () => mockRepo.applyRemoteProjects(captureAny()),
        ).captured;
        final dtos = captured.first as List<dynamic>;

        expect(dtos.length, 1);
        expect(dtos.first.id, 'remote_1');
      },
    );
  });
}
