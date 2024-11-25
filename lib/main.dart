import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Zitat App'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TextField(),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                    onPressed: () {}, child: const Text('Neues Zitat'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
