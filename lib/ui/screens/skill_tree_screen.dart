import "dart:collection";
import "dart:math";

import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../data/db/app_db.dart";
import "../../domain/prereq_rules.dart";
import "../../state/providers.dart";
import "../theme/cosmetic_visuals.dart";
import "../theme/tier_visuals.dart";
import "../widgets/quick_log_sheet.dart";
import "movement_detail_screen.dart";

const double _kNodeW = 240.0;
// Extra height to avoid flex overflow when text scales up.
const double _kNodeH = 114.0;
const double _kViewerMinScale = 0.06;
const double _kViewerMaxScale = 10.0;
const double _kAutoFocusMaxScaleCompact = 2.4;
const double _kAutoFocusMaxScaleRegular = 1.6;

/// Highlight plan provider: derives prereq tree + smart unmet/satisfied split for the selected movement.
final skillTreePlanProvider = Provider.family<_HighlightPlan, String?>((
  ref,
  targetId,
) {
  if (targetId == null) return _HighlightPlan.empty();

  final movements = ref.watch(movementsWithProgressProvider);
  final prereqs = ref.watch(prereqsProvider);
  final stats = ref.watch(userStatProvider);

  // Fail-soft: keep the UI responsive while upstream streams load or error.
  if (movements is AsyncLoading ||
      prereqs is AsyncLoading ||
      stats is AsyncLoading) {
    return _HighlightPlan.empty();
  }

  final allMovements = movements.value;
  final allReqs = prereqs.value;
  final stat = stats.value;

  if (allMovements == null || allReqs == null || stat == null) {
    return _HighlightPlan.empty();
  }

  return _computeHighlightPlan(
    targetId: targetId,
    allMovements: allMovements,
    allReqs: allReqs,
    totalXp: stat.totalXp,
  );
});

class SkillTreeScreen extends ConsumerStatefulWidget {
  const SkillTreeScreen({super.key});

  @override
  ConsumerState<SkillTreeScreen> createState() => _SkillTreeScreenState();
}

