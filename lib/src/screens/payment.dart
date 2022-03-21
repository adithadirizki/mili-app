import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/data/transaction.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/routing.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';
import 'package:miliv2/src/widgets/screen.dart';

@immutable
class SummaryItems {
  final String itemDescription;
  final double price;

  const SummaryItems(this.itemDescription, this.price);
}

class PaymentScreen extends StatefulWidget {
  final String purchaseCode;
  final String destination;
  final String description;
  final double total;
  final List<SummaryItems> items;
  final VoidCallback onPaymentConfirmed;

  const PaymentScreen({
    Key? key,
    required this.purchaseCode,
    required this.destination,
    required this.description,
    required this.items,
    required this.onPaymentConfirmed,
    required this.total,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod selectedPayment = PaymentMethod.mainBalance;
  bool isLoading = false;
  String trxId = '';

  @override
  void initState() {
    super.initState();
    trxId = DateTime.now().millisecondsSinceEpoch.toString();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (userBalanceState.isGuest()) {
        confirmSignin();
      }
    });
  }

  void confirmSignin() {
    confirmDialog(
      context,
      title: 'Konfirmasi',
      msg:
          'Anda perlu melakukan Pendaftaran atau Login untuk melanjutkan transaksi',
      confirmAction: () {
        RouteStateScope.of(context).go('/signin');
      },
      confirmText: 'Ya, lanjutkan',
      cancelText: 'Batal',
    );
  }

  void confirmPayment() {
    confirmDialog(
      context,
      title: 'Konfirmasi',
      msg: 'Lanjutkan pembelian ?',
      confirmAction: execPayment,
      confirmText: 'Ya, lanjutkan',
      cancelText: 'Batal',
    );
  }

  FutureOr<Null> _handleError(Object e) async {
    snackBarDialog(context, e.toString());
    setState(() {
      isLoading = false;
    });
    return;
  }

  Future<void> execPayment() async {
    // popScreen(context);
    setState(() {
      isLoading = true;
    });
    //  TODO Kirim pembelian ke api dan panggil listener
    Api.purchaseProduct(
      trxId: trxId,
      productCode: widget.purchaseCode,
      destination: widget.destination,
      method: selectedPayment,
    ).then((_) async {
      setState(() {
        isLoading = false;
      });
      await popScreen(context);
      userBalanceState.fetchData();
      transactionState.updateState();
      widget.onPaymentConfirmed();
    }).catchError(_handleError);
  }

  bool sufficientBalance() {
    if (selectedPayment == PaymentMethod.mainBalance) {
      return widget.total <= userBalanceState.balance;
    } else if (selectedPayment == PaymentMethod.creditBalance) {
      return widget.total <= userBalanceState.balanceCredit;
    }
    return false;
  }

  double getBalance() {
    if (selectedPayment == PaymentMethod.mainBalance) {
      return userBalanceState.balance;
    } else if (selectedPayment == PaymentMethod.creditBalance) {
      return userBalanceState.balanceCredit;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar(title: 'Pembayaran'),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Metode Pembayaran',
              style: Theme.of(context).textTheme.headline5,
            ),
            DropdownButton<PaymentMethod>(
              value: selectedPayment,
              icon: const Icon(Icons.arrow_drop_down_circle_outlined),
              // elevation: 16,
              // style: const TextStyle(color: Colors.deepPurple),
              // underline: Container(
              //   height: 2,
              //   color: Colors.deepPurpleAccent,
              // ),
              onChanged: (newValue) {
                selectedPayment = newValue!;
                setState(() {});
              },
              items: <PaymentMethod>[
                PaymentMethod.mainBalance,
                PaymentMethod.creditBalance
              ].map<DropdownMenuItem<PaymentMethod>>((value) {
                return DropdownMenuItem<PaymentMethod>(
                  value: value,
                  child: paymentMethodLabel[value] != null
                      ? Text(
                          paymentMethodLabel[value]!,
                          style: Theme.of(context)
                              .textTheme
                              .button!
                              .copyWith(fontSize: 18),
                        )
                      : Text(
                          'Tidak diketahui',
                          style: Theme.of(context).textTheme.button!.copyWith(),
                        ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            FlexBoxGray(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Detail'),
                          Text(widget.description),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      top: 30,
                      bottom: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Saldo'),
                          Text(formatNumber(getBalance())),
                        ],
                      ),
                      for (var e in widget.items)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                e.itemDescription,
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            Text(formatNumber(e.price)),
                          ],
                        ),
                      const Divider(
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sisa Saldo'),
                          Text(formatNumber(getBalance() - widget.total)),
                        ],
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            AppButton('Bayar',
                isLoading || !sufficientBalance() ? null : confirmPayment),
          ],
        ),
      ),
    );
  }
}
