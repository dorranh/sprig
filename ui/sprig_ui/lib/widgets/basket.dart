import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sprig_ui/repo.dart';
import 'package:sprig_ui/widgets/split.dart';
import 'package:sprig_ui/widgets/sprig_details_panel.dart';
import 'package:sprig_ui/widgets/sprig_list.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

/// The main UI component for managing Sprig baskets.
class BasketUI extends StatefulHookConsumerWidget {
  final Map<String, Highlighter> languageHighlighters;
  final String backendPath;
  const BasketUI(
      {super.key,
      required this.languageHighlighters,
      required this.backendPath});

  @override
  ConsumerState<BasketUI> createState() => _BasketUIState();
}

class _BasketUIState extends ConsumerState<BasketUI> {
  @override
  Widget build(BuildContext context) {
    ValueNotifier<(LocalBasket, Sprig)?> selectedSprig = useState(null);

    if (selectedSprig.value != null) {
      return Split(
        axis: Axis.horizontal,
        initialFractions: const [0.3, 0.7],
        minSizes: [200, 200],
        splitters: [
          SizedBox(
            width: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
        ],
        children: [
          SprigList(
            onSprigSelected: (selection) => selectedSprig.value = selection,
          ),
          SprigDetailsPanel(
            sprig: selectedSprig.value!.$2,
            repo: selectedSprig.value!.$1,
            languageHighlighters: widget.languageHighlighters,
          )
        ],
      );
    } else {
      return Center(
          child: SprigList(
        onSprigSelected: (selection) => selectedSprig.value = selection,
      ));
    }
  }
}
