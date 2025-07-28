import 'package:flutter/material.dart';
import 'dart:math' as math;

class ChartWidget extends StatefulWidget {
  final String title;
  final List<double> data;
  final Color color;
  final String unit;
  final double? minValue;
  final double? maxValue;

  const ChartWidget({
    Key? key,
    required this.title,
    required this.data,
    required this.color,
    this.unit = '',
    this.minValue,
    this.maxValue,
  }) : super(key: key);

  @override
  _ChartWidgetState createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 16),
          _buildChart(),
          SizedBox(height: 12),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${widget.data.length} data points',
            style: TextStyle(
              fontSize: 12,
              color: widget.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    if (widget.data.isEmpty) {
      return _buildEmptyChart();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 120,
          child: CustomPaint(
            painter: ChartPainter(
              data: widget.data,
              color: widget.color,
              animationProgress: _animation.value,
              minValue: widget.minValue,
              maxValue: widget.maxValue,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              color: Colors.grey[400],
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'Tidak ada data',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    if (widget.data.isEmpty) return SizedBox.shrink();

    double currentValue = widget.data.last;
    double previousValue = widget.data.length > 1
        ? widget.data[widget.data.length - 2]
        : currentValue;
    double change = currentValue - previousValue;
    bool isIncreasing = change > 0;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Text(
          'Nilai saat ini: ${currentValue.toStringAsFixed(1)}${widget.unit}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Spacer(),
        if (change != 0) ...[
          Icon(
            isIncreasing ? Icons.trending_up : Icons.trending_down,
            color: isIncreasing ? Colors.green : Colors.red,
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 12,
              color: isIncreasing ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double animationProgress;
  final double? minValue;
  final double? maxValue;

  ChartPainter({
    required this.data,
    required this.color,
    required this.animationProgress,
    this.minValue,
    this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || animationProgress == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    // Calculate min and max values
    double dataMin = minValue ?? data.reduce(math.min);
    double dataMax = maxValue ?? data.reduce(math.max);
    double range = dataMax - dataMin;

    if (range == 0) range = 1; // Avoid division by zero

    // Draw grid lines
    _drawGrid(canvas, size, gridPaint);

    // Create path for line chart
    final path = Path();
    final fillPath = Path();

    List<Offset> points = [];

    for (int i = 0; i < data.length; i++) {
      final double x = (i / (data.length - 1)) * size.width;
      final double normalizedY = (data[i] - dataMin) / range;
      final double y = size.height - (normalizedY * size.height);

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Close fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Apply animation by clipping
    final animatedWidth = size.width * animationProgress;
    canvas.clipRect(Rect.fromLTWH(0, 0, animatedWidth, size.height));

    // Draw fill area
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(path, paint);

    // Draw points
    for (int i = 0; i < points.length; i++) {
      if (points[i].dx <= animatedWidth) {
        // Draw outer circle (white background)
        canvas.drawCircle(
          points[i],
          5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
        // Draw inner circle (colored)
        canvas.drawCircle(points[i], 3, pointPaint);

        // Draw value label for last point
        if (i == points.length - 1 && animationProgress > 0.8) {
          _drawValueLabel(canvas, points[i], data[i]);
        }
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size, Paint gridPaint) {
    // Draw horizontal grid lines
    for (int i = 1; i < 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw vertical grid lines
    for (int i = 1; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  void _drawValueLabel(Canvas canvas, Offset point, double value) {
    final textSpan = TextSpan(
      text: value.toStringAsFixed(1),
      style: TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final labelWidth = textPainter.width + 8;
    final labelHeight = textPainter.height + 4;

    // Draw label background
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(point.dx, point.dy - 20),
        width: labelWidth,
        height: labelHeight,
      ),
      Radius.circular(4),
    );

    canvas.drawRRect(
      labelRect,
      Paint()..color = color,
    );

    // Draw text
    textPainter.paint(
      canvas,
      Offset(
        point.dx - textPainter.width / 2,
        point.dy - 20 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color;
  }
}

// Mini chart widget untuk preview
class MiniChartWidget extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double height;

  const MiniChartWidget({
    Key? key,
    required this.data,
    required this.color,
    this.height = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: CustomPaint(
        painter: MiniChartPainter(data: data, color: color),
        size: Size.infinite,
      ),
    );
  }
}

class MiniChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  MiniChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    final double minValue = data.reduce(math.min);
    final double maxValue = data.reduce(math.max);
    final double range = maxValue - minValue == 0 ? 1 : maxValue - minValue;

    for (int i = 0; i < data.length; i++) {
      final double x = (i / (data.length - 1)) * size.width;
      final double normalizedY = (data[i] - minValue) / range;
      final double y = size.height - (normalizedY * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MiniChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}
