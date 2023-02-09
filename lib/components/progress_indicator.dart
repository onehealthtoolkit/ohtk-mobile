import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OhtkProgressIndicator extends StatelessWidget {
  const OhtkProgressIndicator({Key? key, this.size = 180}) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset('assets/animations/waiting.json',
        width: size, height: size);
  }
}
