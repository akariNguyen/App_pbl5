import 'dart:math' as math;
import 'package:flutter/material.dart';

class DonutChartData {
  final String label;
  final double value;
  final Color color;

  const DonutChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class DonutChartPainter extends CustomPainter {
  final List<DonutChartData> data;
  final double animationValue;
  final double strokeWidth;

  DonutChartPainter({
    required this.data,
    required this.animationValue,
    this.strokeWidth = 32,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final total = data.fold<double>(0, (sum, d) => sum + d.value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    for (final segment in data) {
      final sweepAngle = (segment.value / total) * 2 * math.pi * animationValue;
      paint.color = segment.color;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    // Center text
    final textPainter = TextPainter(
      text: TextSpan(
        text: total.toInt().toString(),
        style: TextStyle(
          color: data.first.color.withOpacity(0.9),
          fontSize: radius * 0.45,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2 + 8),
    );

    final labelPainter = TextPainter(
      text: const TextSpan(
        text: 'lần scan',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 11,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(
      canvas,
      center - Offset(labelPainter.width / 2, -12),
    );
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.data != data;
}

class DonutChart extends StatefulWidget {
  final List<DonutChartData> data;
  final double size;
  final double strokeWidth;

  const DonutChart({
    super.key,
    required this.data,
    this.size = 180,
    this.strokeWidth = 32,
  });

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(DonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
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
        size: Size(widget.size, widget.size),
        painter: DonutChartPainter(
          data: widget.data,
          animationValue: _animation.value,
          strokeWidth: widget.strokeWidth,
        ),
      ),
    );
  }
}
