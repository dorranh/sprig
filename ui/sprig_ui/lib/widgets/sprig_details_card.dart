import 'package:flutter/material.dart';
import 'package:sprig_ui/repo.dart';

class SprigDetailsCard extends StatelessWidget {
  const SprigDetailsCard({super.key, required this.sprigDetails});

  final SprigDetails sprigDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        child: Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${sprigDetails.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Structure: ${sprigDetails.structure}'),
                      Text('Format: ${sprigDetails.format}'),
                      Text('ID: ${sprigDetails.id}')
                    ]))));
  }
}
