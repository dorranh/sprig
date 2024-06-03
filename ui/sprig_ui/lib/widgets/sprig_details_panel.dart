import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprig_ui/model.dart';
import 'package:sprig_ui/repo.dart';
import 'package:sprig_ui/utils/settings.dart';
import 'package:sprig_ui/widgets/sprig_details_card.dart';
import 'package:sprig_ui/widgets/sprig_usage.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

class SprigDetailsPanel extends ConsumerStatefulWidget {
  final Map<String, Highlighter> languageHighlighters;

  const SprigDetailsPanel(
      {super.key,
      required this.sprig,
      required this.repo,
      required this.languageHighlighters});

  final Sprig sprig;
  final LocalBasket repo;

  @override
  ConsumerState<SprigDetailsPanel> createState() => _SprigDetailsPanelState();
}

class _SprigDetailsPanelState extends ConsumerState<SprigDetailsPanel> {
  @override
  Widget build(BuildContext context) {
    AsyncValue<String> sprigBinaryPath = ref.watch(backendConfigProvider);

    return sprigBinaryPath.when(
      data: (path) {
        return FutureBuilder<SprigDetails>(
          future: widget.repo.getDetails(widget.sprig, path),
          builder:
              (BuildContext context, AsyncSnapshot<SprigDetails> snapshot) {
            List<Widget> children;
            if (snapshot.hasData &&
                !(snapshot.connectionState == ConnectionState.waiting)) {
              children = <Widget>[
                SprigDetailsCard(sprigDetails: snapshot.data!),
                SprigUsage(
                    sprigName: snapshot.data?.name,
                    basketInfo: widget.repo.path,
                    languageHighlighters: widget.languageHighlighters),
                const Spacer(),
              ];
            } else if (snapshot.hasError) {
              children = <Widget>[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error: ${snapshot.error}'),
                ),
              ];
            } else {
              children = const <Widget>[
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Awaiting result...'),
                ),
              ];
            }
            final leftPanel = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            );

            return Center(child: leftPanel);
          },
        );
      },
      // FIXME: Refine these.
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('Error: $error'),
    );
  }
}
