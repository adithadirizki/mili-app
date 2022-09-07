import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';

class ScannerAnimation extends AnimatedWidget {
  final bool stopped;
  final double width;

  ScannerAnimation(
    this.stopped,
    this.width, {
    Key? key,
    required Animation<double> animation,
  }) : super(
          key: key,
          listenable: animation,
        );

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    final scorePosition = (animation.value * 440) + 16;

    Color color1 = const Color(0x5500C2FF);
    Color color2 = const Color(0x0000C2FF);

    if (animation.status == AnimationStatus.reverse) {
      color1 = const Color(0x0000C2FF);
      color2 = const Color(0x5500C2FF);
    }

    return Positioned(
      bottom: scorePosition,
      child: Opacity(
        opacity: (stopped) ? 0.0 : 1.0,
        child: Container(
          height: 75.0,
          width: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.1, 1],
              colors: [color1, color2],
            ),
          ),
        ),
      ),
    );
  }
}
