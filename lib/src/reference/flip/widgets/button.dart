import 'package:flutter/material.dart';

class ButtonFlip extends StatelessWidget {
  final Widget child;
  final Function()? onPressed;

  const ButtonFlip({Key? key, required this.child, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: child,
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          // fontFamily: 'Montserrat',
          fontSize: 13,
          fontWeight: FontWeight.w900,
          overflow: TextOverflow.fade,
        ),
        minimumSize: const Size.fromHeight(45),
        primary: const Color(0xFFFF5731),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
      ),
    );
  }
}
