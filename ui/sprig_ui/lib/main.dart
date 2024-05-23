import 'package:flutter/material.dart';
import 'package:sprig_ui/repo.dart';
import 'package:sprig_ui/split.dart';

void main() {
  runApp(const SprigUI());
}

class SprigUI extends StatelessWidget {
  const SprigUI({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sprig',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(
            // TRY THIS: Try changing the color here to a specific color (to
            // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
            // change color while the other colors stay the same.
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: const Text('Sprig'),
          ),
          body: const BasketUI(),
        ));
  }
}

class SprigDetailsPanel extends StatefulWidget {
  const SprigDetailsPanel({super.key, required this.sprigName});

  final Sprig sprigName;

  @override
  State<SprigDetailsPanel> createState() => _SprigDetailsPanelState();
}

class _SprigDetailsPanelState extends State<SprigDetailsPanel> {
  @override
  Widget build(BuildContext context) {
    return Text('Sprig: ${widget.sprigName.name}');
  }
}

/// The main UI component for managing Sprig baskets.
class SprigList extends StatefulWidget {
  const SprigList({super.key, required this.onSprigSelected});
  final Function(Sprig?)? onSprigSelected;
  @override
  State<SprigList> createState() => _SprigListState();
}

class _SprigListState extends State<SprigList> {
  // FIXME: This default value is just for debugging
  Basket repo = LocalBasket(
      sprigBinary: "/Users/dorran/dev/sprig/clients/python/.venv/bin/sprig");

  @override
  Widget build(BuildContext context) {
    final asyncSprigWidget = FutureBuilder<Sprigs>(
      future: repo.list(),
      builder: (BuildContext context, AsyncSnapshot<Sprigs> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          children = <Widget>[
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 60,
            ),
            Flexible(
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data?.sprigs?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                          onTap: () {
                            widget.onSprigSelected
                                ?.call(snapshot.data?.sprigs?[index]);
                          },
                          child: Container(
                            height: 50,
                            color: Colors.lightBlue,
                            child: Center(
                                child: Text(
                                    '${snapshot.data?.sprigs?[index].name}')),
                          ));
                    }))
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
    return asyncSprigWidget;
  }
}

/// The main UI component for managing Sprig baskets.
class BasketUI extends StatefulWidget {
  const BasketUI({super.key});

  @override
  State<BasketUI> createState() => _BasketUIState();
}

class _BasketUIState extends State<BasketUI> {
  /// The currently selected sprig
  Sprig? selectedSprig;

  @override
  Widget build(BuildContext context) {
    callback(selection) {
      setState(() {
        selectedSprig = selection;
      });
    }

    if (selectedSprig != null) {
      return Split(
        axis: Axis.horizontal,
        initialFractions: const [0.3, 0.7],
        splitters: [
          SizedBox(
            width: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
        ],
        children: [
          Expanded(child: SprigList(onSprigSelected: callback)),
          SprigDetailsPanel(
            sprigName: selectedSprig!,
          )
        ],
      );
    } else {
      return Center(
          child: SprigList(
        onSprigSelected: callback,
      ));
    }
  }
}
