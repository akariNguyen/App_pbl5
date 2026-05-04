import 'package:flutter/material.dart';
import '../models/statistics_data.dart';

class TopSpeciesList extends StatelessWidget {
  final List<SpeciesCount> species;
  final Color primaryColor;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;

  const TopSpeciesList({
    super.key,
    required this.species,
    required this.primaryColor,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
  });

  static const List<String> _rankMedals = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];

  @override
  Widget build(BuildContext context) {
    final total = species.fold<int>(0, (s, e) => s + e.count);
    if (species.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Chưa có dữ liệu',
            style: TextStyle(color: mutedColor),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(species.length, (i) {
        final item = species[i];
        final pct = total > 0 ? item.count / total : 0.0;
        final medal = i < _rankMedals.length ? _rankMedals[i] : '  ';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  medal,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.displayName,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item.count} lần',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LayoutBuilder(
                      builder: (ctx, constraints) {
                        return Stack(
                          children: [
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              height: 8,
                              width: constraints.maxWidth * pct,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryColor, accentColor],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
