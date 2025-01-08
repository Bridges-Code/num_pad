import 'package:flutter/material.dart';
import 'package:num_pad/num_pad.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: NumPadButton(),
        ),
      ),
    );
  }
}

class NumPadButton extends StatelessWidget {
  const NumPadButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          // Show Num Pad
          final result = await showNumPad(context);
          print(result);
        },
        child: Text('Show Num Pad'));
  }
}
