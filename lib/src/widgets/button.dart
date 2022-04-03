import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miliv2/src/theme/colors.dart';

class AppButton extends ElevatedButton {
  final String label;
  final void Function()? onPress;

  AppButton(this.label, this.onPress, {Key? key, Size? size})
      : super(
          key: key,
          onPressed: onPress,
          child: Flexible(
            child: FittedBox(
                child: Text(
              label,
              overflow: TextOverflow.fade,
            )),
          ),
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: FontWeight.w900,
              overflow: TextOverflow.fade,
            ),
            primary: AppColors.button,
            minimumSize: size ?? const Size(200, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
}
