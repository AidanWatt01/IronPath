import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../domain/daily_quest_catalog.dart";
import "../../domain/daily_quest_service.dart";
import "../../domain/perk_catalog.dart";
import "../../domain/weekly_quest_service.dart";
import "../../state/providers.dart";

class PerksScreen extends ConsumerStatefulWidget {
  const PerksScreen({super.key});

  @override
  ConsumerState<PerksScreen> createState() => _PerksScreenState();
}

class _PerksScreenState extends ConsumerState<PerksScreen> {
  final Set<String> _busyPerkIds = <String>{};
  final Set<String> _busyQuestIds = <String>{};
  bool _respecBusy = false;
  bool _weeklyRerollBusy = false;

  String _timeUntilResetText() {
    final now = DateTime.now();
    final reset = DateTime(now.year, now.month, now.day + 1);
    final d = reset.difference(now);

    final hh = d.inHours.toString().padLeft(2, "0");
    final mm = (d.inMinutes % 60).toString().padLeft(2, "0");

    return "Resets in $hh:$mm";
  }

  String _timeUntilWeeklyResetText() {
    final now = DateTime.now();
    int daysToAdd = (DateTime.monday - now.weekday + 7) % 7;
    if (daysToAdd == 0) {
      daysToAdd = 7;
    }

    final reset = DateTime(now.year, now.month, now.day + daysToAdd);
    final d = reset.difference(now);

    final dd = d.inDays;
    final hh = (d.inHours % 24).toString().padLeft(2, "0");
    final mm = (d.inMinutes % 60).toString().padLeft(2, "0");

    return "Weekly reset in ${dd}d $hh:$mm";
  }

  String _rarityLabel(DailyQuestRarity rarity) {
    switch (rarity) {
      case DailyQuestRarity.common:
        return "Common";
      case DailyQuestRarity.rare:
        return "Rare";
      case DailyQuestRarity.epic:
        return "Epic";
    }
  }

  Color _rarityColor(DailyQuestRarity rarity, ColorScheme scheme) {
    switch (rarity) {
      case DailyQuestRarity.common:
        return scheme.tertiary;
      case DailyQuestRarity.rare:
        return scheme.primary;
      case DailyQuestRarity.epic:
        return const Color(0xFF7C3AED);
    }
  }

  String _bonusText(PerkDefinition perk, int level) {
    if (perk.id == PerkCatalog.momentum.id) {
      return "+${(level * 10)}% first-workout XP";
    }
    if (perk.id == PerkCatalog.specialist.id) {
      return "+${(level * 5)}% goal-movement XP";
    }
    if (perk.id == PerkCatalog.collector.id) {
      return "+${(level * 10)}% coins earned";
    }
    if (perk.id == PerkCatalog.technician.id) {
      return "+${(level * 5)}% XP on high-form logs";
    }
    if (perk.id == PerkCatalog.volumeEngine.id) {
      return "+${(level * 4)}% XP on 3+ set logs";
    }
    if (perk.id == PerkCatalog.finisher.id) {
      return "+${(level * 5)}% coins on 80+ XP logs";
    }
    if (perk.id == PerkCatalog.streakSurge.id) {
      return "+${(level * 3)}% XP at 3+ day streak";
    }
    if (perk.id == PerkCatalog.holdSpecialist.id) {
      return "+${(level * 6)}% XP on hold movements";
    }
    if (perk.id == PerkCatalog.masteryHunter.id) {
      return "+${(level * 4)}% XP on non-mastered movements";
    }
    if (perk.id == PerkCatalog.timekeeper.id) {
      return "+${(level * 5)}% coins on 90s+ sessions";
    }
    return "Level $level";
  }

