import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FlexBoxGray extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  const FlexBoxGray(
      {Key? key,
      required this.child,
      this.margin = const EdgeInsets.all(0),
      this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 10)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      fit: FlexFit.tight,
      child: Container(
        margin: margin,
        // padding: padding,
        // decoration: const BoxDecoration(
        //   borderRadius: BorderRadius.all(Radius.elliptical(15, 15)),
        //   color: Color(0xFFF3F3F3),
        // ),
        child: child,
      ),
    );
  }
}
