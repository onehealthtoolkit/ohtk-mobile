import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WaitingScreen extends StatelessWidget {
  const WaitingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xEE1D415A),
              Color(0xFF1A2431),
            ],
          ),
        ),
        child: Center(
          child: Lottie.asset('assets/animations/waiting.json',
              width: 180, height: 180),
        ),
      ),
    );
  }
}
