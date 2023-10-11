import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/data/transaction.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/reference/flip/widgets/button.dart';
import 'package:miliv2/src/reference/flip/widgets/dialog.dart';
import 'package:miliv2/src/services/auth.dart';
import 'package:miliv2/src/services/storage.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';

class PaymentScreenFlip extends StatefulWidget {
  final String destination;
  final Vendor vendor;
  final String accountName;
  final double amount;
  final double adminFee;
  final double nominal;

  const PaymentScreenFlip({
    Key? key,
    required this.destination,
    required this.vendor,
    required this.accountName,
    required this.amount,
    required this.adminFee,
    required this.nominal,
  }) : super(key: key);

  @override
  _PaymentScreenFlipState createState() => _PaymentScreenFlipState();
}

class _PaymentScreenFlipState extends State<PaymentScreenFlip> {
  PaymentMethod selectedPayment = PaymentMethod.none;
  bool isLoading = false;
  String trxId = '';
  bool hasConfirmPayment = false;

  @override
  void initState() {
    super.initState();
    trxId = DateTime.now().millisecondsSinceEpoch.toString();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (userBalanceState.isGuest()) {
        confirmSignin(context);
        return;
      }
    });
  }

  bool isValid() {
    return selectedPayment != PaymentMethod.none &&
        sufficientBalance() != false;
  }

  void confirmPayment() {
    if (isLoading) return;

    if (AppAuth.pinTransactionRequired()) {
      AppAuth.pinAuthentication(context, (context) {
        popScreen(context);
        execPayment();
      });
    } else {
      confirmDialogFlip(
        context: context,
        title: 'Lanjutkan Transfer?',
        description:
            'Pastikan nomor rekening tujuan dan jumlah transfer kamu sudah benar',
        onConfirm: execPayment,
        onCancel: () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  FutureOr<Null> _handleError(Object e) async {
    alertDialogFlip(context, e.toString());
    setState(() {
      isLoading = false;
    });
    return;
  }

  void onPaymentProcessed() {
    confirmDialogFlip(
      context: context,
      title: 'Transfer Sedang Diproses',
      description:
          'Tunggu beberapa saat, transfer akan dikirim ke rekening tujuan',
      onConfirm: () {
        // close onPaymentProcessed
        Navigator.of(context).pop();
      },
      confirmText: 'Kembali',
    );
  }

  Future<void> execPayment() async {
    // close confirmPayment
    Navigator.of(context).pop();

    setState(() {
      isLoading = true;
    });
    //  TODO Kirim pembelian ke api dan panggil listener
    Api.purchaseProduct(
      trxId: trxId,
      productCode: widget.vendor.paymentCode,
      destination: widget.destination,
      method: selectedPayment,
    ).then((_) async {
      setState(() {
        isLoading = false;
        hasConfirmPayment = true;
      });
      userBalanceState.fetchData();
      transactionState.updateState();
      AppStorage.setPaymentMethod(selectedPayment);
      onPaymentProcessed();
    }).catchError(_handleError);
  }

  bool sufficientBalance() {
    if (selectedPayment == PaymentMethod.mainBalance) {
      return widget.amount <= userBalanceState.balance;
    } else if (selectedPayment == PaymentMethod.creditBalance) {
      return widget.amount <= userBalanceState.balanceCredit;
    } else if (selectedPayment == PaymentMethod.wallet) {
      return widget.amount <= userBalanceState.walletBalance;
    }
    return false;
  }

  double getBalance() {
    if (selectedPayment == PaymentMethod.mainBalance) {
      return userBalanceState.balance;
    } else if (selectedPayment == PaymentMethod.creditBalance) {
      return userBalanceState.balanceCredit;
    } else if (selectedPayment == PaymentMethod.wallet) {
      return userBalanceState.walletBalance;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 0,
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(90),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.black45,
                  size: 30,
                ),
              ),
              onTap: () {
                Navigator.maybePop(context);
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'Transfer Sekarang',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      body: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 25,
                          horizontal: 15,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF4FA),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Row(
                          children: [
                            CachedNetworkImage(
                              width: 70,
                              height: 50,
                              imageUrl: widget.vendor.getImageUrl(),
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.accountName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    widget.destination,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 15,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Jumlah Transfer',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  'Rp${formatNumber(widget.nominal)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Biaya Admin',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  'Rp${formatNumber(widget.adminFee)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Metode Transfer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                RadioListTile<PaymentMethod>(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  title: const Text(
                    'Saldo MILI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  subtitle: Text(
                    'Rp${formatNumber(userBalanceState.walletBalance)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                    ),
                  ),
                  value: selectedPayment,
                  groupValue: PaymentMethod.wallet,
                  onChanged: (value) {
                    setState(() {
                      selectedPayment = PaymentMethod.wallet;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.trailing,
                  activeColor: const Color(0xFFFF5731),
                ),
                RadioListTile<PaymentMethod>(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  title: const Text(
                    'Koin MILI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  subtitle: Text(
                    'Rp${formatNumber(userBalanceState.balance)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                    ),
                  ),
                  value: selectedPayment,
                  groupValue: PaymentMethod.mainBalance,
                  onChanged: (value) {
                    setState(() {
                      selectedPayment = PaymentMethod.mainBalance;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.trailing,
                  activeColor: const Color(0xFFFF5731),
                ),
                RadioListTile<PaymentMethod>(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  title: const Text(
                    'Saldo Kredit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  subtitle: Text(
                    'Rp${formatNumber(userBalanceState.balanceCredit)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                    ),
                  ),
                  value: selectedPayment,
                  groupValue: PaymentMethod.creditBalance,
                  onChanged: (value) {
                    setState(() {
                      selectedPayment = PaymentMethod.creditBalance;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.trailing,
                  activeColor: const Color(0xFFFF5731),
                  dense: true,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Transfer',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Rp${formatNumber(widget.amount)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            ButtonFlip(
              child: isLoading
                  ? Transform.scale(
                      scale: 0.5,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 5,
                      ),
                    )
                  : Text(hasConfirmPayment ? 'Kembali' : 'Lanjutkan'),
              onPressed: hasConfirmPayment
                  ? () => Navigator.of(context).pop()
                  : sufficientBalance() && selectedPayment != PaymentMethod.none
                      ? confirmPayment
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
