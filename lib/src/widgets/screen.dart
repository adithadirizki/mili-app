import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FlexBoxGray extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color color;

  const FlexBoxGray({
    Key? key,
    required this.child,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
    this.borderRadius = const BorderRadius.all(Radius.zero),
    this.color = Colors.transparent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      fit: FlexFit.tight,
      child: Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: color,
        ),
        child: child,
      ),
    );
  }
}
