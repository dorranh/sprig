import 'package:flutter/material.dart';
import 'package:sprig_ui/repo.dart';

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

  int? _selectedSprigIndex;

  @override
  Widget build(BuildContext context) {
    final asyncSprigWidget = FutureBuilder<Sprigs>(
      future: repo.list(),
      builder: (BuildContext context, AsyncSnapshot<Sprigs> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          children = <Widget>[
            Text(
              'Sprigs:',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.start,
            ),
            Flexible(
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data?.sprigs?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        onTap: () {
                          // Update the state of this widget
                          setState(() {
                            _selectedSprigIndex = index;
                          });
                          // Fire off any provided callbacks as well
                          widget.onSprigSelected
                              ?.call(snapshot.data?.sprigs?[index]);
                        },
                        tileColor: _selectedSprigIndex == index
                            ? Color.fromARGB(255, 148, 243, 154)
                            : null,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey, width: 0.5),
                            borderRadius: BorderRadius.circular(4)),
                        leading: const Icon(Icons.data_object_outlined),
                        title: Text('${snapshot.data?.sprigs?[index].name}'),
                      );
                    })),
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
