import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/user_config.dart';
import 'package:miliv2/src/services/storage.dart';

/// See https://pub.dev/packages/bluetooth_print for detail
class AppPrinter {
  static bool _initialized = false;
  static bool _connected = false;
  static late final BluetoothPrint _printer;
  static String? _printerAddress;

  AppPrinter._();

  static Future<void> initialize() async {
    if (_initialized) return;

    _printer = BluetoothPrint.instance;
    // _connected = await _printer.isConnected ?? false;
    _printerAddress = AppStorage.getPrinterAddress();

    _printer.state.listen((state) {
      switch (state) {
        case BluetoothPrint.CONNECTED:
          debugPrint('Printer state Connected');
          if (_printerAddress != null && !_connected) {
            _printer.scanResults.listen((deviceList) {
              var devices =
                  deviceList.where((d) => d.address == _printerAddress);
              if (devices.isNotEmpty) {
                connect(devices.first);
              }
            });
          }
          // _connected = true;
          break;
        case BluetoothPrint.DISCONNECTED:
          debugPrint('Printer state Disconnected');
          // _connected = false;
          break;
        default:
          break;
      }
    });

    // Reconnect
    if (_printerAddress != null) {
      Map<String, dynamic> deviceData = <String, dynamic>{};
      deviceData['name'] = 'Default Printer';
      deviceData['address'] = _printerAddress;
      deviceData['connected'] = true;
      BluetoothDevice device = BluetoothDevice.fromJson(deviceData);
      _printer.connect(device);
    }

    _initialized = true;
  }

  static Future<UserConfig?> getPrinterConfig() async {
    UserConfig? config = AppDB.userConfigDB
        .query(UserConfig_.name
            .equals('PRINTER_SETTING')
            .and(UserConfig_.userId.equals(userBalanceState.userId)))
        .build()
        .findFirst();
    return config;
  }

  static Future<void> scanDevices() async {
    await _printer.stopScan();
    return _printer.startScan(timeout: const Duration(seconds: 20));
  }

  static Future<void> stopScan() async {
    await _printer.stopScan();
  }

  static Future<bool> get bluetoothActive {
    return _printer.isOn;
  }

  static bool get connected {
    return _connected;
  }

  static String? get printerAddress {
    return _printerAddress;
  }

  static Stream<List<BluetoothDevice>> get streamer {
    return _printer.scanResults;
  }

  static Future<void> connect(BluetoothDevice device) async {
    debugPrint('Printer connecting ${device.address}');
    await _printer.connect(device);
    _printerAddress = device.address;
    _connected = true;
    AppStorage.setPrinterAddress(device.address!);
  }

  static Future<void> disconnect() async {
    await _printer.disconnect();
    AppStorage.setPrinterAddress(null);
  }

  static Future<void> print(List<LineText> rows,
      {Map<String, dynamic>? config}) async {
    if (!_connected) {
      debugPrint('WARN Printer disconnected !!!');
      return;
    }
    UserConfig? printerConfig = await getPrinterConfig();
    if (printerConfig != null) {
      var configMap = printerConfig.configMap;

      List<LineText> headers = [];
      if (configMap.containsKey('header1') && configMap['header1'] != null) {
        headers.add(LineText(
          weight: 1,
          width: 1,
          type: LineText.TYPE_TEXT,
          align: LineText.ALIGN_CENTER,
          content: configMap['header1'] as String,
          linefeed: 1,
        ));
      }
      if (configMap.containsKey('header2') && configMap['header2'] != null) {
        headers.add(LineText(
          weight: 0,
          type: LineText.TYPE_TEXT,
          align: LineText.ALIGN_CENTER,
          content: configMap['header2'] as String,
          linefeed: 1,
        ));
      }
      if (headers.isNotEmpty) {
        headers.add(LineText(
          type: LineText.TYPE_TEXT,
          align: LineText.ALIGN_CENTER,
          content: '------------------------------',
          underline: 2,
          linefeed: 1,
        ));
        rows.insertAll(0, headers);
      }

      List<LineText> footers = [];
      if (configMap.containsKey('footer1') && configMap['footer1'] != null) {
        footers.add(LineText(
          weight: 0,
          type: LineText.TYPE_TEXT,
          align: LineText.ALIGN_CENTER,
          content: configMap['footer1'] as String,
          linefeed: 1,
        ));
      }
      if (configMap.containsKey('footer2') && configMap['footer2'] != null) {
        footers.add(LineText(
          weight: 0,
          type: LineText.TYPE_TEXT,
          align: LineText.ALIGN_CENTER,
          content: configMap['footer2'] as String,
          linefeed: 1,
        ));
      }
      if (footers.isNotEmpty) {
        footers.insert(0, LineText(linefeed: 1));
        rows.addAll(footers);
      }
    }

    await _printer.printReceipt(config ?? <String, dynamic>{}, rows);
  }

  static Future<void> printConfig(List<Map<String, dynamic>> configs,
      {Map<String, dynamic>? config}) async {
    List<LineText> rows = [];

    // build LineText from config
    LineText buildRow(Map<String, dynamic> config, bool newLine) {
      var align = LineText.ALIGN_LEFT;
      int? width, height;
      int? linefeed = newLine ? 1 : null;
      if (config.containsKey('align')) {
        switch (config['align'].toString().toUpperCase()) {
          case 'CENTER':
            align = LineText.ALIGN_CENTER;
            break;
          case 'RIGHT':
            align = LineText.ALIGN_RIGHT;
            break;
        }
      }
      // Max character
      // if (config.containsKey('width')) {
      //   width = config['width'] as int?;
      // }
      if (config.containsKey('config') &&
          (config['config'] as Map<String, dynamic>).containsKey('width')) {
        width = config['config']['width'] as int?;
      }
      if (config.containsKey('config') &&
          (config['config'] as Map<String, dynamic>).containsKey('height')) {
        height = config['config']['height'] as int?;
      }
      return LineText(
        weight: 0,
        type: LineText.TYPE_TEXT,
        align: align,
        content: config['text'].toString(),
        width: width,
        height: height,
        linefeed: linefeed,
      );
    }

    for (var config in configs) {
      if (config.containsKey('columns')) {
        var columns = config['columns'] as List<dynamic>;
        for (var col in columns) {
          rows.add(buildRow(col as Map<String, dynamic>,
              columns.indexOf(col) == columns.length - 1));
        }
      } else if (config.containsKey('text')) {
        rows.add(buildRow(config, true));
      }
    }

    await print(rows, config: config);
  }
}
