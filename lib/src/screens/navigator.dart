// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:miliv2/src/screens/homepage.dart';
import 'package:miliv2/src/screens/otp_verification.dart';
import 'package:miliv2/src/screens/sign_up.dart';
import 'package:miliv2/src/screens/splash.dart';
import 'package:miliv2/src/utils/device.dart';
import 'package:miliv2/src/utils/dialog.dart';

import '../routing.dart';
import '../services/auth.dart';
import '../widgets/fade_transition_page.dart';
import 'forgot_password.dart';
import 'sign_in.dart';

/// Builds the top-level navigator for the app. The pages to display are based
/// on the `routeState` that was parsed by the TemplateRouteParser.
class AppNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const AppNavigator({
    required this.navigatorKey,
    Key? key,
  }) : super(key: key);

  @override
  _AppNavigatorState createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  final _splashKey = const ValueKey('Splash Screen');
  final _signInKey = const ValueKey('Sign In Screen');
  final _forgotKey = const ValueKey('Forgot Password Screen');
  final _otpKey = const ValueKey('OTP Screen');
  final _registrationKey = const ValueKey('Registration Screen');
  final _scaffoldKey = const ValueKey<String>('App scaffold');
  final _bookDetailsKey = const ValueKey<String>('Book details screen');
  final _authorDetailsKey = const ValueKey<String>('Author details screen');

  Future<void> onSignIn(Credentials credentials) async {
    // final routeState = RouteStateScope.of(context); // get route state
    final authState = AppAuthScope.of(context); // get auth state

    var deviceId = await getDeviceId();
    var signedIn = await authState
        .signIn(
      credentials.username,
      credentials.password,
      deviceId,
    )
        .catchError((Object e) {
      simpleSnackBarDialog(context, e.toString());
      return true;
    });
  }

  Future<void> onVerified(OTPVerified credentials) async {
    final authState = AppAuthScope.of(context); // get auth state
    await authState.setVerified(credentials.verified, credentials.token);
  }

  Future<void> onSignUp(SignUpVerified credentials) async {
    final authState = AppAuthScope.of(context); // get auth state
    await authState.setAuth(credentials.signedIn, credentials.verified,
        credentials.username, credentials.deviceId, credentials.token);
  }

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context); // get route state
    final pathTemplate = routeState.route.pathTemplate;

    debugPrint('AppNavigator build ${routeState.route}');

    // // get book detail
    // Book? selectedBook;
    // if (pathTemplate == '/book/:bookId') {
    //   selectedBook = libraryInstance.allBooks.firstWhereOrNull(
    //       (b) => b.id.toString() == routeState.route.parameters['bookId']);
    // }
    //
    // // get author detail
    // Author? selectedAuthor;
    // if (pathTemplate == '/author/:authorId') {
    //   selectedAuthor = libraryInstance.allAuthors.firstWhereOrNull(
    //       (b) => b.id.toString() == routeState.route.parameters['authorId']);
    // }

    // return Navigation
    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, dynamic result) {
        if (route.settings is Page &&
            (route.settings as Page).key == _bookDetailsKey) {
          routeState.go('/');
        }

        if (route.settings is Page &&
            (route.settings as Page).key == _authorDetailsKey) {
          routeState.go('/authors');
        }

        return route.didPop(result);
      },
      pages: [
        if (routeState.route.pathTemplate == '/splash')
          FadeTransitionPage<void>(
            key: _splashKey,
            child: const SplashScreen(),
          )
        else if (routeState.route.pathTemplate == '/signin')
          FadeTransitionPage<void>(
            key: _signInKey,
            child: SignInScreen(
              onSignIn: onSignIn,
            ),
          )
        else if (routeState.route.pathTemplate == '/forgot')
          FadeTransitionPage<void>(
            key: _forgotKey,
            child: const ForgotPasswordScreen(),
          )
        else if (routeState.route.pathTemplate == '/otp')
          FadeTransitionPage<void>(
            key: _otpKey,
            child: OTPVerificationScreen(
              onBack: () {
                final authState = AppAuthScope.of(context);
                authState.signOut();
              },
              onVerified: onVerified,
            ),
          )
        else if (routeState.route.pathTemplate == '/signup')
          FadeTransitionPage<void>(
            key: _registrationKey,
            child: SignUpScreen(
              onBack: () {
                final routeState = RouteStateScope.of(context);
                routeState.go('/signin');
              },
              onVerified: onSignUp,
            ),
          )
        else ...[
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            // child: const AppScaffold(),
            child: const Homepage(),
          ),
          // // Add an additional page to the stack if the user is viewing a book
          // // or an author
          // if (selectedBook != null)
          //   MaterialPage<void>(
          //     key: _bookDetailsKey,
          //     child: BookDetailsScreen(
          //       book: selectedBook,
          //     ),
          //   )
          // else if (selectedAuthor != null)
          //   MaterialPage<void>(
          //     key: _authorDetailsKey,
          //     child: AuthorDetailsScreen(
          //       author: selectedAuthor,
          //     ),
          //   ),
        ],
      ],
    );
  }
}
