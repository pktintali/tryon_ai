import 'package:flutter/material.dart';

class ScannerAnimation extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;

  const ScannerAnimation({
    super.key,
    required this.child,
    required this.width,
    required this.height,
  });

  @override
  State<ScannerAnimation> createState() => _ScannerAnimationState();
}

class _ScannerAnimationState extends State<ScannerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        // The main content (product image)
        widget.child,

        // Scanning effect overlay
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ScannerPainter(
                    scannerPosition: _animation.value,
                    primaryColor: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class ScannerPainter extends CustomPainter {
  final double scannerPosition;
  final Color primaryColor;

  ScannerPainter({
    required this.scannerPosition,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Add a semi-transparent overlay over the entire image
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, overlayPaint);

    // Calculate scanner line position
    final scannerY = size.height * scannerPosition;

    // Draw scanner line
    final scannerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          primaryColor,
          primaryColor,
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, scannerY - 1, size.width, 2));

    canvas.drawRect(
      Rect.fromLTWH(0, scannerY - 1, size.width, 2),
      scannerPaint,
    );

    // Draw glow effect around scanner line
    final glowPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawRect(
      Rect.fromLTWH(0, scannerY - 1, size.width, 2),
      glowPaint,
    );

    // Draw highlight area around scanner line
    final highlightHeight = size.height * 0.15;
    final highlightRect = Rect.fromLTWH(
      0,
      scannerY - highlightHeight / 2,
      size.width,
      highlightHeight,
    );

    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          primaryColor.withOpacity(0.15),
          primaryColor.withOpacity(0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(highlightRect);

    canvas.drawRect(highlightRect, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant ScannerPainter oldDelegate) {
    return scannerPosition != oldDelegate.scannerPosition;
  }
}
