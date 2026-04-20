import 'package:flutter/material.dart';

import '../models/app_content.dart';
import '../models/daily_gospel.dart';

class GospelScreen extends StatelessWidget {
  final AppContent content;
  final DailyGospel gospel;
  final DateTime selectedDate;

  const GospelScreen({
    super.key,
    required this.content,
    required this.gospel,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> layout = content.layout;
    final Map<String, dynamic> gospelStrings = content.gospelStrings;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(content.stringAt(gospelStrings, 'title')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(content.doubleAt(layout, 'pagePadding')),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildDateLabel(theme, gospelStrings),
              SizedBox(height: content.doubleAt(layout, 'mediumGap')),
              _buildReferenceChip(theme, layout),
              SizedBox(height: content.doubleAt(layout, 'largeGap')),
              Text(
                gospel.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: content.doubleAt(layout, 'largeGap')),
              Container(
                width: double.infinity,
                padding:
                    EdgeInsets.all(content.doubleAt(layout, 'extraLargeGap')),
                decoration: BoxDecoration(
                  color: content.colorAt('appCardBackground'),
                  borderRadius: BorderRadius.circular(
                    content.doubleAt(layout, 'cardBorderRadius'),
                  ),
                  border: Border.all(color: content.colorAt('appCardBorder')),
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
                child: SelectableText(
                  gospel.text,
                  style: theme.textTheme.bodyLarge?.copyWith(
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
      ),
    );
  }

  Widget _buildDateLabel(
    ThemeData theme,
    Map<String, dynamic> gospelStrings,
  ) {
    final String month = selectedDate.month.toString().padLeft(2, '0');
    final String day = selectedDate.day.toString().padLeft(2, '0');
    final String year = selectedDate.year.toString();
    final String template = content.stringAt(gospelStrings, 'dateTemplate');
    final String label = template
        .replaceAll('{month}', month)
        .replaceAll('{day}', day)
        .replaceAll('{year}', year);

    return Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
    );
  }

  Widget _buildReferenceChip(
    ThemeData theme,
    Map<String, dynamic> layout,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: content.doubleAt(layout, 'mediumGap'),
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(
          content.doubleAt(layout, 'smallTileBorderRadius'),
        ),
      ),
      child: Text(
        gospel.reference,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
