import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:miliv2/src/screens/qris_payment.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrisScannerScreen extends StatefulWidget {
  final String title;

  const QrisScannerScreen({Key? key, this.title = 'Scan QRIS'}) : super(key: key);

  @override
  State<QrisScannerScreen> createState() => _QrisScannerScreenState();
}

class _QrisScannerScreenState extends State<QrisScannerScreen> {

  bool isLoading = false;

  FutureOr<void> handleError(Object e) {
    setState(() {
      isLoading = false;
    });
    snackBarDialog(context, e.toString());
    popScreen(context);
  }

  void fetchWidget(String paymentCode) {
      replaceScreen(
        context,
        (_) => QrisPaymentScreen(paymentCode: paymentCode),
      );
  }

  @override
  Widget build(BuildContext context) {
    MobileScannerController cameraController = MobileScannerController();
    return Scaffold(
      appBar: SimpleAppBar2(title: widget.title, actions: [
            IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.torchState,
                builder: (context, state, child) {
                  switch (state as TorchState) {
                    case TorchState.off:
                      return const Icon(Icons.flash_off, color: AppColors.blue1);
                    case TorchState.on:
                      return const Icon(Icons.flash_on, color: Colors.yellow);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.toggleTorch(),
            ),
            IconButton(
              color: AppColors.blue1,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.cameraFacingState,
                builder: (context, state, child) {
                  switch (state as CameraFacing) {
                    case CameraFacing.front:
                      return const Icon(Icons.camera_front);
                    case CameraFacing.back:
                      return const Icon(Icons.camera_rear);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.switchCamera(),
            ),
          ],
      ),
      body: MobileScanner(
          allowDuplicates: false,
          controller: cameraController,
          onDetect: (barcode, args) {
            if (barcode.rawValue == null) {
              // debugPrint('Failed to scan Barcode');
            } else {
              final String code = barcode.rawValue!;
              confirmDialog(context, msg: 'Kode Pembayaran berhasil terbaca, lanjutkan ?', confirmAction: () {
                Timer(const Duration(milliseconds: 200), () {
                  // popScreenWithCallback<String>(context, code);
                  fetchWidget(code);
                });
              }, cancelAction: () {
                popScreen(context);
              });
            }
          }),
    );
  }
}