import 'package:flutter/material.dart';
import 'package:sprig_ui/widgets/basket.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

class SprigUI extends StatelessWidget {
  final Map<String, Highlighter> languageHighlighters;

  const SprigUI({super.key, required this.languageHighlighters});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sprig',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Sprig'),
          ),
          body: BasketUI(languageHighlighters: languageHighlighters),
        ));
  }
}
