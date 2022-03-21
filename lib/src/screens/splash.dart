import 'package:flutter/material.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.white1,
        alignment: Alignment.center,
        child: Stack(children: const [
          Positioned(
            bottom: 0,
            left: 0,
            child: Image(
              image: AppImages.splashBg1,
              height: 210,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Image(
              image: AppImages.logoColor,
              width: 300,
              height: 300,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Image(
              image: AppImages.splashBg2,
              height: 210,
            ),
          ),
        ]),
      ),
    );
  }
}
