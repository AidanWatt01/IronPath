import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../data/db/app_db.dart";
import "../../domain/cosmetic_catalog.dart";
import "../../state/providers.dart";
import "../theme/cosmetic_visuals.dart";

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  bool _buyXpBoostBusy = false;
  bool _buyCoinBoostBusy = false;
  final Set<String> _busyCosmeticIds = <String>{};
  String? _previewCosmeticId;

  Future<void> _buyXpBoostPack() async {
    if (_buyXpBoostBusy) return;
    setState(() => _buyXpBoostBusy = true);

    try {
      final db = ref.read(appDbProvider);
      final result = await db.tryBuyBoostPack(
        metaKey: AppDb.xpBoostUsesMetaKey,
        costCoins: 120,
        addUses: 3,
      );

      ref.read(coinBoostRefreshProvider.notifier).bump();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            result.success
                ? "Bought XP Boost Pack: +3 boosted logs (+25% XP each)."
                : result.message,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _buyXpBoostBusy = false);
      }
    }
  }

  Future<void> _buyCoinBoostPack() async {
    if (_buyCoinBoostBusy) return;
    setState(() => _buyCoinBoostBusy = true);

    try {
      final db = ref.read(appDbProvider);
      final result = await db.tryBuyBoostPack(
        metaKey: AppDb.coinBoostUsesMetaKey,
        costCoins: 90,
        addUses: 3,
      );

      ref.read(coinBoostRefreshProvider.notifier).bump();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            result.success
                ? "Bought Coin Boost Pack: +3 boosted logs (+35% coins each)."
                : result.message,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _buyCoinBoostBusy = false);
      }
    }
  }

  Future<void> _buyCosmetic(CosmeticDefinition item) async {
    if (_busyCosmeticIds.contains(item.id)) return;
    setState(() => _busyCosmeticIds.add(item.id));

    try {
      final db = ref.read(appDbProvider);
      final result = await db.tryBuyCosmetic(
        cosmeticId: item.id,
        costCoins: item.costCoins,
      );

      if (result.success) {
        await db.trySetEquippedCosmeticId(item.id);
        if (mounted) {
          setState(() => _previewCosmeticId = item.id);
        }
      }

      ref.read(cosmeticRefreshProvider.notifier).bump();

      if (!mounted) return;
      final message = result.success
          ? "Unlocked ${item.name} and equipped it."
          : result.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _busyCosmeticIds.remove(item.id));
      }
    }
  }

  Future<void> _equipCosmetic(String? cosmeticId) async {
    final busyKey = cosmeticId ?? "none";
    if (_busyCosmeticIds.contains(busyKey)) return;
    setState(() => _busyCosmeticIds.add(busyKey));

    try {
      final ok = await ref
          .read(appDbProvider)
          .trySetEquippedCosmeticId(cosmeticId);
      if (ok && mounted) {
        setState(() => _previewCosmeticId = cosmeticId);
      }
      ref.read(cosmeticRefreshProvider.notifier).bump();

      if (!mounted) return;
      final item = CosmeticCatalog.byId(cosmeticId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            ok
                ? (item == null
                      ? "Cleared equipped cosmetic."
                      : "Equipped ${item.name}.")
                : "You need to buy this cosmetic first.",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _busyCosmeticIds.remove(busyKey));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(userStatProvider);
    final coinBoostStatus = ref.watch(coinBoostStatusProvider);
    final cosmeticStatus = ref.watch(cosmeticStatusProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Shop")),
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
                              icon: Icons.monetization_on,
                              label: "Coins",
                              value: "${s.coins}",
                            ),
                            _StatChip(
                              icon: Icons.bolt,
                              label: "XP",
                              value: "${s.totalXp}",
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
                    "Boost Packs",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Spend coins on temporary boosts that apply to your next logs.",
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  coinBoostStatus.when(
                    data: (shop) {
                      return Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          "XP Boost Pack",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      _StatChip(
                                        icon: Icons.bolt,
                                        label: "Active",
                                        value: "${shop.xpBoostUses}",
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Cost: 120 coins - Grants 3 boosted logs (+25% XP each log).",
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.tonal(
                                      onPressed: _buyXpBoostBusy
                                          ? null
                                          : _buyXpBoostPack,
                                      child: _buyXpBoostBusy
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text("Buy XP Boost Pack"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          "Coin Boost Pack",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      _StatChip(
                                        icon: Icons.monetization_on,
                                        label: "Active",
                                        value: "${shop.coinBoostUses}",
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Cost: 90 coins - Grants 3 boosted logs (+35% coins each log).",
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.tonal(
                                      onPressed: _buyCoinBoostBusy
                                          ? null
                                          : _buyCoinBoostPack,
                                      child: _buyCoinBoostBusy
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text("Buy Coin Boost Pack"),
                                    ),
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
                        child: Text("Coin shop error: $e"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Cosmetics",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Buy and equip visual styles for your progress card.",
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Adding new cosmetic IDs to the catalog works automatically with generated fallback visuals.",
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  cosmeticStatus.when(
                    data: (status) {
                      final previewId =
                          _previewCosmeticId ?? status.equippedCosmeticId;
                      final previewVisual = cosmeticVisualForId(
                        previewId,
                        fallbackColor: scheme.primary,
                      );
                      final previewColor = previewVisual.color;
                      final previewName =
                          CosmeticCatalog.byId(previewId)?.name ??
                          (previewId == null ? "Default" : previewId);
                      final previewOnColor =
                          ThemeData.estimateBrightnessForColor(previewColor) ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black;

                      return Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final isCompact = constraints.maxWidth < 430;
                                  final useDefaultButton = FilledButton.tonal(
                                    onPressed: _busyCosmeticIds.contains("none")
                                        ? null
                                        : () => _equipCosmetic(null),
                                    child: _busyCosmeticIds.contains("none")
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text("Use Default"),
                                  );

                                  final styleText = Text(
                                    status.equippedCosmeticId == null
                                        ? "Current style: Default"
                                        : "Current style: ${CosmeticCatalog.byId(status.equippedCosmeticId)?.name ?? status.equippedCosmeticId}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  );

                                  if (isCompact) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.checkroom),
                                            const SizedBox(width: 10),
                                            Expanded(child: styleText),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          child: useDefaultButton,
                                        ),
                                      ],
                                    );
                                  }

                                  return Row(
                                    children: [
                                      const Icon(Icons.checkroom),
                                      const SizedBox(width: 10),
                                      Expanded(child: styleText),
                                      useDefaultButton,
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        previewVisual.icon,
                                        color: previewColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Live Preview - $previewName",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      if (_previewCosmeticId != null)
                                        TextButton(
                                          onPressed: () => setState(
                                            () => _previewCosmeticId = null,
                                          ),
                                          child: const Text("Use equipped"),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      _PreviewDashboardTile(
                                        accent: previewColor,
                                        icon: previewVisual.icon,
                                        onAccent: previewOnColor,
                                      ),
                                      _PreviewTreeNodeTile(
                                        accent: previewColor,
                                        icon: previewVisual.icon,
                                        onAccent: previewOnColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ...CosmeticCatalog.all.map((item) {
                            final owned = status.ownedCosmeticIds.contains(
                              item.id,
                            );
                            final equipped =
                                status.equippedCosmeticId == item.id;
                            final busy = _busyCosmeticIds.contains(item.id);
                            final visual = cosmeticVisualForId(
                              item.id,
                              fallbackColor: scheme.primary,
                            );
                            final color = visual.color;

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: color.withValues(
                                              alpha: 0.18,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(color: color),
                                          ),
                                          child: Icon(
                                            visual.icon,
                                            color: color,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                item.description,
                                                style: TextStyle(
                                                  color:
                                                      scheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _StatChip(
                                          icon: Icons.monetization_on,
                                          label: "Cost",
                                          value: "${item.costCoins}",
                                        ),
                                        if (owned)
                                          _PillLabel(
                                            text: equipped
                                                ? "Equipped"
                                                : "Owned",
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: FilledButton.tonal(
                                            onPressed: busy
                                                ? null
                                                : owned
                                                ? (equipped
                                                      ? null
                                                      : () => _equipCosmetic(
                                                          item.id,
                                                        ))
                                                : () => _buyCosmetic(item),
                                            child: busy
                                                ? const SizedBox(
                                                    width: 14,
                                                    height: 14,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : Text(
                                                    owned
                                                        ? (equipped
                                                              ? "Equipped"
                                                              : "Equip")
                                                        : "Buy ${item.name}",
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton.icon(
                                          onPressed: busy
                                              ? null
                                              : () => setState(
                                                  () => _previewCosmeticId =
                                                      item.id,
                                                ),
                                          icon: const Icon(Icons.visibility),
                                          label: const Text("Preview"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
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
                        child: Text("Cosmetics error: $e"),
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
  });

  final IconData icon;
  final String label;
  final String value;

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
        mainAxisSize: MainAxisSize.min,
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

class _PreviewDashboardTile extends StatelessWidget {
  const _PreviewDashboardTile({
    required this.accent,
    required this.icon,
    required this.onAccent,
  });

  final Color accent;
  final IconData icon;
  final Color onAccent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.60)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.22), scheme.surface],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 14, color: onAccent),
              ),
              const SizedBox(width: 8),
              const Text(
                "Dashboard",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Progress frame tint",
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewTreeNodeTile extends StatelessWidget {
  const _PreviewTreeNodeTile({
    required this.accent,
    required this.icon,
    required this.onAccent,
  });

  final Color accent;
  final IconData icon;
  final Color onAccent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Skill Tree Node",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accent.withValues(alpha: 0.75),
                width: 1.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 12, color: onAccent),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Node accent preview",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PillLabel extends StatelessWidget {
  const _PillLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
