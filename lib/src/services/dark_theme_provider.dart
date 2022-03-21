import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DarkThemeProvider with ChangeNotifier {
  // MiliPreferences miliPreferences = MiliPreferences();
  bool _darkTheme = true;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    // miliPreferences.setDarkTheme(value);
    notifyListeners();
  }
}

class DarkThemeProviderScope extends InheritedNotifier<DarkThemeProvider> {
  const DarkThemeProviderScope({
    required DarkThemeProvider notifier,
    required Widget child,
    Key? key,
  }) : super(key: key, notifier: notifier, child: child);

  static DarkThemeProvider of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<DarkThemeProviderScope>()!
      .notifier!;
}
