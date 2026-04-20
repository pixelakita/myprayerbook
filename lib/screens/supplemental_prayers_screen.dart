import 'package:flutter/material.dart';

import '../models/app_content.dart';

class SupplementalPrayersScreen extends StatefulWidget {
  final AppContent content;
  final List<Map<String, String>> prayers;

  const SupplementalPrayersScreen({
    super.key,
    required this.content,
    required this.prayers,
  });

  @override
  State<SupplementalPrayersScreen> createState() =>
      _SupplementalPrayersScreenState();
}

class _SupplementalPrayersScreenState extends State<SupplementalPrayersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  List<Map<String, String>> get _filteredPrayers {
    final String normalized = _query.trim().toLowerCase();

    if (normalized.isEmpty) {
      return widget.prayers;
    }

    return widget.prayers.where((Map<String, String> prayer) {
      final String title = (prayer['title'] ?? '').toLowerCase();
      return title.contains(normalized);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Map<String, dynamic> layout = widget.content.layout;
    final List<Map<String, String>> filteredPrayers = _filteredPrayers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer List'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            widget.content.doubleAt(layout, 'pagePadding'),
          ),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _searchController,
                onChanged: (String value) {
                  setState(() {
                    _query = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search prayers by title',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: widget.content.colorAt('white'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      widget.content.doubleAt(layout, 'journalBorderRadius'),
                    ),
                    borderSide: BorderSide(
                      color: widget.content.colorAt('mutedBorder'),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      widget.content.doubleAt(layout, 'journalBorderRadius'),
                    ),
                    borderSide: BorderSide(
                      color: widget.content.colorAt('mutedBorder'),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      widget.content.doubleAt(layout, 'journalBorderRadius'),
                    ),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: widget.content.doubleAt(layout, 'largeGap'),
              ),
              Expanded(
                child: filteredPrayers.isEmpty
                    ? Center(
                        child: Text(
                          'No prayers found.',
                          style: theme.textTheme.bodyLarge,
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredPrayers.length,
                        separatorBuilder: (_, __) => SizedBox(
                          height: widget.content.doubleAt(layout, 'mediumGap'),
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final Map<String, String> prayer =
                              filteredPrayers[index];
                          final String title = prayer['title'] ?? '';
                          final String text = prayer['text'] ?? '';

                          return Container(
                            decoration: BoxDecoration(
                              color: widget.content.colorAt('white'),
                              borderRadius: BorderRadius.circular(
                                widget.content.doubleAt(
                                  layout,
                                  'cardBorderRadius',
                                ),
                              ),
                              border: Border.all(
                                color: widget.content.colorAt('mutedBorder'),
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: widget.content.colorAt('shadow'),
                                  blurRadius: widget.content.doubleAt(
                                    layout,
                                    'cardShadowBlur',
                                  ),
                                  offset: Offset(
                                    0,
                                    widget.content.doubleAt(
                                      layout,
                                      'cardShadowOffsetY',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.symmetric(
                                horizontal: widget.content.doubleAt(
                                  layout,
                                  'mediumGap',
                                ),
                                vertical: 6,
                              ),
                              childrenPadding: EdgeInsets.fromLTRB(
                                widget.content.doubleAt(layout, 'mediumGap'),
                                0,
                                widget.content.doubleAt(layout, 'mediumGap'),
                                widget.content.doubleAt(layout, 'mediumGap'),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  widget.content.doubleAt(
                                    layout,
                                    'cardBorderRadius',
                                  ),
                                ),
                              ),
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  widget.content.doubleAt(
                                    layout,
                                    'cardBorderRadius',
                                  ),
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
                                    widget.content.doubleAt(
                                      layout,
                                      'mediumGap',
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.content.colorAt('white'),
                                    borderRadius: BorderRadius.circular(
                                      widget.content.doubleAt(
                                        layout,
                                        'journalBorderRadius',
                                      ),
                                    ),
                                  ),
                                  child: SelectableText(
                                    text,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      height: widget.content.doubleAt(
                                        layout,
                                        'supplementalPrayerLineHeight',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
