import 'package:flutter/material.dart';

class BlueBox extends StatelessWidget {
  final int width;

  const BlueBox({
    required this.width,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue,
        border: Border.all(),
      ),
    );
  }
}