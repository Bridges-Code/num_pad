import 'package:flutter/material.dart';
import 'package:num_pad/num_pad.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.material(
      theme: ShadThemeData(
          brightness: Brightness.light,
          colorScheme: ShadColorScheme.fromName('neutral')),
      darkTheme: ShadThemeData(
          brightness: Brightness.dark,
          colorScheme:
              ShadColorScheme.fromName('neutral', brightness: Brightness.dark)),
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
    return ShadButton(
        onPressed: () async {
          // Show Num Pad
          final result = await showNumPad(context);
          print(result);
        },
        child: Text('Show Num Pad'));
  }
}
