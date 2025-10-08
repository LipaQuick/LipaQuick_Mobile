import 'package:flutter/material.dart';

class BoxBorderCamera extends CustomPainter {
  Color color;
  BoxBorderCamera({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    double lineSize = 90;
    Path path = Path();

    double startPointX = 0;
    double startPointY = 0;
    path.moveTo(startPointX, startPointY);
    path.lineTo(lineSize, 0);
    path.moveTo(startPointX, startPointY);
    path.lineTo(0, lineSize);
    canvas.drawPath(path, paint);
    //new startpoint
    path = Path();

    startPointX = size.width;
    startPointY = 0;
    path.moveTo(startPointX, startPointY);
    path.lineTo(startPointX, lineSize);
    startPointX = startPointX - lineSize;
    path.moveTo(startPointX, startPointY);
    path.lineTo(size.width, startPointY);
    canvas.drawPath(path, paint);

    path = Path();

    startPointX = 0;
    startPointY = size.height;
    path.moveTo(startPointX, startPointY);
    path.lineTo(lineSize, startPointY);

    startPointY = startPointY - lineSize;
    path.moveTo(startPointX, startPointY);
    path.lineTo(startPointX, size.height);
    canvas.drawPath(path, paint);


    path = Path();

    startPointX = size.width;
    startPointY = size.height;
    startPointX = startPointX - lineSize;
    path.moveTo(startPointX, startPointY);
    path.lineTo(size.width, size.height);

    startPointX = size.width;
    startPointY = startPointY - lineSize;
    path.moveTo(startPointX, startPointY);
    path.lineTo(startPointX, size.height);

    canvas.drawPath(path, paint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}