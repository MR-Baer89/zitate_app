import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String quote = '';
  String author = '';

  Future<void> fetchQuote() async {
    final response = await http.get(
        Uri.parse('https://api.api-ninjas.com/v1/quotes'),
        headers: {'X-Api-Key': 'Fg1eV7NHdzj3Wp/VQx5AfQ==7coi7tcvw0zADpLu'});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)[0];
      setState(() {
        quote = data['quote'];
        author = data['author'];
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 200, 199, 199),
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          title: const Text(
            'Zitat App',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 32,
                fontFamily: '.SF UI Display'),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  quote,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 16),
                Text(
                  '- $author',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: fetchQuote,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      shadowColor: const Color.fromARGB(255, 137, 187, 212)),
                  child: const Text(
                    'Neues Zitat',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
