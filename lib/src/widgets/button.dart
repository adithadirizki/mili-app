import 'package:flutter/material.dart';

class AppButton extends ElevatedButton {
  final String label;
  final void Function()? onPress;

  AppButton(this.label, this.onPress, {Key? key, Size? size})
      : super(
          key: key,
          onPressed: onPress,
          child: Text(label),
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
            primary: const Color.fromRGBO(255, 204, 64, 1),
            minimumSize: size ?? const Size(200, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
}