class _SkillTreeScreenState extends ConsumerState<SkillTreeScreen>
    with SingleTickerProviderStateMixin {
  final TransformationController viewerController = TransformationController();

  // Reuse layout without redoing heavy work every build.
  final Map<_LayoutCacheKey, _LayeredLayout> _layoutCache = {};
  static const int _maxCacheEntries = 32;

  final Map<String, String> categoryLabels = {
    "push": "Push",
    "pull": "Pull",
    "legs": "Legs",
    "core": "Core",
    "skill": "Skill",
    "compound": "Compound",
    "rings": "Rings",
    "mobility": "Mobility",
  };

  final List<String> categoryOrder = [
    "push",
    "pull",
    "legs",
    "core",
    "skill",
    "compound",
    "rings",
    "mobility",
  ];

  late final Set<String> activeCategories = categoryLabels.keys.toSet();

  bool showCategoryHeaders = true;

  // Readability controls
  bool showAllEdges = false;
  bool showCrossLinks = false;

  String? selectedMovementId;
  bool _goalFocusOnly = false;

  bool didInitTransform = false;
  bool _clearSelectionScheduled = false;

  // Auto-focus
  String? _pendingAutoFocusTargetId;
  late final AnimationController _focusController;
  Animation<Matrix4>? _matrixAnim;
  VoidCallback? _matrixListener;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
  }

  @override
  void dispose() {
    if (_matrixListener != null && _matrixAnim != null) {
      _matrixAnim!.removeListener(_matrixListener!);
    }
    _focusController.dispose();
    viewerController.dispose();
    super.dispose();
  }

  bool _isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 720;

  _LayeredLayout _getOrBuildLayout(
    _LayoutCacheKey key,
    _LayeredLayout Function() builder,
  ) {
    final cached = _layoutCache[key];
    if (cached != null) return cached;

    final layout = builder();
    _layoutCache[key] = layout;

    if (_layoutCache.length > _maxCacheEntries) {
      _layoutCache.remove(_layoutCache.keys.first);
    }
    return layout;
  }

  void _animateToMatrix(Matrix4 end) {
    _focusController.stop();

    if (_matrixListener != null && _matrixAnim != null) {
      _matrixAnim!.removeListener(_matrixListener!);
    }

    final anim = Matrix4Tween(begin: viewerController.value.clone(), end: end)
        .animate(
          CurvedAnimation(parent: _focusController, curve: Curves.easeOutCubic),
        );

    void listener() {
      viewerController.value = anim.value;
    }

    anim.addListener(listener);
    _matrixAnim = anim;
    _matrixListener = listener;

    _focusController.forward(from: 0);
  }

  Matrix4 _computeFocusMatrix({
    required Size viewport,
    required Rect contentRect,
    required double minScale,
    required double maxScale,
    required double focusMaxScale,
  }) {
    const pad = 56.0;

    final w = max(1.0, contentRect.width + pad);
    final h = max(1.0, contentRect.height + pad);

    final sw = viewport.width / w;
    final sh = viewport.height / h;

    final scale = min(focusMaxScale, min(sw, sh)).clamp(minScale, maxScale);

    final viewportCenter = Offset(viewport.width / 2, viewport.height / 2);
    final rectCenter = contentRect.center;

    // With matrix = Scale * Translate: v = s * (p + t) -> t = v/s - p
    final tx = (viewportCenter.dx / scale) - rectCenter.dx;
    final ty = (viewportCenter.dy / scale) - rectCenter.dy;

    return Matrix4.identity()
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(tx, ty, 0, 1);
  }

  void _autoFocusToUnmetSubtree({
    required BoxConstraints constraints,
    required _LayeredLayout layout,
    required _HighlightPlan plan,
    required bool isCompact,
  }) {
    final focusIds = <String>{plan.targetId, ...plan.unmetNodes};

    final centers = <Offset>[];
    for (final id in focusIds) {
      final c = layout.nodeCenters[id];
      if (c != null) centers.add(c);
    }
    if (centers.isEmpty) return;

    double minX = double.infinity, minY = double.infinity;
    double maxX = -double.infinity, maxY = -double.infinity;

    for (final c in centers) {
      minX = min(minX, c.dx - _kNodeW / 2);
      maxX = max(maxX, c.dx + _kNodeW / 2);
      minY = min(minY, c.dy - _kNodeH / 2);
      maxY = max(maxY, c.dy + _kNodeH / 2);
    }

    const extra = 90.0;
    final rect = Rect.fromLTRB(
      minX - extra,
      minY - extra,
      maxX + extra,
      maxY + extra,
    );

    final viewport = Size(constraints.maxWidth, constraints.maxHeight);

    final matrix = _computeFocusMatrix(
      viewport: viewport,
      contentRect: rect,
      minScale: _kViewerMinScale,
      maxScale: _kViewerMaxScale,
      focusMaxScale: isCompact
          ? _kAutoFocusMaxScaleCompact
          : _kAutoFocusMaxScaleRegular,
    );

    _animateToMatrix(matrix);
  }

  void _fitToViewport({
    required BoxConstraints constraints,
    required _LayeredLayout layout,
  }) {
    final vw = constraints.maxWidth;
    final vh = constraints.maxHeight;

    const pad = 40.0;

    final sw = (vw - pad) / layout.canvasSize.width;
    final sh = (vh - pad) / layout.canvasSize.height;

    final scale = min(1.0, min(sw, sh)).clamp(_kViewerMinScale, 1.0);

    final dx = (vw - layout.canvasSize.width * scale) / 2;
    final dy = (vh - layout.canvasSize.height * scale) / 2;

    viewerController.value = Matrix4.identity()
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(dx / scale, dy / scale, 0, 1);
  }

  Future<void> _openFiltersSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
              top: 8,
            ),
            child: StatefulBuilder(
              builder: (context, setLocal) {
                void setParent(VoidCallback fn) {
                  setState(fn);
                  setLocal(() {});
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Filters & View",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonal(
                          onPressed: () {
                            setParent(() {
                              activeCategories
                                ..clear()
                                ..addAll(categoryLabels.keys);
                              didInitTransform = false;
                            });
                          },
                          child: const Text("All"),
                        ),
                        ...categoryOrder.where(categoryLabels.containsKey).map((
                          k,
                        ) {
                          final selected = activeCategories.contains(k);
                          return FilterChip(
                            label: Text(categoryLabels[k] ?? k),
                            selected: selected,
                            onSelected: (_) {
                              setParent(() {
                                if (activeCategories.contains(k)) {
                                  activeCategories.remove(k);
                                } else {
                                  activeCategories.add(k);
                                }
                                if (activeCategories.isEmpty) {
                                  activeCategories.add(k);
                                }
                                didInitTransform = false;
                              });
                            },
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: showCategoryHeaders,
                      title: const Text("Category headers"),
                      onChanged: (v) {
                        setParent(() {
                          showCategoryHeaders = v;
                          didInitTransform = false;
                        });
                      },
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: showAllEdges,
                      title: const Text("Show edges"),
                      onChanged: (v) => setParent(() => showAllEdges = v),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: showCrossLinks,
                      title: const Text("Cross-links"),
                      subtitle: !showAllEdges
                          ? const Text('Enable "Show edges" first')
                          : null,
                      onChanged: !showAllEdges
                          ? null
                          : (v) => setParent(() => showCrossLinks = v),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Tip: drag to pan | pinch to zoom | tap a node to plan",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _openMobileQuestSheet({
    required BuildContext context,
    required String movementId,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 12 + MediaQuery.viewInsetsOf(context).bottom,
              top: 6,
            ),
            child: _MobileQuestSheet(
              movementId: movementId,
              categoryLabels: categoryLabels,
              onOpenMovement: (id) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MovementDetailScreen(movementId: id),
                  ),
                );
              },
              onQuickLog: (id, name) async {
                final movement = ref
                    .read(movementsWithProgressProvider)
                    .maybeWhen<Movement?>(
                      data: (items) {
                        for (final x in items) {
                          if (x.movement.id == id) return x.movement;
                        }
                        return null;
                      },
                      orElse: () => null,
                    );

                if (movement == null) return;

                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => QuickLogSheet(
                    movementId: movement.id,
                    movementName: movement.name,
                    xpPerRep: movement.xpPerRep,
                    xpPerSecond: movement.xpPerSecond,
                    category: movement.category,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _openSearchSheet(BuildContext context) async {
    final allItems = ref
        .read(movementsWithProgressProvider)
        .maybeWhen(data: (items) => items, orElse: () => null);

    if (allItems == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Movements are still loading. Try again in a moment."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final sorted = [...allItems]
      ..sort((a, b) => a.movement.name.compareTo(b.movement.name));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        String query = "";
        return StatefulBuilder(
          builder: (context, setLocal) {
            final q = query.trim().toLowerCase();
            final filtered = sorted
                .where((x) {
                  if (q.isEmpty) return true;
                  return x.movement.name.toLowerCase().contains(q) ||
                      x.movement.category.toLowerCase().contains(q);
                })
                .take(40)
                .toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Jump to Movement",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      autofocus: true,
                      onChanged: (v) => setLocal(() => query = v),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search by movement or category",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 420),
                      child: filtered.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 18),
                                child: Text("No movements match this search."),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final x = filtered[i];
                                final locked = x.progress.state == "locked";
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    locked
                                        ? Icons.lock_outline
                                        : Icons.fitness_center,
                                  ),
                                  title: Text(x.movement.name),
                                  subtitle: Text(
                                    "${categoryLabels[x.movement.category] ?? x.movement.category} | ${x.progress.state}",
                                  ),
                                  onTap: () {
                                    Navigator.of(sheetContext).pop();
                                    if (!mounted) return;
                                    setState(() {
                                      activeCategories.add(x.movement.category);
                                      selectedMovementId = x.movement.id;
                                      _goalFocusOnly = false;
                                      _pendingAutoFocusTargetId = x.movement.id;
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openLegendSheet(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final equippedCosmeticId = ref
        .read(cosmeticStatusProvider)
        .maybeWhen(data: (v) => v.equippedCosmeticId, orElse: () => null);
    final accent = cosmeticVisualForId(
      equippedCosmeticId,
      fallbackColor: cs.primary,
    ).color;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tree Legend",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Edges",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                _LegendLine(
                  color: accent.withValues(alpha: 0.92),
                  label: "Unmet prerequisite (train this first)",
                ),
                _LegendLine(
                  color: accent.withValues(alpha: 0.30),
                  label: "Satisfied prerequisite",
                ),
                _LegendLine(
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                  label: "Normal dependency",
                ),
                _LegendLine(
                  color: cs.outlineVariant.withValues(alpha: 0.20),
                  label: "Cross-category link",
                ),
                const SizedBox(height: 12),
                const Text(
                  "Nodes",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                _LegendIconLine(
                  icon: Icons.flag,
                  label: "Goal movement",
                  color: cs.tertiary,
                ),
                _LegendIconLine(
                  icon: Icons.track_changes,
                  label: "Current selected target",
                  color: accent,
                ),
                _LegendIconLine(
                  icon: Icons.lock_outline,
                  label: "Locked node",
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  "Tips: tap a node to see its plan panel. Use Search to jump quickly and auto-focus.",
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = _isCompact(context);
    final goalMovementId = ref
        .watch(skillGoalProvider)
        .maybeWhen(data: (id) => id, orElse: () => null);
    final cosmeticStatus = ref.watch(cosmeticStatusProvider);

    final movements = ref.watch(movementsWithProgressProvider);
    final prereqs = ref.watch(prereqsProvider);
    final stats = ref.watch(userStatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Skill Tree"),
        actions: [
          IconButton(
            tooltip: "Search movement",
            onPressed: () => _openSearchSheet(context),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: "Legend",
            onPressed: () => _openLegendSheet(context),
            icon: const Icon(Icons.help_outline),
          ),
          if (isCompact)
            IconButton(
              tooltip: "Filters & view",
              onPressed: () => _openFiltersSheet(context),
              icon: const Icon(Icons.tune),
            ),
          if (selectedMovementId != null)
            IconButton(
              tooltip: "Focus selected",
              onPressed: () => setState(() {
                _pendingAutoFocusTargetId = selectedMovementId;
              }),
              icon: const Icon(Icons.my_location),
            ),
          IconButton(
            tooltip: "Reset view",
            onPressed: () {
              didInitTransform = false;
              _pendingAutoFocusTargetId = null;
              viewerController.value = Matrix4.identity();
              setState(() {});
            },
            icon: const Icon(Icons.center_focus_strong),
          ),
          if (goalMovementId != null)
            IconButton(
              tooltip: _goalFocusOnly ? "Show full tree" : "Focus goal",
              onPressed: () => setState(() {
                if (_goalFocusOnly) {
                  _goalFocusOnly = false;
                  return;
                }
                _goalFocusOnly = true;
                selectedMovementId = goalMovementId;
                _pendingAutoFocusTargetId = goalMovementId;
              }),
              icon: Icon(_goalFocusOnly ? Icons.flag_circle : Icons.flag),
            ),
          IconButton(
            tooltip: "Clear selection",
            onPressed: () => setState(() {
              selectedMovementId = null;
              _pendingAutoFocusTargetId = null;
              _goalFocusOnly = false;
            }),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isCompact ? 0 : 16),
        child: Column(
          children: [
            if (!isCompact) ...[
              _TopControlsDesktop(
                categoryLabels: categoryLabels,
                categoryOrder: categoryOrder,
                activeCategories: activeCategories,
                showCategoryHeaders: showCategoryHeaders,
                showAllEdges: showAllEdges,
                showCrossLinks: showCrossLinks,
                onToggleCategory: (key) {
                  setState(() {
                    if (activeCategories.contains(key)) {
                      activeCategories.remove(key);
                    } else {
                      activeCategories.add(key);
                    }
                    if (activeCategories.isEmpty) activeCategories.add(key);
                    didInitTransform = false;
                    _pendingAutoFocusTargetId = null;
                  });
                },
                onSelectAll: () {
                  setState(() {
                    activeCategories
                      ..clear()
                      ..addAll(categoryLabels.keys);
                    didInitTransform = false;
                    _pendingAutoFocusTargetId = null;
                  });
                },
                onToggleHeaders: (v) => setState(() {
                  showCategoryHeaders = v;
                  didInitTransform = false;
                  _pendingAutoFocusTargetId = null;
                }),
                onToggleAllEdges: (v) => setState(() => showAllEdges = v),
                onToggleCrossLinks: (v) => setState(() => showCrossLinks = v),
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: stats.when(
                data: (_) {
                  return movements.when(
                    data: (allItems) {
                      return prereqs.when(
                        data: (allReqs) {
                          final visibleMovements = allItems
                              .where(
                                (x) => activeCategories.contains(
                                  x.movement.category,
                                ),
                              )
                              .toList();

                          if (visibleMovements.isEmpty) {
                            return const Center(
                              child: Text(
                                "No movements in the selected categories.",
                              ),
                            );
                          }

                          final visibleCount = visibleMovements.length;
                          final lockedCount = visibleMovements
                              .where((x) => x.progress.state == "locked")
                              .length;
                          final unlockedCount = visibleCount - lockedCount;

                          final movementByIdAll =
                              <String, MovementWithProgress>{
                                for (final x in allItems) x.movement.id: x,
                              };

                          final movementByIdVisible =
                              <String, MovementWithProgress>{
                                for (final x in visibleMovements)
                                  x.movement.id: x,
                              };

                          final prereqsByMovement =
                              <String, List<MovementPrereq>>{};
                          for (final r in allReqs) {
                            prereqsByMovement
                                .putIfAbsent(r.movementId, () => [])
                                .add(r);
                          }

                          // Validate selection visibility (do not mutate state directly during build).
                          if (selectedMovementId != null) {
                            final sel = movementByIdAll[selectedMovementId!];
                            final shouldClear =
                                sel == null ||
                                !activeCategories.contains(
                                  sel.movement.category,
                                );

                            if (shouldClear && !_clearSelectionScheduled) {
                              _clearSelectionScheduled = true;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                _clearSelectionScheduled = false;
                                setState(() {
                                  selectedMovementId = null;
                                  _pendingAutoFocusTargetId = null;
                                  _goalFocusOnly = false;
                                });
                              });
                            }
                          }

                          final selection = selectedMovementId != null
                              ? movementByIdAll[selectedMovementId!]
                              : null;

                          final selectedPlan = ref.watch(
                            skillTreePlanProvider(selection?.movement.id),
                          );
                          final renderTargetId =
                              (_goalFocusOnly && goalMovementId != null)
                              ? goalMovementId
                              : selection?.movement.id;
                          final renderPlan = ref.watch(
                            skillTreePlanProvider(renderTargetId),
                          );
                          final isGoalFocusActive =
                              _goalFocusOnly &&
                              goalMovementId != null &&
                              renderPlan.targetId.isNotEmpty;

                          final layoutKey = _LayoutCacheKey(
                            signature: _layoutSignature(visibleMovements),
                            prereqSignature: _prereqSignature(allReqs),
                            activeCategories: activeCategories,
                            showCategoryHeaders: showCategoryHeaders,
                          );

                          final layout = _getOrBuildLayout(
                            layoutKey,
                            () => _buildLayeredLayout(
                              visibleMovements: visibleMovements,
                              allReqs: allReqs,
                              prereqsByMovement: prereqsByMovement,
                              activeCategories: activeCategories,
                              categoryOrder: categoryOrder,
                              showCategoryHeaders: showCategoryHeaders,
                              isCompact: isCompact,
                            ),
                          );

                          final cs = Theme.of(context).colorScheme;
                          final equippedCosmeticId = cosmeticStatus.maybeWhen(
                            data: (v) => v.equippedCosmeticId,
                            orElse: () => null,
                          );
                          final cosmeticAccent = cosmeticVisualForId(
                            equippedCosmeticId,
                            fallbackColor: cs.primary,
                          ).color;

                          Widget viewer(BoxConstraints constraints) {
                            final drawLayout = isGoalFocusActive
                                ? _buildGoalPathLayout(
                                    focusNodeIds: renderPlan.highlightNodes,
                                    allEdges: layout.edges,
                                    movementByIdVisible: movementByIdVisible,
                                  )
                                : layout;

                            final big =
                                max(
                                  drawLayout.canvasSize.width,
                                  drawLayout.canvasSize.height,
                                ) +
                                2500;

                            if (!didInitTransform) {
                              didInitTransform = true;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                _fitToViewport(
                                  constraints: constraints,
                                  layout: drawLayout,
                                );
                              });
                            }

                            // Auto-focus exactly once after a user tap.
                            if (_pendingAutoFocusTargetId != null &&
                                _pendingAutoFocusTargetId ==
                                    selectedMovementId &&
                                renderPlan.targetId.isNotEmpty) {
                              final pending = _pendingAutoFocusTargetId;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                if (pending != selectedMovementId) return;
                                _pendingAutoFocusTargetId = null;
                                _autoFocusToUnmetSubtree(
                                  constraints: constraints,
                                  layout: drawLayout,
                                  plan: renderPlan,
                                  isCompact: isCompact,
                                );
                              });
                            }

                            final displayEdges = drawLayout.edges;
                            final displayHeaderEdges = drawLayout.headerEdges;
                            final displayMovementNodes =
                                drawLayout.movementNodes;
                            final displayCategoryHeaders = drawLayout
                                .categoryHeaderCenters
                                .entries
                                .toList();

                            // Desktop trackpad/mousewheel scroll: pan instead of zoom.
                            return Listener(
                              onPointerSignal: (ps) {
                                if (ps is PointerScrollEvent) {
                                  final scale = viewerController.value
                                      .getMaxScaleOnAxis();
                                  final next = viewerController.value.clone()
                                    ..translateByDouble(
                                      -ps.scrollDelta.dx / scale,
                                      -ps.scrollDelta.dy / scale,
                                      0,
                                      1,
                                    );
                                  viewerController.value = next;
                                }
                              },
                              child: InteractiveViewer(
                                transformationController: viewerController,
                                constrained: false,
                                boundaryMargin: EdgeInsets.all(big),
                                panEnabled: true,
                                scaleEnabled: true,
                                minScale: _kViewerMinScale,
                                maxScale: _kViewerMaxScale,
                                clipBehavior: Clip.none,
                                child: SizedBox(
                                  width: drawLayout.canvasSize.width,
                                  height: drawLayout.canvasSize.height,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: _LayeredTreePainter(
                                            nodeCenters: drawLayout.nodeCenters,
                                            categoryHeaderCenters: drawLayout
                                                .categoryHeaderCenters,
                                            edges: displayEdges,
                                            headerEdges: displayHeaderEdges,
                                            unmetEdges: renderPlan.unmetEdges,
                                            satisfiedEdges:
                                                renderPlan.satisfiedEdges,
                                            showAllEdges: showAllEdges,
                                            showCrossLinks: showCrossLinks,
                                            colorScheme: cs,
                                            highlightAccent: cosmeticAccent,
                                            goalFocusRouting:
                                                isGoalFocusActive,
                                          ),
                                        ),
                                      ),
                                      if (showCategoryHeaders &&
                                          !isGoalFocusActive)
                                        ...displayCategoryHeaders.map((e) {
                                          final label =
                                              categoryLabels[e.key] ?? e.key;
                                          final c = e.value;
                                          return Positioned(
                                            left: c.dx - 70,
                                            top: c.dy - 18,
                                            child: _CategoryPill(label: label),
                                          );
                                        }),
                                      ...displayMovementNodes.map((n) {
                                        final x = movementByIdVisible[n.id];
                                        if (x == null) {
                                          return const SizedBox.shrink();
                                        }

                                        final isSelected =
                                            selectedMovementId == n.id;

                                        final hasHighlight =
                                            renderPlan
                                                .highlightNodes
                                                .isNotEmpty &&
                                            (selectedMovementId != null ||
                                                isGoalFocusActive);
                                        final isInTree = renderPlan
                                            .highlightNodes
                                            .contains(n.id);
                                        final dimmed =
                                            !isGoalFocusActive &&
                                            hasHighlight &&
                                            !isInTree;

                                        final isTarget =
                                            n.id == renderPlan.targetId;
                                        final unmet = renderPlan.unmetNodes
                                            .contains(n.id);

                                        return Positioned(
                                          left: n.center.dx - (_kNodeW / 2),
                                          top: n.center.dy - (_kNodeH / 2),
                                          child: _MovementNodeCard(
                                            movementId: x.movement.id,
                                            name: x.movement.name,
                                            category:
                                                categoryLabels[x
                                                    .movement
                                                    .category] ??
                                                x.movement.category,
                                            difficulty: x.movement.difficulty,
                                            state: x.progress.state,
                                            selected: isSelected,
                                            inTree: isInTree,
                                            unmet: unmet,
                                            isTarget: isTarget,
                                            isGoal: goalMovementId == n.id,
                                            cosmeticAccent: cosmeticAccent,
                                            dimmed: dimmed,
                                            onTap: () async {
                                              setState(() {
                                                selectedMovementId =
                                                    x.movement.id;
                                                if (!isGoalFocusActive) {
                                                  _pendingAutoFocusTargetId =
                                                      x.movement.id;
                                                }
                                              });

                                              if (isCompact) {
                                                final id = x.movement.id;
                                                await _openMobileQuestSheet(
                                                  context: context,
                                                  movementId: id,
                                                );
                                                if (!mounted) return;
                                              }
                                            },
                                            onOpen: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      MovementDetailScreen(
                                                        movementId:
                                                            x.movement.id,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return Stack(
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) =>
                                    viewer(constraints),
                              ),
                              IgnorePointer(
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: isCompact ? 8 : 12,
                                      top: isCompact ? 8 : 12,
                                      right: 8,
                                    ),
                                    child: _TreeViewSummary(
                                      visibleCount: visibleCount,
                                      unlockedCount: unlockedCount,
                                      lockedCount: lockedCount,
                                      goalFocusOnly: isGoalFocusActive,
                                      hasSelection: selectedMovementId != null,
                                      compact: isCompact,
                                    ),
                                  ),
                                ),
                              ),
                              if (!isCompact &&
                                  selection != null &&
                                  selectedMovementId != null)
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _QuestPanel(
                                      selection: selection,
                                      plan: selectedPlan,
                                      categoryLabels: categoryLabels,
                                      nameForId: (id) =>
                                          movementByIdAll[id]?.movement.name ??
                                          id,
                                      onOpenMovement: (id) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                MovementDetailScreen(
                                                  movementId: id,
                                                ),
                                          ),
                                        );
                                      },
                                      onQuickLog: (id, name) async {
                                        final movement =
                                            movementByIdAll[id]?.movement;
                                        if (movement == null) return;

                                        await showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (_) => QuickLogSheet(
                                            movementId: movement.id,
                                            movementName: movement.name,
                                            xpPerRep: movement.xpPerRep,
                                            xpPerSecond: movement.xpPerSecond,
                                            category: movement.category,
                                          ),
                                        );
                                      },
                                      isGoal:
                                          goalMovementId ==
                                          selection.movement.id,
                                      onSetGoal: () async {
                                        await ref
                                            .read(skillGoalProvider.notifier)
                                            .setGoal(selection.movement.id);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Goal set: ${selection.movement.name}",
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      onClearGoal: () async {
                                        await ref
                                            .read(skillGoalProvider.notifier)
                                            .setGoal(null);
                                        setState(() {
                                          _goalFocusOnly = false;
                                        });
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Goal cleared"),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      onClear: () => setState(() {
                                        selectedMovementId = null;
                                        _pendingAutoFocusTargetId = null;
                                      }),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) =>
                            Center(child: Text("Prereqs error: $e")),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text("Movements error: $e")),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Stats error: $e")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _LayeredLayout _buildGoalPathLayout({
    required Set<String> focusNodeIds,
    required List<_EdgeSpec> allEdges,
    required Map<String, MovementWithProgress> movementByIdVisible,
  }) {
    final filteredEdges = allEdges
        .where(
          (e) => focusNodeIds.contains(e.from) && focusNodeIds.contains(e.to),
        )
        .toList();

    final prereqsByNode = <String, List<String>>{};
    final childrenByNode = <String, List<String>>{};
    final parentsByNode = <String, List<String>>{};
    for (final e in filteredEdges) {
      prereqsByNode.putIfAbsent(e.to, () => <String>[]).add(e.from);
      childrenByNode.putIfAbsent(e.from, () => <String>[]).add(e.to);
      parentsByNode.putIfAbsent(e.to, () => <String>[]).add(e.from);
    }

    final depthMemo = <String, int>{};
    final visiting = <String>{};
    int depthOf(String id) {
      final cached = depthMemo[id];
      if (cached != null) return cached;

      // Defensive: malformed cyclic data should not recurse forever.
      if (visiting.contains(id)) {
        return 0;
      }
      visiting.add(id);

      final pre = prereqsByNode[id] ?? const <String>[];
      if (pre.isEmpty) {
        visiting.remove(id);
        depthMemo[id] = 0;
        return 0;
      }

      var d = 0;
      for (final p in pre) {
        d = max(d, depthOf(p) + 1);
      }
      visiting.remove(id);
      depthMemo[id] = d;
      return d;
    }

    final depthBuckets = <int, List<String>>{};
    for (final id in focusNodeIds) {
      final d = depthOf(id);
      depthBuckets.putIfAbsent(d, () => <String>[]).add(id);
    }

    int compareNodeId(String a, String b) {
      final ma = movementByIdVisible[a]?.movement;
      final mb = movementByIdVisible[b]?.movement;
      if (ma == null && mb == null) return a.compareTo(b);
      if (ma == null) return 1;
      if (mb == null) return -1;

      final cat = ma.category.compareTo(mb.category);
      if (cat != 0) return cat;

      final so = ma.sortOrder.compareTo(mb.sortOrder);
      if (so != 0) return so;
      return ma.name.compareTo(mb.name);
    }

    final depths = depthBuckets.keys.toList()..sort();
    final rowOrder = <int, List<String>>{
      for (final d in depths)
        d: (depthBuckets[d]!..sort(compareNodeId)).toList(growable: true),
    };

    Map<String, double> normalizedPositions() {
      final pos = <String, double>{};
      for (final d in depths) {
        final row = rowOrder[d] ?? const <String>[];
        if (row.isEmpty) continue;
        if (row.length == 1) {
          pos[row.first] = 0.5;
          continue;
        }
        for (var i = 0; i < row.length; i++) {
          pos[row[i]] = i / (row.length - 1);
        }
      }
      return pos;
    }

    void reorderRowByNeighbors({
      required int depth,
      required Map<String, List<String>> neighborMap,
      required Map<String, double> neighborPos,
    }) {
      final row = rowOrder[depth];
      if (row == null || row.length < 2) return;

      final barycenter = <String, double?>{};
      for (final id in row) {
        final neighbors = neighborMap[id] ?? const <String>[];
        if (neighbors.isEmpty) {
          barycenter[id] = null;
          continue;
        }

        var sum = 0.0;
        var count = 0;
        for (final n in neighbors) {
          final p = neighborPos[n];
          if (p == null) continue;
          sum += p;
          count++;
        }
        barycenter[id] = count == 0 ? null : sum / count;
      }

      row.sort((a, b) {
        final sa = barycenter[a];
        final sb = barycenter[b];

        if (sa != null && sb != null) {
          final c = sa.compareTo(sb);
          if (c != 0) return c;
        } else if (sa != null) {
          return -1;
        } else if (sb != null) {
          return 1;
        }

        return compareNodeId(a, b);
      });
    }

    // Crossing minimization: sweep down (parents) then up (children).
    const sweepPasses = 6;
    for (var pass = 0; pass < sweepPasses; pass++) {
      var pos = normalizedPositions();
      for (final d in depths.skip(1)) {
        reorderRowByNeighbors(
          depth: d,
          neighborMap: parentsByNode,
          neighborPos: pos,
        );
      }

      pos = normalizedPositions();
      for (final d in depths.reversed.skip(1)) {
        reorderRowByNeighbors(
          depth: d,
          neighborMap: childrenByNode,
          neighborPos: pos,
        );
      }
    }

    const sidePad = 120.0;
    const topPad = 120.0;
    const colGap = 42.0;
    const levelGap = 182.0;

    var maxPerRow = 1;
    for (final d in depths) {
      maxPerRow = max(maxPerRow, rowOrder[d]!.length);
    }

    final rowWidth = maxPerRow * (_kNodeW + colGap) - colGap;
    final nodeCenters = <String, Offset>{};
    final movementNodes = <_LayoutNode>[];

    for (final d in depths) {
      final ids = rowOrder[d]!;
      final y = topPad + d * levelGap;
      final w = ids.length * (_kNodeW + colGap) - colGap;
      final startX = sidePad + (rowWidth - w) / 2 + _kNodeW / 2;

      for (var i = 0; i < ids.length; i++) {
        final id = ids[i];
        final center = Offset(startX + i * (_kNodeW + colGap), y);
        nodeCenters[id] = center;
        movementNodes.add(_LayoutNode(id: id, center: center));
      }
    }

    final maxDepth = depths.isEmpty ? 0 : depths.last;
    final canvasW = max(900.0, sidePad * 2 + rowWidth);
    final canvasH = max(700.0, topPad + maxDepth * levelGap + 260.0);

    return _LayeredLayout(
      canvasSize: Size(canvasW, canvasH),
      nodeCenters: nodeCenters,
      categoryHeaderCenters: const <String, Offset>{},
      movementNodes: movementNodes,
      edges: filteredEdges,
      headerEdges: const <_EdgeSpec>[],
      showCategoryHeaders: false,
    );
  }

  _LayeredLayout _buildLayeredLayout({
    required List<MovementWithProgress> visibleMovements,
    required List<MovementPrereq> allReqs,
    required Map<String, List<MovementPrereq>> prereqsByMovement,
    required Set<String> activeCategories,
    required List<String> categoryOrder,
    required bool showCategoryHeaders,
    required bool isCompact,
  }) {
    final movementByIdVisible = <String, MovementWithProgress>{
      for (final x in visibleMovements) x.movement.id: x,
    };

    final active = categoryOrder.where(activeCategories.contains).toList();
    final catCount = max(1, active.length);

    // Spacing (fixed)
    const spread = 1.15;
    final colGap = 120.0 * spread;
    final levelGap = 150.0 * spread;
    final laneGap = 70.0 * spread;

    final topPad = isCompact ? 150.0 : 200.0;
    final sidePad = isCompact ? 160.0 : 200.0;

    // Depth within category (ignoring cross prereqs for layout)
    final depthMemo = <String, int>{};
    final visiting = <String>{};

    int depthWithinCategory(String id) {
      final cached = depthMemo[id];
      if (cached != null) return cached;

      if (visiting.contains(id)) return 0;
      visiting.add(id);

      final me = movementByIdVisible[id];
      if (me == null) {
        visiting.remove(id);
        depthMemo[id] = 0;
        return 0;
      }

      final reqs = prereqsByMovement[id] ?? const <MovementPrereq>[];
      int d = 0;

      for (final r in reqs) {
        final pre = movementByIdVisible[r.prereqMovementId];
        if (pre == null) continue;
        if (pre.movement.category != me.movement.category) continue;

        d = max(d, 1 + depthWithinCategory(pre.movement.id));
      }

      visiting.remove(id);
      depthMemo[id] = d;
      return d;
    }

    // Group nodes by category -> depth
    final byCatDepth = <String, Map<int, List<MovementWithProgress>>>{};

    for (final x in visibleMovements) {
      final cat = x.movement.category;
      byCatDepth.putIfAbsent(cat, () => {});
      final d = depthWithinCategory(x.movement.id);
      byCatDepth[cat]!.putIfAbsent(d, () => []).add(x);
    }

    // Per-category lane width based on max nodes in any depth row
    final laneWidths = <String, double>{};

    for (final cat in active) {
      final levels = byCatDepth[cat] ?? {};
      int maxPerRow = 1;

      for (final e in levels.entries) {
        maxPerRow = max(maxPerRow, e.value.length);
      }

      final rowW = maxPerRow * (_kNodeW + laneGap) - laneGap;
      laneWidths[cat] = max(_kNodeW + 80, rowW + 80);
    }

    // Layout lanes left-to-right
    final categoryHeaderCenters = <String, Offset>{};
    final movementNodes = <_LayoutNode>[];
    final nodeCenters = <String, Offset>{};

    double xCursor = sidePad;
    double maxY = topPad;

    for (int i = 0; i < catCount; i++) {
      final cat = active[i];
      final laneW = laneWidths[cat] ?? (_kNodeW + 80);

      final headerCenter = Offset(xCursor + laneW / 2, topPad);
      categoryHeaderCenters[cat] = headerCenter;

      final levels = byCatDepth[cat] ?? {};
      final depthKeys = levels.keys.toList()..sort();

      for (final depth in depthKeys) {
        final nodes = (levels[depth] ?? []).toList()
          ..sort((a, b) {
            final so = a.movement.sortOrder.compareTo(b.movement.sortOrder);
            if (so != 0) return so;
            return a.movement.name.compareTo(b.movement.name);
          });

        final y = topPad + (showCategoryHeaders ? 70 : 10) + depth * levelGap;

        final totalW = nodes.length * (_kNodeW + laneGap) - laneGap;
        final startX = xCursor + (laneW - totalW) / 2 + _kNodeW / 2;

        for (int idx = 0; idx < nodes.length; idx++) {
          final id = nodes[idx].movement.id;
          final cx = startX + idx * (_kNodeW + laneGap);

          final center = Offset(cx, y);
          movementNodes.add(_LayoutNode(id: id, center: center));
          nodeCenters[id] = center;

          maxY = max(maxY, y);
        }
      }

      xCursor += laneW + colGap;
    }

    final canvasW = max(1400.0, xCursor - colGap + sidePad);
    final canvasH = max(1200.0, maxY + 360);

    // Edges: prereq -> movement (only when both visible)
    final edges = <_EdgeSpec>[];

    for (final r in allReqs) {
      final a = movementByIdVisible[r.prereqMovementId];
      final b = movementByIdVisible[r.movementId];
      if (a == null || b == null) continue;

      edges.add(
        _EdgeSpec(
          from: r.prereqMovementId,
          to: r.movementId,
          isCross: a.movement.category != b.movement.category,
        ),
      );
    }

    // Header wiring: header -> roots (roots = no same-category prereq)
    final headerEdges = <_EdgeSpec>[];

    for (final x in visibleMovements) {
      final id = x.movement.id;
      final reqs = prereqsByMovement[id] ?? const <MovementPrereq>[];

      bool hasSameCatPrereq = false;

      for (final r in reqs) {
        final pre = movementByIdVisible[r.prereqMovementId];
        if (pre == null) continue;

        if (pre.movement.category == x.movement.category) {
          hasSameCatPrereq = true;
          break;
        }
      }

      if (!hasSameCatPrereq) {
        headerEdges.add(
          _EdgeSpec(from: "cat:${x.movement.category}", to: id, isCross: false),
        );
      }
    }

    return _LayeredLayout(
      canvasSize: Size(canvasW, canvasH),
      nodeCenters: nodeCenters,
      categoryHeaderCenters: categoryHeaderCenters,
      movementNodes: movementNodes,
      edges: edges,
      headerEdges: headerEdges,
      showCategoryHeaders: showCategoryHeaders,
    );
  }
}

/// --------------------
/// Smart highlighting: full tree + unmet/satisfied split
/// --------------------

class _PrereqClosure {
  _PrereqClosure(this.nodes, this.edgeMap);
  final Set<String> nodes;
  final Map<_EdgeKey, MovementPrereq> edgeMap;
}

_PrereqClosure _collectPrereqClosure({
  required String targetId,
  required Map<String, List<MovementPrereq>> prereqsByMovement,
}) {
  final nodes = <String>{};
  final edgeMap = <_EdgeKey, MovementPrereq>{};
  final visited = <String>{};

  void dfs(String id) {
    if (visited.contains(id)) return;
    visited.add(id);

    final reqs = prereqsByMovement[id] ?? const <MovementPrereq>[];
    for (final r in reqs) {
      final preId = r.prereqMovementId;
      final key = _EdgeKey(preId, id);
      nodes.add(preId);
      edgeMap[key] = r;
      dfs(preId);
    }
  }

  dfs(targetId);
  return _PrereqClosure(nodes, edgeMap);
}

_HighlightPlan _computeHighlightPlan({
  required String targetId,
  required List<MovementWithProgress> allMovements,
  required List<MovementPrereq> allReqs,
  required int totalXp,
}) {
  final movementById = <String, MovementWithProgress>{
    for (final x in allMovements) x.movement.id: x,
  };

  final prereqsByMovement = <String, List<MovementPrereq>>{};
  for (final r in allReqs) {
    prereqsByMovement.putIfAbsent(r.movementId, () => []).add(r);
  }

  final target = movementById[targetId];
  if (target == null) return _HighlightPlan.empty();

  final xpMissing = max(0, target.movement.xpToUnlock - totalXp);

  final missingDirect = _missingPrereqsFor(
    movementId: targetId,
    prereqsByMovement: prereqsByMovement,
    movementById: movementById,
  );

  // Full tree (context)
  final closure = _collectPrereqClosure(
    targetId: targetId,
    prereqsByMovement: prereqsByMovement,
  );

  final highlightNodes = <String>{targetId, ...closure.nodes};

  final unmetEdges = <_EdgeKey>{};
  final satisfiedEdges = <_EdgeKey>{};
  final unmetNodes = <String>{};

  for (final entry in closure.edgeMap.entries) {
    final key = entry.key;
    final edge = entry.value;
    final ok = _isSatisfied(edge, movementById);

    if (ok) {
      satisfiedEdges.add(key);
    } else {
      unmetEdges.add(key);
      unmetNodes.add(edge.prereqMovementId);
    }
  }

  // Optional: next actionable chain for the panel
  final visited = <String>{targetId};
  final q = Queue<String>()..add(targetId);
  final parent = <String, String>{}; // prereq -> nextTowardTarget
  String? found;

  while (q.isNotEmpty) {
    final current = q.removeFirst();
    final reqs = prereqsByMovement[current] ?? const <MovementPrereq>[];

    for (final r in reqs) {
      if (_isSatisfied(r, movementById)) continue;

      final pre = r.prereqMovementId;
      if (visited.contains(pre)) continue;

      visited.add(pre);
      parent[pre] = current;

      if (_isActionable(pre, r, movementById)) {
        found = pre;
        q.clear();
        break;
      }
      q.add(pre);
    }
  }

  final steps = <String>[];
  if (found != null) {
    String cursor = found;
    steps.add(cursor);
    while (parent.containsKey(cursor)) {
      final next = parent[cursor]!;
      steps.add(next);
      cursor = next;
      if (cursor == targetId) break;
    }
  }

  final grindSuggestions =
      (steps.isEmpty && xpMissing > 0 && missingDirect.isEmpty)
      ? _suggestXpGrind(movementById.values.toList())
      : const <String>[];

  return _HighlightPlan(
    targetId: targetId,
    highlightNodes: highlightNodes,
    unmetNodes: unmetNodes,
    unmetEdges: unmetEdges,
    satisfiedEdges: satisfiedEdges,
    missingDirect: missingDirect,
    xpMissing: xpMissing,
    pathSteps: steps,
    grindSuggestions: grindSuggestions,
  );
}

List<_MissingPrereq> _missingPrereqsFor({
  required String movementId,
  required Map<String, List<MovementPrereq>> prereqsByMovement,
  required Map<String, MovementWithProgress> movementById,
}) {
  final reqs = prereqsByMovement[movementId] ?? const <MovementPrereq>[];
  final missing = <_MissingPrereq>[];

  for (final r in reqs) {
    if (_isSatisfied(r, movementById)) continue;

    final pre = movementById[r.prereqMovementId];

    missing.add(
      _MissingPrereq(
        movementId: r.prereqMovementId,
        name: pre?.movement.name ?? r.prereqMovementId,
        prereqType: r.prereqType,
        currentState: pre?.progress.state ?? "locked",
      ),
    );
  }

  return missing;
}

bool _isSatisfied(
  MovementPrereq r,
  Map<String, MovementWithProgress> movementById,
) {
  final pre = movementById[r.prereqMovementId];
  if (pre == null) return false;
  return isPrereqSatisfied(
    prereqType: r.prereqType,
    currentState: pre.progress.state,
  );
}

bool _isActionable(
  String prereqId,
  MovementPrereq edge,
  Map<String, MovementWithProgress> movementById,
) {
  final pre = movementById[prereqId];
  if (pre == null) return false;

  if (pre.progress.state == "locked") return false;
  return !isPrereqSatisfied(
    prereqType: edge.prereqType,
    currentState: pre.progress.state,
  );
}

List<String> _suggestXpGrind(List<MovementWithProgress> all) {
  final unlocked = all.where((x) => x.progress.state != "locked").toList()
    ..sort((a, b) => a.movement.difficulty.compareTo(b.movement.difficulty));
  return unlocked.take(3).map((x) => x.movement.id).toList();
}

/// --------------------
/// Layout types
/// --------------------

class _LayeredLayout {
  _LayeredLayout({
    required this.canvasSize,
    required this.nodeCenters,
    required this.categoryHeaderCenters,
    required this.movementNodes,
    required this.edges,
    required this.headerEdges,
    required this.showCategoryHeaders,
  });

  final Size canvasSize;
  final Map<String, Offset> nodeCenters;
  final Map<String, Offset> categoryHeaderCenters;
  final List<_LayoutNode> movementNodes;
  final List<_EdgeSpec> edges;
  final List<_EdgeSpec> headerEdges;
  final bool showCategoryHeaders;
}

class _LayoutNode {
  const _LayoutNode({required this.id, required this.center});
  final String id;
  final Offset center;
}

class _EdgeSpec {
  const _EdgeSpec({
    required this.from,
    required this.to,
    required this.isCross,
  });
  final String from;
  final String to;
  final bool isCross;
}

/// --------------------
/// Painter (smart edges)
/// --------------------

class _LayeredTreePainter extends CustomPainter {
  _LayeredTreePainter({
    required this.nodeCenters,
    required this.categoryHeaderCenters,
    required this.edges,
    required this.headerEdges,
    required this.unmetEdges,
    required this.satisfiedEdges,
    required this.showAllEdges,
    required this.showCrossLinks,
    required this.colorScheme,
    required this.highlightAccent,
    required this.goalFocusRouting,
  });

  final Map<String, Offset> nodeCenters;
  final Map<String, Offset> categoryHeaderCenters;

  final List<_EdgeSpec> edges;
  final List<_EdgeSpec> headerEdges;

  final Set<_EdgeKey> unmetEdges;
  final Set<_EdgeKey> satisfiedEdges;

  final bool showAllEdges;
  final bool showCrossLinks;

  final ColorScheme colorScheme;
  final Color highlightAccent;
  final bool goalFocusRouting;

  bool _isMainEdgeVisible(
    _EdgeSpec e, {
    required bool isUnmet,
    required bool isSatisfied,
  }) {
    // If this edge is part of the selected plan, always show it.
    if (!isUnmet && !isSatisfied) {
      if (!showAllEdges) {
        if (e.isCross) return false;
      } else {
        if (e.isCross && !showCrossLinks) return false;
      }
    }
    return true;
  }

  Map<_EdgeKey, _EdgeRouteHint> _computeEdgeRouteHints() {
    final visibleEdges = <_EdgeSpec>[];

    for (final e in edges) {
      final aCenter = nodeCenters[e.from];
      final bCenter = nodeCenters[e.to];
      if (aCenter == null || bCenter == null) continue;

      final key = _EdgeKey(e.from, e.to);
      final isUnmet = unmetEdges.contains(key);
      final isSatisfied = satisfiedEdges.contains(key);
      if (
          !_isMainEdgeVisible(
            e,
            isUnmet: isUnmet,
            isSatisfied: isSatisfied,
          )) {
        continue;
      }

      visibleEdges.add(e);
    }

    final fromMap = <String, List<_EdgeSpec>>{};
    final toMap = <String, List<_EdgeSpec>>{};

    for (final e in visibleEdges) {
      fromMap.putIfAbsent(e.from, () => <_EdgeSpec>[]).add(e);
      toMap.putIfAbsent(e.to, () => <_EdgeSpec>[]).add(e);
    }

    List<double> slotOffsetsForCount(int count) {
      if (count <= 1) return const <double>[0.0];

      const desiredGap = 22.0;
      const maxHalfSpread = _kNodeW * 0.32;
      final mid = (count - 1) / 2.0;
      final rawMax = mid * desiredGap;
      final scale = rawMax <= 0 ? 1.0 : min(1.0, maxHalfSpread / rawMax);

      return List<double>.generate(
        count,
        (i) => (i - mid) * desiredGap * scale,
        growable: false,
      );
    }

    int compareOutgoing(_EdgeSpec a, _EdgeSpec b) {
      final ax = nodeCenters[a.to]?.dx ?? 0.0;
      final bx = nodeCenters[b.to]?.dx ?? 0.0;
      final cx = ax.compareTo(bx);
      if (cx != 0) return cx;
      final ct = a.to.compareTo(b.to);
      if (ct != 0) return ct;
      return a.from.compareTo(b.from);
    }

    int compareIncoming(_EdgeSpec a, _EdgeSpec b) {
      final ax = nodeCenters[a.from]?.dx ?? 0.0;
      final bx = nodeCenters[b.from]?.dx ?? 0.0;
      final cx = ax.compareTo(bx);
      if (cx != 0) return cx;
      final ct = a.from.compareTo(b.from);
      if (ct != 0) return ct;
      return a.to.compareTo(b.to);
    }

    final startOffsets = <_EdgeKey, double>{};
    final endOffsets = <_EdgeKey, double>{};
    final incomingIndex = <_EdgeKey, int>{};
    final incomingCount = <_EdgeKey, int>{};

    for (final list in fromMap.values) {
      list.sort(compareOutgoing);
      final slots = slotOffsetsForCount(list.length);
      for (var i = 0; i < list.length; i++) {
        final e = list[i];
        startOffsets[_EdgeKey(e.from, e.to)] = slots[i];
      }
    }

    for (final list in toMap.values) {
      list.sort(compareIncoming);
      final slots = slotOffsetsForCount(list.length);
      for (var i = 0; i < list.length; i++) {
        final e = list[i];
        final key = _EdgeKey(e.from, e.to);
        endOffsets[key] = slots[i];
        incomingIndex[key] = i;
        incomingCount[key] = list.length;
      }
    }

    final routes = <_EdgeKey, _EdgeRouteHint>{};
    for (final e in visibleEdges) {
      final key = _EdgeKey(e.from, e.to);
      routes[key] = _EdgeRouteHint(
        startPortX: startOffsets[key] ?? 0.0,
        endPortX: endOffsets[key] ?? 0.0,
        incomingIndex: incomingIndex[key] ?? 0,
        incomingCount: incomingCount[key] ?? 1,
      );
    }

    return routes;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = colorScheme.outlineVariant.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 240) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), bgPaint);
    }

    final hubPaint = Paint()
      ..color = colorScheme.outlineVariant.withValues(alpha: 0.30)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final samePaint = Paint()
      ..color = colorScheme.outlineVariant.withValues(alpha: 0.18)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final crossPaint = Paint()
      ..color = colorScheme.outlineVariant.withValues(alpha: 0.10)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final satisfiedPaint = Paint()
      ..color = highlightAccent.withValues(alpha: 0.22)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final unmetPaint = Paint()
      ..color = highlightAccent.withValues(alpha: 0.92)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;

    final edgeHints = _computeEdgeRouteHints();

    // Header wiring always visible
    for (final e in headerEdges) {
      final catKey = e.from.startsWith("cat:") ? e.from.substring(4) : e.from;
      final aCenter = categoryHeaderCenters[catKey];
      final bCenter = nodeCenters[e.to];
      if (aCenter == null || bCenter == null) continue;

      _drawEdge(
        canvas,
        aCenter + const Offset(0, 18),
        bCenter,
        hubPaint,
        crossBias: 0.0,
      );
    }

    // Main edges
    for (final e in edges) {
      final aCenter = nodeCenters[e.from];
      final bCenter = nodeCenters[e.to];
      if (aCenter == null || bCenter == null) continue;

      final key = _EdgeKey(e.from, e.to);
      final isUnmet = unmetEdges.contains(key);
      final isSatisfied = satisfiedEdges.contains(key);

      if (
          !_isMainEdgeVisible(
            e,
            isUnmet: isUnmet,
            isSatisfied: isSatisfied,
          )) {
        continue;
      }

      final paint = isUnmet
          ? unmetPaint
          : isSatisfied
          ? satisfiedPaint
          : e.isCross
          ? crossPaint
          : samePaint;
      final route = edgeHints[_EdgeKey(e.from, e.to)] ??
          const _EdgeRouteHint(
            startPortX: 0.0,
            endPortX: 0.0,
            incomingIndex: 0,
            incomingCount: 1,
          );

      if (goalFocusRouting) {
        _drawGoalFocusEdge(
          canvas,
          aCenter,
          bCenter,
          paint,
          startPortX: route.startPortX,
          endPortX: route.endPortX,
          incomingIndex: route.incomingIndex,
          incomingCount: route.incomingCount,
          crossBias: e.isCross ? 0.35 : 0.0,
        );
      } else {
        _drawEdge(
          canvas,
          aCenter,
          bCenter,
          paint,
          startPortX: route.startPortX,
          endPortX: route.endPortX,
          crossBias: e.isCross ? 0.35 : 0.0,
        );
      }
    }
  }

  void _drawEdge(
    Canvas canvas,
    Offset fromCenter,
    Offset toCenter,
    Paint paint, {
    double startPortX = 0.0,
    double endPortX = 0.0,
    required double crossBias,
  }) {
    final start = fromCenter + Offset(startPortX, _kNodeH / 2);
    final end = toCenter + Offset(endPortX, -_kNodeH / 2);

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;

    if (dy.abs() < 2 && dx.abs() < 2) return;

    final bend = dx * (0.20 + crossBias * 0.35);
    final fan = (startPortX - endPortX) * 0.55;
    final c1 = start + Offset(bend + fan, dy * 0.35);
    final c2 = end - Offset(bend - fan, dy * 0.35);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);

    canvas.drawPath(path, paint);
  }

  void _drawGoalFocusEdge(
    Canvas canvas,
    Offset fromCenter,
    Offset toCenter,
    Paint paint, {
    required double startPortX,
    required double endPortX,
    required int incomingIndex,
    required int incomingCount,
    required double crossBias,
  }) {
    final start = fromCenter + Offset(startPortX, _kNodeH / 2);
    final end = toCenter + Offset(endPortX, -_kNodeH / 2);

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    if (dy.abs() < 2 && dx.abs() < 2) return;

    final laneCenter = (incomingCount - 1) / 2.0;
    final lane = incomingIndex - laneCenter;
    final laneX = lane * 14.0;
    final laneTighten = lane.abs() * 4.0;

    final rawApproachY = end.dy - 34.0 - laneTighten;
    final approachY = rawApproachY.clamp(start.dy + 8.0, end.dy - 8.0);

    final bend = dx * (0.18 + crossBias * 0.22);
    final c1 = Offset(start.dx + bend * 0.65, start.dy + (approachY - start.dy) * 0.55);
    final c2 = Offset(end.dx + laneX, approachY - 3.0);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx + laneX, approachY)
      ..lineTo(end.dx, approachY)
      ..quadraticBezierTo(end.dx, end.dy - 9.0, end.dx, end.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LayeredTreePainter oldDelegate) {
    return oldDelegate.nodeCenters != nodeCenters ||
        oldDelegate.categoryHeaderCenters != categoryHeaderCenters ||
        oldDelegate.edges != edges ||
        oldDelegate.headerEdges != headerEdges ||
        oldDelegate.unmetEdges != unmetEdges ||
        oldDelegate.satisfiedEdges != satisfiedEdges ||
        oldDelegate.showAllEdges != showAllEdges ||
        oldDelegate.showCrossLinks != showCrossLinks ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.highlightAccent != highlightAccent ||
        oldDelegate.goalFocusRouting != goalFocusRouting;
  }
}

class _EdgeRouteHint {
  const _EdgeRouteHint({
    required this.startPortX,
    required this.endPortX,
    required this.incomingIndex,
    required this.incomingCount,
  });

  final double startPortX;
  final double endPortX;
  final int incomingIndex;
  final int incomingCount;
}

class _EdgeKey {
  const _EdgeKey(this.from, this.to);
  final String from;
  final String to;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _EdgeKey && other.from == from && other.to == to);

  @override
  int get hashCode => Object.hash(from, to);
}

/// IMPORTANT: immutable key; snapshot categories so Set mutation does not break Map hashing.
class _LayoutCacheKey {
  _LayoutCacheKey({
    required this.signature,
    required this.prereqSignature,
    required Set<String> activeCategories,
    required this.showCategoryHeaders,
  }) : categoriesSig = (activeCategories.toList()..sort()).join(",");

  final String signature;
  final String prereqSignature;
  final String categoriesSig;
  final bool showCategoryHeaders;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _LayoutCacheKey &&
          other.signature == signature &&
          other.prereqSignature == prereqSignature &&
          other.categoriesSig == categoriesSig &&
          other.showCategoryHeaders == showCategoryHeaders);

  @override
  int get hashCode => Object.hash(
    signature,
    prereqSignature,
    categoriesSig,
    showCategoryHeaders,
  );
}

String _layoutSignature(List<MovementWithProgress> movements) {
  final items =
      movements
          .map(
            (m) =>
                "${m.movement.id}|${m.movement.category}|${m.movement.sortOrder}",
          )
          .toList()
        ..sort();
  return items.join(";");
}

String _prereqSignature(List<MovementPrereq> prereqs) {
  final items =
      prereqs
          .map((r) => "${r.movementId}|${r.prereqMovementId}|${r.prereqType}")
          .toList()
        ..sort();
  return items.join(";");
}

/// --------------------
/// Desktop controls
/// --------------------

class _TopControlsDesktop extends StatelessWidget {
  const _TopControlsDesktop({
    required this.categoryLabels,
    required this.categoryOrder,
    required this.activeCategories,
    required this.showCategoryHeaders,
    required this.showAllEdges,
    required this.showCrossLinks,
    required this.onToggleCategory,
    required this.onSelectAll,
    required this.onToggleHeaders,
    required this.onToggleAllEdges,
    required this.onToggleCrossLinks,
  });

  final Map<String, String> categoryLabels;
  final List<String> categoryOrder;
  final Set<String> activeCategories;

  final bool showCategoryHeaders;
  final bool showAllEdges;
  final bool showCrossLinks;

  final void Function(String key) onToggleCategory;
  final VoidCallback onSelectAll;

  final void Function(bool v) onToggleHeaders;
  final void Function(bool v) onToggleAllEdges;
  final void Function(bool v) onToggleCrossLinks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonal(
              onPressed: onSelectAll,
              child: const Text("All"),
            ),
            ...categoryOrder.where(categoryLabels.containsKey).map((k) {
              final selected = activeCategories.contains(k);
              return FilterChip(
                label: Text(categoryLabels[k] ?? k),
                selected: selected,
                onSelected: (_) => onToggleCategory(k),
              );
            }),
            FilterChip(
              label: const Text("Category headers"),
              selected: showCategoryHeaders,
              onSelected: onToggleHeaders,
            ),
            FilterChip(
              label: const Text("Show edges"),
              selected: showAllEdges,
              onSelected: onToggleAllEdges,
            ),
            FilterChip(
              label: const Text("Cross-links"),
              selected: showCrossLinks,
              onSelected: showAllEdges ? onToggleCrossLinks : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Tap a node: unmet prereqs pop up | view auto-focuses to what you need next",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// --------------------
/// UI pieces
/// --------------------

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.10),
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: cs.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _TreeViewSummary extends StatelessWidget {
  const _TreeViewSummary({
    required this.visibleCount,
    required this.unlockedCount,
    required this.lockedCount,
    required this.goalFocusOnly,
    required this.hasSelection,
    required this.compact,
  });

  final int visibleCount;
  final int unlockedCount;
  final int lockedCount;
  final bool goalFocusOnly;
  final bool hasSelection;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxWidth = compact ? 360.0 : 520.0;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        color: cs.surface.withValues(alpha: 0.92),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _SummaryPill(
                label: "Visible",
                value: "$visibleCount",
                color: cs.primary,
              ),
              _SummaryPill(
                label: "Unlocked",
                value: "$unlockedCount",
                color: cs.secondary,
              ),
              _SummaryPill(
                label: "Locked",
                value: "$lockedCount",
                color: cs.onSurfaceVariant,
              ),
              if (hasSelection)
                _SummaryPill(
                  label: "Selection",
                  value: "Active",
                  color: cs.tertiary,
                ),
              if (goalFocusOnly)
                _SummaryPill(
                  label: "Goal View",
                  value: "Focused",
                  color: cs.tertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _LegendLine extends StatelessWidget {
  const _LegendLine({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class _LegendIconLine extends StatelessWidget {
  const _LegendIconLine({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class _MovementNodeCard extends StatelessWidget {
  const _MovementNodeCard({
    required this.movementId,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.state,
    required this.selected,
    required this.inTree,
    required this.unmet,
    required this.isTarget,
    required this.isGoal,
    required this.cosmeticAccent,
    required this.dimmed,
    required this.onTap,
    required this.onOpen,
  });

  final String movementId;
  final String name;
  final String category;
  final int difficulty;
  final String state;

  final bool selected;
  final bool inTree;
  final bool unmet;
  final bool isTarget;
  final bool isGoal;
  final Color cosmeticAccent;
  final bool dimmed;

  final VoidCallback onTap;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tier = TierVisuals.forState(state, cs);
    final locked = tier.state == "locked";

    final bg = tier.cardBg;
    final cosmeticMix = Color.lerp(tier.accent, cosmeticAccent, 0.32)!;
    final effectiveAccent = locked ? tier.accent : cosmeticMix;

    final border = selected
        ? effectiveAccent
        : isTarget
        ? effectiveAccent
        : isGoal
        ? cs.tertiary
        : unmet
        ? effectiveAccent.withValues(alpha: 0.92)
        : inTree
        ? Color.lerp(tier.cardBorder, effectiveAccent, 0.35)!
        : tier.cardBorder.withValues(alpha: 0.70);

    final icon = tier.icon;

    final thumbPath = "assets/movements/$movementId.png";

    final double baseOpacity = locked ? 0.72 : 1.0;
    final double highlightSoftening =
        (inTree && !unmet && !isTarget && !isGoal && !selected) ? 0.82 : 1.0;
    final double effectiveOpacity = dimmed
        ? baseOpacity * 0.38
        : baseOpacity * highlightSoftening;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 140),
      opacity: effectiveOpacity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: _kNodeW,
          height: _kNodeH,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border,
              width: selected || unmet || isTarget || isGoal ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withValues(alpha: 0.10),
                offset: const Offset(0, 7),
              ),
              if (unmet || isTarget || isGoal)
                BoxShadow(
                  blurRadius: 20,
                  spreadRadius: 1,
                  color: (isGoal ? cs.tertiary : effectiveAccent).withValues(
                    alpha: unmet ? 0.22 : 0.16,
                  ),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: tier.iconBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: locked
                        ? tier.cardBorder
                        : effectiveAccent.withValues(alpha: 0.75),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(
                    thumbPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, error, stackTrace) =>
                        Center(child: Icon(icon, size: 18, color: tier.iconFg)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        if (isGoal) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.flag,
                            size: 14,
                            color: locked ? cs.tertiary : effectiveAccent,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${isGoal ? "Goal | " : ""}$category | D$difficulty | ${tier.label}",
                      style: TextStyle(
                        color: locked ? cs.onSurfaceVariant : effectiveAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: "Open",
                onPressed: onOpen,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.open_in_new,
                  color: locked ? cs.onSurfaceVariant : effectiveAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mobile sheet that uses providers directly so it stays correct even if progress updates.
class _MobileQuestSheet extends ConsumerWidget {
  const _MobileQuestSheet({
    required this.movementId,
    required this.categoryLabels,
    required this.onOpenMovement,
    required this.onQuickLog,
  });

  final String movementId;
  final Map<String, String> categoryLabels;
  final void Function(String movementId) onOpenMovement;
  final Future<void> Function(String movementId, String movementName)
  onQuickLog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movements = ref.watch(movementsWithProgressProvider);
    final plan = ref.watch(skillTreePlanProvider(movementId));
    final goalMovementId = ref
        .watch(skillGoalProvider)
        .maybeWhen(data: (id) => id, orElse: () => null);

    return movements.when(
      data: (items) {
        final byId = <String, MovementWithProgress>{
          for (final x in items) x.movement.id: x,
        };
        final selection = byId[movementId];

        if (selection == null) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Text("Movement not found."),
          );
        }

        return _QuestPanel(
          selection: selection,
          plan: plan,
          categoryLabels: categoryLabels,
          nameForId: (id) => byId[id]?.movement.name ?? id,
          onOpenMovement: onOpenMovement,
          onQuickLog: onQuickLog,
          isGoal: goalMovementId == selection.movement.id,
          onSetGoal: () async {
            await ref
                .read(skillGoalProvider.notifier)
                .setGoal(selection.movement.id);
          },
          onClearGoal: () async {
            await ref.read(skillGoalProvider.notifier).setGoal(null);
          },
          onClear: () => Navigator.of(context).pop(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text("Movements error: $e"),
      ),
    );
  }
}

class _QuestPanel extends StatelessWidget {
  const _QuestPanel({
    required this.selection,
    required this.plan,
    required this.categoryLabels,
    required this.nameForId,
    required this.onOpenMovement,
    required this.onQuickLog,
    required this.isGoal,
    required this.onSetGoal,
    required this.onClearGoal,
    required this.onClear,
  });

  final MovementWithProgress selection;
  final _HighlightPlan plan;

  final Map<String, String> categoryLabels;
  final String Function(String id) nameForId;

  final void Function(String movementId) onOpenMovement;
  final Future<void> Function(String movementId, String movementName)
  onQuickLog;
  final bool isGoal;
  final Future<void> Function() onSetGoal;
  final Future<void> Function() onClearGoal;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locked = selection.progress.state == "locked";

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Card(
        elevation: 3,
        color: cs.surface,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selection.movement.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${categoryLabels[selection.movement.category] ?? selection.movement.category} | ${TierVisuals.labelForState(selection.progress.state)}",
                          style: TextStyle(
                            color: TierVisuals.forState(
                              selection.progress.state,
                              cs,
                            ).accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isGoal) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: cs.tertiaryContainer,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: Text(
                              "Current Goal",
                              style: TextStyle(
                                color: cs.onTertiaryContainer,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: "Close",
                    onPressed: onClear,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (locked && plan.xpMissing > 0)
                _InfoRow(
                  icon: Icons.auto_graph,
                  text: "Need ${plan.xpMissing} XP to unlock.",
                ),
              if (locked && plan.missingDirect.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: plan.missingDirect.map((m) {
                    final required = normalizePrereqType(m.prereqType);
                    final short = required == "unlocked"
                        ? "unlock"
                        : prereqLabel(required).toLowerCase();
                    final label = "${m.name} ($short)";
                    return ActionChip(
                      label: Text(label),
                      avatar: Icon(_prereqTypeIcon(required)),
                      onPressed: () => onOpenMovement(m.movementId),
                    );
                  }).toList(),
                ),
              ],
              if (plan.pathSteps.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  "Next best path",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Column(
                  children: plan.pathSteps.map((id) {
                    final isTarget = id == plan.targetId;
                    final title = isTarget
                        ? "Target: ${selection.movement.name}"
                        : nameForId(id);

                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: FilledButton.tonal(
                        onPressed: () => onOpenMovement(id),
                        child: Text(isTarget ? "View" : "Open"),
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (plan.pathSteps.isEmpty &&
                  plan.grindSuggestions.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  "Do this next (for XP)",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: plan.grindSuggestions.map((id) {
                    final n = nameForId(id);
                    return FilledButton.tonal(
                      onPressed: () async => onQuickLog(id, n),
                      child: Text("Log $n"),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton(
                    onPressed: () => onOpenMovement(selection.movement.id),
                    child: const Text("Open details"),
                  ),
                  FilledButton.tonal(
                    onPressed: selection.progress.state == "locked"
                        ? null
                        : () async => onQuickLog(
                            selection.movement.id,
                            selection.movement.name,
                          ),
                    child: const Text("Quick log"),
                  ),
                  FilledButton.tonal(
                    onPressed: () async {
                      if (isGoal) {
                        await onClearGoal();
                        return;
                      }
                      await onSetGoal();
                    },
                    child: Text(isGoal ? "Clear goal" : "Set goal"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

/// --------------------
/// Plan model
/// --------------------

class _HighlightPlan {
  _HighlightPlan({
    required this.targetId,
    required this.highlightNodes, // target + full prereq tree
    required this.unmetNodes, // nodes you still need
    required this.unmetEdges, // blocking edges (bright)
    required this.satisfiedEdges, // satisfied edges (dim)
    required this.missingDirect,
    required this.xpMissing,
    required this.pathSteps,
    required this.grindSuggestions,
  });

  factory _HighlightPlan.empty() => _HighlightPlan(
    targetId: "",
    highlightNodes: <String>{},
    unmetNodes: <String>{},
    unmetEdges: <_EdgeKey>{},
    satisfiedEdges: <_EdgeKey>{},
    missingDirect: const <_MissingPrereq>[],
    xpMissing: 0,
    pathSteps: const <String>[],
    grindSuggestions: const <String>[],
  );

  final String targetId;

  final Set<String> highlightNodes;
  final Set<String> unmetNodes;

  final Set<_EdgeKey> unmetEdges;
  final Set<_EdgeKey> satisfiedEdges;

  final List<_MissingPrereq> missingDirect;
  final int xpMissing;

  final List<String> pathSteps;
  final List<String> grindSuggestions;
}

class _MissingPrereq {
  _MissingPrereq({
    required this.movementId,
    required this.name,
    required this.prereqType,
    required this.currentState,
  });

  final String movementId;
  final String name;
  final String prereqType;
  final String currentState;
}

IconData _prereqTypeIcon(String prereqType) {
  switch (normalizePrereqType(prereqType)) {
    case "unlocked":
      return Icons.lock_open;
    case "progress":
      return Icons.trending_up;
    case "bronze":
    case "silver":
    case "gold":
    case "mastered":
      return Icons.emoji_events;
    default:
      return Icons.lock_open;
  }
}
