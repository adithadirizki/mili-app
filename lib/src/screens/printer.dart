import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/purchase.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/user_config.dart';
import 'package:miliv2/src/services/printer.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/screen.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({Key? key}) : super(key: key);

  @override
  _PrinterScreenState createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  bool initialized = false;
  bool isLoading = false;
  bool bluetoothActive = false;
  late BluetoothPrint bluetoothPrint;

  bool connected = false;
  String? deviceAddress;
  String tips = 'Langkah-langkah koneksi Printer Bluetooth \n\n'
      '1. Nyalakan Printer & aktifkan Bluetooth \n'
      '2. Buka menu Setting -> Bluetooth kemudian pilih Printer, pastikan berhasil terhubung \n'
      '3. Pilih printer yang muncul pada halaman dibawah \n'
      '4. Lakukan setting Header atau Footer dan lakukan test print \n'
      '\n** Untuk info lebih lanjut silahkan ikuti petunjuk di Buku Manual Printer Anda';

  final formKey = GlobalKey<FormState>();
  late UserConfig printConfig;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await initDB();
      await initBluetooth();
    });
  }

  Future<void> initDB() async {
    UserConfig? prev = await AppPrinter.getPrinterConfig();
    if (prev == null) {
      printConfig = UserConfig(
        serverId: 0,
        userId: '',
        name: 'PRINTER_SETTING',
        config: json.encode(<String, dynamic>{}),
        lastUpdate: DateTime.now(),
      );
    } else {
      printConfig = prev;
    }
  }

  Future<void> initBluetooth() async {
    bluetoothActive = await AppPrinter.bluetoothActive;
    deviceAddress = AppPrinter.printerAddress;
    connected = deviceAddress != null;
    debugPrint(
        'initBluetooth address $deviceAddress active $bluetoothActive connected $connected');
    if (bluetoothActive) {
      AppPrinter.scanDevices();
    }
    initialized = true;
    setState(() {});
  }

  Future<void> printTest() async {
    setState(() {
      isLoading = true;
    });
    Api.getPrintSample().then((response) {
      setState(() {
        isLoading = false;
      });
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var struct = PurchaseHistoryDetailResponse.fromJson(bodyMap);
      AppPrinter.printPurchaseHistory(struct, context: context);
    });
  }

  Future<void> openPrintConfig() async {
    Map<String, dynamic> prevConfig = printConfig.configMap;
    showDialog<Widget>(
      context: context,
      builder: (ctx) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 100, maxHeight: 400),
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Header & Footer',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          TextFormField(
                            decoration: generateInputDecoration(
                              label: 'Header 1',
                              hint: 'contoh: Gisna Cell',
                            ),
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            onSaved: (newValue) {
                              prevConfig['header1'] = newValue;
                            },
                            initialValue: prevConfig['header1'] == null
                                ? ''
                                : (prevConfig['header1'] as String),
                          ),
                          TextFormField(
                            decoration: generateInputDecoration(
                              label: 'Header 2',
                              hint: 'contoh: Alamat',
                            ),
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            onSaved: (newValue) {
                              prevConfig['header2'] = newValue;
                            },
                            initialValue: prevConfig['header2'] == null
                                ? ''
                                : (prevConfig['header2'] as String),
                          ),
                          TextFormField(
                            decoration: generateInputDecoration(
                              label: 'Footer 1',
                              hint: '',
                            ),
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            onSaved: (newValue) {
                              prevConfig['footer1'] = newValue;
                            },
                            initialValue: prevConfig['footer1'] == null
                                ? ''
                                : (prevConfig['footer1'] as String),
                          ),
                          TextFormField(
                            decoration: generateInputDecoration(
                              label: 'Footer 2',
                              hint: '',
                            ),
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.done,
                            onSaved: (newValue) {
                              prevConfig['footer2'] = newValue;
                            },
                            initialValue: prevConfig['footer2'] == null
                                ? ''
                                : (prevConfig['footer2'] as String),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: const Text(
                            'Tutup',
                            // style: Theme.of(context).textTheme.button,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          child: const Text(
                            'Simpan',
                            // style: Theme.of(context).textTheme.button,
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              saveConfig(prevConfig);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> saveConfig(Map<String, dynamic> config) async {
    setState(() {
      isLoading = true;
    });
    printConfig.config = json.encode(config);
    Api.saveUserConfig(printConfig).then((res) {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      AppDB.syncUserConfig();
    });
  }

  Future<void> onRefresh() {
    return initBluetooth();
  }

  VoidCallback selectPrinter(BluetoothDevice d) {
    return () async {
      await AppPrinter.connect(d, context);
      setState(() {
        deviceAddress = d.address;
        connected = true;
      });
    };
  }

  Widget buildTop(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            'Bluetooth',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: Switch(
            onChanged: (_) {
              AppSettings.openBluetoothSettings();
            },
            value: bluetoothActive,
            activeColor: Colors.lightBlueAccent,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                child: Text(
                  tips,
                  overflow: TextOverflow.visible,
                  maxLines: 10,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget buildItems(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: initialized
          ? StreamBuilder<List<BluetoothDevice>>(
              stream: AppPrinter.streamer,
              initialData: const [],
              builder: (c, snapshot) {
                return snapshot.data != null && snapshot.data!.isNotEmpty
                    ? ListView(
                        children: snapshot.data!
                            .map((d) => ListTile(
                                  title: Text(
                                    d.name ?? '',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  subtitle: Text(
                                    d.address!,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  onTap: selectPrinter(d),
                                  trailing: deviceAddress != null &&
                                          (deviceAddress == d.address)
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        )
                                      : null,
                                ))
                            .toList(),
                      )
                    : Center(
                        child: Text(
                          'Tidak ada printer',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
              },
            )
          : const Center(
              child: Text('Please wait'),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar2(
        title: 'Konfigurasi Printer',
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.print),
            color: AppColors.gold3,
            onPressed: connected ? printTest : null,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            color: AppColors.gold3,
            onPressed: openPrintConfig,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          children: [
            buildTop(context),
            // const Divider(),
            FlexBoxGray(
              margin: const EdgeInsets.only(top: 10),
              child: buildItems(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    AppPrinter.stopScan();
    super.dispose();
  }
}
