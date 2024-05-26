import 'package:flutter/material.dart';
import 'package:sprig_ui/repo.dart';
import 'package:sprig_ui/widgets/sprig_details_card.dart';

class SprigDetailsPanel extends StatefulWidget {
  const SprigDetailsPanel({super.key, required this.sprigName});

  final Sprig sprigName;

  @override
  State<SprigDetailsPanel> createState() => _SprigDetailsPanelState();
}

class _SprigDetailsPanelState extends State<SprigDetailsPanel> {
  // FIXME: This default value is just for debugging
  Basket repo = LocalBasket(
      sprigBinary: "/Users/dorran/dev/sprig/clients/python/.venv/bin/sprig");

  @override
  Widget build(BuildContext context) {
    final asyncSprigWidget = FutureBuilder<SprigDetails>(
      future: repo.getDetails(widget.sprigName),
      builder: (BuildContext context, AsyncSnapshot<SprigDetails> snapshot) {
        List<Widget> children;
        if (snapshot.hasData &&
            !(snapshot.connectionState == ConnectionState.waiting)) {
          children = <Widget>[SprigDetailsCard(sprigDetails: snapshot.data!)];
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
    return asyncSprigWidget;
  }
}
