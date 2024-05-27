import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprig_ui/repo.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:sprig_ui/utils/settings.dart';

/// Local type alias to help with type annotations below. Repesents a Sprig and the basket it resides in.
typedef BasketSprig = (LocalBasket, Sprig);

/// The main UI component for managing Sprig baskets.
class SprigList extends StatefulWidget {
  const SprigList({super.key, required this.onSprigSelected});
  final Function(Sprig?)? onSprigSelected;
  @override
  State<SprigList> createState() => _SprigListState();
}

/// Helper for querying all configured repos for the sprigs they contain.
Future<List<BasketSprig>>? listAll(
    List<LocalBasket> repos, String sprigBinary) async {
  var allSprigs = await Future.wait(repos.map((repo) => repo
      .list()!
      .then((sprigs) => sprigs.sprigs?.map((s) => (repo, s)).toList())));
  final List<BasketSprig> flattenedResult = [];
  for (var repoSprigs in allSprigs) {
    if (repoSprigs != null) {
      flattenedResult.addAll(repoSprigs);
    }
  }
  return flattenedResult;
}

class _SprigListState extends State<SprigList> {
  List<LocalBasket> repos = [];
  int? _selectedSprigIndex;

  final sprigBinary = "/Users/dorran/dev/sprig/clients/python/.venv/bin/sprig";

  @override
  void initState() {
    super.initState();
    getBaskets()
        .then((basketPaths) => basketPaths
            .map((p) => LocalBasket(sprigBinary: sprigBinary, path: p))
            .toList())
        .then((baskets) {
      setState(() {
        repos = baskets;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncSprigWidget = FutureBuilder<List<BasketSprig>>(
      future: listAll(repos, sprigBinary),
      builder:
          (BuildContext context, AsyncSnapshot<List<BasketSprig>> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          children = <Widget>[
            Text(
              'Sprigs:',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.start,
            ),
            Flexible(
                child: GroupedListView<dynamic, String>(
                    elements: snapshot.data ?? [],
                    groupBy: (element) => element.$1.path,
                    // groupComparator: (value1, value2) => value2.compareTo(value1),
                    // itemComparator: (item1, item2) =>
                    //     item1['name'].compareTo(item2['name']),
                    order: GroupedListOrder.DESC,
                    useStickyGroupSeparators: true,
                    groupSeparatorBuilder: (String value) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Basket: $value",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                    indexedItemBuilder: (c, element, index) {
                      return ListTile(
                        onTap: () {
                          // Update the state of this widget
                          setState(() {
                            _selectedSprigIndex = index;
                          });
                          // Fire off any provided callbacks as well
                          widget.onSprigSelected
                              ?.call(snapshot.data?[index].$2);
                        },
                        tileColor: _selectedSprigIndex == index
                            ? Color.fromARGB(255, 148, 243, 154)
                            : null,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey, width: 0.5),
                            borderRadius: BorderRadius.circular(4)),
                        leading: const Icon(Icons.data_object_outlined),
                        title: Text('${snapshot.data?[index].$2.name}'),
                      );
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
          children: children +
              <Widget>[
                ElevatedButton.icon(
                  icon: Icon(Icons.shopping_basket),
                  label: Text("Create Sprig"),
                  onPressed: () async {
                    // Wait until we get a user-provided directory
                    String? selectedDirectory =
                        await FilePicker.platform.getDirectoryPath();
                    // If the user actually selected something, we can save it to our application
                    // settings.
                    if (selectedDirectory != null) {
                      await getBaskets().then((baskets) {
                        baskets.add(selectedDirectory);
                        saveBaskets(baskets);
                        // TODO: This could be cleaner
                        setState(() {
                          repos = baskets
                              .map((b) => LocalBasket(
                                  sprigBinary: sprigBinary, path: b))
                              .toList();
                        });
                      });
                    }
                  },
                )
              ],
        );

        return Center(child: leftPanel);
      },
    );
    return asyncSprigWidget;
  }
}
