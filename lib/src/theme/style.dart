import 'package:flutter/material.dart';

final colorButtonStyle = ElevatedButton.styleFrom(
  textStyle: const TextStyle(fontFamily: 'Montserrat', fontSize: 13),
  primary: const Color.fromRGBO(255, 204, 64, 1),
  minimumSize: const Size(127, 50),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
  ),
);

final outlineButtonStyle = OutlinedButton.styleFrom(
  textStyle: const TextStyle(fontFamily: 'Montserrat', fontSize: 13),
  minimumSize: const Size(127, 50),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
  ),
);

final textButtonStyle = TextButton.styleFrom(
  textStyle: const TextStyle(
    // color: Color.fromRGBO(1, 132, 225, 1),
    fontFamily: 'Montserrat',
    fontSize: 13,
    letterSpacing: 0 /*percentages not used in flutter. defaulting to zero*/,
    fontWeight: FontWeight.normal,
    height: 1,
  ),
);

const defaultLabelStyle = TextStyle(
  fontSize: 12.0,
  fontFamily: 'Montserrat',
);

InputDecoration generateInputDecoration({
  String? hint,
  String? label,
  String? errorMsg,
  VoidCallback? onClear,
  Color color = Colors.black54,
  Widget? prefixIcon,
  Widget? suffixIcon,
  bool outlineBorder = false,
}) {
  return InputDecoration(
    hintText: hint,
    labelText: label,
    errorText: errorMsg,
    counterText: "",
    enabledBorder: outlineBorder
        ? OutlineInputBorder(
            borderSide: BorderSide(color: color),
          )
        : UnderlineInputBorder(
            borderSide: BorderSide(color: color),
          ),
    focusedBorder: outlineBorder
        ? OutlineInputBorder(
            borderSide: BorderSide(color: color),
          )
        : UnderlineInputBorder(
            borderSide: BorderSide(color: color),
          ),
    border: outlineBorder
        ? OutlineInputBorder(
            borderSide: BorderSide(color: color),
          )
        : UnderlineInputBorder(
            borderSide: BorderSide(color: color),
          ),
    labelStyle: TextStyle(
      color: color,
      fontFamily: 'Montserrat',
    ),
    hintStyle: TextStyle(
      color: color,
      fontFamily: 'Montserrat',
    ),
    focusColor: color,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon ??
        (onClear != null
            ? IconButton(
                icon: const Icon(Icons.clear_outlined),
                onPressed: onClear,
              )
            : null),
  );
}
