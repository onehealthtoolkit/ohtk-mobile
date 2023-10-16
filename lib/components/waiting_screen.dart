import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WaitingScreen extends StatefulWidget {
  final StreamController<String> progressStream;
  const WaitingScreen(this.progressStream, {Key? key}) : super(key: key);

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  final List<String> _progress = ['init app'];
  late StreamSubscription? _progressStreamSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.progressStream.hasListener) {
      return;
    }

    try {
      _progressStreamSubscription =
          widget.progressStream.stream.listen((event) {
        _progress.add(event);
        setState(() {});
      });
    } catch (e) {
      _progressStreamSubscription = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_progressStreamSubscription != null) {
      _progressStreamSubscription!.cancel();
    }
  }

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
          child: SizedBox(
            height: 300,
            child: Column(
              children: [
                Lottie.asset(
                  'assets/animations/waiting.json',
                  width: 180,
                  height: 180,
                ),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      _progress.join('\n'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
