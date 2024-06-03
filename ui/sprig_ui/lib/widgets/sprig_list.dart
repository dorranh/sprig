import 'package:async_value_group/async_value_group.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sprig_ui/repo.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:sprig_ui/utils/settings.dart';

/// Local type alias to help with type annotations below. Repesents a Sprig and the basket it resides in.
typedef BasketSprig = (LocalBasket, Sprig);

/// The main UI component for managing Sprig baskets.
class SprigList extends StatefulHookConsumerWidget {
  const SprigList({super.key, required this.onSprigSelected});
  final Function(BasketSprig?)? onSprigSelected;

  @override
  ConsumerState<SprigList> createState() => _SprigListState();
}

/// Helper for querying all configured repos for the sprigs they contain.
Future<List<BasketSprig>>? listAll(
    List<LocalBasket> repos, String sprigBinaryPath) async {
  var allSprigs = await Future.wait(repos.map((repo) => repo
      .list(sprigBinaryPath)!
      .then((sprigs) => sprigs.sprigs?.map((s) => (repo, s)).toList())));
  final List<BasketSprig> flattenedResult = [];
  for (var repoSprigs in allSprigs) {
    if (repoSprigs != null) {
      flattenedResult.addAll(repoSprigs);
    }
  }
  return flattenedResult;
}

class _SprigListState extends ConsumerState<SprigList> {
  @override
  Widget build(BuildContext context) {
    AsyncValue<(List<LocalBasket>, String)> config = AsyncValueGroup.group2(
        ref.watch(basketConfigProvider), ref.watch(backendConfigProvider));

    ValueNotifier<int?> _selectedSprigIndex = useState(null);

    return config.when(
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) =>
            const Text('Failed to load basket configuration!'),
        data: (d) {
          final baskets = d.$1;
          final sprigBinaryPath = d.$2;

          return FutureBuilder<List<BasketSprig>>(
            future: listAll(baskets, sprigBinaryPath),
            builder: (BuildContext context,
                AsyncSnapshot<List<BasketSprig>> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                children = <Widget>[
                  Flexible(
                      child: GroupedListView<dynamic, String>(
                          reverse: false,
                          elements: snapshot.data ?? [],
                          groupBy: (element) => element.$1.path,
                          // groupComparator: (value1, value2) => value2.compareTo(value1),
                          // itemComparator: (item1, item2) =>
                          //     item1['name'].compareTo(item2['name']),
                          order: GroupedListOrder.DESC,
                          useStickyGroupSeparators: true,
                          groupSeparatorBuilder: (String value) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(children: <Widget>[
                                  Text(
                                    "$value",
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Tooltip(
                                      message:
                                          "Remove this basket from the UI. Does not delete data from the basket.",
                                      child: IconButton(
                                          onPressed: () {
                                            // Remove the selected basket from the list
                                            final newRepos = baskets
                                                .where((element) =>
                                                    element.path != value)
                                                .toList();
                                            ref
                                                .read(basketConfigProvider
                                                    .notifier)
                                                .setBaskets(
                                                    newRepos.toSet().toList());
                                          },
                                          icon: const Icon(Icons.close))),
                                ]),
                              ),
                          indexedItemBuilder: (c, element, index) {
                            return ListTile(
                              onTap: () {
                                _selectedSprigIndex.value = index;
                                // Fire off any provided callbacks as well
                                widget.onSprigSelected
                                    ?.call(snapshot.data?[index]);
                              },
                              tileColor: _selectedSprigIndex.value == index
                                  ? const Color.fromARGB(255, 248, 214,
                                      253) //Color.fromARGB(255, 177, 239, 182)
                                  : null,
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Colors.grey, width: 0.5),
                                  borderRadius: BorderRadius.circular(4)),
                              leading: const Icon(Icons.table_rows),
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
                      Container(
                          margin: const EdgeInsets.only(bottom: 10.0),
                          child: Tooltip(
                              message:
                                  "Add a local directory containing sprigs to the UI",
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.inventory),
                                label: Text("Add Basket"),
                                onPressed: () async {
                                  // Wait until we get a user-provided directory
                                  String? selectedDirectory = await FilePicker
                                      .platform
                                      .getDirectoryPath();
                                  // If the user actually selected something, we can save it to our application
                                  // settings.
                                  if (selectedDirectory != null) {
                                    final updatedBasketList = (baskets +
                                            [
                                              LocalBasket(
                                                  path: selectedDirectory)
                                            ])
                                        .toSet()
                                        // Deduplicate the list
                                        .toList();
                                    ref
                                        .read(basketConfigProvider.notifier)
                                        .setBaskets(updatedBasketList);
                                  }
                                },
                              )))
                    ],
              );

              return Center(child: leftPanel);
            },
          );
        });
  }
}
