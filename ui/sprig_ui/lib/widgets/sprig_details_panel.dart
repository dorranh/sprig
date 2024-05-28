import 'package:flutter/material.dart';
import 'package:sprig_ui/repo.dart';
import 'package:sprig_ui/widgets/sprig_details_card.dart';
import 'package:sprig_ui/widgets/sprig_usage.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

class SprigDetailsPanel extends StatefulWidget {
  final Map<String, Highlighter> languageHighlighters;

  const SprigDetailsPanel(
      {super.key,
      required this.sprig,
      required this.repo,
      required this.languageHighlighters});

  final Sprig sprig;
  final LocalBasket repo;

  @override
  State<SprigDetailsPanel> createState() => _SprigDetailsPanelState();
}

class _SprigDetailsPanelState extends State<SprigDetailsPanel> {
  @override
  Widget build(BuildContext context) {
    final asyncSprigWidget = FutureBuilder<SprigDetails>(
      future: widget.repo.getDetails(widget.sprig),
      builder: (BuildContext context, AsyncSnapshot<SprigDetails> snapshot) {
        List<Widget> children;
        if (snapshot.hasData &&
            !(snapshot.connectionState == ConnectionState.waiting)) {
          children = <Widget>[
            SprigDetailsCard(sprigDetails: snapshot.data!),
            SprigUsage(
                sprigName: snapshot.data?.name,
                basketInfo: widget.repo.path,
                languageHighlighters: widget.languageHighlighters)
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
          children: children + [const Spacer()],
        );

        return Center(child: leftPanel);
      },
    );
    return asyncSprigWidget;
  }
}
