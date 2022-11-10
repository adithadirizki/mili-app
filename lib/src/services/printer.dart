import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/api/purchase.dart';
import 'package:miliv2/src/api/train.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/user_config.dart';
import 'package:miliv2/src/services/storage.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';

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
    _connected = await _printer.isConnected ?? false;
    _printerAddress = AppStorage.getPrinterAddress();

    _printer.state.listen((state) {
      switch (state) {
        case BluetoothPrint.CONNECTED:
          debugPrint('AppPrinter state Connected');
          _connected = true;
          break;
        case BluetoothPrint.DISCONNECTED:
          debugPrint('AppPrinter state Disconnected');
          _connected = false;
          break;
        default:
          break;
      }
    });

    debugPrint('AppPrinter connected $_connected');

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

  static Future<void> connect(
      BluetoothDevice device, BuildContext context) async {
    debugPrint('Printer connecting ${device.address}');
    simpleSnackBarDialog(context, 'Menghubungkan printer ...');
    await _printer.connect(device);
    _printerAddress = device.address;
    _connected = true;
    AppStorage.setPrinterAddress(device.address!);
    simpleSnackBarDialog(context, 'Berhasil menghubungkan printer ...');
  }

  static Future<void> disconnect() async {
    await _printer.disconnect();
    AppStorage.setPrinterAddress(null);
  }

  static Future<void> _print(List<LineText> rows,
      {Map<String, dynamic>? config, required BuildContext context}) async {
    if (!_connected) {
      debugPrint('AppPrinter not connected !!!');
      simpleSnackBarDialog(context, 'Printer tidak terhubung');
      return;
    }
    simpleSnackBarDialog(context, 'Mencetak data ...');
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
          content: '==============================',
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
        // footers.insert(0, LineText(linefeed: 1));
        rows.addAll(footers);
      }
    }

    await _printer.printReceipt(config ?? <String, dynamic>{}, rows);
  }

  static Future<void> _printByConfig(List<Map<String, dynamic>> configs,
      {Map<String, dynamic>? config, required BuildContext context}) async {
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

    // FIXME printConfig by column
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

    await _print(rows, context: context, config: config);
  }

  static Future<void> printStruct({required String struct, List<Map<String, dynamic>>? config, required BuildContext context}) async {
    if (config == null) {
      List<LineText> rows = [];
      rows.add(LineText(
        type: LineText.TYPE_TEXT,
        content: struct,
        weight: 0,
        align: LineText.ALIGN_LEFT,
        linefeed: 1,
      ));

      rows.add(LineText(
        linefeed: 1,
      ));

      await _print(rows, context: context);
    } else {
      await _printByConfig(config, context: context);
    }
  }

  static Future<void> printPurchaseHistory(PurchaseHistoryDetailResponse data,
      {Map<String, dynamic>? config, required BuildContext context}) async {
    if (data.config == null) {
      List<LineText> rows = [];
      rows.add(LineText(
        type: LineText.TYPE_TEXT,
        content: data.invoice,
        weight: 0,
        align: LineText.ALIGN_LEFT,
        linefeed: 1,
      ));

      rows.add(LineText(
        linefeed: 1,
      ));

      await _print(rows, context: context, config: config);
    } else {
      await _printByConfig(data.config!, context: context, config: config);
    }
  }

  static Future<void> printTrainReceipt(TrainBookingResponse data,
      {Map<String, dynamic>? config, required BuildContext context}) async {
    if (!_connected) {
      debugPrint('AppPrinter not connected !!!');
      return;
    }
    List<LineText> rows = [];
    rows.add(LineText(
      type: LineText.TYPE_TEXT,
      content:
          'Tanggal : ${formatDate(data.createdDatetime, format: 'dd/MM/yyyy HH:mm')}',
      weight: 0,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));
    rows.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Kereta : ${data.trainName}',
      weight: 0,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));
    rows.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'No : ${data.trainNo}',
      weight: 0,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));
    rows.add(LineText(
      type: LineText.TYPE_TEXT,
      content:
          'Stasiun : ${data.departure.stationName} (${data.departure.code})',
      weight: 0,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));
    rows.add(LineText(
      type: LineText.TYPE_TEXT,
      content:
          'Tanggal : ${formatDate(data.departureDatetime, format: 'EEEE, dd MMMM yyyy HH:mm')}',
      weight: 0,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));
    rows.add(LineText(
      type: LineText.TYPE_TEXT,
      content:
          'Penumpang : Dewasa (x${data.adultNum}) ${data.childNum > 0 ? ', Anak (x${data.childNum})' : ''}',
      weight: 0,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));
    rows.add(LineText(
      type: LineText.TYPE_TEXT,
      content:
          'Tujuan : ${data.destination.stationName} (${data.destination.code})',
      weight: 0,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));
    rows.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Waktu : ${data.estimationTime()}',
      weight: 0,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));
    rows.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Reff ID : ${data.bookingNumber}',
      weight: 0,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));
    rows.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Total : ${formatNumber(data.totalPrice)}',
      weight: 0,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));
    rows.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Admin : ${formatNumber(data.totalAdmin)}',
      weight: 0,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));
    if (data.totalDiscount > 0) {
      rows.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Potongan : ${formatNumber(data.totalDiscount)}',
        weight: 0,
        align: LineText.ALIGN_LEFT,
        linefeed: 1,
      ));
    }
    rows.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Bayar : ${formatNumber(data.grandTotal)}',
      weight: 0,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));
    rows.add(LineText(
      linefeed: 1,
    ));
    rows.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Kode Booking',
      weight: 0,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));
    rows.add(LineText(
      type: LineText.TYPE_TEXT,
      content: data.bookingCode,
      weight: 0,
      height: 1,
      width: 1,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));
    rows.add(LineText(
      linefeed: 1,
    ));
    rows.add(LineText(
      type: LineText.TYPE_QRCODE,
      content: data.bookingCode,
      weight: 0,
      size: 7,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    await _print(rows, context: context, config: config);
  }
}
