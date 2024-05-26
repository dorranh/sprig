import 'package:flutter/material.dart';
import 'package:sprig_ui/repo.dart';
import 'package:sprig_ui/widgets/split.dart';
import 'package:sprig_ui/widgets/sprig_details_panel.dart';
import 'package:sprig_ui/widgets/sprig_list.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

/// The main UI component for managing Sprig baskets.
class BasketUI extends StatefulWidget {
  final Map<String, Highlighter> languageHighlighters;

  const BasketUI({super.key, required this.languageHighlighters});

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
            width: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
        ],
        children: [
          SprigList(onSprigSelected: callback),
          SprigDetailsPanel(
              sprigName: selectedSprig!,
              languageHighlighters: widget.languageHighlighters)
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
