import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/app_content.dart';
import '../services/template_utils.dart';
import '../widgets/app_card.dart';

class InteractiveRosaryScreen extends StatefulWidget {
  final AppContent content;
  final String title;
  final String weekday;
  final List<String> steps;

  const InteractiveRosaryScreen({
    super.key,
    required this.content,
    required this.title,
    required this.weekday,
    required this.steps,
  });

  @override
  State<InteractiveRosaryScreen> createState() =>
      _InteractiveRosaryScreenState();
}

class RosaryBeadData {
  final int index;
  final List<String> prayers;
  final String label;
  final String group;
  final int? mysteryIndex;
  final int? beadInDecade;
  final bool isLarge;
  final bool isCross;
  final bool isDrawable;

  const RosaryBeadData({
    required this.index,
    required this.prayers,
    required this.label,
    required this.group,
    this.mysteryIndex,
    this.beadInDecade,
    this.isLarge = false,
    this.isCross = false,
    this.isDrawable = true,
  });
}

class _InteractiveRosaryScreenState extends State<InteractiveRosaryScreen> {
  late final List<String> mysteries;
  late final List<RosaryBeadData> beads;

  int currentBeadIndex = 0;
  int currentPrayerIndex = 0;

  Map<String, dynamic> get _layout => widget.content.layout;
  Map<String, dynamic> get _interactive => widget.content.interactiveRosary;

  @override
  void initState() {
    super.initState();
    mysteries = _buildMysteryTitles(widget.title);
    beads = _buildTraditionalRosary(mysteries);
  }

  List<String> _buildMysteryTitles(String title) {
    final Map<String, dynamic> configuredMysteries = Map<String, dynamic>.from(
        _interactive['mysteriesByTitleKeyword'] as Map);

    for (final MapEntry<String, dynamic> entry in configuredMysteries.entries) {
      if (entry.key == 'default') {
        continue;
      }
      if (title.contains(entry.key)) {
        return List<String>.from(entry.value as List<dynamic>);
      }
    }

    return List<String>.from(configuredMysteries['default'] as List<dynamic>);
  }

  List<RosaryBeadData> _buildTraditionalRosary(List<String> mysteryTitles) {
    final List<RosaryBeadData> result = <RosaryBeadData>[];
    int beadIndex = 0;

    void addBead({
      required List<String> prayers,
      required String label,
      required String group,
      int? mysteryIndex,
      int? beadInDecade,
      bool isLarge = false,
      bool isCross = false,
      bool isDrawable = true,
    }) {
      result.add(
        RosaryBeadData(
          index: beadIndex,
          prayers: prayers,
          label: label,
          group: group,
          mysteryIndex: mysteryIndex,
          beadInDecade: beadInDecade,
          isLarge: isLarge,
          isCross: isCross,
          isDrawable: isDrawable,
        ),
      );
      beadIndex++;
    }

    _addOpeningChain(addBead);
    _addMainLoop(addBead, mysteryTitles);
    return result;
  }

  void _addOpeningChain(
    void Function({
      required List<String> prayers,
      required String label,
      required String group,
      int? mysteryIndex,
      int? beadInDecade,
      bool isLarge,
      bool isCross,
      bool isDrawable,
    }) addBead,
  ) {
    final List<Map<String, dynamic>> openingChain = widget.content.mapListAt(
      _interactive,
      'openingChain',
    );

    for (final Map<String, dynamic> bead in openingChain) {
      addBead(
        prayers: List<String>.from(bead['prayers'] as List<dynamic>),
        label: bead['label'] as String,
        group: bead['group'] as String,
        beadInDecade: bead['beadInDecade'] as int?,
        isLarge: bead['isLarge'] as bool? ?? false,
        isCross: bead['isCross'] as bool? ?? false,
      );
    }
  }

  void _addMainLoop(
    void Function({
      required List<String> prayers,
      required String label,
      required String group,
      int? mysteryIndex,
      int? beadInDecade,
      bool isLarge,
      bool isCross,
      bool isDrawable,
    }) addBead,
    List<String> mysteryTitles,
  ) {
    for (int mysteryIndex = 0;
        mysteryIndex < mysteryTitles.length;
        mysteryIndex++) {
      final int mysteryNumber = mysteryIndex + 1;
      final String mysteryTitle = mysteryTitles[mysteryIndex];
      final String decadeGroup = 'Decade $mysteryNumber';
      final bool isLastMystery = mysteryIndex == mysteryTitles.length - 1;

      for (int hailMaryNumber = 1; hailMaryNumber <= 10; hailMaryNumber++) {
        addBead(
          prayers: const <String>['Hail Mary'],
          label: 'Hail Mary $hailMaryNumber of 10 for $mysteryTitle.',
          group: decadeGroup,
          mysteryIndex: mysteryIndex,
          beadInDecade: hailMaryNumber,
        );
      }

      addBead(
        prayers: isLastMystery
            ? const <String>['Glory Be', 'Fatima Prayer', 'Hail Holy Queen']
            : const <String>['Glory Be', 'Fatima Prayer', 'Our Father'],
        label: isLastMystery
            ? 'Pray the Glory Be, Fatima Prayer, and Hail Holy Queen.'
            : 'Pray the Glory Be, Fatima Prayer, and Our Father for Mystery ${mysteryNumber + 1}.',
        group: decadeGroup,
        mysteryIndex: mysteryIndex,
        isLarge: true,
      );
    }
  }

