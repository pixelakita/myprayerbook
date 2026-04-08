import 'package:flutter/material.dart';
import '../models/app_content.dart';

class AppCard extends StatelessWidget {
  final AppContent content;
  final Widget child;

  const AppCard({
    super.key,
    required this.content,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> layout = content.layout;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(content.doubleAt(layout, 'extraLargeGap')),
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
            offset: Offset(0, content.doubleAt(layout, 'cardShadowOffsetY')),
          ),
        ],
      ),
      child: child,
    );
  }
}
