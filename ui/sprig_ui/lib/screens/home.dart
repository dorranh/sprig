import 'package:flutter/material.dart';
import 'package:sprig_ui/widgets/basket.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

class SprigUI extends StatelessWidget {
  final Map<String, Highlighter> languageHighlighters;

  const SprigUI({super.key, required this.languageHighlighters});

  @override
  Widget build(BuildContext context) {
    var colorScheme =
        ColorScheme.fromSeed(seedColor: const Color.fromRGBO(129, 199, 132, 1));
    return MaterialApp(
        title: 'Sprig',
        theme: ThemeData(
          colorScheme: colorScheme,
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: colorScheme.inversePrimary,
            title: Row(children: <Widget>[
              Icon(Icons.data_exploration),
              Text('Sprig'),
            ]),
          ),
          body: BasketUI(languageHighlighters: languageHighlighters),
        ));
  }
}
