import 'package:flutter/widgets.dart';

class PrinterSelector extends StatefulWidget {
  const PrinterSelector({Key? key}) : super(key: key);

  @override
  _PrinterSelectorState createState() => _PrinterSelectorState();
}

class _PrinterSelectorState extends State<PrinterSelector> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) => initBluetooth());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    // bluetoothPrint = BluetoothPrint.instance;
    // bluetoothPrint.startScan(timeout: const Duration(seconds: 10));
    //
    // bool isConnected = await bluetoothPrint.isConnected ?? false;
    //
    // bluetoothPrint.state.listen((state) {
    //   print('cur device status: $state');
    //
    //   switch (state) {
    //     case BluetoothPrint.CONNECTED:
    //       setState(() {
    //         _connected = true;
    //         tips = 'connect success';
    //       });
    //       break;
    //     case BluetoothPrint.DISCONNECTED:
    //       setState(() {
    //         _connected = false;
    //         _device = null;
    //         tips = 'disconnect success';
    //       });
    //       break;
    //     default:
    //       break;
    //   }
    // });
    //
    // if (!mounted) return;
    //
    // if (isConnected) {
    //   setState(() {
    //     _connected = true;
    //     initialized = true;
    //   });
    // } else {
    //   setState(() {
    //     initialized = true;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