  int get _loopBeadCount {
    return beads.length -
        widget.content.intAt(_layout, 'openingChainCount') -
        widget.content.intAt(_layout, 'closingPrayerCount');
  }

  bool get _isAtLastStep {
    final RosaryBeadData currentBead = beads[currentBeadIndex];
    final bool isLastBead = currentBeadIndex == beads.length - 1;
    final bool isLastPrayerInBead =
        currentPrayerIndex == currentBead.prayers.length - 1;
    return isLastBead && isLastPrayerInBead;
  }

  void _goToBead(int index, {int prayerIndex = 0}) {
    setState(() {
      currentBeadIndex = index;
      currentPrayerIndex = prayerIndex;
    });
  }

  void _goToNextBead() {
    final RosaryBeadData currentBead = beads[currentBeadIndex];
    if (currentPrayerIndex < currentBead.prayers.length - 1) {
      setState(() => currentPrayerIndex++);
      return;
    }

    if (currentBeadIndex >= beads.length - 1) {
      return;
    }

    _goToBead(currentBeadIndex + 1);
  }

  void _goToPreviousBead() {
    if (currentPrayerIndex > 0) {
      setState(() => currentPrayerIndex--);
      return;
    }

    if (currentBeadIndex <= 0) {
      return;
    }

    final RosaryBeadData previousBead = beads[currentBeadIndex - 1];
    _goToBead(
      currentBeadIndex - 1,
      prayerIndex: previousBead.prayers.length - 1,
    );
  }

  List<Offset> _buildRosaryPath(Size size) {
    final List<Offset> points = <Offset>[];
    final double centerX = size.width / 2;
    final Offset loopCenter = Offset(
      centerX,
      widget.content.doubleAt(_layout, 'loopCenterY'),
    );
    final double loopRadiusX =
        size.width * widget.content.doubleAt(_layout, 'loopRadiusXFactor');
    final double loopRadiusY = widget.content.doubleAt(_layout, 'loopRadiusY');
    final double connectorStartY = loopCenter.dy + loopRadiusY;

    points.addAll(
      _buildOpeningChainPoints(
        centerX: centerX,
        connectorStartY: connectorStartY,
      ),
    );
    points.addAll(
      _buildLoopPoints(
        center: loopCenter,
        radiusX: loopRadiusX,
        radiusY: loopRadiusY,
      ),
    );
    return points;
  }

  List<Offset> _buildOpeningChainPoints({
    required double centerX,
    required double connectorStartY,
  }) {
    final List<dynamic> offsets =
        _layout['openingChainOffsets'] as List<dynamic>;
    return offsets
        .map(
          (dynamic offset) =>
              Offset(centerX, connectorStartY + (offset as num).toDouble()),
        )
        .toList();
  }

  List<Offset> _buildLoopPoints({
    required Offset center,
    required double radiusX,
    required double radiusY,
  }) {
    final List<Offset> points = <Offset>[];
    if (_loopBeadCount <= 1) {
      return points;
    }

    final int loopSegments = _loopBeadCount - 1;

    for (int index = 0; index < _loopBeadCount; index++) {
      final double angle = math.pi / 2 + (2 * math.pi * index / loopSegments);
      final double topBottomWeight = math.sin(angle).abs();
      final double adjustedRadiusX = radiusX *
          (1 +
              widget.content.doubleAt(_layout, 'loopWidthWeightFactor') *
                  topBottomWeight);

      points.add(
        Offset(
          center.dx + adjustedRadiusX * math.cos(angle),
          center.dy + radiusY * math.sin(angle),
        ),
      );
    }

    return points;
  }

  double _getBeadOffset(RosaryBeadData bead) {
    if (bead.isCross) {
      return widget.content.doubleAt(_layout, 'beadCrossOffset');
    }
    if (bead.isLarge) {
      return widget.content.doubleAt(_layout, 'beadLargeOffset');
    }
    return widget.content.doubleAt(_layout, 'beadSmallOffset');
  }

