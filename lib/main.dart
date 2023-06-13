// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:miliv2/firebase_options.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/services/analytics.dart';
import 'package:miliv2/src/services/messaging.dart';
import 'package:miliv2/src/services/onesignal.dart';
import 'package:miliv2/src/services/printer.dart';
import 'package:miliv2/src/services/storage.dart';
import 'package:url_strategy/url_strategy.dart';

import 'src/app.dart';

void main() async {
  // Use package:url_strategy until this pull request is released:
  // https://github.com/flutter/flutter/pull/77103

  // Use to setHashUrlStrategy() to use "/#/" in the address bar (default). Use
  // setPathUrlStrategy() to use the path. You may need to configure your web
  // server to redirect all paths to index.html.
  //
  // On mobile platforms, both functions are no-ops.
  setHashUrlStrategy();
  // setPathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AppStorage.initialize();
  await AppAnalytic.initialize();
  await AppMessaging.initialize();
  // await AppPrinter.initialize();
  await AppDB.initialize();
  await AppOnesignal.initialize();

  await initializeDateFormatting('id_ID', null);

  runApp(const App());
}
