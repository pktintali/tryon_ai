import 'package:flutter/material.dart';

class EmojiPainters extends CustomPainter {
  const EmojiPainters({required this.mouthPainter});
  final void Function(Canvas canvas, Size size) mouthPainter;
  @override
  void paint(Canvas canvas, Size size) {
    final leftEye = Offset(size.width * .25, size.height * .4);
    canvas.drawCircle(leftEye, 2, Paint());

    final rightEye = Offset(size.width - (size.width * .25), size.height * .4);
    canvas.drawCircle(rightEye, 2, Paint());
    // void function to draw the mouth of the emojis
    mouthPainter(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

final mouthPainters = [
  firstMouthPainters,
  secondMouthPainter,
  thirdMouthPainters,
  fourthMouthPainter,
  fifthMouthPainter,
];

void firstMouthPainters(Canvas canvas, Size size) {
  final mouthPath = Path()
    ..moveTo(size.width * .25, size.height * .7)
    ..quadraticBezierTo(size.width * .5, size.height * .4,
        size.width - (size.width * .25), size.height * .7)
    ..close();
  canvas.drawPath(
    mouthPath,
    Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round,
  );
}

void secondMouthPainter(Canvas canvas, Size size) {
  final mouthPath = Path()
    ..moveTo(size.width * .25, size.height * .7)
    ..quadraticBezierTo(size.width * .5, size.height * .5,
        size.width - (size.width * .25), size.height * .7);

  canvas.drawPath(
    mouthPath,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2,
  );
}

void thirdMouthPainters(Canvas canvas, Size size) {
  canvas.drawLine(
    Offset(size.width * .25, size.height * .7),
    Offset(size.width - (size.width * .25), size.height * .7),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2,
  );
}

void fourthMouthPainter(Canvas canvas, Size size) {
  final mouthPath = Path()
    ..moveTo(size.width * .25, size.height * .6)
    ..quadraticBezierTo(size.width * .5, size.height * .9,
        size.width - (size.width * .25), size.height * .6);

  canvas.drawPath(
    mouthPath,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2,
  );
}

void fifthMouthPainter(Canvas canvas, Size size) {
  final mouthPath = Path()
    ..moveTo(size.width * .25, size.height * .65)
    ..quadraticBezierTo(size.width * .5, size.height * .9,
        size.width - (size.width * .25), size.height * .65)
    ..close();
  canvas.drawPath(
    mouthPath,
    Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round,
  );
}
