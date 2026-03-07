import 'package:flutter/material.dart';

/// HamroGharSewa Logo Widget - Custom House Design
class HamroLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? primaryColor;
  final Color? accentColor;

  const HamroLogo({
    Key? key,
    this.size = 80,
    this.showText = false,
    this.primaryColor,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = primaryColor ?? const Color(0xFF00BFA5); // Teal
    final accent = accentColor ?? const Color(0xFFFF9800); // Orange

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo icon
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF1A3A3A),
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.3),
                blurRadius: size * 0.3,
                spreadRadius: size * 0.05,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _HouseLogoPainter(
              houseColor: primary,
              doorColor: accent,
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.15),
          Text(
            'HamroGharSewa',
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
              color: primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom painter for the house logo
class _HouseLogoPainter extends CustomPainter {
  final Color houseColor;
  final Color doorColor;

  _HouseLogoPainter({
    required this.houseColor,
    required this.doorColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final houseSize = size.width * 0.5;

    // Draw house outline (teal)
    paint.color = houseColor;

    // Roof
    final roofPath = Path();
    roofPath.moveTo(center.dx - houseSize * 0.6, center.dy - houseSize * 0.1);
    roofPath.lineTo(center.dx, center.dy - houseSize * 0.7);
    roofPath.lineTo(center.dx + houseSize * 0.6, center.dy - houseSize * 0.1);
    canvas.drawPath(roofPath, paint);

    // Chimney
    final chimneyPath = Path();
    chimneyPath.moveTo(center.dx + houseSize * 0.25, center.dy - houseSize * 0.45);
    chimneyPath.lineTo(center.dx + houseSize * 0.25, center.dy - houseSize * 0.6);
    chimneyPath.lineTo(center.dx + houseSize * 0.35, center.dy - houseSize * 0.6);
    chimneyPath.lineTo(center.dx + houseSize * 0.35, center.dy - houseSize * 0.35);
    canvas.drawPath(chimneyPath, paint);

    // House body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + houseSize * 0.25),
        width: houseSize * 1.2,
        height: houseSize * 0.7,
      ),
      Radius.circular(size.width * 0.02),
    );
    canvas.drawRRect(bodyRect, paint);

    // Window
    final windowRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx - houseSize * 0.35, center.dy + houseSize * 0.15),
        width: houseSize * 0.25,
        height: houseSize * 0.25,
      ),
      Radius.circular(size.width * 0.01),
    );
    canvas.drawRRect(windowRect, paint);

    // Door (orange, filled)
    final doorPaint = Paint()
      ..color = doorColor
      ..style = PaintingStyle.fill;

    final doorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx + houseSize * 0.2, center.dy + houseSize * 0.35),
        width: houseSize * 0.35,
        height: houseSize * 0.5,
      ),
      Radius.circular(size.width * 0.02),
    );
    canvas.drawRRect(doorRect, doorPaint);
  }

  @override
  bool shouldRepaint(_HouseLogoPainter oldDelegate) => false;
}

/// Circular logo variant
class HamroLogoCircular extends StatelessWidget {
  final double size;
  final Color? primaryColor;
  final Color? accentColor;

  const HamroLogoCircular({
    Key? key,
    this.size = 80,
    this.primaryColor,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = primaryColor ?? const Color(0xFF00BFA5); // Teal
    final accent = accentColor ?? const Color(0xFFFF9800); // Orange

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A3A),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.4),
            blurRadius: size * 0.3,
            spreadRadius: size * 0.05,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _HouseLogoPainter(
          houseColor: primary,
          doorColor: accent,
        ),
      ),
    );
  }
}

/// Minimal logo variant (just icon, no decoration)
class HamroLogoMinimal extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? houseColor;
  final Color? doorColor;

  const HamroLogoMinimal({
    Key? key,
    this.size = 40,
    this.backgroundColor,
    this.houseColor,
    this.doorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF1A3A3A),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: CustomPaint(
        painter: _HouseLogoPainter(
          houseColor: houseColor ?? const Color(0xFF00BFA5),
          doorColor: doorColor ?? const Color(0xFFFF9800),
        ),
      ),
    );
  }
}
