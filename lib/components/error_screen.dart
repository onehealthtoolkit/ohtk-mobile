import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String error;
  const ErrorScreen(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SizedBox(
            height: 400,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/error_icon.png',
                  width: 200,
                ),
                Text(error, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
