import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprig_ui/utils/settings.dart';
import 'package:sprig_ui/widgets/basket.dart';
import 'package:sprig_ui/widgets/footer.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

class SprigUI extends ConsumerStatefulWidget {
  final Map<String, Highlighter> languageHighlighters;

  @override
  ConsumerState<SprigUI> createState() => _SprigUIState();

  const SprigUI({
    super.key,
    required this.languageHighlighters,
  });
}

class _SprigUIState extends ConsumerState<SprigUI> {
  // @override
  // void initState() {
  //   super.initState();
  //   // State life-cycles have access to "ref" too.
  //   // This enables things such as adding a listener on a specific provider
  //   // to show dialogs/snackbars.
  //   ref.listenManual(getSprigBinaryPathProvider, (previous, next) {
  //     // TODO show a snackbar/dialog
  //   });

  @override
  Widget build(BuildContext context) {
    final AsyncValue<String> backendPath = ref.watch(backendConfigProvider);

    var colorScheme =
        ColorScheme.fromSeed(seedColor: const Color.fromRGBO(129, 199, 132, 1));

    final (body, footer) = backendPath.when(
        loading: () => (CircularProgressIndicator(), null),
        error: (error, stack) =>
            (Text('Failed to load backend configuration!'), null),
        data: (bp) {
          final body = BasketUI(
            languageHighlighters: widget.languageHighlighters,
            backendPath: bp,
          );
          return (body, const Footer());
        });

    return MaterialApp(
        title: 'Sprig',
        theme: ThemeData(
          colorScheme: colorScheme,
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: colorScheme.inversePrimary,
            title: const Row(children: <Widget>[
              Icon(Icons.data_exploration),
              Text('Sprig'),
            ]),
          ),
          body: body,
          persistentFooterButtons: (footer == null ? null : [footer]),
          persistentFooterAlignment: AlignmentDirectional.centerStart,
        ));
  }
}
