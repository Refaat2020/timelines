import 'dart:math';

import 'package:flutter/material.dart';

class DashedLinePainter extends CustomPainter {
  const DashedLinePainter({
    required this.direction,
    required this.color,
    required this.gapColor,
    this.dashSize = 4.0,
    this.gapSize = 4.0,
    this.strokeWidth = 2.0,
    this.strokeCap = StrokeCap.square,
  })  : assert(dashSize > 0),
        assert(gapSize >= 0),
        assert(strokeWidth >= 0);

  final Axis direction;
  final Color color;
  final Color gapColor;
  final double dashSize;
  final double gapSize;
  final double strokeWidth;
  final StrokeCap strokeCap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap
      ..style = PaintingStyle.stroke;

    double startX = direction == Axis.horizontal ? 0 : size.width / 2;
    double startY = direction == Axis.vertical ? 0 : size.height / 2;
    final maxLength = direction == Axis.horizontal ? size.width : size.height;

    while ((direction == Axis.horizontal ? startX : startY) < maxLength) {
      paint.color = color; // Paint dash with primary color
      final dashEndX =
          direction == Axis.horizontal ? startX + dashSize : startX;
      final dashEndY = direction == Axis.vertical ? startY + dashSize : startY;

      if ((direction == Axis.horizontal ? dashEndX : dashEndY) > maxLength)
        break;
      canvas.drawLine(
          Offset(startX, startY), Offset(dashEndX, dashEndY), paint);

      startX = dashEndX;
      startY = dashEndY;

      paint.color = gapColor; // Paint gap with secondary color
      final gapEndX = direction == Axis.horizontal ? startX + gapSize : startX;
      final gapEndY = direction == Axis.vertical ? startY + gapSize : startY;

      if ((direction == Axis.horizontal ? gapEndX : gapEndY) > maxLength) break;
      canvas.drawLine(Offset(startX, startY), Offset(gapEndX, gapEndY), paint);

      startX = gapEndX;
      startY = gapEndY;
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) {
    return direction != oldDelegate.direction ||
        color != oldDelegate.color ||
        gapColor != oldDelegate.gapColor ||
        dashSize != oldDelegate.dashSize ||
        gapSize != oldDelegate.gapSize ||
        strokeWidth != oldDelegate.strokeWidth ||
        strokeCap != oldDelegate.strokeCap;
  }
}

class SplitLinePainter extends CustomPainter {
  const SplitLinePainter({
    required this.direction,
    required this.color1,
    required this.color2,
    this.strokeWidth = 4.0,
  }) : assert(strokeWidth >= 0);

  final Axis direction;
  final Color color1;
  final Color color2;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Calculate the midpoint of the line
    final halfLength =
        direction == Axis.vertical ? size.height / 2 : size.width / 2;

    // Draw the first segment in color1
    paint.color = color1;
    if (direction == Axis.vertical) {
      canvas.drawLine(
          Offset(size.width / 2, 0), Offset(size.width / 2, halfLength), paint);
    } else {
      canvas.drawLine(Offset(0, size.height / 2),
          Offset(halfLength, size.height / 2), paint);
    }

    // Draw the second segment in color2
    paint.color = color2;
    if (direction == Axis.vertical) {
      canvas.drawLine(Offset(size.width / 2, halfLength),
          Offset(size.width / 2, size.height), paint);
    } else {
      canvas.drawLine(Offset(halfLength, size.height / 2),
          Offset(size.width, size.height / 2), paint);
    }
  }

  @override
  bool shouldRepaint(SplitLinePainter oldDelegate) {
    return direction != oldDelegate.direction ||
        color1 != oldDelegate.color1 ||
        color2 != oldDelegate.color2 ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}

class SplitDashedLinePainter extends CustomPainter {
  const SplitDashedLinePainter({
    required this.direction,
    required this.color1,
    required this.color2,
    this.dashSize = 5.0,
    this.gapSize = 3.0,
    this.strokeWidth = 4.0,
  });