  String _nextBonusText(PerkDefinition perk, int level) {
    if (level >= perk.maxLevel) return "Max level reached";

    final next = level + 1;
    if (perk.id == PerkCatalog.momentum.id) {
      return "Next: +${(next * 10)}% first-workout XP";
    }
    if (perk.id == PerkCatalog.specialist.id) {
      return "Next: +${(next * 5)}% goal-movement XP";
    }
    if (perk.id == PerkCatalog.collector.id) {
      return "Next: +${(next * 10)}% coins earned";
    }
    if (perk.id == PerkCatalog.technician.id) {
      return "Next: +${(next * 5)}% XP on high-form logs";
    }
    if (perk.id == PerkCatalog.volumeEngine.id) {
      return "Next: +${(next * 4)}% XP on 3+ set logs";
    }
    if (perk.id == PerkCatalog.finisher.id) {
      return "Next: +${(next * 5)}% coins on 80+ XP logs";
    }
    if (perk.id == PerkCatalog.streakSurge.id) {
      return "Next: +${(next * 3)}% XP at 3+ day streak";
    }
    if (perk.id == PerkCatalog.holdSpecialist.id) {
      return "Next: +${(next * 6)}% XP on hold movements";
    }
    if (perk.id == PerkCatalog.masteryHunter.id) {
      return "Next: +${(next * 4)}% XP on non-mastered movements";
    }
    if (perk.id == PerkCatalog.timekeeper.id) {
      return "Next: +${(next * 5)}% coins on 90s+ sessions";
    }
    return "Next level: $next";
  }

