import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:num_pad/num_pad.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              final result = await showNumPad(context,
                  hintText: 'Enter a number',
                  withNegative: false,
                  withDot: false,
                  maxLength: 8);
              print(result);
            },
            child: const Text('Show Num Pad')),
      ),
    );
  }
}

class ShadMainApp extends StatelessWidget {
  const ShadMainApp({super.key});

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
      themeMode: ThemeMode.light,
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
          // final result = await showNumPad(context, maxLength: 5);
          // print(result);
        },
        child: Text('Show Num Pad'));
  }
}
