import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/filtered_notes_provider.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/bottom_nav.dart';
import 'package:ink/features/notes/presentation/widgets/notes/editor/note_editor_sheet.dart';
import 'package:ink/features/notes/presentation/widgets/notes/empty_state_view.dart';
import 'package:ink/features/notes/presentation/widgets/notes/task_list_view.dart';
import 'package:ink/features/notes/presentation/widgets/projects/projects_drawer.dart';
import 'package:ink/i18n/strings.g.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isBottomSheetLayoutOpen = false;
  bool _isDrawerOpen = false;

  late AnimationController _drawerController;
  late Animation<double> _drawerAnimation;

  @override
  void initState() {
    super.initState();

    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _drawerAnimation = CurvedAnimation(
      parent: _drawerController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  Future<void> _openDrawer() async {
    setState(() => _isDrawerOpen = true);
    await _drawerController.forward();
  }

  Future<void> _closeDrawer() async {
    await _drawerController.reverse().whenComplete(
      () => setState(() => _isDrawerOpen = false),
    );
  }

  Future<void> _openAddTask() async {
    setState(() => _isBottomSheetLayoutOpen = true);

    await context
        .showAppBottomSheetLayout<void>(
          child: const NoteEditorSheet(),
        )
        .whenComplete(() => setState(() => _isBottomSheetLayoutOpen = false));
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(projectNotesProvider);
    final selectedProjectId = ref.watch(selectedProjectIdProvider);
    final selectedProjectTitle = ref.watch(selectedProjectTitleProvider);
    final showDescription = ref.watch(showDescriptionProvider);

    return Scaffold(
      backgroundColor: context.customColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: _openDrawer,
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      showDescription
                          ? Icons.subject_rounded
                          : Icons.short_text_rounded,
                      color: showDescription
                          ? context.colorScheme.onSurface
                          : context.colorScheme.primary,
                    ),
                    tooltip: showDescription
                        ? context.t.note.hideDetails
                        : context.t.note.showDetails,
                    onPressed: ref
                        .read(showDescriptionProvider.notifier)
                        .toggle,
                  ),
                ],
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: notes.isNotEmpty
                      ? TaskListView(
                          key: ValueKey('list-$selectedProjectId'),
                          title: selectedProjectTitle,
                        )
                      : EmptyStateView(
                          key: const ValueKey('empty'),
                          title: selectedProjectTitle,
                        ),
                ),
              ),
            ],
          ),

          Positioned(
            right: 16,
            bottom: 16,
            child: AnimatedScale(
              scale: _isDrawerOpen ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                opacity: _isDrawerOpen ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 180),
                child: FloatingActionButton(
                  onPressed: _isDrawerOpen ? null : _openAddTask,
                  backgroundColor: context.colorScheme.primary,
                  foregroundColor: context.colorScheme.surface,
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, size: 28),
                ),
              ),
            ),
          ),

          if (_isBottomSheetLayoutOpen)
            Positioned.fill(
              child: IgnorePointer(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),

          if (_isDrawerOpen)
            AnimatedBuilder(
              animation: _drawerAnimation,
              builder: (_, _) => GestureDetector(
                onTap: _closeDrawer,
                child: Container(
                  color: context.colorScheme.shadow.withValues(
                    alpha: 0.35 * _drawerAnimation.value,
                  ),
                ),
              ),
            ),

          if (_isDrawerOpen)
            AnimatedBuilder(
              animation: _drawerAnimation,
              builder: (_, child) {
                final screenWidth = MediaQuery.of(context).size.width;
                final drawerWidth = screenWidth * 0.82;
                return Positioned(
                  left: -drawerWidth * (1 - _drawerAnimation.value),
                  top: 0,
                  bottom: 0,
                  width: drawerWidth,
                  child: child!,
                );
              },
              child: const ProjectsDrawer(),
            ),
        ],
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}