  double _getRosaryCanvasHeight(BoxConstraints constraints) {
    final double minimumHeight =
        widget.content.doubleAt(_layout, 'minimumRosaryHeight');

    if (!constraints.hasBoundedHeight || constraints.maxHeight.isInfinite) {
      return minimumHeight;
    }

    return constraints.maxHeight > minimumHeight
        ? constraints.maxHeight
        : minimumHeight;
  }

  String _getPrayerText(String prayerName) {
    final Map<String, dynamic> prayerTexts =
        Map<String, dynamic>.from(_interactive['prayerTexts'] as Map);
    return prayerTexts[prayerName] as String? ??
        widget.content.stringAt(_interactive, 'longPlaceholder');
  }

  Widget _buildRosaryPanel(
    BuildContext context,
    RosaryBeadData currentBead,
    double progress,
  ) {
    return AppCard(
      content: widget.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildRosaryHeader(context, currentBead),
          SizedBox(height: widget.content.doubleAt(_layout, 'mediumGap')),
          LinearProgressIndicator(value: progress),
          SizedBox(height: widget.content.doubleAt(_layout, 'extraLargeGap')),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  widget.content.doubleAt(_layout, 'minimumRosaryHeight'),
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final Size rosarySize = Size(
                  constraints.maxWidth,
                  _getRosaryCanvasHeight(constraints),
                );
                final List<Offset> points = _buildRosaryPath(rosarySize);
                return SizedBox(
                  width: rosarySize.width,
                  height: rosarySize.height,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _RosaryPathPainter(
                            content: widget.content,
                            points: points,
                            openingChainCount: widget.content
                                .intAt(_layout, 'openingChainCount'),
                          ),
                        ),
                      ),
                      ..._buildPositionedBeads(points),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRosaryHeader(BuildContext context, RosaryBeadData currentBead) {
    final String progressText = TemplateUtils.fill(
      widget.content.stringAt(_interactive, 'beadProgressTemplate'),
      <String, Object>{
        'group': currentBead.group,
        'current': currentBead.index + 1,
        'total': beads.length,
      },
    );

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                progressText,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _goToBead(0),
          icon: const Icon(Icons.refresh_rounded),
          tooltip: widget.content.stringAt(_interactive, 'resetTooltip'),
        ),
      ],
    );
  }

  List<Widget> _buildPositionedBeads(List<Offset> points) {
    final List<Widget> widgets = <Widget>[];
    final int drawableCount = math.min(points.length, beads.length);

    for (int i = drawableCount - 1; i >= 0; i--) {
      final RosaryBeadData bead = beads[i];
      if (!bead.isDrawable) {
        continue;
      }

      final Offset point = points[i];
      final double beadOffset = _getBeadOffset(bead);

      widgets.add(
        Positioned(
          left: point.dx - beadOffset,
          top: point.dy - beadOffset,
          child: _RosaryBeadWidget(
            content: widget.content,
            bead: bead,
            isActive: i == currentBeadIndex,
            isDone: i < currentBeadIndex,
            onTap: () => _goToBead(i),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildInfoPanel(BuildContext context, RosaryBeadData currentBead) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildCurrentPrayerCard(context, currentBead),
        SizedBox(height: widget.content.doubleAt(_layout, 'largeGap')),
        _buildControlsCard(),
        SizedBox(height: widget.content.doubleAt(_layout, 'largeGap')),
        _buildMysteryGroupsCard(context, currentBead),
      ],
    );
  }

  Widget _buildCurrentPrayerCard(
    BuildContext context,
    RosaryBeadData currentBead,
  ) {
    final String currentPrayer = currentBead.prayers[currentPrayerIndex];
    final int totalPrayers = currentBead.prayers.length;

    return AppCard(
      content: widget.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            currentPrayer,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (totalPrayers > 1) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              TemplateUtils.fill(
                widget.content
                    .stringAt(_interactive, 'currentPrayerProgressTemplate'),
                <String, Object>{
                  'current': currentPrayerIndex + 1,
                  'total': totalPrayers,
                },
              ),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black54),
            ),
          ],
          SizedBox(height: widget.content.doubleAt(_layout, 'smallGap')),
          Text(
            _getPrayerText(currentPrayer),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: widget.content
                      .doubleAt(_layout, 'rosaryPrimaryPrayerLineHeight'),
                ),
          ),
          _buildMysteryInfo(context, currentBead),
        ],
      ),
    );
  }

  Widget _buildMysteryInfo(BuildContext context, RosaryBeadData currentBead) {
    if (currentBead.mysteryIndex == null) {
      return const SizedBox.shrink();
    }

    final int mysteryNumber = currentBead.mysteryIndex! + 1;
    final String title = mysteries[currentBead.mysteryIndex!];
    final String label = TemplateUtils.fill(
      widget.content.stringAt(_interactive, 'mysteryTitleTemplate'),
      <String, Object>{'number': mysteryNumber, 'title': title},
    );

    return Column(
      children: <Widget>[
        SizedBox(height: widget.content.doubleAt(_layout, 'mediumGap')),
        Container(
          width: double.infinity,
          padding:
              EdgeInsets.all(widget.content.doubleAt(_layout, 'mediumGap')),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(
              widget.content.doubleAt(_layout, 'tileBorderRadius'),
            ),
          ),
          child: Text(label),
        ),
      ],
    );
  }

  Widget _buildControlsCard() {
    final bool isFirstStep = currentBeadIndex == 0 && currentPrayerIndex == 0;

    return AppCard(
      content: widget.content,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isAtLastStep ? null : _goToNextBead,
              icon: const Icon(Icons.chevron_right_rounded),
              label:
                  Text(widget.content.stringAt(_interactive, 'nextBeadLabel')),
            ),
          ),
          SizedBox(height: widget.content.doubleAt(_layout, 'mediumGap')),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isFirstStep ? null : _goToPreviousBead,
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: Text(
                      widget.content.stringAt(_interactive, 'previousLabel')),
                ),
              ),
              SizedBox(width: widget.content.doubleAt(_layout, 'mediumGap')),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _goToBead(0),
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: Text(
                      widget.content.stringAt(_interactive, 'startOverLabel')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalPrayersCard(BuildContext context) {
    final List<Map<String, dynamic>> prayers = widget.content.mapListAt(
      _interactive,
      'additionalPrayers',
    );

    return AppCard(
      content: widget.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            widget.content.stringAt(_interactive, 'additionalPrayersTitle'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: widget.content.doubleAt(_layout, 'mediumGap')),
          ...List<Widget>.generate(prayers.length, (int index) {
            final Map<String, dynamic> prayer = prayers[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == prayers.length - 1
                    ? 0
                    : widget.content.doubleAt(_layout, 'mediumGap'),
              ),
              child: ExpansionTile(
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    widget.content.doubleAt(_layout, 'tileBorderRadius'),
                  ),
                  side:
                      BorderSide(color: widget.content.colorAt('mutedBorder')),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    widget.content.doubleAt(_layout, 'tileBorderRadius'),
                  ),
                  side:
                      BorderSide(color: widget.content.colorAt('mutedBorder')),
                ),
                backgroundColor: widget.content.colorAt('white'),
                collapsedBackgroundColor: widget.content.colorAt('white'),
                title: Text(
                  prayer['title'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                children: <Widget>[
                  Text(
                    prayer['text'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: widget.content.doubleAt(
                              _layout, 'rosaryPrimaryPrayerLineHeight'),
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

  Widget _buildMysteryGroupsCard(
    BuildContext context,
    RosaryBeadData currentBead,
  ) {
    return AppCard(
      content: widget.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            widget.content.stringAt(_interactive, 'mysteryGroupsTitle'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: widget.content.doubleAt(_layout, 'mediumGap')),
          ListView.builder(
            itemCount: mysteries.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              final bool isActive = currentBead.mysteryIndex == index;
              final String label = TemplateUtils.fill(
                widget.content.stringAt(_interactive, 'decadeTitleTemplate'),
                <String, Object>{
                  'number': index + 1,
                  'title': mysteries[index]
                },
              );

              return Container(
                margin: EdgeInsets.only(
                  bottom: widget.content.doubleAt(_layout, 'mediumGap') - 2,
                ),
                padding: EdgeInsets.all(
                    widget.content.doubleAt(_layout, 'mediumGap') + 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? Theme.of(context).colorScheme.primaryContainer
                      : widget.content.colorAt('white'),
                  borderRadius: BorderRadius.circular(
                    widget.content.doubleAt(_layout, 'tileBorderRadius'),
                  ),
                  border: Border.all(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : widget.content.colorAt('mutedBorder'),
                  ),
                ),
                child: Text(label),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout(
    Widget rosaryPanel,
    Widget infoPanel,
    Widget additionalPrayersCard,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height:
                      widget.content.doubleAt(_layout, 'minimumRosaryHeight'),
                  child: rosaryPanel,
                ),
                SizedBox(height: widget.content.doubleAt(_layout, 'largeGap')),
                additionalPrayersCard,
              ],
            ),
          ),
        ),
        SizedBox(width: widget.content.doubleAt(_layout, 'largeGap')),
        Expanded(flex: 4, child: SingleChildScrollView(child: infoPanel)),
      ],
    );
  }

  Widget _buildMobileLayout(
    Widget rosaryPanel,
    Widget infoPanel,
    Widget additionalPrayersCard,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          infoPanel,
          SizedBox(height: widget.content.doubleAt(_layout, 'largeGap')),
          rosaryPanel,
          SizedBox(height: widget.content.doubleAt(_layout, 'largeGap')),
          additionalPrayersCard,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final RosaryBeadData currentBead = beads[currentBeadIndex];
    final double progress = (currentBeadIndex + 1) / beads.length;
    final bool isWideLayout = MediaQuery.of(context).size.width >=
        widget.content.doubleAt(_layout, 'wideRosaryBreakpoint');

    return Scaffold(
      appBar: AppBar(title: Text('${widget.weekday} Rosary')),
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.all(widget.content.doubleAt(_layout, 'pagePadding')),
          child: isWideLayout
              ? _buildWideLayout(
                  _buildRosaryPanel(context, currentBead, progress),
                  _buildInfoPanel(context, currentBead),
                  _buildAdditionalPrayersCard(context),
                )
              : _buildMobileLayout(
                  _buildRosaryPanel(context, currentBead, progress),
                  _buildInfoPanel(context, currentBead),
                  _buildAdditionalPrayersCard(context),
                ),
        ),
      ),
    );
  }
}

class _RosaryBeadWidget extends StatelessWidget {
  final AppContent content;
  final RosaryBeadData bead;
  final bool isActive;
  final bool isDone;
  final VoidCallback onTap;

  const _RosaryBeadWidget({
    required this.content,
    required this.bead,
    required this.isActive,
    required this.isDone,
    required this.onTap,
  });

  double _getBeadSize() {
    return bead.isLarge
        ? content.doubleAt(content.layout, 'beadLargeSize')
        : content.doubleAt(content.layout, 'beadSmallSize');
  }

  Color _getFillColor(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (isActive) {
      return colorScheme.primary;
    }
    if (isDone) {
      return colorScheme.secondaryContainer;
    }
    return content.colorAt('white');
  }

  Color _getBorderColor(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (isActive) {
      return colorScheme.primary;
    }
    if (isDone) {
      return colorScheme.secondary;
    }
    return content.colorAt('beadBorder');
  }

  Color _getCrossColor(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (isActive) {
      return colorScheme.primary;
    }
    if (isDone) {
      return colorScheme.secondary;
    }
    return content.colorAt('crossColor');
  }

  @override
  Widget build(BuildContext context) {
    if (bead.isCross) {
      return GestureDetector(
        onTap: onTap,
        child: Icon(
          Icons.add_rounded,
          size: content.doubleAt(content.layout, 'beadCrossIconSize'),
          color: _getCrossColor(context),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(
          milliseconds: content.intAt(content.layout, 'beadAnimationMillis'),
        ),
        width: _getBeadSize(),
        height: _getBeadSize(),
        decoration: BoxDecoration(
          color: _getFillColor(context),
          shape: BoxShape.circle,
          border: Border.all(
            color: _getBorderColor(context),
            width: isActive
                ? content.doubleAt(content.layout, 'activeBorderWidth')
                : content.doubleAt(content.layout, 'defaultBorderWidth'),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: content.colorAt('shadow'),
              blurRadius: content.doubleAt(content.layout, 'beadShadowBlur'),
              offset: Offset(
                  0, content.doubleAt(content.layout, 'beadShadowOffsetY')),
            ),
          ],
        ),
      ),
    );
  }
}

class _RosaryPathPainter extends CustomPainter {
  final AppContent content;
  final List<Offset> points;
  final int openingChainCount;

  _RosaryPathPainter({
    required this.content,
    required this.points,
    required this.openingChainCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = content.colorAt('pathColor')
      ..strokeWidth = content.doubleAt(content.layout, 'pathStrokeWidth')
      ..style = PaintingStyle.stroke;

    if (points.length < openingChainCount + 1) {
      return;
    }

    final Path chainPath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < openingChainCount; i++) {
      chainPath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(chainPath, linePaint);

    final Path loopPath = Path()
      ..moveTo(points[openingChainCount].dx, points[openingChainCount].dy);
    for (int i = openingChainCount + 1; i < points.length; i++) {
      loopPath.lineTo(points[i].dx, points[i].dy);
    }
    loopPath.close();
    canvas.drawPath(loopPath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _RosaryPathPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.openingChainCount != openingChainCount;
  }
}