  Future<void> _upgradePerk(PerkDefinition perk) async {
    if (_busyPerkIds.contains(perk.id)) return;
    setState(() => _busyPerkIds.add(perk.id));

    try {
      final db = ref.read(appDbProvider);
      final ok = await db.tryUpgradePerk(
        perkId: perk.id,
        maxLevel: perk.maxLevel,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            ok
                ? "${perk.name} upgraded!"
                : "Cannot upgrade ${perk.name} right now.",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _busyPerkIds.remove(perk.id));
      }
    }
  }

  Future<void> _claimQuest(DailyQuestProgress quest) async {
    if (_busyQuestIds.contains(quest.quest.id)) return;

    setState(() => _busyQuestIds.add(quest.quest.id));

    try {
      final goalMovementId = ref
          .read(skillGoalProvider)
          .maybeWhen(data: (id) => id, orElse: () => null);
      final service = ref.read(dailyQuestServiceProvider);
      final result = await service.claimTodayQuest(
        questId: quest.quest.id,
        goalMovementId: goalMovementId,
      );

      if (!mounted) return;

      if (result.claimed) {
        final bonus = result.levelsGained > 0
            ? " - +${result.levelsGained} lvl, +${result.perkPointsEarned} perk pt"
            : "";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Claimed ${quest.quest.title}: +${result.xpEarned} XP, +${result.coinsEarned} coins$bonus",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              result.failureReason ?? "Cannot claim this quest yet.",
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busyQuestIds.remove(quest.quest.id));
      }
    }
  }

  Future<void> _claimWeeklyQuest(WeeklyQuestProgress quest) async {
    if (_busyQuestIds.contains(quest.quest.id)) return;

    setState(() => _busyQuestIds.add(quest.quest.id));

    try {
      final goalMovementId = ref
          .read(skillGoalProvider)
          .maybeWhen(data: (id) => id, orElse: () => null);
      final service = ref.read(weeklyQuestServiceProvider);
      final result = await service.claimThisWeekQuest(
        questId: quest.quest.id,
        goalMovementId: goalMovementId,
      );

      if (!mounted) return;

      if (result.claimed) {
        final bonus = result.levelsGained > 0
            ? " - +${result.levelsGained} lvl, +${result.perkPointsEarned} perk pt"
            : "";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Claimed ${quest.quest.title}: +${result.xpEarned} XP, +${result.coinsEarned} coins$bonus",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              result.failureReason ?? "Cannot claim this quest yet.",
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busyQuestIds.remove(quest.quest.id));
      }
    }
  }

  Future<void> _rerollWeeklyQuests() async {
    if (_weeklyRerollBusy) return;

    setState(() => _weeklyRerollBusy = true);
    try {
      final service = ref.read(weeklyQuestServiceProvider);
      final result = await service.rerollThisWeek();
      ref.read(weeklyQuestRefreshProvider.notifier).bump();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(result.message),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _weeklyRerollBusy = false);
      }
    }
  }

  Future<void> _respecPerks() async {
    if (_respecBusy) return;

    final shouldRespec = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Respec Perks"),
          content: Text(
            "Reset all perk levels and refund spent points for ${PerkCatalog.respecCoinCost} coins?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text("Respec"),
            ),
          ],
        );
      },
    );

    if (shouldRespec != true) return;

    setState(() => _respecBusy = true);
    try {
      final result = await ref
          .read(appDbProvider)
          .tryRespecPerks(coinCost: PerkCatalog.respecCoinCost);

      if (!mounted) return;

      final message = result.success
          ? "Respec complete: refunded ${result.refundedPoints} points for ${result.coinsSpent} coins."
          : (result.message ?? "Respec failed.");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _respecBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(userStatProvider);
    final perks = ref.watch(userPerksProvider);
    final quests = ref.watch(dailyQuestsProvider);
    final weeklyQuests = ref.watch(weeklyQuestsProvider);
    final weeklyRerollInfo = ref.watch(weeklyQuestRerollInfoProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Perks")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 430;
          final horizontalPadding = compact ? 12.0 : 16.0;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  16,
                ),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: stats.when(
                        data: (s) => Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _StatChip(
                              icon: Icons.star,
                              label: "Level",
                              value: "${s.level}",
                            ),
                            _StatChip(
                              icon: Icons.bolt,
                              label: "XP",
                              value: "${s.totalXp}",
                            ),
                            _StatChip(
                              icon: Icons.auto_awesome,
                              label: "Perk Pts",
                              value: "${s.perkPoints}",
                            ),
                            _StatChip(
                              icon: Icons.monetization_on,
                              label: "Coins",
                              value: "${s.coins}",
                            ),
                          ],
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => Text("Stats error: $e"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Daily Quests",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Claim rewards once per day after completing each quest.",
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Text(
                          _timeUntilResetText(),
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  quests.when(
                    data: (items) {
                      return Column(
                        children: items.map((q) {
                          final busy = _busyQuestIds.contains(q.quest.id);
                          final progress = (q.progress / q.target).clamp(
                            0.0,
                            1.0,
                          );
                          final rarityColor = _rarityColor(
                            q.quest.rarity,
                            scheme,
                          );

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          q.quest.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: rarityColor.withValues(
                                            alpha: 0.14,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: rarityColor.withValues(
                                              alpha: 0.36,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          _rarityLabel(q.quest.rarity),
                                          style: TextStyle(
                                            color: rarityColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (q.claimed)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: scheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            "Claimed",
                                            style: TextStyle(
                                              color: scheme.onPrimaryContainer,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    q.statusText,
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(value: progress),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${q.progress}/${q.target}",
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _StatChip(
                                          icon: Icons.bolt,
                                          label: "Reward",
                                          value: "+${q.rewardXp} XP",
                                          expand: true,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _StatChip(
                                          icon: Icons.monetization_on,
                                          label: "Reward",
                                          value: "+${q.rewardCoins} coins",
                                          expand: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.tonal(
                                      onPressed: (q.canClaim && !busy)
                                          ? () => _claimQuest(q)
                                          : null,
                                      child: busy
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              q.claimed ? "Claimed" : "Claim",
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: LinearProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text("Daily quests error: $e"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Weekly Quests",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Bigger rewards for steady training all week.",
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Text(
                          _timeUntilWeeklyResetText(),
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  weeklyRerollInfo.when(
                    data: (info) {
                      final costLabel = info.freeRerollAvailable
                          ? "Free"
                          : "${info.nextCoinCost} coins";
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Reroll Weekly Quests",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Next reroll: $costLabel",
                                      style: TextStyle(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: _weeklyRerollBusy
                                    ? null
                                    : _rerollWeeklyQuests,
                                icon: _weeklyRerollBusy
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.casino_outlined),
                                label: const Text("Reroll"),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: LinearProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text("Reroll info error: $e"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  weeklyQuests.when(
                    data: (items) {
                      return Column(
                        children: items.map((q) {
                          final busy = _busyQuestIds.contains(q.quest.id);
                          final progress = (q.progress / q.target).clamp(
                            0.0,
                            1.0,
                          );
                          final rarityColor = _rarityColor(
                            q.quest.rarity,
                            scheme,
                          );

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          q.quest.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: rarityColor.withValues(
                                            alpha: 0.14,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: rarityColor.withValues(
                                              alpha: 0.36,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          _rarityLabel(q.quest.rarity),
                                          style: TextStyle(
                                            color: rarityColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (q.claimed)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: scheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            "Claimed",
                                            style: TextStyle(
                                              color: scheme.onPrimaryContainer,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    q.statusText,
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(value: progress),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${q.progress}/${q.target}",
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _StatChip(
                                          icon: Icons.bolt,
                                          label: "Reward",
                                          value: "+${q.rewardXp} XP",
                                          expand: true,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _StatChip(
                                          icon: Icons.monetization_on,
                                          label: "Reward",
                                          value: "+${q.rewardCoins} coins",
                                          expand: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.tonal(
                                      onPressed: (q.canClaim && !busy)
                                          ? () => _claimWeeklyQuest(q)
                                          : null,
                                      child: busy
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              q.claimed ? "Claimed" : "Claim",
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: LinearProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text("Weekly quests error: $e"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.storefront),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Coin purchases moved to the Shop tab (boost packs + cosmetics).",
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Perk Upgrades",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  stats.when(
                    data: (s) => perks.when(
                      data: (rows) {
                        final levelById = <String, int>{
                          for (final p in rows) p.perkId: p.level,
                        };

                        return Column(
                          children: [
                            ...PerkCatalog.all.map((perk) {
                              final level = levelById[perk.id] ?? 0;
                              final atMax = level >= perk.maxLevel;
                              final canUpgrade =
                                  !atMax &&
                                  s.perkPoints > 0 &&
                                  !_busyPerkIds.contains(perk.id);

                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final isCompact =
                                              constraints.maxWidth < 430;
                                          final upgradeButton = FilledButton.tonal(
                                            onPressed: canUpgrade
                                                ? () => _upgradePerk(perk)
                                                : null,
                                            child:
                                                _busyPerkIds.contains(perk.id)
                                                ? const SizedBox(
                                                    width: 14,
                                                    height: 14,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : Text(
                                                    atMax
                                                        ? "Maxed"
                                                        : "Upgrade (1 pt)",
                                                  ),
                                          );

                                          if (isCompact) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${perk.name} - Lv $level/${perk.maxLevel}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: upgradeButton,
                                                ),
                                              ],
                                            );
                                          }

                                          return Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "${perk.name} - Lv $level/${perk.maxLevel}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                              upgradeButton,
                                            ],
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        perk.description,
                                        style: TextStyle(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Current: ${_bonusText(perk, level)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        _nextBonusText(perk, level),
                                        style: TextStyle(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 10),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Respec",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Reset all perks and refund all spent perk points for ${PerkCatalog.respecCoinCost} coins.",
                                      style: TextStyle(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    FilledButton.tonalIcon(
                                      onPressed: _respecBusy
                                          ? null
                                          : _respecPerks,
                                      icon: _respecBusy
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.restart_alt),
                                      label: const Text("Respec Perks"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Card(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: LinearProgressIndicator(),
                        ),
                      ),
                      error: (e, _) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text("Perks error: $e"),
                        ),
                      ),
                    ),
                    loading: () => const Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: LinearProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text("Stats error: $e"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.expand = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(color: scheme.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
