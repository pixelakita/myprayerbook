import 'package:flutter/material.dart';

import '../models/app_content.dart';
import 'app_card.dart';

class RosaryGuideSection extends StatelessWidget {
  final AppContent content;
  final Map<String, dynamic> rosaryGuide;
  final VoidCallback onOpenInteractiveRosary;

  const RosaryGuideSection({
    super.key,
    required this.content,
    required this.rosaryGuide,
    required this.onOpenInteractiveRosary,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> layout = content.layout;
    final Map<String, dynamic> interactiveRosary = content.interactiveRosary;
    final List<String> mysteries =
        List<String>.from(rosaryGuide['mysteries'] as List<dynamic>);

    return AppCard(
      content: content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Rosary Mysteries',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: content.doubleAt(layout, 'smallGap') - 2),
                    Text(
                      rosaryGuide['title'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onOpenInteractiveRosary,
                icon: const Icon(Icons.auto_stories_rounded),
                tooltip: content.stringAt(
                  interactiveRosary,
                  'openInteractiveRosaryTooltip',
                ),
              ),
            ],
          ),
          SizedBox(height: content.doubleAt(layout, 'mediumGap')),
          Text(
            rosaryGuide['focus'] as String,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: content.doubleAt(layout, 'largeGap')),
          ...List<Widget>.generate(mysteries.length, (int index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == mysteries.length - 1
                    ? 0
                    : content.doubleAt(layout, 'mediumGap') - 2,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: content.doubleAt(layout, 'mysteryCircleRadius'),
                    child: Text('${index + 1}'),
                  ),
                  SizedBox(width: content.doubleAt(layout, 'mediumGap')),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(mysteries[index]),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
