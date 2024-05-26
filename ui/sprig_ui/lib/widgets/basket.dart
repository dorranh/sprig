import 'package:flutter/material.dart';
import 'package:sprig_ui/repo.dart';
import 'package:sprig_ui/widgets/split.dart';
import 'package:sprig_ui/widgets/sprig_details_panel.dart';
import 'package:sprig_ui/widgets/sprig_list.dart';

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
          SprigList(onSprigSelected: callback),
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
