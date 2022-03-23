// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/theme/theme.dart';
import 'package:miliv2/src/utils/device.dart';

import 'routing.dart';
import 'screens/navigator.dart';
import 'services/auth.dart';
import 'services/dark_theme_provider.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final _themeChange = DarkThemeProvider();
  late AppAuth _auth;
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final RouteState _routeState;
  late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;

  @override
  void initState() {
    /// Configure the parser with all of the app's allowed path templates.
    _routeParser = TemplateRouteParser(
      allowedPaths: [
        '/splash',
        '/signin',
        '/forgot',
        '/signup',
        '/otp',
        '/reset',
        '/',
        // '/authors',
        // '/settings',
        // '/books/new',
        // '/books/all',
        // '/books/popular',
        // '/book/:bookId',
        // '/author/:authorId',
      ],
      guard: _guard,
      initialRoute: '/splash',
    );

    _routeState = RouteState(_routeParser);

    _routerDelegate = SimpleRouterDelegate(
      routeState: _routeState,
      navigatorKey: _navigatorKey,
      builder: (context) => AppNavigator(
        // Build navigator
        navigatorKey: _navigatorKey,
      ),
    );

    _auth = AppAuth();
    // Listen for when the user logs out and display the signin screen.
    _auth.addListener(_handleAuthStateChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => DarkThemeProviderScope(
        notifier: _themeChange,
        child: RouteStateScope(
          notifier: _routeState,
          child: AppAuthScope(
            notifier: _auth,
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerDelegate: _routerDelegate,
              routeInformationParser: _routeParser,
              themeMode: ThemeMode.light, // FIXME Force to light mode for now
              theme: lightTheme,
              darkTheme: darkTheme,
            ),
          ),
        ),
      );

  // @override
  // Widget build(BuildContext context) {
  //   return MultiProvider(
  //     providers: [
  //       Provider(create: (context) => _appStorage),
  //       Provider(create: (context) => _auth),
  //       Provider(create: (context) => _themeChange),
  //       Provider(create: (context) => _routeState),
  //       // ChangeNotifierProxyProvider
  //     ],
  //     child: MaterialApp.router(
  //       debugShowCheckedModeBanner: false,
  //       routerDelegate: _routerDelegate,
  //       routeInformationParser: _routeParser,
  //       // theme: AppTheme.themeData(_themeChange.darkTheme, context),
  //       theme: ThemeData(
  //         pageTransitionsTheme: const PageTransitionsTheme(
  //           builders: <TargetPlatform, PageTransitionsBuilder>{
  //             TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
  //             TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  //             TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
  //             TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
  //             TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<ParsedRoute> _guard(ParsedRoute from) async {
    final signedIn = _auth.signedIn;
    final verified = _auth.verified;

    debugPrint('App guard : signedin $signedIn verified $verified from $from');

    final signInRoute =
        ParsedRoute('/signin', '/signin', {}, {"redirect": "_guard"});
    final mainRoute = ParsedRoute('/', '/', {}, {"redirect": "_guard"});
    final publicRoute = [
      '/splash',
      '/signin',
      '/forgot',
      '/reset',
      '/signup',
      '/otp',
    ];

    // Go to /signin if the user is not signed in
    if (!signedIn &&
        from != signInRoute &&
        !publicRoute.contains(from.pathTemplate)) {
      bool success = await _guestSignIn();
      if (success) {
        debugPrint('App guard guest to main');
        return mainRoute;
      } else {
        debugPrint('App guard return to signin');
        return signInRoute;
      }
    }
    // Go to / if the user is signed in and tries to go to /signin.
    else if (signedIn && verified && from == signInRoute) {
      return mainRoute;
    }
    return from;
  }

  Future<bool> _guestSignIn() async {
    var deviceId = await getDeviceId();
    var resp = await Api.clientInfo();

    if (resp.statusCode == 200) {
      Map<String, dynamic> bodyMap =
          json.decode(resp.body) as Map<String, dynamic>;

      var ip = bodyMap['ip'] == null ? '-' : bodyMap['ip'] as String;
      return _auth.guestSignIn(deviceId, ip).catchError((dynamic e) {
        debugPrint('Guest error $e');
        return false;
      });
    }

    return false;
  }

  void _handleAuthStateChanged() async {
    debugPrint(
        'Handle auth change ${_auth.signedIn} verified ${_auth.verified}');
    if (!_auth.signedIn) {
      _routeState.go('/signin');
    } else if (_auth.verified) {
      _routeState.go('/');
    } else {
      _routeState.go('/otp');
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_handleAuthStateChanged);
    _routeState.dispose();
    _routerDelegate.dispose();
    _themeChange.dispose();
    super.dispose();
  }
}
