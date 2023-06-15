import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/data/transaction.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/utils/device.dart';

@immutable
class PushNotification {
  const PushNotification({
    this.title,
    this.body,
  });
  final String? title;
  final String? body;
}

class AppMessaging {
  static late final FirebaseMessaging _messaging;
  static late final AndroidNotificationChannel _localChannel;
  static late final FlutterLocalNotificationsPlugin _localNotification;
  static late BuildContext _context;

  AppMessaging._();

  static Future<void> initialize() async {
    _messaging = FirebaseMessaging.instance;
  }

  static Future _setupForegroundHandler() async {
    _localChannel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    _localNotification = FlutterLocalNotificationsPlugin();

    //
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    // var initializationSettingsIOS = IOSInitializationSettings(
    //     onDidReceiveLocalNotification: onDidRecieveLocalNotification);
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: initializationSettingsIOS,
    );
    _localNotification.initialize(initializationSettings,
        onSelectNotification: (e) {
      debugPrint('Messaging on Select Notification : ${e}');
    });

    await _localNotification
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_localChannel);
  }

  static Future requestPermission(BuildContext context) async {
    _context = context;

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Messaging User granted permission');
      _registerNotification();
      _setupListener();
      _checkForInitialMessage();
      // Only for Android https://firebase.flutter.dev/docs/messaging/notifications#android-configuration
      if (defaultTargetPlatform == TargetPlatform.android) {
        _setupForegroundHandler();
      }
    } else {
      debugPrint('Messaging User declined or has not accepted permission');
    }
  }

  static Future _registerNotification() async {
    String? token = await _messaging.getToken();
    debugPrint('Messaging token ${token}');
    var deviceInfo = await getDeviceInfo();
    var version = await getFullAppVersion();
    var osInfo = await getOSInfo();
    Api.subscribeMessaging(
      token: token ?? '',
      deviceInfo: deviceInfo,
      appVersion: version,
      osInfo: osInfo,
    ).then((response) {
      debugPrint('subscribeMessaging ${response.body}');
      // TODO Handle update notification
      // {"memberDevices":{"iddevice":184270,"agenid":"DLI0007","imei":"d1230b28487633f6","datereg":"2022-02-10 10:11:27","merk":"samsung","type":"SM-N976N","OS":"null | REL | 5.1.1 | 22","notification_token":"dKTZhbHPSjaLiGU2VzMcsC:APA91bFfAzqkXLxZbHDJrKgMy7Ty5JIHfI7GwOjQfcftau7SrsLy_AeIczJ0SCLCO0JcRoOC-wzF9AEdChlHh3ycqPN5BOuJNpDvwZNBZzwRqNaYt9KWgtfEhdGOls4U7mxq7tmalJKC","lat":null,"lon":null},"versioning":{"version":"SM-N976N","last_version":"175","update_available":false,"update_required":false,"info":null,"link":"https:\/\/play.google.com\/store\/apps\/details?id=com.moro.app"}}
    });
  }

  static Future _setupListener() async {
    _messaging.onTokenRefresh.listen(_onTokenRefresh);
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen(_realtimeHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpen);
  }

  static Future _onTokenRefresh(String event) async {
    debugPrint('Messaging token refresh ${event}');
    _registerNotification();
  }

  static Future _backgroundHandler(RemoteMessage message) async {
    debugPrint('Messaging background message: ${message.messageId}');
  }

  static Future _realtimeHandler(RemoteMessage message) async {
    debugPrint(
        'Messaging realtime data: ${message.data} ${message.notification}');

    if (message.data['notification_key'] != null) {
      var key = message.data['notification_key'] as String;
      if (key == 'purchase') {
        userBalanceState.fetchData();
        transactionState.updateState();
      } else if (key == 'deposit' ||
          key == 'mutasi' ||
          key == 'transfer_deposit') {
        userBalanceState.fetchData();
      }
    }

    // snackBarDialog(
    //   _context,
    //   message.notification!.body!,
    //   title: message.notification!.title,
    //   duration: 3000,
    // );

    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.
    if (message.notification != null && message.notification!.android != null) {
      var notification = message.notification!;
      var android = notification.android;
      _localNotification.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _localChannel.id,
              _localChannel.name,
              channelDescription: _localChannel.description,
              // icon: android?.smallIcon,
            ),
          ));
    }
  }

  static Future _onMessageOpen(RemoteMessage message) async {
    debugPrint('Messaging on open message : ${message.data}');
    // if (message.data['type'] == 'chat') {
    //   Navigator.pushNamed(context, '/chat',
    //     arguments: ChatArguments(message),
    //   );
    // }
  }

  // For handling notification when the app is in terminated state
  static Future _checkForInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    // if (initialMessage != null) {
    //   PushNotification notification = PushNotification(
    //     title: initialMessage.notification?.title,
    //     body: initialMessage.notification?.body,
    //   );
    // }
  }

  static Future subscribe(String topic) {
    return _messaging.subscribeToTopic(topic);
  }

  static Future unsubscribe(String topic) {
    return FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}
