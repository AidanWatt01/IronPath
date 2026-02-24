import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data/db/app_db.dart";
import "../domain/training_mode.dart";
import "../state/providers.dart";
import "screens/badges_screen.dart";
import "screens/dashboard_screen.dart";
import "screens/history_screen.dart";
import "screens/movements_screen.dart";
import "screens/perks_screen.dart";
import "screens/running_dashboard_screen.dart";
import "screens/running_goals_screen.dart";
import "screens/running_plan_screen.dart";
import "screens/running_tree_screen.dart";
import "screens/shop_screen.dart";
import "screens/skill_tree_screen.dart";
import "widgets/badge_earned_toast.dart";

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int index = 0;

  static const double _kCompactMax = 760;
  static const double _kExtendedRailMin = 1100;
  static const _kCompactMoreNavItem = _NavItem(
    id: "more",
    label: "More",
    icon: Icons.menu_rounded,
    selectedIcon: Icons.menu_open_rounded,
  );

  static const _calisthenicsDestinations = <_NavItem>[
    _NavItem(
      id: "dashboard",
      label: "Dashboard",
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    _NavItem(
      id: "movements",
      label: "Movements",
      icon: Icons.view_list_outlined,
      selectedIcon: Icons.view_list,
    ),
    _NavItem(
      id: "tree",
      label: "Tree",
      icon: Icons.account_tree_outlined,
      selectedIcon: Icons.account_tree,
    ),
    _NavItem(
      id: "history",
      label: "History",
      icon: Icons.history_outlined,
      selectedIcon: Icons.history,
    ),
    _NavItem(
      id: "perks",
      label: "Perks",
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
    ),
    _NavItem(
      id: "shop",
      label: "Shop",
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront,
    ),
    _NavItem(
      id: "badges",
      label: "Badges",
      icon: Icons.emoji_events_outlined,
      selectedIcon: Icons.emoji_events,
    ),
  ];

  static const _runningDestinations = <_NavItem>[
    _NavItem(
      id: "dashboard",
      label: "Dashboard",
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    _NavItem(
      id: "plan",
      label: "Plan",
      icon: Icons.route_outlined,
      selectedIcon: Icons.route,
    ),
    _NavItem(
      id: "tree",
      label: "Tree",
      icon: Icons.account_tree_outlined,
      selectedIcon: Icons.account_tree,
    ),
    _NavItem(
      id: "goals",
      label: "Goals",
      icon: Icons.flag_outlined,
      selectedIcon: Icons.flag,
    ),
  ];

  static const _calisthenicsCompactPrimaryIndices = <int>[0, 1, 2, 5];
  static const _runningCompactPrimaryIndices = <int>[0, 1, 2, 3];

  final Set<String> _knownEarnedBadgeIds = <String>{};
  bool _initializedEarnedSet = false;
  late final ProviderSubscription<AsyncValue<List<BadgeWithEarned>>> _badgeSub;

  @override
  void initState() {
    super.initState();
    _badgeSub = ref.listenManual(badgesProvider, (prev, next) {
      next.whenData((items) {
        final earnedIdsNow = items
            .where((b) => b.isEarned)
            .map((b) => b.badge.id)
            .toSet();

        if (!_initializedEarnedSet) {
          _knownEarnedBadgeIds
            ..clear()
            ..addAll(earnedIdsNow);
          _initializedEarnedSet = true;
          return;
        }

        final newlyEarnedIds = earnedIdsNow.difference(_knownEarnedBadgeIds);
        if (newlyEarnedIds.isEmpty) {
          return;
        }

        _knownEarnedBadgeIds
          ..clear()
          ..addAll(earnedIdsNow);

        if (!mounted) return;
        final newlyEarned = items
            .where((b) => newlyEarnedIds.contains(b.badge.id))
            .toList();
        _showJustEarnedToast(newlyEarned);
      });
    });
  }

  @override
  void dispose() {
    _badgeSub.close();
    super.dispose();
  }

  _ShellConfig _shellForMode(TrainingMode mode) {
    if (mode == TrainingMode.running) {
      return const _ShellConfig(
        destinations: _runningDestinations,
        compactPrimaryIndices: _runningCompactPrimaryIndices,
        pages: [
          RunningDashboardScreen(),
          RunningPlanScreen(),
          RunningTreeScreen(),
          RunningGoalsScreen(),
        ],
      );
    }

    return const _ShellConfig(
      destinations: _calisthenicsDestinations,
      compactPrimaryIndices: _calisthenicsCompactPrimaryIndices,
      pages: [
        DashboardScreen(),
        MovementsScreen(),
        SkillTreeScreen(),
        HistoryScreen(),
        PerksScreen(),
        ShopScreen(),
        BadgesScreen(),
      ],
    );
  }

  Future<void> _setTrainingMode(TrainingMode mode) async {
    await ref.read(trainingModeProvider.notifier).setMode(mode);
    if (!mounted) return;
    setState(() {
      index = 0;
    });
  }

  void _showJustEarnedToast(List<BadgeWithEarned> earned) {
    if (earned.isEmpty) return;

    final names = earned.map((b) => b.badge.name).toList();
    final subtitle = names.length == 1
        ? names.first
        : names.length == 2
        ? "${names[0]} - ${names[1]}"
        : "${names[0]} - +${names.length - 1} more";

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: BadgeEarnedToast(title: "Just earned!", subtitle: subtitle),
        action: SnackBarAction(
          label: "View",
          onPressed: () {
            messenger.hideCurrentSnackBar();
            _openJustEarnedPopup(earned);
          },
        ),
      ),
    );
  }

  Future<void> _openJustEarnedPopup(List<BadgeWithEarned> earned) async {
    if (!mounted || earned.isEmpty) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.workspace_premium, color: scheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Just earned",
                          style: Theme.of(dialogContext).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        tooltip: "Close",
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: SingleChildScrollView(
                      child: Column(
                        children: earned.map((b) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: scheme.outlineVariant),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.emoji_events),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        b.badge.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        b.badge.description,
                                        style: TextStyle(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<int> _compactPrimaryIndices(_ShellConfig config) {
    final valid = config.compactPrimaryIndices
        .where((i) => i >= 0 && i < config.destinations.length)
        .toList();
    if (valid.isEmpty && config.destinations.isNotEmpty) {
      return <int>[0];
    }
    return valid;
  }

  int _compactSelectedNavIndex({
    required int activeIndex,
    required List<int> compactPrimary,
  }) {
    final mapped = compactPrimary.indexOf(activeIndex);
    if (mapped >= 0) {
      return mapped;
    }
    return compactPrimary.length;
  }

  List<int> _compactOverflowIndices(
    _ShellConfig config,
    List<int> compactPrimary,
  ) {
    return List<int>.generate(
      config.destinations.length,
      (i) => i,
    ).where((i) => !compactPrimary.contains(i)).toList();
  }

  Future<void> _openCompactMoreMenu({
    required _ShellConfig config,
    required TrainingMode currentMode,
    required int activeIndex,
  }) async {
    final compactPrimary = _compactPrimaryIndices(config);
    final overflow = _compactOverflowIndices(config, compactPrimary);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Text(
                  "More",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 4),
                child: Text(
                  "Mode",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              ListTile(
                leading: Icon(
                  currentMode == TrainingMode.calisthenics
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                title: const Text("Calisthenics"),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  if (currentMode == TrainingMode.calisthenics) return;
                  await _setTrainingMode(TrainingMode.calisthenics);
                },
              ),
              ListTile(
                leading: Icon(
                  currentMode == TrainingMode.running
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                title: const Text("Running"),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  if (currentMode == TrainingMode.running) return;
                  await _setTrainingMode(TrainingMode.running);
                },
              ),
              if (overflow.isNotEmpty) ...[
                const Divider(),
                ...overflow.map((i) {
                  final item = config.destinations[i];
                  final selected = activeIndex == i;
                  return ListTile(
                    leading: Icon(selected ? item.selectedIcon : item.icon),
                    title: Text(item.label),
                    trailing: selected ? const Icon(Icons.check) : null,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      if (!mounted) return;
                      if (index != i) {
                        setState(() {
                          index = i;
                        });
                      }
                    },
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final modeAsync = ref.watch(trainingModeProvider);
    final scheme = Theme.of(context).colorScheme;

    return modeAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text("Failed to load app mode: $err"),
          ),
        ),
      ),
      data: (mode) {
        final config = _shellForMode(mode);
        final activeIndex = index >= 0 && index < config.pages.length
            ? index
            : 0;
        if (activeIndex != index) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              index = activeIndex;
            });
          });
        }

        final isTree =
            config.destinations.isNotEmpty &&
            config.destinations[activeIndex].id == "tree";
        final body = IndexedStack(index: activeIndex, children: config.pages);

        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final compact = w < _kCompactMax;
            final extendedRail = w >= _kExtendedRailMin;

            if (compact) {
              final compactPrimary = _compactPrimaryIndices(config);
              const showMoreMenu = true;
              final compactDestinations = <_NavItem>[
                for (final i in compactPrimary) config.destinations[i],
                if (showMoreMenu) _kCompactMoreNavItem,
              ];
              final selected = _compactSelectedNavIndex(
                activeIndex: activeIndex,
                compactPrimary: compactPrimary,
              );

              return Scaffold(
                body: ScrollConfiguration(
                  behavior: const _AppScrollBehavior(),
                  child: body,
                ),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: selected.clamp(
                    0,
                    compactDestinations.length - 1,
                  ),
                  labelBehavior:
                      NavigationDestinationLabelBehavior.onlyShowSelected,
                  onDestinationSelected: (i) async {
                    if (i < compactPrimary.length) {
                      setState(() {
                        index = compactPrimary[i];
                      });
                      return;
                    }

                    await _openCompactMoreMenu(
                      config: config,
                      currentMode: mode,
                      activeIndex: activeIndex,
                    );
                  },
                  destinations: compactDestinations.map((d) {
                    return NavigationDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: d.label,
                    );
                  }).toList(),
                ),
              );
            }

            return Scaffold(
              backgroundColor: scheme.surfaceContainerLowest,
              body: SafeArea(
                child: ScrollConfiguration(
                  behavior: const _AppScrollBehavior(),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        _SidebarRail(
                          selectedIndex: activeIndex,
                          extended: extendedRail,
                          items: config.destinations,
                          mode: mode,
                          onModeChanged: _setTrainingMode,
                          onSelect: (i) {
                            setState(() {
                              index = i;
                            });
                          },
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _ContentFrame(
                            maxWidth: isTree ? double.infinity : 1240,
                            child: body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ShellConfig {
  const _ShellConfig({
    required this.destinations,
    required this.compactPrimaryIndices,
    required this.pages,
  });

  final List<_NavItem> destinations;
  final List<int> compactPrimaryIndices;
  final List<Widget> pages;
}

class _NavItem {
  const _NavItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String id;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _SidebarRail extends StatelessWidget {
  const _SidebarRail({
    required this.selectedIndex,
    required this.extended,
    required this.items,
    required this.mode,
    required this.onModeChanged,
    required this.onSelect,
  });

  final int selectedIndex;
  final bool extended;
  final List<_NavItem> items;
  final TrainingMode mode;
  final Future<void> Function(TrainingMode mode) onModeChanged;
  final void Function(int i) onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: scheme.surface,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.65),
            ),
          ),
          child: NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelect,
            extended: extended,
            groupAlignment: -0.85,
            useIndicator: true,
            indicatorColor: scheme.primaryContainer,
            leading: SizedBox(
              width: extended ? 256 : 88,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: _RailHeader(
                  extended: extended,
                  mode: mode,
                  onModeChanged: onModeChanged,
                ),
              ),
            ),
            labelType: extended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.selected,
            destinations: items.map((d) {
              return NavigationRailDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: Text(d.label),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _RailHeader extends StatelessWidget {
  const _RailHeader({
    required this.extended,
    required this.mode,
    required this.onModeChanged,
  });

  final bool extended;
  final TrainingMode mode;
  final Future<void> Function(TrainingMode mode) onModeChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final icon = mode == TrainingMode.running
        ? Icons.directions_run
        : Icons.fitness_center;
    final title = mode == TrainingMode.running
        ? "Run Planner"
        : "Cali Skill Tree";
    final subtitle = mode == TrainingMode.running
        ? "Running mode"
        : "Calisthenics mode";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: scheme.onPrimaryContainer),
            ),
            const Spacer(),
            PopupMenuButton<TrainingMode>(
              tooltip: "Switch mode",
              icon: const Icon(Icons.swap_horiz),
              initialValue: mode,
              onSelected: (next) {
                if (next == mode) return;
                onModeChanged(next);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: TrainingMode.calisthenics,
                  child: Text("Calisthenics"),
                ),
                PopupMenuItem(
                  value: TrainingMode.running,
                  child: Text("Running"),
                ),
              ],
            ),
          ],
        ),
        if (extended) ...[
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _ContentFrame extends StatelessWidget {
  const _ContentFrame({required this.child, required this.maxWidth});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final framed = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: scheme.surface,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.65),
            ),
          ),
          child: child,
        ),
      ),
    );

    if (maxWidth.isInfinite) {
      return framed;
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: framed,
      ),
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices {
    return <PointerDeviceKind>{
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse,
      PointerDeviceKind.stylus,
      PointerDeviceKind.invertedStylus,
      PointerDeviceKind.unknown,
    };
  }
}
