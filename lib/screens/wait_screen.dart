import 'package:flutter/material.dart';
import 'package:parcial_final/components/loader_component.dart';

class WaitScreen extends StatelessWidget {
  const WaitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoaderComponent(
        text: 'Un segundo Por favor ...',
      ),
    );
  }
}
