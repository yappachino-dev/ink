import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_animations.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/app_fab.dart';
import 'package:ink/features/notes/presentation/navigation/notes_routes.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/notes_view_state_provider.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/notebooks/notebooks_drawer.dart';
import 'package:ink/features/notes/presentation/widgets/notes/notes_view.dart';
import 'package:ink/features/notes/presentation/widgets/notes/offline_banner.dart';
import 'package:ink/features/notes/presentation/widgets/notes/sync_trust_indicator.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

/// The notes list, and the app's landing view.
///
/// Named for what it is rather than what it replaced: this was `HomeScreen`
/// with a `home.*` translation namespace, both left over from an MVP where the
/// landing screen was a different thing. The tab is "Notes", the route is
/// `/notes`, and the lens labels now live in the `notes.*` namespace beside the
/// other notes-list strings.
///
/// Owns the notebooks drawer, the FAB, and the offline and sync banners, and
/// renders whichever lens `notesLensSelectionProvider` currently names.
class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen>
    with SingleTickerProviderStateMixin {
  bool _isDrawerOpen = false;

  late AnimationController _drawerController;
  late Animation<double> _drawerAnimation;

  @override
  void initState() {
    super.initState();

    _drawerController = AnimationController(
      vsync: this,
      duration: AppDurations.drawer,
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

  Future<void> _openNewNote() => const NoteNewRoute().push<void>(context);

  @override
  Widget build(BuildContext context) {
    final viewState = ref.watch(notesViewStateProvider);
    final showDescription = ref.watch(showDescriptionProvider);

    return Scaffold(
      backgroundColor: context.ink.surface,
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
                  const SyncTrustIndicator(),
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

              const OfflineBanner(),
              Expanded(
                child: Padding(
                  // Horizontal only. A bottom inset here shrinks the scroll
                  // viewport rather than adding room below the last card, so
                  // the list stopped short of the navigation bar and left a
                  // band of bare background between the final note and the
                  // bar, clipping the last card against it. Calendar's
                  // journal is inset on the sides for the same reason and has
                  // no bottom inset, so the two surfaces now end the same way.
                  padding: AppSpacing.screen,
                  child: AnimatedSwitcher(
                    duration: AppDurations.sheet,
                    // Keyed on the state *type*, never the instance: see
                    // [NotesViewState.switcherKey].
                    child: NotesView(
                      key: ValueKey(viewState.switcherKey),
                      state: viewState,
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_isDrawerOpen)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _drawerAnimation,
                builder: (_, _) => GestureDetector(
                  onTap: _closeDrawer,
                  behavior: HitTestBehavior.opaque,
                  child: ColoredBox(
                    color: context.ink.scrim.withValues(
                      alpha: context.ink.scrim.a * _drawerAnimation.value,
                    ),
                  ),
                ),
              ),
            ),

          if (_isDrawerOpen)
            AnimatedBuilder(
              animation: _drawerAnimation,
              builder: (_, child) {
                final screenWidth = MediaQuery.of(context).size.width;
                final drawerWidth = screenWidth * AppLayout.drawerWidthRatio;

                return Positioned(
                  left: -drawerWidth * (1 - _drawerAnimation.value),
                  top: 0,
                  bottom: 0,
                  width: drawerWidth,
                  child: child!,
                );
              },
              child: const NotebooksDrawer(),
            ),
        ],
      ),
      // In the Scaffold's slot rather than `Positioned` in the Stack above, so
      // it lands identically to Calendar's. The drawer animation comes along
      // for the ride: at scale 0 the button has no hit area, so the open
      // drawer cannot have it swallow taps meant for the scrim.
      floatingActionButtonLocation: const AppFabLocation(),
      floatingActionButton: AnimatedScale(
        scale: _isDrawerOpen ? 0.0 : 1.0,
        duration: AppDurations.base,
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _isDrawerOpen ? 0.0 : 1.0,
          duration: AppDurations.base,
          child: AppFab(onPressed: _isDrawerOpen ? null : _openNewNote),
        ),
      ),
    );
  }
}
