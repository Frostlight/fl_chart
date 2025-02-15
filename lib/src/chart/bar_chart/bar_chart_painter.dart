import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/bar_chart/bar_chart_data.dart';
import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_painter.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BarChartPainter extends AxisChartPainter<BarChartData> with TouchHandler<BarTouchResponse> {
  Paint barPaint, bgTouchTooltipPaint;

  List<GroupBarsPosition> groupBarsPosition;

  BarChartPainter(
    BarChartData data,
    BarChartData targetData,
    Function(TouchHandler) touchHandler,
  ) : super(data, targetData) {
    touchHandler(this);
    barPaint = Paint()..style = PaintingStyle.fill;

    bgTouchTooltipPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);

    if (data.barGroups.isEmpty) {
      return;
    }

    final List<double> groupsX = calculateGroupsX(size, data.barGroups, data.alignment);
    groupBarsPosition = calculateGroupAndBarsPosition(size, groupsX, data.barGroups);

    drawBars(canvas, size, groupBarsPosition);
    drawTitles(canvas, size, groupBarsPosition);

    for (int i = 0; i < targetData.barGroups.length; i++) {
      final barGroup = targetData.barGroups[i];
      for (int j = 0; j < barGroup.barRods.length; j++) {
        if (!barGroup.showingTooltipIndicators.contains(j)) {
          continue;
        }
        final barRod = barGroup.barRods[j];

        drawTouchTooltip(canvas, size, groupBarsPosition, targetData.barTouchData.touchTooltipData,
          barGroup, i,
          barRod, j);
      }
    }
  }

  /// this method calculates the x of our showing groups,
  /// they calculate as center of the group
  /// we position the groups based on the given [alignment],
  List<double> calculateGroupsX(
      Size viewSize, List<BarChartGroupData> barGroups, BarChartAlignment alignment) {
    final Size drawSize = getChartUsableDrawSize(viewSize);

    final List<double> groupsX = List<double>(barGroups.length);

    final double leftTextsSpace = getLeftOffsetDrawSize();

    switch (alignment) {
      case BarChartAlignment.start:
        double tempX = 0;
        barGroups.asMap().forEach((i, group) {
          groupsX[i] = leftTextsSpace + tempX + group.width / 2;
          tempX += group.width;
        });
        break;

      case BarChartAlignment.end:
        double tempX = 0;
        for (int i = barGroups.length - 1; i >= 0; i--) {
          final group = barGroups[i];
          groupsX[i] = (leftTextsSpace + drawSize.width) - tempX - group.width / 2;
          tempX += group.width;
        }
        break;

      case BarChartAlignment.center:
        final double sumWidth = barGroups.map((group) => group.width).reduce((a, b) => a + b);
        final double horizontalMargin = (drawSize.width - sumWidth) / 2;

        double tempX = 0;
        for (int i = 0; i < barGroups.length; i++) {
          final group = barGroups[i];
          groupsX[i] = leftTextsSpace + horizontalMargin + tempX + group.width / 2;
          tempX += group.width;
        }
        break;

      case BarChartAlignment.spaceBetween:
        final double sumWidth = barGroups.map((group) => group.width).reduce((a, b) => a + b);
        final double spaceAvailable = drawSize.width - sumWidth;
        final double eachSpace = spaceAvailable / (barGroups.length - 1);

        double tempX = 0;
        barGroups.asMap().forEach((index, group) {
          tempX += group.width / 2;
          if (index != 0) {
            tempX += eachSpace;
          }
          groupsX[index] = leftTextsSpace + tempX;
          tempX += group.width / 2;
        });
        break;

      case BarChartAlignment.spaceAround:
        final double sumWidth = barGroups.map((group) => group.width).reduce((a, b) => a + b);
        final double spaceAvailable = drawSize.width - sumWidth;
        final double eachSpace = spaceAvailable / (barGroups.length * 2);

        double tempX = 0;
        barGroups.asMap().forEach((i, group) {
          tempX += eachSpace;
          tempX += group.width / 2;
          groupsX[i] = leftTextsSpace + tempX;
          tempX += group.width / 2;
          tempX += eachSpace;
        });
        break;

      case BarChartAlignment.spaceEvenly:
        final double sumWidth = barGroups.map((group) => group.width).reduce((a, b) => a + b);
        final double spaceAvailable = drawSize.width - sumWidth;
        final double eachSpace = spaceAvailable / (barGroups.length + 1);

        double tempX = 0;
        barGroups.asMap().forEach((i, group) {
          tempX += eachSpace;
          tempX += group.width / 2;
          groupsX[i] = leftTextsSpace + tempX;
          tempX += group.width / 2;
        });
        break;
    }

    return groupsX;
  }

  List<GroupBarsPosition> calculateGroupAndBarsPosition(
      Size viewSize, List<double> groupsX, List<BarChartGroupData> barGroups) {
    if (groupsX.length != barGroups.length) {
      throw Exception('inconsistent state groupsX.length != barGroups.length');
    }

    final List<GroupBarsPosition> groupBarsPosition = [];
    for (int i = 0; i < barGroups.length; i++) {
      final BarChartGroupData barGroup = barGroups[i];
      final double groupX = groupsX[i];

      double tempX = 0;
      final List<double> barsX = [];
      barGroup.barRods.asMap().forEach((barIndex, barRod) {
        final double widthHalf = barRod.width / 2;
        barsX.add(groupX - (barGroup.width / 2) + tempX + widthHalf);
        tempX += barRod.width + barGroup.barsSpace;
      });
      groupBarsPosition.add(GroupBarsPosition(groupX, barsX));
    }
    return groupBarsPosition;
  }

  void drawBars(Canvas canvas, Size viewSize, List<GroupBarsPosition> groupBarsPosition) {
    final Size drawSize = getChartUsableDrawSize(viewSize);

    for (int i = 0; i < data.barGroups.length; i++) {
      final barGroup = data.barGroups[i];
      for (int j = 0; j < barGroup.barRods.length; j++) {
        final barRod = barGroup.barRods[j];
        final double widthHalf = barRod.width / 2;
        final double roundedRadius = barRod.isRound ? widthHalf : 0;

        final double x = groupBarsPosition[i].barsX[j];

        Offset from, to;

        barPaint.strokeWidth = barRod.width;
        barPaint.strokeCap = barRod.isRound ? StrokeCap.round : StrokeCap.butt;

        /// Draw [BackgroundBarChartRodData]
        if (barRod.backDrawRodData.show && barRod.backDrawRodData.y != 0) {
          from = Offset(
            x,
            getPixelY(0, drawSize) - roundedRadius,
          );
          to = Offset(
            x,
            getPixelY(barRod.backDrawRodData.y, drawSize) + roundedRadius,
          );
          barPaint.color = barRod.backDrawRodData.color;
          canvas.drawLine(from, to, barPaint);
        }

        // draw Main Rod
        if (barRod.y != 0) {
          final yFrom = getPixelY(0, drawSize);
          from = Offset(
            x,
            yFrom - roundedRadius,
          );

          var yTo = getPixelY(barRod.y, drawSize);

          if ((yFrom - yTo).abs() <= barRod.width) {
            yTo = yFrom - barRod.width;
          }

          to = Offset(
            x,
            yTo + roundedRadius,
          );
          barPaint.color = barRod.color;
          canvas.drawLine(from, to, barPaint);
        }
      }
    }
  }

  void drawTitles(Canvas canvas, Size viewSize, List<GroupBarsPosition> groupBarsPosition) {
    if (!data.titlesData.show) {
      return;
    }
    final Size drawSize = getChartUsableDrawSize(viewSize);

    // Left Titles
    final leftTitles = data.titlesData.leftTitles;
    if (leftTitles.showTitles) {
      int verticalCounter = 0;
      while (leftTitles.interval * verticalCounter <= data.maxY) {
        double x = 0 + getLeftOffsetDrawSize();
        double y = getPixelY(data.gridData.verticalInterval * verticalCounter, drawSize) +
            getTopOffsetDrawSize();

        final String text = leftTitles.getTitles(data.gridData.verticalInterval * verticalCounter);

        final TextSpan span = TextSpan(style: leftTitles.textStyle, text: text);
        final TextPainter tp =
            TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
        tp.layout(maxWidth: getExtraNeededHorizontalSpace());
        x -= tp.width + leftTitles.margin;
        y -= tp.height / 2;
        tp.paint(canvas, Offset(x, y));

        verticalCounter++;
      }
    }

    // Right Titles
    final rightTitles = data.titlesData.rightTitles;
    if (rightTitles.showTitles) {
      int verticalCounter = 0;
      while (rightTitles.interval * verticalCounter <= data.maxY) {
        double x = drawSize.width + getLeftOffsetDrawSize();
        double y = getPixelY(data.gridData.verticalInterval * verticalCounter, drawSize) +
            getTopOffsetDrawSize();

        final String text = rightTitles.getTitles(data.gridData.verticalInterval * verticalCounter);

        final TextSpan span = TextSpan(style: rightTitles.textStyle, text: text);
        final TextPainter tp =
            TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
        tp.layout(maxWidth: getExtraNeededHorizontalSpace());
        x += rightTitles.margin;
        y -= tp.height / 2;
        tp.paint(canvas, Offset(x, y));

        verticalCounter++;
      }
    }

    // Bottom titles
    final bottomTitles = data.titlesData.bottomTitles;
    if (bottomTitles.showTitles) {
      for (int index = 0; index < groupBarsPosition.length; index++) {
        final GroupBarsPosition groupBarPos = groupBarsPosition[index];

        final String text = bottomTitles.getTitles(index.toDouble());

        final TextSpan span = TextSpan(style: bottomTitles.textStyle, text: text);
        final TextPainter tp =
            TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
        tp.layout();

        final double textX = groupBarPos.groupX - (tp.width / 2);
        final double textY = drawSize.height + getTopOffsetDrawSize() + bottomTitles.margin;

        tp.paint(canvas, Offset(textX, textY));
      }
    }
  }

  void drawTouchTooltip(Canvas canvas, Size viewSize,
    List<GroupBarsPosition> groupPositions, BarTouchTooltipData tooltipData,
    BarChartGroupData showOnBarGroup, int barGroupIndex,
    BarChartRodData showOnRodData, int barRodIndex,) {

    final Size chartUsableSize = getChartUsableDrawSize(viewSize);

    const double textsBelowMargin = 4;

    final BarTooltipItem tooltipItem = tooltipData.getTooltipItem(
      showOnBarGroup, barGroupIndex,
      showOnRodData, barRodIndex,
    );

    if (tooltipItem == null) {
      return;
    }

    final TextSpan span = TextSpan(style: tooltipItem.textStyle, text: tooltipItem.text);
    final TextPainter tp =
    TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.layout(maxWidth: tooltipData.maxContentWidth);

    /// creating TextPainters to calculate the width and height of the tooltip
    final TextPainter drawingTextPainter = tp;

    /// biggerWidth
    /// some texts maybe larger, then we should
    /// draw the tooltip' width as wide as biggerWidth
    ///
    /// sumTextsHeight
    /// sum up all Texts height, then we should
    /// draw the tooltip's height as tall as sumTextsHeight
    final double textWidth = drawingTextPainter.width;
    final double textHeight = drawingTextPainter.height + textsBelowMargin;

    /// if we have multiple bar lines,
    /// there are more than one FlCandidate on touch area,
    /// we should get the most top FlSpot Offset to draw the tooltip on top of it
    final Offset mostTopOffset = Offset(
      groupPositions[barGroupIndex].barsX[barRodIndex],
      getPixelY(showOnRodData.y, chartUsableSize),
    );

    final double tooltipWidth = textWidth + tooltipData.tooltipPadding.horizontal;
    final double tooltipHeight = textHeight + tooltipData.tooltipPadding.vertical;

    /// draw the background rect with rounded radius
    final Rect rect = Rect.fromLTWH(
      mostTopOffset.dx - (tooltipWidth / 2),
      mostTopOffset.dy - tooltipHeight - tooltipData.tooltipBottomMargin,
      tooltipWidth,
      tooltipHeight);
    final Radius radius = Radius.circular(tooltipData.tooltipRoundedRadius);
    final RRect roundedRect = RRect.fromRectAndCorners(rect,
      topLeft: radius, topRight: radius, bottomLeft: radius, bottomRight: radius);
    bgTouchTooltipPaint.color = tooltipData.tooltipBgColor;
    canvas.drawRRect(roundedRect, bgTouchTooltipPaint);

    /// draw the texts one by one in below of each other
    final double top = tooltipData.tooltipPadding.top;
    final drawOffset = Offset(
      rect.center.dx - (tp.width / 2),
      rect.topCenter.dy + top,
    );
    tp.paint(canvas, drawOffset);
  }

  /// We add our needed horizontal space to parent needed.
  /// we have some titles that maybe draw in the left and right side of our chart,
  /// then we should draw the chart a with some left space,
  /// the left space is [getLeftOffsetDrawSize],
  /// and the whole space is [getExtraNeededHorizontalSpace]
  @override
  double getExtraNeededHorizontalSpace() {
    double sum = super.getExtraNeededHorizontalSpace();
    if (data.titlesData.show) {
      final leftSide = data.titlesData.leftTitles;
      if (leftSide.showTitles) {
        sum += leftSide.reservedSize + leftSide.margin;
      }

      final rightSide = data.titlesData.rightTitles;
      if (rightSide.showTitles) {
        sum += rightSide.reservedSize + rightSide.margin;
      }
    }
    return sum;
  }

  /// We add our needed vertical space to parent needed.
  /// we have some titles that maybe draw in the top and bottom side of our chart,
  /// then we should draw the chart a with some top space,
  /// the top space is [getTopOffsetDrawSize()],
  /// and the whole space is [getExtraNeededVerticalSpace]
  @override
  double getExtraNeededVerticalSpace() {
    double sum = super.getExtraNeededVerticalSpace();
    if (data.titlesData.show) {
      final bottomSide = data.titlesData.bottomTitles;
      if (bottomSide.showTitles) {
        sum += bottomSide.reservedSize + bottomSide.margin;
      }
    }
    return sum;
  }

  /// calculate left offset for draw the chart,
  /// maybe we want to show both left and right titles,
  /// then just the left titles will effect on this function.
  @override
  double getLeftOffsetDrawSize() {
    var sum = super.getLeftOffsetDrawSize();

    final leftTitles = data.titlesData.leftTitles;
    if (data.titlesData.show && leftTitles.showTitles) {
      sum += leftTitles.reservedSize + leftTitles.margin;
    }

    return sum;
  }

  @override
  BarTouchResponse handleTouch(FlTouchInput touchInput, Size size) {
    final BarTouchedSpot touchedSpot = _getNearestTouchedSpot(size, touchInput.getOffset(), groupBarsPosition);
    return BarTouchResponse(touchedSpot, touchInput);
  }

  /// find the nearest spot base on the touched offset
  BarTouchedSpot _getNearestTouchedSpot(Size viewSize, Offset touchedPoint, List<GroupBarsPosition> groupBarsPosition) {
    final Size chartViewSize = getChartUsableDrawSize(viewSize);

    /// Find the nearest barRod
    for (int i = 0; i < groupBarsPosition.length; i++) {
      final GroupBarsPosition groupBarPos = groupBarsPosition[i];
      for (int j = 0; j < groupBarPos.barsX.length; j++) {
        final double barX = groupBarPos.barsX[j];
        final double barWidth = targetData.barGroups[i].barRods[j].width;
        final double halfBarWidth = barWidth / 2;
        final double barTopY = getPixelY(targetData.barGroups[i].barRods[j].y, chartViewSize);
        final double barBotY = getPixelY(0, chartViewSize);
        final double backDrawBarTopY =
            getPixelY(targetData.barGroups[i].barRods[j].backDrawRodData.y, chartViewSize);
        final EdgeInsets touchExtraThreshold = targetData.barTouchData.touchExtraThreshold;

        final bool isXInTouchBounds =
            (touchedPoint.dx <= barX + halfBarWidth + touchExtraThreshold.right) &&
                (touchedPoint.dx >= barX - halfBarWidth - touchExtraThreshold.left);

        final bool isYInBarBounds = (touchedPoint.dy <= barBotY + touchExtraThreshold.bottom) &&
            (touchedPoint.dy >= barTopY - touchExtraThreshold.top);

        final bool isYInBarBackDrawBounds =
            (touchedPoint.dy <= barBotY + touchExtraThreshold.bottom) &&
                (touchedPoint.dy >= backDrawBarTopY - touchExtraThreshold.top);

        final bool isYInTouchBounds =
            (targetData.barTouchData.allowTouchBarBackDraw && isYInBarBackDrawBounds) ||
                isYInBarBounds;

        if (isXInTouchBounds && isYInTouchBounds) {
          final nearestGroup = targetData.barGroups[i];
          final nearestBarRod = nearestGroup.barRods[j];
          final nearestSpot = FlSpot(nearestGroup.x.toDouble(), nearestBarRod.y);
          final nearestSpotPos = Offset(barX, getPixelY(nearestSpot.y, chartViewSize));

          return BarTouchedSpot(nearestGroup, i, nearestBarRod, j, nearestSpot, nearestSpotPos);
        }
      }
    }

    return null;
  }

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) => oldDelegate.data != data;
}

class GroupBarsPosition {
  final double groupX;
  final List<double> barsX;

  GroupBarsPosition(this.groupX, this.barsX);
}