  final Axis direction;
  final Color color1;
  final Color color2;
  final double dashSize;
  final double gapSize;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Calculate the total length in the specified direction
    final totalLength = direction == Axis.vertical ? size.height : size.width;
    final halfLength = totalLength / 2;

    double currentOffset = 0.0;

    while (currentOffset < totalLength) {
      // Switch color depending on the current position
      paint.color = currentOffset < halfLength ? color1 : color2;

      // Calculate end of dash to ensure it doesn't overflow the total length
      final dashEnd = currentOffset + dashSize;
      final drawEnd = dashEnd < totalLength ? dashEnd : totalLength;

      // Draw the dash segment
      if (direction == Axis.vertical) {
        canvas.drawLine(
          Offset(size.width / 2, currentOffset),
          Offset(size.width / 2, drawEnd),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(currentOffset, size.height / 2),
          Offset(drawEnd, size.height / 2),
          paint,
        );
      }

      // Update the offset for the next dash segment
      currentOffset = drawEnd + gapSize;
    }
  }

  @override
  bool shouldRepaint(SplitDashedLinePainter oldDelegate) {
    return direction != oldDelegate.direction ||
        color1 != oldDelegate.color1 ||
        color2 != oldDelegate.color2 ||
        dashSize != oldDelegate.dashSize ||
        gapSize != oldDelegate.gapSize ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}

class _DashOffset extends Offset {
  factory _DashOffset({
    required Size containerSize,
    required double strokeWidth,
    required double dashSize,
    required double gapSize,
    required Axis axis,
  }) {
    return _DashOffset._(
      dx: axis == Axis.vertical ? containerSize.width / 2 : 0,
      dy: axis == Axis.vertical ? 0 : containerSize.height / 2,
      strokeWidth: strokeWidth,
      containerSize: containerSize,
      dashSize: dashSize,
      gapSize: gapSize,
      axis: axis,
    );
  }

  const _DashOffset._({
    required double dx,
    required double dy,
    required this.strokeWidth,
    required this.containerSize,
    required this.dashSize,
    required this.gapSize,
    required this.axis,
  }) : super(dx, dy);

  final Size containerSize;
  final double strokeWidth;
  final double dashSize;
  final double gapSize;
  final Axis axis;

  double get offset {
    if (axis == Axis.vertical) {
      return dy;
    } else {
      return dx;
    }
  }

  bool get hasNext {
    if (axis == Axis.vertical) {
      return offset < containerSize.height;
    } else {
      return offset < containerSize.width;
    }
  }

  _DashOffset translateDashSize() {
    return _translateDirectionally(dashSize);
  }

  _DashOffset translateGapSize() {
    return _translateDirectionally(gapSize + strokeWidth);
  }

  _DashOffset _translateDirectionally(double offset) {
    if (axis == Axis.vertical) {
      return translate(0, offset) as _DashOffset;
    } else {
      return translate(offset, 0) as _DashOffset;
    }
  }

  @override
  Offset translate(double translateX, double translateY) {
    double dx, dy;
    if (axis == Axis.vertical) {
      dx = this.dx;
      dy = this.dy + translateY;
    } else {
      dx = this.dx + translateX;
      dy = this.dy;
    }
    return copyWith(
      dx: min(dx, containerSize.width),
      dy: min(dy, containerSize.height),
    );
  }

  _DashOffset copyWith({
    double? dx,
    double? dy,
    Size? containerSize,
    double? strokeWidth,
    double? dashSize,
    double? gapSize,
    Axis? axis,
  }) {
    return _DashOffset._(
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      containerSize: containerSize ?? this.containerSize,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      dashSize: dashSize ?? this.dashSize,
      gapSize: gapSize ?? this.gapSize,
      axis: axis ?? this.axis,
    );
  }
}
