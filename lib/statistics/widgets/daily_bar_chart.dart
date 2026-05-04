import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/statistics_data.dart';

class BarChartPainter extends CustomPainter {
  final List<DailyScanPoint> points;
  final double animationValue;
  final Color barColor;
  final Color barColorEnd;
  final Color textColor;
  final Color gridColor;
  final DateRangeMode mode;

  BarChartPainter({
    required this.points,
    required this.animationValue,
    required this.barColor,
    required this.barColorEnd,
    required this.textColor,
    required this.gridColor,
    this.mode = DateRangeMode.month,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxCount = points.fold<int>(0, (m, p) => math.max(m, p.count));
    if (maxCount == 0) return;

    const labelHeight = 28.0;
    const topPad = 16.0;
    const leftPad = 36.0;
    final chartH = size.height - labelHeight - topPad;
    final chartW = size.width - leftPad;

    // Grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    const gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      final y = topPad + chartH - (chartH / gridLines) * i;
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);

      // Y axis label
      final val = ((maxCount / gridLines) * i).round();
      final tp = TextPainter(
        text: TextSpan(
          text: val.toString(),
          style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Determine which points to show labels for (avoid crowding)
    final n = points.length;
    int labelStep = 1;
    if (n > 60) labelStep = 14;
    else if (n > 30) labelStep = 7;
    else if (n > 14) labelStep = 3;
    else if (n > 7) labelStep = 2;

    final barW = (chartW / n) * 0.65;
    final gapW = chartW / n;

    for (int i = 0; i < n; i++) {
      final point = points[i];
      final x = leftPad + gapW * i + gapW / 2;
      final barH = (point.count / maxCount) * chartH * animationValue;
      final top = topPad + chartH - barH;

      if (point.count > 0) {
        // Gradient bar
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x - barW / 2, top, barW, barH),
          const Radius.circular(4),
        );
        final paint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [barColor, barColorEnd],
          ).createShader(Rect.fromLTWH(x - barW / 2, top, barW, barH));
        canvas.drawRRect(rect, paint);
      }

      // X label
      if (i % labelStep == 0) {
        final dt = point.date;
        final label = '${dt.day}/${dt.month}';
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(color: textColor.withOpacity(0.55), fontSize: 9),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(x - tp.width / 2, size.height - labelHeight + 6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(BarChartPainter old) =>
      old.animationValue != animationValue || old.points != points;
}

enum DateRangeMode { week, month, quarter, all, custom }

class DailyBarChart extends StatefulWidget {
  final List<DailyScanPoint> points;
  final Color barColor;
  final Color barColorEnd;
  final Color textColor;
  final Color gridColor;

  const DailyBarChart({
    super.key,
    required this.points,
    required this.barColor,
    required this.barColorEnd,
    required this.textColor,
    required this.gridColor,
  });

  @override
  State<DailyBarChart> createState() => _DailyBarChartState();
}

class _DailyBarChartState extends State<DailyBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(DailyBarChart old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => CustomPaint(
        size: const Size(double.infinity, 180),
        painter: BarChartPainter(
          points: widget.points,
          animationValue: _animation.value,
          barColor: widget.barColor,
          barColorEnd: widget.barColorEnd,
          textColor: widget.textColor,
          gridColor: widget.gridColor,
        ),
      ),
    );
  }
}
