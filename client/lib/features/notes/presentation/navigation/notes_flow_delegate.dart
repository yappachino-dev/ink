import 'package:riverpod_annotation/riverpod_annotation.dart';

abstract interface class NotesFlowDelegate {}

@Riverpod(keepAlive: true)
NotesFlowDelegate notesFlowDelegate(Ref ref) =>
    throw UnimplementedError('notesFlowDelegate must be overridden in main');
