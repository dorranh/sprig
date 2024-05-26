// Create a stateless widget called `SprigUsage` that displays the usage of a Sprig.
import 'package:flutter/material.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

// FIXME: The content of this sample is currently incorrect
String pythonUsage(String? sprigName, String basketInfo) {
  return """
from sprig import Sprig, Basket

basket = Basket("foo")
sprig = basket.get("$sprigName")

print(sprig)
""";
}

String getCodeSample(String language, String? sprigName, String basketInfo) {
  if (language == "python") {
    return pythonUsage(sprigName, basketInfo);
  } else {
    // TODO: Use a better exception type here
    throw "Unsupported language: $language";
  }
}

class SprigUsage extends StatelessWidget {
  const SprigUsage(
      {super.key,
      this.sprigName,
      required this.basketInfo,
      required this.languageHighlighters});

  final String? sprigName;
  final String basketInfo;
  final Map<String, Highlighter> languageHighlighters;
  // TODO: Add support for various other languages, allowing this to be set dynamically
  final String language = "python";

  @override
  Widget build(BuildContext context) {
    if (languageHighlighters[language] == null) {
      return Text("Unsupported language: $language");
    }

    final highlighter = languageHighlighters[language]!;
    final codeSample = getCodeSample(language, sprigName, basketInfo);
    return Container(
        height: 200,
        width: double.infinity,
        child: Card(
            child: Container(
                child: Text.rich(highlighter.highlight(codeSample)))));
  }
}
