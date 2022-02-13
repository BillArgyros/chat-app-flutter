import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(229, 229, 229, 1),
      child: const Center(
        child: SpinKitChasingDots(
          color: Colors.blueAccent,
          size: 50.0,
        ),
      ),
    );
  }
}
