import 'package:flutter/material.dart';

import '../models/app_content.dart';
import '../models/daily_gospel.dart';
import '../screens/gospel_screen.dart';
import 'app_card.dart';

class GospelSection extends StatelessWidget {
  final AppContent content;
  final DailyGospel? gospel;
  final DateTime selectedDate;
  final bool isLoading;

  const GospelSection({
    super.key,
    required this.content,
    required this.gospel,
    required this.selectedDate,
    this.isLoading = false,
  });

  void _openGospelScreen(BuildContext context) {
    if (gospel == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GospelScreen(
          content: content,
          gospel: gospel!,
          selectedDate: selectedDate,
        ),
      ),
    );
  }

  String _dateLabel(Map<String, dynamic> gospelStrings) {
    final String month = selectedDate.month.toString().padLeft(2, '0');
    final String day = selectedDate.day.toString().padLeft(2, '0');
    final String year = selectedDate.year.toString();
    final String template = content.stringAt(gospelStrings, 'dateTemplate');
    return template
        .replaceAll('{month}', month)
        .replaceAll('{day}', day)
        .replaceAll('{year}', year);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> layout = content.layout;
    final Map<String, dynamic> gospelStrings = content.gospelStrings;
    final ThemeData theme = Theme.of(context);

    return AppCard(
      content: content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeader(theme, gospelStrings, layout),
          SizedBox(height: content.doubleAt(layout, 'mediumGap')),
          if (isLoading)
            const LinearProgressIndicator()
          else if (gospel == null)
            Text(
              content.stringAt(gospelStrings, 'notFound'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
            )
          else ...<Widget>[
            _buildReferenceChip(theme, layout),
            SizedBox(height: content.doubleAt(layout, 'largeGap')),
            _buildGospelTitle(theme),
            SizedBox(height: content.doubleAt(layout, 'mediumGap')),
            _buildPreviewText(theme, layout),
            SizedBox(height: content.doubleAt(layout, 'mediumGap')),
            _buildReadButton(context, theme, gospelStrings, layout),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    Map<String, dynamic> gospelStrings,
    Map<String, dynamic> layout,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                content.stringAt(gospelStrings, 'title'),
                style: theme.textTheme.headlineSmall,
              ),
              SizedBox(height: content.doubleAt(layout, 'smallGap')),
              Text(
                _dateLabel(gospelStrings),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.menu_book_rounded,
          color: theme.colorScheme.primary,
        ),
      ],
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
        gospel!.reference,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGospelTitle(ThemeData theme) {
    return Text(
      gospel!.title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildPreviewText(
    ThemeData theme,
    Map<String, dynamic> layout,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(content.doubleAt(layout, 'mediumGap')),
      decoration: BoxDecoration(
        color: content.colorAt('white'),
        borderRadius: BorderRadius.circular(
          content.doubleAt(layout, 'journalBorderRadius'),
        ),
        border: Border.all(color: content.colorAt('mutedBorder')),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: Text(
              gospel!.text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                height:
                    content.doubleAt(layout, 'supplementalPrayerLineHeight'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReadButton(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> gospelStrings,
    Map<String, dynamic> layout,
  ) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _openGospelScreen(context),
        icon: const Icon(Icons.menu_book_rounded),
        label: Text(content.stringAt(gospelStrings, 'readLabel')),
      ),
    );
  }
}
