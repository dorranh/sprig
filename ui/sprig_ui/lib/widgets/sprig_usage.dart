// Create a stateless widget called `SprigUsage` that displays the usage of a Sprig.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

// FIXME: The content of this sample is currently incorrect
String pythonUsage(String? sprigName, String basketInfo) {
  return """
from sprig.client.basket import LocalBasket

# Create a client for interacting with this basket
basket = Basket("$basketInfo")

# Get a reference to the sprig
sprig = basket.get("$sprigName")

# Now we can read its data to consume in our analysis code,
# for example, as a pandas DataFrame:
df = basket.read_sprig("$sprigName").to_pandas()

print(df.head())
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
        width: double.infinity,
        child: Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                    child: Stack(children: <Widget>[
                  Text.rich(highlighter.highlight(codeSample)),
                  // Your Floating Menu
                  Positioned(
                    right: 10.0,
                    top: 10.0,
                    child: FloatingActionButton(
                      mini: true,
                      onPressed: () async {
                        await Clipboard.setData(
                            ClipboardData(text: codeSample));
                        // copied successfully
                      },
                      child: Icon(Icons.copy),
                    ),
                  ),
                ])))));
  }
}
