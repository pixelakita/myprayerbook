import 'package:flutter/material.dart';

import '../models/app_content.dart';
import '../services/template_utils.dart';
import 'app_card.dart';

class DailyJournalSection extends StatelessWidget {
  final AppContent content;
  final TextEditingController controller;
  final DateTime selectedDate;
  final VoidCallback onSave;
  final bool isSaving;
  final bool isLoading;

  const DailyJournalSection({
    super.key,
    required this.content,
    required this.controller,
    required this.selectedDate,
    required this.onSave,
    this.isSaving = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> journal = content.journal;
    final Map<String, dynamic> layout = content.layout;

    final String description = TemplateUtils.fill(
      content.stringAt(journal, 'descriptionTemplate'),
      <String, Object>{
        'month': selectedDate.month,
        'day': selectedDate.day,
        'year': selectedDate.year,
      },
    );

    return AppCard(
      content: content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            content.stringAt(journal, 'title'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: content.doubleAt(layout, 'smallGap')),
          Text(
            description,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.black54),
          ),
          SizedBox(height: content.doubleAt(layout, 'largeGap')),
          if (isLoading) ...<Widget>[
            const LinearProgressIndicator(),
            SizedBox(height: content.doubleAt(layout, 'mediumGap')),
          ],
          TextField(
            controller: controller,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: content.stringAt(journal, 'hint'),
              filled: true,
              fillColor: content.colorAt('white'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  content.doubleAt(layout, 'journalBorderRadius'),
                ),
                borderSide: BorderSide(color: content.colorAt('mutedBorder')),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  content.doubleAt(layout, 'journalBorderRadius'),
                ),
                borderSide: BorderSide(color: content.colorAt('mutedBorder')),
              ),
            ),
          ),
          SizedBox(height: content.doubleAt(layout, 'mediumGap')),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(
                isSaving ? 'Saving...' : content.stringAt(journal, 'saveLabel'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
