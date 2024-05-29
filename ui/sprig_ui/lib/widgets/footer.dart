// A statefull widget for displaying the sprig binary currently configured
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sprig_ui/utils/settings.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  /// The path to the sprig back-end binary
  String sprigBinary = 'sprig';

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(
        "Using back-end: $sprigBinary",
        style: TextStyle(fontSize: 10),
      ),
      style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              EdgeInsets.symmetric(horizontal: 5, vertical: 5)),
          backgroundColor: MaterialStateProperty.all<Color>(
              Color.fromARGB(255, 226, 228, 227))),
      onPressed: () async {
        FilePickerResult? selection = await FilePicker.platform.pickFiles();
        if (selection != null) {
          setState(() {
            sprigBinary = selection.files.single.path!;
          });
          await saveSprigBinaryPath(sprigBinary);
        }
      },
    );
  }
}
