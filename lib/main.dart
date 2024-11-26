import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as mr_baer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MainApp(prefs: prefs));
}

class MainApp extends StatefulWidget {
  final SharedPreferences prefs;

  const MainApp({super.key, required this.prefs});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String quote = '';
  String author = '';
  String translatedQuote = '';
  String translatedAuthor = '';
  String selectedCategory = 'humor';
  List<String> categories = [
    'humor',
    'car',
    'computer',
    'funny',
    'money',
    'dating'
  ];
  final translator = GoogleTranslator();
  String targetLanguage = 'de';

  @override
  void initState() {
    super.initState();
    _loadQuoteFromPrefs();
    fetchQuoteForCategory(selectedCategory);
  }

  Future<void> _loadQuoteFromPrefs() async {
    final savedQuote = widget.prefs.getString('quote');
    final savedAuthor = widget.prefs.getString('author');
    if (savedQuote != null && savedAuthor != null) {
      setState(() {
        quote = savedQuote;
        author = savedAuthor;
      });
      _translateQuoteAndAuthor();
    } else {
      fetchQuoteForCategory(selectedCategory);
    }
  }

  // Fetch a quote from the API
  Future<void> fetchQuoteForCategory(String category) async {
    final response = await mr_baer.get(
      Uri.parse('https://api.api-ninjas.com/v1/quotes?category=$category'),
      headers: {'X-Api-Key': 'Fg1eV7NHdzj3Wp/VQx5AfQ==7coi7tcvw0zADpLu'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)[0];
      setState(() {
        quote = data['quote'];
        author = data['author'];
        _saveQuoteToPrefs(quote, author);
      });
      _translateQuoteAndAuthor();
    } else {
      if (kDebugMode) {
        print('Anforderung fehlgeschlagen mit Status: ${response.statusCode}.');
      }
    }
  }

  Future<void> _saveQuoteToPrefs(String quote, String author) async {
    await widget.prefs.setString('quote', quote);
    await widget.prefs.setString('author', author);
  }

  Future<void> _clearQuote() async {
    await widget.prefs.remove('quote');
    await widget.prefs.remove('author');
    setState(() {
      quote = '';
      author = '';
      translatedQuote = '';
      translatedAuthor = '';
    });
  }

  Future<void> _translateQuoteAndAuthor() async {
    try {
      final translationQuote =
          await translator.translate(quote, to: targetLanguage);
      final translationAuthor =
          await translator.translate(author, to: targetLanguage);
      setState(() {
        translatedQuote = translationQuote.text;
        translatedAuthor = translationAuthor.text;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Translation failed: $e');
      }
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
                  translatedQuote.isNotEmpty ? translatedQuote : quote,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 16),
                Text(
                  '- ${translatedAuthor.isNotEmpty ? translatedAuthor : author}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => fetchQuoteForCategory(selectedCategory),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shadowColor: const Color.fromARGB(255, 137, 187, 212),
                  ),
                  child: const Text(
                    'Neues Zitat',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _clearQuote,
                  child: const Text('Zitat löschen'),
                ),
                DropdownButton<String>(
                  value: selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                      fetchQuoteForCategory(
                          selectedCategory); // Fetch new category
                    });
                  },
                  items: categories.toSet().map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
