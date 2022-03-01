import 'package:flutter/material.dart';



//this class creates custom boxes to be filled 

class Chevron extends CustomPainter {

  var screenWidth;
  var screenHeight;

  Chevron({ required this.screenWidth , required this.screenHeight});

  @override
  void paint(Canvas canvas, Size size) {

    final Paint paint = Paint()
      ..color = const Color.fromARGB(253, 170, 5, 19);

    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, screenHeight/2);
    path.lineTo(screenWidth , screenHeight/3.5);
    path.lineTo(screenWidth, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}