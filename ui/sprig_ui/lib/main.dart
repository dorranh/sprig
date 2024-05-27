import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprig_ui/screens/home.dart';
import 'package:sprig_ui/utils/settings.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

final SUPPORTED_LANGUAGES = ["python"];

/// Initializes syntax highlighters for all supported languages.
Future<Map<String, Highlighter>> initHighlighters() async {
  var theme = await HighlighterTheme.loadLightTheme();
  Map<String, Highlighter> languageHighlighters = {};
  // TODO: Add error handling here
  for (var language in SUPPORTED_LANGUAGES) {
    // Read in grammar specs included in our repo
    var json = await rootBundle.loadString('grammars/$language.json');
    Highlighter.addLanguage(language, json);
    languageHighlighters[language] = Highlighter(
      language: language,
      theme: theme,
    );
  }
  return languageHighlighters;
}

void main() async {
  // Required before calling async code
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize highlighter instances for each language
  var highlighters = await initHighlighters();
  runApp(SprigUI(
    languageHighlighters: highlighters,
  ));
}
