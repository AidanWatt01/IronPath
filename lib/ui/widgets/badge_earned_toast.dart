import "package:flutter/material.dart";

class BadgeEarnedToast extends StatelessWidget
{
    const BadgeEarnedToast({
        super.key,
        required this.title,
        required this.subtitle,
    });

    final String title;
    final String subtitle;

    @override
    Widget build(BuildContext context)
    {
        final scheme = Theme.of(context).colorScheme;

        return Row(
            children:
            [
                TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.85, end: 1.0),
                    duration: const Duration(milliseconds: 520),
                    curve: Curves.elasticOut,
                    builder: (context, v, child)
                    {
                        return Transform.scale(scale: v, child: child);
                    },
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                            Icons.emoji_events,
                            color: scheme.onPrimaryContainer,
                        ),
                    ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                        [
                            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
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
        );
    }
}
