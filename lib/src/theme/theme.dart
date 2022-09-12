import 'package:flutter/material.dart';
import 'package:miliv2/src/theme/colors.dart';

abstract class AppTheme {
//colors
  static const Color whiteColor = Color(0xffffffff);
  static const Color blackColor = Color(0xff000000);
  static const Color orangeColor = Colors.orange;
  static const Color redColor = Colors.red;
  static const Color darkRedColor = Color(0xFFB71C1C);
  static const Color purpleColor = Color(0xff5E498A);
  static const Color darkThemeColor = Color(0xff33333E);
  static const Color grayColor = Color(0xff797979);
  static const Color greyColorLight = Color(0xffd7d7d7);
  static const Color settingsBackground = Color(0xffefeff4);
  static const Color settingsGroupSubtitle = Color(0xff777777);
  static const Color iconBlue = Color(0xff0000ff);
  static const Color transparent = Colors.transparent;
  static const Color iconGold = Color(0xffdba800);
  static const Color bottomBarSelectedColor = Color(0xff5e4989);
  static const Color miliLightBlue = Color(0xff00C2FF);
  static const Color miliBottomNavBlue = Color(0xff00A3FF);
  static const Color miligreen = Color.fromARGB(255, 69, 170, 74);
  static const Color miligrey = Color.fromARGB(255, 242, 242, 242);
  static const Color miligrey200 = Color.fromARGB(200, 242, 242, 242);
  //Strings
  static const TextStyle defaultTextStyle = TextStyle(
    color: purpleColor,
    fontSize: 20.0,
  );
  static const TextStyle defaultTextStyleBlack = TextStyle(
    color: blackColor,
    fontSize: 20.0,
  );
  static const TextStyle defaultTextStyleGRey = TextStyle(
    color: grayColor,
    fontSize: 20.0,
  );
  static const TextStyle smallTextStyleGRey = TextStyle(
    color: grayColor,
    fontSize: 16.0,
  );
  static const TextStyle smallTextStyle = TextStyle(
    color: purpleColor,
    fontSize: 16.0,
  );
  static const TextStyle smallTextStyleWhite = TextStyle(
    color: whiteColor,
    fontSize: 16.0,
  );
  static const TextStyle smallTextStyleBlack = TextStyle(
    color: blackColor,
    fontSize: 16.0,
  );
  static const TextStyle defaultButtonTextStyle =
      TextStyle(color: whiteColor, fontSize: 20);

  static const TextStyle profileTextStyleBlack = TextStyle(
    color: blackColor,
    fontSize: 20.0,
  );

  static const TextStyle defaultTextStyleWhite = TextStyle(
    color: whiteColor,
    fontSize: 20.0,
  );

  static const TextStyle messageRecipientTextStyle =
      TextStyle(color: blackColor, fontSize: 16.0, fontWeight: FontWeight.bold);

  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
        //* Custom Google Font
        //  fontFamily: Devfest.google_sans_family,
        primarySwatch: Colors.blue,
        primaryColor: isDarkTheme ? Colors.black : Colors.white,
        //saldoColor: isDarkTheme ? Colors.black : Color.fromRGBO(0, 173, 210, 1),
        //backgroundColor: isDarkTheme ? Colors.black : Color(0xffF1F5FB),
        backgroundColor:
            isDarkTheme ? Colors.black : const Color.fromRGBO(0, 173, 210, 1),
        indicatorColor:
            isDarkTheme ? const Color(0xff0E1D36) : const Color(0xffCBDCF8),
        buttonColor:
            isDarkTheme ? const Color(0xff3B3B3B) : const Color(0xffF1F5FB),
        hintColor:
            isDarkTheme ? const Color(0xff280C0B) : const Color(0xffEECED3),
        highlightColor:
            isDarkTheme ? const Color(0xff372901) : const Color(0xffFCE192),
        hoverColor:
            isDarkTheme ? const Color(0xff3A3A3B) : const Color(0xff4285F4),
        focusColor:
            isDarkTheme ? const Color(0xff0B2512) : const Color(0xffA8DAB5),
        disabledColor: Colors.grey,
        //textSelectionColor: isDarkTheme ? Colors.white : Colors.black,
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: isDarkTheme ? Colors.white : Colors.black,
          //cursorColor: Color(0xffBA379B).withOpacity(.6),
          //selectionHandleColor: Color(0xffBA379B).withOpacity(1),
        ),
        cardColor: isDarkTheme ? const Color(0xFF151515) : Colors.white,
        canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
        brightness: isDarkTheme ? Brightness.dark : Brightness.light,
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
            colorScheme:
                isDarkTheme ? ColorScheme.dark() : ColorScheme.light()),
        appBarTheme: const AppBarTheme(
          elevation: 0.0,
        ),

        // Revert back to pre-Flutter-2.5 transition behavior:
        // https://github.com/flutter/flutter/issues/82053
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ));
  }
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'MavenPro',
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    titleTextStyle: TextStyle(color: Colors.blue),
    toolbarTextStyle: TextStyle(color: Colors.blue),
    actionsIconTheme: IconThemeData(color: Colors.blue),
  ),
  primaryColor: AppColors.blue2,
  accentColor: const Color(0xff4285F4),
  colorScheme: const ColorScheme.light(primary: AppColors.blue2),
  primarySwatch: Colors.blue,
  // backgroundColor: isDarkTheme ? Colors.black : Color(0xffF1F5FB),
  backgroundColor: const Color(0xffF1F5FB),
  indicatorColor: const Color(0xffCBDCF8),
  buttonColor: const Color(0xffF1F5FB),
  hintColor: const Color(0xffEECED3),
  highlightColor: const Color(0xffFCE192),
  hoverColor: const Color(0xff4285F4),
  focusColor: const Color(0xffA8DAB5),
  disabledColor: Colors.grey,
  // textSelectionTheme: const TextSelectionThemeData(
  //   selectionColor: Colors.black,
  //   //cursorColor: Color(0xffBA379B).withOpacity(.6),
  //   //selectionHandleColor: Color(0xffBA379B).withOpacity(1),
  // ),
  cardColor: Colors.white,
  canvasColor: Colors.grey[50],
  buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
  scaffoldBackgroundColor: Colors.grey[50],
  // buttonTheme: Theme.of(context).buttonTheme.copyWith(
  //     colorScheme:
  //         isDarkTheme ? ColorScheme.dark() : ColorScheme.light()),
  // textTheme: TextTheme(
  //   bodySmall:
  // ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
    },
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'MavenPro',
  // appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
    },
  ),
);
