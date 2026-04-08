import 'package:flutter/material.dart';

import 'models/app_content.dart';
import 'screens/interactive_rosary_screen.dart';
import 'widgets/calendar_section.dart';
import 'widgets/daily_journal_section.dart';
import 'widgets/rosary_guide_section.dart';
import 'widgets/supplemental_prayers_section.dart';
import 'services/journal_storage_service.dart';

class PrayerBookHomePage extends StatefulWidget {
  final AppContent content;

  const PrayerBookHomePage({
    super.key,
    required this.content,
  });

  @override
  State<PrayerBookHomePage> createState() => _PrayerBookHomePageState();
}

class _PrayerBookHomePageState extends State<PrayerBookHomePage> {
  late DateTime displayedMonth;
  late DateTime selectedDate;
  final TextEditingController journalController = TextEditingController();

  final JournalStorageService journalStorageService = JournalStorageService();
  bool isJournalLoading = false;
  bool isJournalSaving = false;

  @override
  void initState() {
    super.initState();

    final DateTime now = DateTime.now();
    displayedMonth = DateTime(now.year, now.month);
    selectedDate = now;

    _loadJournalForSelectedDate();
  }

  List<Map<String, String>> get supplementalPrayers {
    return widget.content
        .mapListAt(widget.content.supplementalPrayers, 'items')
        .map(
          (Map<String, dynamic> item) => <String, String>{
            'title': item['title'] as String,
            'text': item['text'] as String,
          },
        )
        .toList();
  }

  Map<String, dynamic> getRosaryGuide(DateTime date) {
    final Map<String, dynamic> guideConfig = widget.content.rosaryGuide;
    final Map<String, dynamic> guidesByWeekday =
        Map<String, dynamic>.from(guideConfig['guidesByWeekday'] as Map);
    final String weekday = weekdayNameFromDate(date);
    final String defaultWeekday = guideConfig['defaultWeekday'] as String;
    final Map<String, dynamic> guide = Map<String, dynamic>.from(
      (guidesByWeekday[weekday] ?? guidesByWeekday[defaultWeekday]) as Map,
    );

    return <String, dynamic>{
      'weekday': weekday,
      'title': guide['title'],
      'focus': guide['focus'],
      'steps': widget.content.stringListAt(guideConfig, 'steps'),
    };
  }

  String weekdayNameFromDate(DateTime date) {
    final List<String> weekdays =
        widget.content.stringListAt(widget.content.rosaryGuide, 'weekdayNames');
    return weekdays[date.weekday - 1];
  }

  DateTime previousMonth(DateTime month) =>
      DateTime(month.year, month.month - 1);
  DateTime nextMonth(DateTime month) => DateTime(month.year, month.month + 1);

  Future<void> _loadJournalForSelectedDate() async {
    setState(() {
      isJournalLoading = true;
    });

    try {
      final DateTime dateToLoad = selectedDate;
      final String content = await journalStorageService.loadEntry(dateToLoad);

      if (!mounted) return;

      setState(() {
        journalController.text = content;
      });
    } catch (e, st) {
      debugPrint('Failed to load journal: $e');
      debugPrintStack(stackTrace: st);

      if (!mounted) return;

      setState(() {
        journalController.text = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load journal entry.')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isJournalLoading = false;
      });
    }
  }

  Future<void> _saveJournalForSelectedDate() async {
    setState(() {
      isJournalSaving = true;
    });

    try {
      await journalStorageService.saveEntry(
        date: selectedDate,
        content: journalController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal entry saved.')),
      );
    } catch (e, st) {
      debugPrint('Failed to save journal: $e');
      debugPrintStack(stackTrace: st);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save journal entry.')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isJournalSaving = false;
      });
    }
  }

  @override
  void dispose() {
    journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> layout = widget.content.layout;
    final Map<String, dynamic> app = widget.content.app;
    final Map<String, dynamic> rosaryGuide = getRosaryGuide(selectedDate);
    final List<String> steps =
        List<String>.from(rosaryGuide['steps'] as List<dynamic>);

    return Scaffold(
      appBar: AppBar(title: Text(app['title'] as String)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isWide = constraints.maxWidth >=
                widget.content.doubleAt(layout, 'wideHomeBreakpoint');

            return SingleChildScrollView(
              padding: EdgeInsets.all(
                  widget.content.doubleAt(layout, 'pagePadding')),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: <Widget>[
                              CalendarSection(
                                content: widget.content,
                                displayedMonth: displayedMonth,
                                selectedDate: selectedDate,
                                onPreviousMonth: () {
                                  setState(() => displayedMonth =
                                      previousMonth(displayedMonth));
                                },
                                onNextMonth: () {
                                  setState(() => displayedMonth =
                                      nextMonth(displayedMonth));
                                },
                                onDateSelected: (date) async {
                                  setState(() {
                                    selectedDate = date;
                                    displayedMonth =
                                        DateTime(date.year, date.month);
                                  });

                                  await _loadJournalForSelectedDate();
                                },
                              ),
                              SizedBox(
                                  height: widget.content
                                      .doubleAt(layout, 'largeGap')),
                              RosaryGuideSection(
                                content: widget.content,
                                rosaryGuide: rosaryGuide,
                                onOpenInteractiveRosary: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => InteractiveRosaryScreen(
                                        content: widget.content,
                                        title: rosaryGuide['title'] as String,
                                        weekday:
                                            rosaryGuide['weekday'] as String,
                                        steps: steps,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            width: widget.content.doubleAt(layout, 'largeGap')),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: <Widget>[
                              SupplementalPrayersSection(
                                content: widget.content,
                                prayers: supplementalPrayers,
                              ),
                              SizedBox(
                                  height: widget.content
                                      .doubleAt(layout, 'largeGap')),
                              DailyJournalSection(
                                content: widget.content,
                                controller: journalController,
                                selectedDate: selectedDate,
                                onSave: _saveJournalForSelectedDate,
                                isSaving: isJournalSaving,
                                isLoading: isJournalLoading,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: <Widget>[
                        CalendarSection(
                          content: widget.content,
                          displayedMonth: displayedMonth,
                          selectedDate: selectedDate,
                          onPreviousMonth: () {
                            setState(() =>
                                displayedMonth = previousMonth(displayedMonth));
                          },
                          onNextMonth: () {
                            setState(() =>
                                displayedMonth = nextMonth(displayedMonth));
                          },
                          onDateSelected: (date) async {
                            setState(() {
                              selectedDate = date;
                              displayedMonth = DateTime(date.year, date.month);
                            });

                            await _loadJournalForSelectedDate();
                          },
                        ),
                        SizedBox(
                            height:
                                widget.content.doubleAt(layout, 'largeGap')),
                        RosaryGuideSection(
                          content: widget.content,
                          rosaryGuide: rosaryGuide,
                          onOpenInteractiveRosary: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => InteractiveRosaryScreen(
                                  content: widget.content,
                                  title: rosaryGuide['title'] as String,
                                  weekday: rosaryGuide['weekday'] as String,
                                  steps: steps,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                            height:
                                widget.content.doubleAt(layout, 'largeGap')),
                        SupplementalPrayersSection(
                          content: widget.content,
                          prayers: supplementalPrayers,
                        ),
                        SizedBox(
                            height:
                                widget.content.doubleAt(layout, 'largeGap')),
                        DailyJournalSection(
                          content: widget.content,
                          controller: journalController,
                          selectedDate: selectedDate,
                          onSave: _saveJournalForSelectedDate,
                          isSaving: isJournalSaving,
                          isLoading: isJournalLoading,
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
