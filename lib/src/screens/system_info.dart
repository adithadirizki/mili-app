import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/utils/device.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';

class SystemInfoScreen extends StatefulWidget {
  final String title;

  const SystemInfoScreen({Key? key, required this.title}) : super(key: key);

  @override
  _SystemInfoScreenState createState() => _SystemInfoScreenState();
}

class _SystemInfoScreenState extends State<SystemInfoScreen> {
  late String model = '-';
  late String deviceId = '-';
  late String osName = '-';
  late String appVersion = '-';
  late String buildNumber = '-';
  late String screen = '-';
  DateTime now = DateTime.now();
  late String ip = '-';
  late String isp = '-';
  late String timezone = '-';
  late String region = '-';
  late String databaseInfo = '-';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      initData();
    });
  }

  void initData() async {
    model = await getDeviceModel();
    deviceId = await getDeviceId();
    osName = await getOSName();
    appVersion = await getAppVersion();
    buildNumber = await getBuildNumber();
    var ratio = MediaQuery.of(context).devicePixelRatio;
    screen =
        '${(MediaQuery.of(context).size.width.ceil() * ratio).ceil()} x ${(MediaQuery.of(context).size.height.ceil() * ratio).ceil()}';
    try {
      var resp = await Api.clientInfo();

      debugPrint('Client info ${resp.body}');

      if (resp.statusCode == 200) {
        Map<String, dynamic> bodyMap =
            json.decode(resp.body) as Map<String, dynamic>;

        ip = bodyMap['ip'] == null ? '-' : bodyMap['ip'] as String;
        isp = bodyMap['org'] == null ? '-' : bodyMap['org'] as String;
        timezone =
            bodyMap['timezone'] == null ? '-' : bodyMap['timezone'] as String;
        region = bodyMap['region'] == null ? '-' : bodyMap['region'] as String;
      }
    } catch (e) {
      debugPrint('Error Client info ${e}');
    }
    try {
      var vendorCount = AppDB.vendorDB.count();
      var productCount = AppDB.productDB.count();

      databaseInfo = 'Data 1 (${productCount}) | Data 2 ($vendorCount) ';
      // '| Mutasi Utama ($mutasiCount) | Mutasi Kredit ($creditCount) | Notifikasi ($notificationCount) | Customer Service ($csCount) | Transaksi ($historyCount) | Topup ($topupCount)';
    } catch (e) {
      debugPrint('Error Client info ${e}');
    }
    setState(() {});
  }

  var loadingPercentage = 0;

  Widget buildContent(BuildContext context) {
    var titleStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1, height: 2);
    var contentStyle = Theme.of(context).textTheme.bodyMedium?.copyWith();
    return ListView(
      // mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Model',
          style: titleStyle,
        ),
        Text(
          '$model',
          style: contentStyle,
        ),
        Text(
          'Sistem Operasi',
          style: titleStyle,
        ),
        Text(
          osName,
          style: contentStyle,
        ),
        Text(
          'Ukuran Layar',
          style: titleStyle,
        ),
        Text(
          screen,
          style: contentStyle,
        ),
        Text(
          'Versi Aplikasi',
          style: titleStyle,
        ),
        Text(
          appVersion,
          style: contentStyle,
        ),
        Text(
          'Waktu',
          style: titleStyle,
        ),
        Text(
          formatDate(now, format: 'dd/MM/yyyy HH:mm:ss'),
          style: contentStyle,
        ),
        Text(
          'Timezone',
          style: titleStyle,
        ),
        Text(
          timezone,
          style: contentStyle,
        ),
        Text(
          'Wilayah',
          style: titleStyle,
        ),
        Text(
          region,
          style: contentStyle,
        ),
        Text(
          'ISP',
          style: titleStyle,
        ),
        Text(
          isp,
          style: contentStyle,
        ),
        Text(
          'IP',
          style: titleStyle,
        ),
        Text(
          ip,
          style: contentStyle,
        ),
        Text(
          'Data',
          style: titleStyle,
        ),
        Text(
          databaseInfo,
          style: contentStyle,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar2(
        title: widget.title,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: buildContent(context),
      ),
    );
  }
}
