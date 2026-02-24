import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../data/db/app_db.dart";
import "../../domain/movement_tier.dart";
import "../../state/providers.dart";
import "../theme/cosmetic_visuals.dart";

enum _BadgeFilter { all, earned, locked }

enum _BadgeSort { recommended, name, newestEarned }

enum _BadgeCategory {
  all,
  onboarding,
  sessions,
  streaks,
  xp,
  level,
  unlocks,
  mastery,
  time,
  pullup,
  pushup,
  squat,
  plank,
  handstand,
  skills,
  misc,
}

enum _BadgeTier { bronze, silver, gold }

class _BadgeProgress {
  const _BadgeProgress({
    required this.current,
    required this.target,
    required this.label,
    required this.hint,
  });

  final int current;
  final int target;
  final String label;
  final String hint;

  double get pct {
    if (target <= 0) return 0.0;
    return (current / target).clamp(0.0, 1.0);
  }

  bool get isComplete => target > 0 && current >= target;
}

class BadgesScreen extends ConsumerStatefulWidget {
  const BadgesScreen({super.key});

  @override
  ConsumerState<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends ConsumerState<BadgesScreen> {
  _BadgeFilter filter = _BadgeFilter.all;
  _BadgeSort sort = _BadgeSort.recommended;
  _BadgeCategory category = _BadgeCategory.all;
  String query = "";

  BadgeMetrics? _cachedMetrics;

  ProviderSubscription<AsyncValue<List<BadgeWithEarned>>>? _badgesSub;
  final Set<String> _knownEarnedIds = <String>{};
  bool _initEarned = false;

  @override
  void initState() {
    super.initState();

    _badgesSub = ref.listenManual<AsyncValue<List<BadgeWithEarned>>>(
      badgesProvider,
      (prev, next) {
        next.whenData((items) {
          final earnedNow = items
              .where((b) => b.isEarned)
              .map((b) => b.badge.id)
              .toSet();

          if (!_initEarned) {
            _knownEarnedIds
              ..clear()
              ..addAll(earnedNow);
            _initEarned = true;
            return;
          }

          final newly = earnedNow.difference(_knownEarnedIds);
          if (newly.isEmpty) return;

          _knownEarnedIds
            ..clear()
            ..addAll(earnedNow);

          if (!mounted) return;

          final newlyEarned = items
              .where((b) => newly.contains(b.badge.id))
              .toList();
          _showJustEarnedToast(newlyEarned);
        });
      },
    );
  }

  @override
  void dispose() {
    _badgesSub?.close();
    super.dispose();
  }

  void _showJustEarnedToast(List<BadgeWithEarned> newlyEarned) {
    if (newlyEarned.isEmpty) return;

    final names = newlyEarned.map((b) => b.badge.name).toList();
    final subtitle = names.length == 1
        ? names.first
        : names.length == 2
        ? "${names[0]} • ${names[1]}"
        : "${names[0]} • +${names.length - 1} more";

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: _JustEarnedToast(subtitle: subtitle),
        action: SnackBarAction(
          label: "View",
          onPressed: () {
            final first = newlyEarned.first;
            _openBadgeDetails(
              context,
              first,
              _progressForBadge(first, _cachedMetrics),
            );
          },
        ),
      ),
    );
  }

  bool get _hasActiveFilters =>
      query.trim().isNotEmpty ||
      filter != _BadgeFilter.all ||
      category != _BadgeCategory.all ||
      sort != _BadgeSort.recommended;

  void _clearAll() {
    setState(() {
      query = "";
      filter = _BadgeFilter.all;
      sort = _BadgeSort.recommended;
      category = _BadgeCategory.all;
    });
  }

  @override
  Widget build(BuildContext context) {
    final badgesAsync = ref.watch(badgesProvider);
    final metricsAsync = ref.watch(badgeMetricsProvider);
    final scheme = Theme.of(context).colorScheme;
    final equippedCosmeticId = ref
        .watch(cosmeticStatusProvider)
        .maybeWhen(data: (v) => v.equippedCosmeticId, orElse: () => null);
    final cosmeticAccent = cosmeticVisualForId(
      equippedCosmeticId,
      fallbackColor: scheme.primary,
    ).color;

    final metrics = metricsAsync.maybeWhen(data: (m) => m, orElse: () => null);
    _cachedMetrics = metrics;

    return Scaffold(
      appBar: AppBar(title: const Text("Badges")),
      body: badgesAsync.when(
        data: (items) {
          final earnedCount = items.where((b) => b.isEarned).length;
          final total = items.length;
          final pct = total == 0 ? 0.0 : (earnedCount / total);

          final filtered = _applyQueryAndFilter(items);
          final categorized = _applyCategory(filtered);
          final sorted = _applySort(categorized, metrics);

          // ✅ FIX: slivers so header/controls scroll on mobile (no RenderFlex overflow)
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _BadgesHeader(
                        earned: earnedCount,
                        total: total,
                        pct: pct,
                        nextSuggestion: _pickNextTarget(items, metrics),
                      ),
                      const SizedBox(height: 12),

                      _ControlsRow(
                        query: query,
                        filter: filter,
                        sort: sort,
                        category: category,
                        onQueryChanged: (v) => setState(() => query = v),
                        onFilterChanged: (v) => setState(() => filter = v),
                        onSortChanged: (v) => setState(() => sort = v),
                        onCategoryChanged: (v) => setState(() => category = v),
                      ),
                      const SizedBox(height: 12),

                      LayoutBuilder(
                        builder: (context, box) {
                          final compact = box.maxWidth < 360;

                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${sorted.length} badge${sorted.length == 1 ? "" : "s"}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              if (_hasActiveFilters)
                                compact
                                    ? IconButton(
                                        tooltip: "Clear",
                                        onPressed: _clearAll,
                                        icon: const Icon(Icons.clear),
                                      )
                                    : TextButton.icon(
                                        onPressed: _clearAll,
                                        icon: const Icon(Icons.clear),
                                        label: const Text("Clear"),
                                      ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              if (sorted.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _EmptyState(
                      title: "No badges match your filters",
                      subtitle: "Try clearing search or switching to All.",
                      onClear: _clearAll,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.crossAxisExtent;

                      // ✅ Give very small phones 1 column (stops right-overflows in tight tiles)
                      final crossAxisCount = w < 360
                          ? 1
                          : w < 520
                          ? 2
                          : w < 820
                          ? 3
                          : w < 1120
                          ? 4
                          : w < 1440
                          ? 5
                          : 6;

                      // width/height (smaller => taller)
                      final aspect = switch (crossAxisCount) {
                        1 => 3.10, // list-like card for small phones
                        2 => 1.10,
                        3 => 1.02,
                        4 => 0.95,
                        5 => 0.90,
                        _ => 0.86,
                      };

                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: aspect,
                        ),
                        delegate: SliverChildBuilderDelegate((context, i) {
                          final b = sorted[i];
                          final progress = _progressForBadge(b, metrics);
                          final tier = _tierForBadge(b, progress);

                          return _BadgeCard(
                            badge: b,
                            progress: progress,
                            tier: tier,
                            cosmeticAccent: cosmeticAccent,
                            onTap: () =>
                                _openBadgeDetails(context, b, progress),
                          );
                        }, childCount: sorted.length),
                      );
                    },
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Badges error: $e")),
      ),
    );
  }

  List<BadgeWithEarned> _applyQueryAndFilter(List<BadgeWithEarned> items) {
    final q = query.trim().toLowerCase();

    return items.where((b) {
      final name = b.badge.name.toLowerCase();
      final desc = b.badge.description.toLowerCase();

      final matchesQuery = q.isEmpty || name.contains(q) || desc.contains(q);

      final matchesFilter = switch (filter) {
        _BadgeFilter.all => true,
        _BadgeFilter.earned => b.isEarned,
        _BadgeFilter.locked => !b.isEarned,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  }

  List<BadgeWithEarned> _applyCategory(List<BadgeWithEarned> items) {
    if (category == _BadgeCategory.all) return items;
    return items.where((b) => _categoryForId(b.badge.id) == category).toList();
  }

  List<BadgeWithEarned> _applySort(
    List<BadgeWithEarned> items,
    BadgeMetrics? metrics,
  ) {
    final out = [...items];

    int safeCompareString(String a, String b) =>
        a.toLowerCase().compareTo(b.toLowerCase());

    out.sort((a, b) {
      if (sort == _BadgeSort.recommended) {
        if (a.isEarned != b.isEarned) return a.isEarned ? -1 : 1;

        if (a.isEarned && b.isEarned) {
          final ad = a.userBadge?.earnedAt;
          final bd = b.userBadge?.earnedAt;
          if (ad != null && bd != null) return bd.compareTo(ad);
        }

        final ap = _progressForBadge(a, metrics)?.pct ?? 0.0;
        final bp = _progressForBadge(b, metrics)?.pct ?? 0.0;
        if (ap != bp) return bp.compareTo(ap);

        return safeCompareString(a.badge.name, b.badge.name);
      }

      if (sort == _BadgeSort.name) {
        return safeCompareString(a.badge.name, b.badge.name);
      }

      final ad = a.userBadge?.earnedAt;
      final bd = b.userBadge?.earnedAt;
      if (ad == null && bd == null)
        return safeCompareString(a.badge.name, b.badge.name);
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad);
    });

    return out;
  }

  String? _pickNextTarget(List<BadgeWithEarned> items, BadgeMetrics? metrics) {
    if (metrics == null) return null;

    final locked = items.where((b) => !b.isEarned).toList();
    if (locked.isEmpty) return null;

    locked.sort((a, b) {
      final ap = _progressForBadge(a, metrics)?.pct ?? 0.0;
      final bp = _progressForBadge(b, metrics)?.pct ?? 0.0;
      return bp.compareTo(ap);
    });

    final best = locked.first;
    final prog = _progressForBadge(best, metrics);
    if (prog == null) return null;

    return "Next up: ${best.badge.name} • ${prog.label}";
  }

  Future<void> _openBadgeDetails(
    BuildContext context,
    BadgeWithEarned b,
    _BadgeProgress? progress,
  ) async {
    final tier = _tierForBadge(b, progress);
    final scheme = Theme.of(context).colorScheme;
    final equippedCosmeticId = ref
        .read(cosmeticStatusProvider)
        .maybeWhen(data: (v) => v.equippedCosmeticId, orElse: () => null);
    final cosmeticAccent = cosmeticVisualForId(
      equippedCosmeticId,
      fallbackColor: scheme.primary,
    ).color;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _BadgeDetailsSheet(
        badge: b,
        progress: progress,
        tier: tier,
        cosmeticAccent: cosmeticAccent,
      ),
    );
  }
}

class _BadgesHeader extends StatelessWidget {
  const _BadgesHeader({
    required this.earned,
    required this.total,
    required this.pct,
    required this.nextSuggestion,
  });

  final int earned;
  final int total;
  final double pct;
  final String? nextSuggestion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = (pct * 100).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: scheme.primary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Collection",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              // ✅ FIX: scale down on narrow widths instead of overflowing right
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      "$earned / $total • $percent%",
                      style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            earned == total
                ? "All badges earned. Absolute machine."
                : (nextSuggestion ?? "Keep going — each badge is a milestone."),
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ControlsRow extends StatelessWidget {
  const _ControlsRow({
    required this.query,
    required this.filter,
    required this.sort,
    required this.category,
    required this.onQueryChanged,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onCategoryChanged,
  });

  final String query;
  final _BadgeFilter filter;
  final _BadgeSort sort;
  final _BadgeCategory category;

  final ValueChanged<String> onQueryChanged;
  final ValueChanged<_BadgeFilter> onFilterChanged;
  final ValueChanged<_BadgeSort> onSortChanged;
  final ValueChanged<_BadgeCategory> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onChanged: onQueryChanged,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: "Search badges…",
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _FilterChip(
              label: "All",
              selected: filter == _BadgeFilter.all,
              onTap: () => onFilterChanged(_BadgeFilter.all),
            ),
            _FilterChip(
              label: "Earned",
              selected: filter == _BadgeFilter.earned,
              onTap: () => onFilterChanged(_BadgeFilter.earned),
            ),
            _FilterChip(
              label: "Locked",
              selected: filter == _BadgeFilter.locked,
              onTap: () => onFilterChanged(_BadgeFilter.locked),
            ),
            const SizedBox(width: 6),
            _SortDropdown(value: sort, onChanged: onSortChanged),
          ],
        ),

        const SizedBox(height: 10),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _BadgeCategory.values.map((c) {
              final label = _categoryLabel(c);
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _FilterChip(
                  label: label,
                  selected: category == c,
                  onTap: () => onCategoryChanged(c),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.value, required this.onChanged});

  final _BadgeSort value;
  final ValueChanged<_BadgeSort> onChanged;

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: keep the selected label short so it doesn’t overflow in tight layouts
    String shortLabel(_BadgeSort s) => switch (s) {
      _BadgeSort.recommended => "Recommended",
      _BadgeSort.name => "Name",
      _BadgeSort.newestEarned => "Newest",
    };

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 190),
      child: DropdownButton<_BadgeSort>(
        value: value,
        isExpanded: true,
        borderRadius: BorderRadius.circular(12),
        underline: const SizedBox.shrink(),
        selectedItemBuilder: (context) {
          return _BadgeSort.values.map((s) {
            return Text(
              "Sort: ${shortLabel(s)}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          }).toList();
        },
        items: const [
          DropdownMenuItem(
            value: _BadgeSort.recommended,
            child: Text("Sort: Recommended"),
          ),
          DropdownMenuItem(value: _BadgeSort.name, child: Text("Sort: Name")),
          DropdownMenuItem(
            value: _BadgeSort.newestEarned,
            child: Text("Sort: Newest earned"),
          ),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.badge,
    required this.progress,
    required this.tier,
    required this.cosmeticAccent,
    required this.onTap,
  });

  final BadgeWithEarned badge;
  final _BadgeProgress? progress;
  final _BadgeTier tier;
  final Color cosmeticAccent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEarned = badge.isEarned;

    final icon = isEarned ? Icons.emoji_events : Icons.lock_outline;

    final earnedAt = badge.userBadge?.earnedAt;
    final earnedText = earnedAt == null
        ? null
        : _formatDateTime(context, earnedAt);
    final onAccent =
        ThemeData.estimateBrightnessForColor(cosmeticAccent) == Brightness.dark
        ? Colors.white
        : Colors.black;

    final tierColors = _tierColors(scheme, tier);

    return LayoutBuilder(
      builder: (context, box) {
        final compactH = box.maxHeight < 190;
        final compactW = box.maxWidth < 170;
        final compact = compactH || compactW;

        final pad = compact ? 10.0 : 12.0;

        final showProgress = !isEarned && progress != null && !compact;
        final showFooter = !compact;
        final descLines = compact ? 2 : (showProgress ? 2 : 3);

        return Opacity(
          opacity: isEarned ? 1.0 : 0.62,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Card(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isEarned
                        ? Color.lerp(tierColors.border, cosmeticAccent, 0.45)!
                        : tierColors.border.withValues(alpha: 0.65),
                  ),
                  boxShadow: isEarned
                      ? <BoxShadow>[
                          BoxShadow(
                            color: cosmeticAccent.withValues(alpha: 0.14),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Padding(
                  padding: EdgeInsets.all(pad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isEarned
                                  ? cosmeticAccent.withValues(alpha: 0.22)
                                  : scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                              border: isEarned
                                  ? Border.all(
                                      color: cosmeticAccent.withValues(
                                        alpha: 0.62,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Icon(
                              icon,
                              color: isEarned
                                  ? onAccent
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  badge.badge.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),

                                // ✅ FIX: both pills flexible so row never overflows right
                                Row(
                                  children: [
                                    Flexible(
                                      child: _TierPill(
                                        tier: tier,
                                        compact: compactW,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Tooltip(
                                        message: isEarned
                                            ? (earnedText == null
                                                  ? "Earned"
                                                  : "Earned • $earnedText")
                                            : "Locked",
                                        child: _StatusPill(
                                          isEarned: isEarned,
                                          // keep short in grid; full in tooltip + details sheet
                                          earnedText: null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Expanded(
                        child: Text(
                          badge.badge.description,
                          maxLines: descLines,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),

                      if (showProgress) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress!.pct,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          progress!.label,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      if (showFooter) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                isEarned ? "Tap to view" : "Tap for details",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isEarned, required this.earnedText});

  final bool isEarned;
  final String? earnedText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = isEarned
        ? (earnedText == null ? "Earned" : "Earned • $earnedText")
        : "Locked";

    final bg = isEarned ? scheme.secondaryContainer : scheme.surface;
    final fg = isEarned ? scheme.onSecondaryContainer : scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _TierPill extends StatelessWidget {
  const _TierPill({required this.tier, required this.compact});

  final _BadgeTier tier;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = _tierColors(scheme, tier);

    final size = compact ? 24.0 : 28.0;
    final iconSize = compact ? 13.0 : 16.0;

    final icon = switch (tier) {
      _BadgeTier.bronze => Icons.military_tech_outlined,
      _BadgeTier.silver => Icons.military_tech,
      _BadgeTier.gold => Icons.workspace_premium,
    };

    return Tooltip(
      message: _tierLabel(tier),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.bg, Color.alphaBlend(Colors.white24, colors.bg)],
          ),
          border: Border.all(color: colors.border, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: colors.border.withValues(alpha: 0.28),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: iconSize, color: colors.fg),
      ),
    );
  }
}

class _BadgeDetailsSheet extends StatelessWidget {
  const _BadgeDetailsSheet({
    required this.badge,
    required this.progress,
    required this.tier,
    required this.cosmeticAccent,
  });

  final BadgeWithEarned badge;
  final _BadgeProgress? progress;
  final _BadgeTier tier;
  final Color cosmeticAccent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final isEarned = badge.isEarned;
    final icon = isEarned ? Icons.emoji_events : Icons.lock_outline;

    final earnedAt = badge.userBadge?.earnedAt;
    final earnedText = earnedAt == null
        ? null
        : _formatDateTime(context, earnedAt);
    final onAccent =
        ThemeData.estimateBrightnessForColor(cosmeticAccent) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isEarned
                        ? cosmeticAccent.withValues(alpha: 0.24)
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(18),
                    border: isEarned
                        ? Border.all(
                            color: cosmeticAccent.withValues(alpha: 0.62),
                          )
                        : null,
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: isEarned ? onAccent : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        badge.badge.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _TierPill(tier: tier, compact: false),
                          _StatusPill(
                            isEarned: isEarned,
                            earnedText: isEarned ? earnedText : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              badge.badge.description,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.3),
            ),

            const SizedBox(height: 14),

            if (!isEarned && progress != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cosmeticAccent.withValues(alpha: 0.42),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Progress",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress!.pct,
                        minHeight: 10,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          cosmeticAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      progress!.label,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: scheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        progress!.hint,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.onClear,
  });

  final String title;
  final String subtitle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 56),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onClear,
              child: const Text("Clear filters"),
            ),
          ],
        ),
      ),
    );
  }
}

class _JustEarnedToast extends StatelessWidget {
  const _JustEarnedToast({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.emoji_events, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Just earned!",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(BuildContext context, DateTime dt) {
  final local = dt.toLocal();
  final date = MaterialLocalizations.of(context).formatShortDate(local);
  final time = MaterialLocalizations.of(
    context,
  ).formatTimeOfDay(TimeOfDay.fromDateTime(local), alwaysUse24HourFormat: true);
  return "$date • $time";
}

String _fmtInt(int n) {
  final s = n.toString();
  return s.replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+$)"), (m) => "${m[1]},");
}

String _fmtSeconds(int sec) {
  if (sec < 60) return "${sec}s";
  final m = sec ~/ 60;
  final s = sec % 60;
  if (m < 60) return "${m}m ${s}s";
  final h = m ~/ 60;
  final mm = m % 60;
  return "${h}h ${mm}m";
}

_BadgeCategory _categoryForId(String id) {
  if (id == "first_session" || id == "first_unlocked" || id == "first_mastery")
    return _BadgeCategory.onboarding;

  if (id.startsWith("sessions_") || id == "ten_sessions")
    return _BadgeCategory.sessions;
  if (id.startsWith("streak_")) return _BadgeCategory.streaks;

  if (id.startsWith("xp_")) return _BadgeCategory.xp;
  if (id.startsWith("level_")) return _BadgeCategory.level;

  if (id.startsWith("unlocked_")) return _BadgeCategory.unlocks;
  if (id.startsWith("mastered_")) return _BadgeCategory.mastery;

  if (id.startsWith("time_")) return _BadgeCategory.time;

  if (id.startsWith("pullup_") || id == "first_pull_up")
    return _BadgeCategory.pullup;
  if (id.startsWith("pushup_")) return _BadgeCategory.pushup;
  if (id.startsWith("squat_")) return _BadgeCategory.squat;

  if (id.startsWith("plank_")) return _BadgeCategory.plank;
  if (id.startsWith("wall_handstand_")) return _BadgeCategory.handstand;

  if (id.startsWith("movement_") &&
      (id.endsWith("_logged") ||
          id.endsWith("_bronze") ||
          id.endsWith("_silver") ||
          id.endsWith("_gold") ||
          id.endsWith("_mastered"))) {
    return _BadgeCategory.skills;
  }

  if (id.startsWith("challenge_")) return _BadgeCategory.skills;

  if (id.endsWith("_mastered") || id.startsWith("first_"))
    return _BadgeCategory.skills;

  return _BadgeCategory.misc;
}

String _categoryLabel(_BadgeCategory c) {
  return switch (c) {
    _BadgeCategory.all => "All",
    _BadgeCategory.onboarding => "Onboarding",
    _BadgeCategory.sessions => "Sessions",
    _BadgeCategory.streaks => "Streaks",
    _BadgeCategory.xp => "XP",
    _BadgeCategory.level => "Level",
    _BadgeCategory.unlocks => "Unlocks",
    _BadgeCategory.mastery => "Mastery",
    _BadgeCategory.time => "Time",
    _BadgeCategory.pullup => "Pull-ups",
    _BadgeCategory.pushup => "Push-ups",
    _BadgeCategory.squat => "Squats",
    _BadgeCategory.plank => "Plank",
    _BadgeCategory.handstand => "Handstand",
    _BadgeCategory.skills => "Skills",
    _BadgeCategory.misc => "Misc",
  };
}

int? _parseIntSuffix(String id, String prefix) {
  if (!id.startsWith(prefix)) return null;
  final s = id.substring(prefix.length);
  return int.tryParse(s);
}

int? _parseHours(String id) {
  if (!id.startsWith("time_") || !id.endsWith("h")) return null;
  final s = id.substring(5, id.length - 1);
  return int.tryParse(s);
}

String? _parseMovementBadgeId(String id, String suffix) {
  const prefix = "movement_";
  if (!id.startsWith(prefix) || !id.endsWith(suffix)) return null;

  final core = id.substring(prefix.length, id.length - suffix.length);
  if (core.isEmpty) return null;
  return core;
}

_BadgeProgress? _progressForBadge(BadgeWithEarned b, BadgeMetrics? m) {
  if (m == null) return null;

  final id = b.badge.id;
  final earned = b.isEarned;

  // sessions
  if (id == "ten_sessions") {
    final cur = m.sessionsCount;
    const target = 10;
    return _BadgeProgress(
      current: earned ? target : cur,
      target: target,
      label: "${_fmtInt(math.min(cur, target))} / ${_fmtInt(target)} sessions",
      hint: "Log sessions from Movements or the Tree. Any movement counts.",
    );
  }

  final sessTarget = _parseIntSuffix(id, "sessions_");
  if (sessTarget != null) {
    final cur = m.sessionsCount;
    return _BadgeProgress(
      current: earned ? sessTarget : cur,
      target: sessTarget,
      label:
          "${_fmtInt(math.min(cur, sessTarget))} / ${_fmtInt(sessTarget)} sessions",
      hint: "Aim for small daily logs. Consistency beats intensity.",
    );
  }

  // streak
  final streakTarget = _parseIntSuffix(id, "streak_");
  if (streakTarget != null) {
    final cur = m.stats.currentStreak;
    return _BadgeProgress(
      current: earned ? streakTarget : cur,
      target: streakTarget,
      label: "${math.min(cur, streakTarget)} / $streakTarget days",
      hint: "Log at least one session per day to keep the streak alive.",
    );
  }

  // xp
  final xpTarget = _parseIntSuffix(id, "xp_");
  if (xpTarget != null) {
    final cur = m.stats.totalXp;
    return _BadgeProgress(
      current: earned ? xpTarget : cur,
      target: xpTarget,
      label: "${_fmtInt(math.min(cur, xpTarget))} / ${_fmtInt(xpTarget)} XP",
      hint: "More sessions + higher form score = faster XP.",
    );
  }

  // level
  final levelTarget = _parseIntSuffix(id, "level_");
  if (levelTarget != null) {
    final cur = m.stats.level;
    return _BadgeProgress(
      current: earned ? levelTarget : cur,
      target: levelTarget,
      label: "${math.min(cur, levelTarget)} / $levelTarget level",
      hint: "Levels follow total XP. Keep logging quality sessions.",
    );
  }

  // unlock/mastery counts
  if (id == "first_unlocked") {
    final cur = m.unlockedCount;
    return _BadgeProgress(
      current: earned ? 1 : math.min(1, cur),
      target: 1,
      label: cur > 0 ? "Unlocked" : "Not yet unlocked",
      hint: "Reach XP requirements + prerequisites to unlock a movement.",
    );
  }

  if (id == "first_mastery") {
    final cur = m.masteredCount;
    return _BadgeProgress(
      current: earned ? 1 : math.min(1, cur),
      target: 1,
      label: cur > 0 ? "Mastered" : "Not yet mastered",
      hint: "Mastery comes from best reps/holds and total XP in that movement.",
    );
  }

  final unlockedTarget = _parseIntSuffix(id, "unlocked_");
  if (unlockedTarget != null) {
    final cur = m.unlockedCount;
    return _BadgeProgress(
      current: earned ? unlockedTarget : cur,
      target: unlockedTarget,
      label: "${math.min(cur, unlockedTarget)} / $unlockedTarget unlocked",
      hint: "Unlock more by progressing XP and mastering prerequisites.",
    );
  }

  final masteredTarget = _parseIntSuffix(id, "mastered_");
  if (masteredTarget != null) {
    final cur = m.masteredCount;
    return _BadgeProgress(
      current: earned ? masteredTarget : cur,
      target: masteredTarget,
      label: "${math.min(cur, masteredTarget)} / $masteredTarget mastered",
      hint: "Pick a few movements and push them to mastery.",
    );
  }

  // time
  final hours = _parseHours(id);
  if (hours != null) {
    final targetSec = hours * 3600;
    final cur = m.totalDurationSeconds;
    return _BadgeProgress(
      current: earned ? targetSec : cur,
      target: targetSec,
      label:
          "${_fmtSeconds(math.min(cur, targetSec))} / ${_fmtSeconds(targetSec)}",
      hint: "Fill in Duration in Quick Log to track time-based badges.",
    );
  }

  // pull-ups
  if (id == "first_pull_up") {
    final best = m.progressById["pull_up"]?.bestReps ?? 0;
    return _BadgeProgress(
      current: earned ? 1 : math.min(1, best),
      target: 1,
      label: best >= 1 ? "Done" : "0 / 1 rep",
      hint: "Log a Pull-up session with at least 1 rep.",
    );
  }

  final pullupTotalTarget = _parseIntSuffix(id, "pullup_total_");
  if (pullupTotalTarget != null) {
    final cur = m.pullUpTotalReps;
    return _BadgeProgress(
      current: earned ? pullupTotalTarget : cur,
      target: pullupTotalTarget,
      label:
          "${_fmtInt(math.min(cur, pullupTotalTarget))} / ${_fmtInt(pullupTotalTarget)} reps",
      hint: "Accumulates from Pull-up sessions (movementId: pull_up).",
    );
  }

  final pullupBestTarget = _parseIntSuffix(id, "pullup_best_");
  if (pullupBestTarget != null) {
    final best = m.progressById["pull_up"]?.bestReps ?? 0;
    return _BadgeProgress(
      current: earned ? pullupBestTarget : best,
      target: pullupBestTarget,
      label:
          "${math.min(best, pullupBestTarget)} / $pullupBestTarget best reps",
      hint: "Push your best reps in a single Pull-up session.",
    );
  }

  // push-ups
  final pushupTotalTarget = _parseIntSuffix(id, "pushup_total_");
  if (pushupTotalTarget != null) {
    final cur = m.pushUpTotalReps;
    return _BadgeProgress(
      current: earned ? pushupTotalTarget : cur,
      target: pushupTotalTarget,
      label:
          "${_fmtInt(math.min(cur, pushupTotalTarget))} / ${_fmtInt(pushupTotalTarget)} reps",
      hint: "Accumulates from Push-up sessions (movementId: push_up).",
    );
  }

  final pushupBestTarget = _parseIntSuffix(id, "pushup_best_");
  if (pushupBestTarget != null) {
    final best = m.progressById["push_up"]?.bestReps ?? 0;
    return _BadgeProgress(
      current: earned ? pushupBestTarget : best,
      target: pushupBestTarget,
      label:
          "${math.min(best, pushupBestTarget)} / $pushupBestTarget best reps",
      hint: "Hit it in a single Push-up session (best reps).",
    );
  }

  // squats
  final squatTotalTarget = _parseIntSuffix(id, "squat_total_");
  if (squatTotalTarget != null) {
    final cur = m.squatTotalReps;
    return _BadgeProgress(
      current: earned ? squatTotalTarget : cur,
      target: squatTotalTarget,
      label:
          "${_fmtInt(math.min(cur, squatTotalTarget))} / ${_fmtInt(squatTotalTarget)} reps",
      hint:
          "Accumulates from Bodyweight Squat sessions (movementId: bodyweight_squat).",
    );
  }

  // plank
  final plankBestTarget = _parseIntSuffix(id, "plank_best_");
  if (plankBestTarget != null) {
    final best = m.progressById["plank"]?.bestHoldSeconds ?? 0;
    return _BadgeProgress(
      current: earned ? plankBestTarget : best,
      target: plankBestTarget,
      label:
          "${_fmtSeconds(math.min(best, plankBestTarget))} / ${_fmtSeconds(plankBestTarget)} best hold",
      hint: "Log a plank hold with Hold(sec) at or above the target.",
    );
  }

  final plankTotalTarget = _parseIntSuffix(id, "plank_total_");
  if (plankTotalTarget != null) {
    final cur = m.plankTotalHoldSeconds;
    return _BadgeProgress(
      current: earned ? plankTotalTarget : cur,
      target: plankTotalTarget,
      label:
          "${_fmtSeconds(math.min(cur, plankTotalTarget))} / ${_fmtSeconds(plankTotalTarget)} total",
      hint: "Accumulates from Plank holdSeconds across all sessions.",
    );
  }

  // wall handstand best
  final whBestTarget = _parseIntSuffix(id, "wall_handstand_best_");
  if (whBestTarget != null) {
    final best = m.progressById["wall_handstand"]?.bestHoldSeconds ?? 0;
    return _BadgeProgress(
      current: earned ? whBestTarget : best,
      target: whBestTarget,
      label:
          "${_fmtSeconds(math.min(best, whBestTarget))} / ${_fmtSeconds(whBestTarget)} best hold",
      hint: "Log a Wall Handstand with Hold(sec) at or above the target.",
    );
  }

  // mastered skill badges
  if (id == "front_lever_mastered") {
    final done =
        (m.progressById["front_lever"]?.state ?? "locked") == "mastered";
    return _BadgeProgress(
      current: done ? 1 : 0,
      target: 1,
      label: done ? "Mastered" : "Not mastered",
      hint: "Work through tuck → advanced tuck → straddle → front lever.",
    );
  }

  if (id == "planche_mastered") {
    final done = (m.progressById["planche"]?.state ?? "locked") == "mastered";
    return _BadgeProgress(
      current: done ? 1 : 0,
      target: 1,
      label: done ? "Mastered" : "Not mastered",
      hint:
          "Build straight-arm strength: planche lean → tuck → advanced tuck → straddle → planche.",
    );
  }

  // first_ skill logs
  if (id == "first_free_handstand") {
    final xp = m.progressById["freestanding_handstand"]?.totalXp ?? 0;
    final done = xp > 0;
    return _BadgeProgress(
      current: done ? 1 : 0,
      target: 1,
      label: done ? "Logged" : "Not yet",
      hint: "Log any session for Freestanding Handstand.",
    );
  }

  if (id == "first_bar_muscle_up") {
    final best = m.progressById["bar_muscle_up"]?.bestReps ?? 0;
    final done = best >= 1;
    return _BadgeProgress(
      current: done ? 1 : 0,
      target: 1,
      label: done ? "Logged" : "0 / 1 rep",
      hint: "Log a Bar Muscle-up with at least 1 rep.",
    );
  }

  if (id == "first_ring_muscle_up") {
    final best = m.progressById["ring_muscle_up"]?.bestReps ?? 0;
    final done = best >= 1;
    return _BadgeProgress(
      current: done ? 1 : 0,
      target: 1,
      label: done ? "Logged" : "0 / 1 rep",
      hint: "Log a Ring Muscle-up with at least 1 rep.",
    );
  }

  // unique challenge badges
  if (id == "challenge_upper_balance") {
    const pullTarget = 100;
    const pushTarget = 1000;
    final pull = m.pullUpTotalReps;
    final push = m.pushUpTotalReps;
    final cur =
        math.min<int>(pull, pullTarget) + math.min<int>(push, pushTarget);
    final target = pullTarget + pushTarget;
    return _BadgeProgress(
      current: earned ? target : cur,
      target: target,
      label:
          "Pull-ups ${_fmtInt(math.min(pull, pullTarget))}/100 • Push-ups ${_fmtInt(math.min(push, pushTarget))}/1,000",
      hint:
          "Build pull and push volume together instead of specializing early.",
    );
  }

  if (id == "challenge_core_legs") {
    const squatTarget = 2000;
    const plankTotalTarget = 3600;
    final squat = m.squatTotalReps;
    final plankTotal = m.plankTotalHoldSeconds;
    final cur =
        math.min<int>(squat, squatTarget) +
        math.min<int>(plankTotal, plankTotalTarget);
    final target = squatTarget + plankTotalTarget;
    return _BadgeProgress(
      current: earned ? target : cur,
      target: target,
      label:
          "Squats ${_fmtInt(math.min(squat, squatTarget))}/2,000 • Plank ${_fmtSeconds(math.min(plankTotal, plankTotalTarget))}/${_fmtSeconds(plankTotalTarget)}",
      hint:
          "Alternate leg endurance days and core hold days for steady progress.",
    );
  }

  if (id == "challenge_static_control") {
    const plankBestTarget = 240;
    const wallHsBestTarget = 90;
    final plankBest = m.progressById["plank"]?.bestHoldSeconds ?? 0;
    final wallHsBest = m.progressById["wall_handstand"]?.bestHoldSeconds ?? 0;
    final cur =
        math.min<int>(plankBest, plankBestTarget) +
        math.min<int>(wallHsBest, wallHsBestTarget);
    final target = plankBestTarget + wallHsBestTarget;
    return _BadgeProgress(
      current: earned ? target : cur,
      target: target,
      label:
          "Plank ${_fmtSeconds(math.min(plankBest, plankBestTarget))}/${_fmtSeconds(plankBestTarget)} • Wall HS ${_fmtSeconds(math.min(wallHsBest, wallHsBestTarget))}/${_fmtSeconds(wallHsBestTarget)}",
      hint: "Own static positions with clean breathing and full-body tension.",
    );
  }

  if (id == "challenge_skill_trio") {
    final hsDone = (m.progressById["freestanding_handstand"]?.totalXp ?? 0) > 0;
    final barDone = (m.progressById["bar_muscle_up"]?.bestReps ?? 0) >= 1;
    final ringDone = (m.progressById["ring_muscle_up"]?.bestReps ?? 0) >= 1;
    final cur = (hsDone ? 1 : 0) + (barDone ? 1 : 0) + (ringDone ? 1 : 0);
    return _BadgeProgress(
      current: earned ? 3 : cur,
      target: 3,
      label:
          "HS: ${hsDone ? "Done" : "Pending"} • Bar MU: ${barDone ? "Done" : "Pending"} • Ring MU: ${ringDone ? "Done" : "Pending"}",
      hint: "Sample all three high-skill patterns to round out your practice.",
    );
  }

  if (id == "challenge_all_rounder") {
    final pullBest = m.progressById["pull_up"]?.bestReps ?? 0;
    final pushBest = m.progressById["push_up"]?.bestReps ?? 0;
    final squatTotal = m.squatTotalReps;
    final plankBest = m.progressById["plank"]?.bestHoldSeconds ?? 0;
    final cur =
        (pullBest >= 10 ? 1 : 0) +
        (pushBest >= 50 ? 1 : 0) +
        (squatTotal >= 1000 ? 1 : 0) +
        (plankBest >= 120 ? 1 : 0);
    return _BadgeProgress(
      current: earned ? 4 : cur,
      target: 4,
      label:
          "Pull ${math.min(pullBest, 10)}/10 • Push ${math.min(pushBest, 50)}/50 • Squat ${_fmtInt(math.min(squatTotal, 1000))}/1,000 • Plank ${_fmtSeconds(math.min(plankBest, 120))}/${_fmtSeconds(120)}",
      hint: "This is a balanced standard across pull, push, legs, and core.",
    );
  }

  if (id == "challenge_engine_room") {
    const sessionsTarget = 200;
    const secondsTarget = 100 * 3600;
    final sessions = m.sessionsCount;
    final sec = m.totalDurationSeconds;
    final cur =
        math.min<int>(sessions, sessionsTarget) +
        math.min<int>(sec, secondsTarget);
    final target = sessionsTarget + secondsTarget;
    return _BadgeProgress(
      current: earned ? target : cur,
      target: target,
      label:
          "Sessions ${math.min(sessions, sessionsTarget)}/200 • Time ${_fmtSeconds(math.min(sec, secondsTarget))}/${_fmtSeconds(secondsTarget)}",
      hint: "Long-term output: frequency plus hours, not one or the other.",
    );
  }

  if (id == "challenge_gold_collector_20") {
    int goldCount = 0;
    for (final p in m.progressById.values) {
      if (tierRankFromState(p.state) >= tierRankFromState("gold"))
        goldCount += 1;
    }
    const target = 20;
    return _BadgeProgress(
      current: earned ? target : goldCount,
      target: target,
      label: "${math.min(goldCount, target)} / $target gold-tier movements",
      hint: "Spread your progress across the tree, not just one lane.",
    );
  }

  if (id == "challenge_elite_duo") {
    final frontLever =
        (m.progressById["front_lever"]?.state ?? "locked") == "mastered";
    final planche =
        (m.progressById["planche"]?.state ?? "locked") == "mastered";
    final cur = (frontLever ? 1 : 0) + (planche ? 1 : 0);
    return _BadgeProgress(
      current: earned ? 2 : cur,
      target: 2,
      label:
          "Front Lever: ${frontLever ? "Mastered" : "Pending"} • Planche: ${planche ? "Mastered" : "Pending"}",
      hint: "Two elite static skills. Chip away at both over time.",
    );
  }

  // generic per-movement badges
  final loggedMovementId = _parseMovementBadgeId(id, "_logged");
  if (loggedMovementId != null) {
    final xp = m.progressById[loggedMovementId]?.totalXp ?? 0;
    final done = xp > 0;
    return _BadgeProgress(
      current: done ? 1 : 0,
      target: 1,
      label: done ? "Logged" : "Not yet",
      hint: "Log at least one session for this movement.",
    );
  }

  final bronzeMovementId = _parseMovementBadgeId(id, "_bronze");
  if (bronzeMovementId != null) {
    final state = m.progressById[bronzeMovementId]?.state ?? "locked";
    final done = tierRankFromState(state) >= tierRankFromState("bronze");
    return _BadgeProgress(
      current: done ? 1 : 0,
      target: 1,
      label: done ? "Bronze reached" : "Not yet Bronze",
      hint: "Push this movement to Bronze tier with stronger best sets and XP.",
    );
  }

  final silverMovementId = _parseMovementBadgeId(id, "_silver");
  if (silverMovementId != null) {
    final state = m.progressById[silverMovementId]?.state ?? "locked";
    final done = tierRankFromState(state) >= tierRankFromState("silver");
    return _BadgeProgress(
      current: done ? 1 : 0,
      target: 1,
      label: done ? "Silver reached" : "Not yet Silver",
      hint: "Bronze consistency first, then push to Silver thresholds.",
    );
  }

  final goldMovementId = _parseMovementBadgeId(id, "_gold");
  if (goldMovementId != null) {
    final state = m.progressById[goldMovementId]?.state ?? "locked";
    final done = tierRankFromState(state) >= tierRankFromState("gold");
    return _BadgeProgress(
      current: done ? 1 : 0,
      target: 1,
      label: done ? "Gold reached" : "Not yet Gold",
      hint: "Gold takes elite numbers. Keep building volume and quality.",
    );
  }

  final masteredMovementId = _parseMovementBadgeId(id, "_mastered");
  if (masteredMovementId != null) {
    final done =
        (m.progressById[masteredMovementId]?.state ?? "locked") == "mastered";
    return _BadgeProgress(
      current: done ? 1 : 0,
      target: 1,
      label: done ? "Mastered" : "Not mastered",
      hint: "Push this movement through all tiers to Master.",
    );
  }

  return _BadgeProgress(
    current: earned ? 1 : 0,
    target: 1,
    label: earned ? "Earned" : "Locked",
    hint: "Keep logging sessions and progressing through the tree.",
  );
}

_BadgeTier _tierForBadge(BadgeWithEarned b, _BadgeProgress? progress) {
  final id = b.badge.id;

  if (id == "challenge_elite_duo" ||
      id == "challenge_gold_collector_20" ||
      id == "challenge_engine_room") {
    return _BadgeTier.gold;
  }
  if (id.startsWith("challenge_")) return _BadgeTier.silver;

  if (id.endsWith("_bronze")) return _BadgeTier.bronze;
  if (id.endsWith("_silver")) return _BadgeTier.silver;
  if (id.endsWith("_gold") || id.endsWith("_mastered")) return _BadgeTier.gold;

  if (id.startsWith("first_")) return _BadgeTier.bronze;

  if (progress != null) {
    final target = progress.target;

    if (id.startsWith("time_")) {
      if (target <= 10 * 3600) return _BadgeTier.bronze;
      if (target <= 50 * 3600) return _BadgeTier.silver;
      return _BadgeTier.gold;
    }

    if (id.contains("_best_") &&
        (id.contains("plank") || id.contains("handstand"))) {
      if (target <= 60) return _BadgeTier.bronze;
      if (target <= 180) return _BadgeTier.silver;
      return _BadgeTier.gold;
    }

    if (id.contains("_best_")) {
      if (target <= 10) return _BadgeTier.bronze;
      if (target <= 30) return _BadgeTier.silver;
      return _BadgeTier.gold;
    }

    if (target <= 25) return _BadgeTier.bronze;
    if (target <= 200) return _BadgeTier.silver;
    return _BadgeTier.gold;
  }

  return _BadgeTier.bronze;
}

class _TierPalette {
  const _TierPalette({
    required this.bg,
    required this.fg,
    required this.border,
  });

  final Color bg;
  final Color fg;
  final Color border;
}

_TierPalette _tierColors(ColorScheme scheme, _BadgeTier tier) {
  return switch (tier) {
    _BadgeTier.bronze => _TierPalette(
      bg: Color.alphaBlend(
        scheme.surface.withValues(alpha: 0.06),
        const Color(0xFFFFCF9A),
      ),
      fg: const Color(0xFF754000),
      border: const Color(0xFFB36526),
    ),
    _BadgeTier.silver => _TierPalette(
      bg: Color.alphaBlend(
        scheme.surface.withValues(alpha: 0.06),
        const Color(0xFFE7EEF7),
      ),
      fg: const Color(0xFF3B4E62),
      border: const Color(0xFF93A6BB),
    ),
    _BadgeTier.gold => _TierPalette(
      bg: Color.alphaBlend(
        scheme.surface.withValues(alpha: 0.06),
        const Color(0xFFFFF0B2),
      ),
      fg: const Color(0xFF735400),
      border: const Color(0xFFD39B00),
    ),
  };
}

String _tierLabel(_BadgeTier tier) {
  return switch (tier) {
    _BadgeTier.bronze => "Bronze tier",
    _BadgeTier.silver => "Silver tier",
    _BadgeTier.gold => "Gold tier",
  };
}
