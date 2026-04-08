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

            return Container(
              margin: EdgeInsets.only(
                bottom: content.doubleAt(layout, 'mediumGap') - 2,
              ),
              decoration: BoxDecoration(
                color: content.colorAt('white'),
                borderRadius: BorderRadius.circular(
                  content.doubleAt(layout, 'cardBorderRadius'),
                ),
                border: Border.all(
                  color: content.colorAt('mutedBorder'),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: content.colorAt('shadow'),
                    blurRadius: content.doubleAt(layout, 'cardShadowBlur'),
                    offset: Offset(
                      0,
                      content.doubleAt(layout, 'cardShadowOffsetY'),
                    ),
                  ),
                ],
              ),
              child: Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(
                    horizontal: content.doubleAt(layout, 'mediumGap'),
                    vertical: 6,
                  ),
                  childrenPadding: EdgeInsets.fromLTRB(
                    content.doubleAt(layout, 'mediumGap'),
                    0,
                    content.doubleAt(layout, 'mediumGap'),
                    content.doubleAt(layout, 'mediumGap'),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      content.doubleAt(layout, 'cardBorderRadius'),
                    ),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      content.doubleAt(layout, 'cardBorderRadius'),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  collapsedBackgroundColor: Colors.transparent,
                  iconColor: theme.colorScheme.primary,
                  collapsedIconColor: theme.colorScheme.primary,
                  title: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                        content.doubleAt(layout, 'mediumGap'),
                      ),
                      decoration: BoxDecoration(
                        color: content.colorAt('white'),
                        borderRadius: BorderRadius.circular(
                          content.doubleAt(layout, 'journalBorderRadius'),
                        ),
                      ),
                      child: SelectableText(
                        text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: content.doubleAt(
                            layout,
                            'supplementalPrayerLineHeight',
                          ),
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
