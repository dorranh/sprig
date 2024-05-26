import 'package:flutter/material.dart';
import 'package:sprig_ui/widgets/basket.dart';

class SprigUI extends StatelessWidget {
  const SprigUI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sprig',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Sprig'),
          ),
          body: const BasketUI(),
        ));
  }
}
