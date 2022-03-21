//
// import 'package:shared_preferences/shared_preferences.dart';
//
// class MiliPreferences {
//   static const THEME_STATUS = "THEMESTATUS";
//
//   Future<bool> setDarkTheme(bool value) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setBool(THEME_STATUS, value);
//     return true;
//   }
//
//   Future<bool> getTheme() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(THEME_STATUS) ?? false;
//   }
// }