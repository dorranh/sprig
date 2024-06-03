// A statefull widget for displaying the sprig binary currently configured
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprig_ui/utils/settings.dart';

class Footer extends ConsumerStatefulWidget {
  const Footer({super.key, this.onBackendSelected});
  final Function(String newBackendPath)? onBackendSelected;

  @override
  ConsumerState<Footer> createState() => _FooterState();
}

class _FooterState extends ConsumerState<Footer> {
  @override
  Widget build(BuildContext context) {
    AsyncValue<String> backendPath = ref.watch(backendConfigProvider);

    final footer = backendPath.when(
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => null,
        data: (bp) => TextButton(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5)),
                  backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 226, 228, 227))),
              onPressed: () async {
                FilePickerResult? selection =
                    await FilePicker.platform.pickFiles();
                if (selection != null) {
                  final newBackendPath = selection.files.single.path!;
                  if (newBackendPath != backendPath) {
                    await ref
                        .read(backendConfigProvider.notifier)
                        .setBinaryPath(newBackendPath);
                    widget.onBackendSelected?.call(newBackendPath);
                  }
                }
              },
              child: Text(
                "Using back-end: $bp",
                style: const TextStyle(fontSize: 10),
              ),
            ));
    return footer ?? const Icon(Icons.error_outline);
  }
}
