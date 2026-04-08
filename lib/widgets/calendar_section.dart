import 'package:flutter/material.dart';

import '../models/app_content.dart';
import 'app_card.dart';

class CalendarSection extends StatelessWidget {
  final AppContent content;
  final DateTime displayedMonth;
  final DateTime selectedDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarSection({
    super.key,
    required this.content,
    required this.displayedMonth,
    required this.selectedDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  List<DateTime?> buildCalendarDays() {
    final DateTime firstDayOfMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month,
      1,
    );
    final int daysInMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month + 1,
      0,
    ).day;
    final int leadingEmptySlots = firstDayOfMonth.weekday % 7;
    final List<DateTime?> dates = <DateTime?>[];

    for (int i = 0; i < leadingEmptySlots; i++) {
      dates.add(null);
    }

    for (int day = 1; day <= daysInMonth; day++) {
      dates.add(DateTime(displayedMonth.year, displayedMonth.month, day));
    }

    while (dates.length % 7 != 0) {
      dates.add(null);
    }

    return dates;
  }

  String monthLabel() {
    final List<String> monthNames = content.stringListAt(content.calendar, 'monthNames');
    return '${monthNames[displayedMonth.month - 1]} ${displayedMonth.year}';
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> calendar = content.calendar;
    final Map<String, dynamic> layout = content.layout;
    final List<DateTime?> calendarDays = buildCalendarDays();
    final List<String> weekdaysShort = content.stringListAt(calendar, 'weekdaysShort');

    return AppCard(
      content: content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            content.stringAt(calendar, 'title'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: content.doubleAt(layout, 'smallGap')),
          Text(
            content.stringAt(calendar, 'subtitle'),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.black54),
          ),
          SizedBox(height: content.doubleAt(layout, 'largeGap')),
          Row(
            children: <Widget>[
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  monthLabel(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          SizedBox(height: content.doubleAt(layout, 'mediumGap')),
          Row(
            children: weekdaysShort
                .map(
                  (String day) => Expanded(child: Center(child: Text(day))),
                )
                .toList(),
          ),
          SizedBox(height: content.doubleAt(layout, 'smallGap')),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: calendarDays.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: content.intAt(layout, 'calendarGridCrossAxisCount'),
              crossAxisSpacing: content.doubleAt(layout, 'calendarGridSpacing'),
              mainAxisSpacing: content.doubleAt(layout, 'calendarGridSpacing'),
              childAspectRatio: content.doubleAt(layout, 'calendarGridChildAspectRatio'),
            ),
            itemBuilder: (BuildContext context, int index) {
              final DateTime? date = calendarDays[index];
              if (date == null) {
                return const SizedBox.shrink();
              }

              final bool isSelected = isSameDate(date, selectedDate);
              final bool isToday = isSameDate(date, DateTime.now());

              return InkWell(
                borderRadius: BorderRadius.circular(
                  content.doubleAt(layout, 'smallTileBorderRadius'),
                ),
                onTap: () => onDateSelected(date),
                child: AnimatedContainer(
                  duration: Duration(
                    milliseconds: content.intAt(layout, 'beadAnimationMillis'),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : content.colorAt('white'),
                    borderRadius: BorderRadius.circular(
                      content.doubleAt(layout, 'smallTileBorderRadius'),
                    ),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : isToday
                              ? Theme.of(context).colorScheme.secondary
                              : content.colorAt('mutedBorder'),
                      width: isToday || isSelected
                          ? content.doubleAt(layout, 'selectedDateBorderWidth')
                          : content.doubleAt(layout, 'defaultDateBorderWidth'),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Text(
                          '${date.day}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (isToday)
                        Positioned(
                          top: content.doubleAt(layout, 'todayDotTop'),
                          right: content.doubleAt(layout, 'todayDotRight'),
                          child: Container(
                            width: content.doubleAt(layout, 'todayDotSize'),
                            height: content.doubleAt(layout, 'todayDotSize'),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
