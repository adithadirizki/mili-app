import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miliv2/src/screens/qris_payment.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/scanning_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrisScannerScreen extends StatefulWidget {
  final String title;

  const QrisScannerScreen({Key? key, this.title = 'Scan QRIS'})
      : super(key: key);

  @override
  State<QrisScannerScreen> createState() => _QrisScannerScreenState();
}

class _QrisScannerScreenState extends State<QrisScannerScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;

  late AnimationController _animationController;
  bool _animationStopped = false;

  @override
  void initState() {
    _animationController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animateScanAnimation(true);
      } else if (status == AnimationStatus.dismissed) {
        animateScanAnimation(false);
      }
    });

    animateScanAnimation(true);

    super.initState();
  }

  FutureOr<void> handleError(Object e) {
    setState(() {
      isLoading = false;
    });
    snackBarDialog(context, e.toString());
    popScreen(context);
  }

  void paymentWidget(String paymentCode) {
    replaceScreen(
      context,
      (_) => QrisPaymentScreen(
        paymentCode: paymentCode,
        title: 'Pembayaran QRIS',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MobileScannerController cameraController = MobileScannerController();
    return Scaffold(
      appBar: SimpleAppBar2(
        title: widget.title,
        actions: [
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
      body: Container(
        color: AppColors.white1,
        padding:
            const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Image(
              image: AppImages.logoColor,
              height: 40,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 20),
            Text(
              'Scan Kode QR',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white1,
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              constraints: const BoxConstraints(
                minHeight: 200,
                minWidth: 200,
                maxWidth: 350,
                maxHeight: 400,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                // fit: StackFit.expand,
                children: [
                  MobileScanner(
                    fit: BoxFit.cover,
                    allowDuplicates: false,
                    controller: cameraController,
                    onDetect: (barcode, args) {
                      if (barcode.rawValue == null) {
                        // debugPrint('Failed to scan Barcode');
                      } else {
                        setState(() {
                          _animationStopped = true;
                        });
                        final String code = barcode.rawValue!;
                        confirmDialog(context,
                            msg:
                                'Kode Pembayaran berhasil terbaca, lanjutkan ?',
                            confirmAction: () {
                          Timer(const Duration(milliseconds: 200), () {
                            // popScreenWithCallback<String>(context, code);
                            paymentWidget(code);
                          });
                        }, cancelAction: () {
                          popScreen(context);
                        });
                      }
                    },
                  ),
                  ScannerAnimation(
                    _animationStopped,
                    400,
                    animation: _animationController,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void animateScanAnimation(bool reverse) {
    if (reverse) {
      _animationController.reverse(from: 1.0);
    } else {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
