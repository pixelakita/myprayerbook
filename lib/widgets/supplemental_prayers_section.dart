import 'package:flutter/material.dart';

import '../models/app_content.dart';
import 'app_card.dart';

class SupplementalPrayersSection extends StatelessWidget {
  final AppContent content;
  final List<Map<String, String>> prayers;

  const SupplementalPrayersSection({
    super.key,
    required this.content,
    required this.prayers,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Map<String, dynamic> layout = content.layout;
    final Map<String, dynamic> supplemental = content.supplementalPrayers;
    final double alpha = (content.app['theme'] as Map<String, dynamic>)['surfaceContainerHighestAlpha'] as double;

    return AppCard(
      content: content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            content.stringAt(supplemental, 'title'),
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: content.doubleAt(layout, 'mediumGap')),
          ...prayers.map((Map<String, String> prayer) {
            final String title = prayer['title'] ?? '';
            final String text = prayer['text'] ?? '';

            return Card(
              margin: EdgeInsets.only(
                bottom: content.doubleAt(layout, 'mediumGap') - 2,
              ),
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: alpha,
              ),
              child: Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                  childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  title: Text(title, style: theme.textTheme.titleMedium),
                  iconColor: theme.colorScheme.primary,
                  collapsedIconColor: theme.colorScheme.primary,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SelectableText(
                        text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: content.doubleAt(layout, 'supplementalPrayerLineHeight'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
