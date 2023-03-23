import 'dart:async';

import 'package:flutter/material.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/data/transaction.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/services/auth.dart';
import 'package:miliv2/src/services/storage.dart';
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
  final int? totalVcr;
  final String description;
  final double total;
  final List<SummaryItems> items;
  final VoidCallback onPaymentConfirmed;

  const PaymentScreen({
    Key? key,
    required this.purchaseCode,
    required this.destination,
    this.totalVcr,
    required this.description,
    required this.items,
    required this.onPaymentConfirmed,
    required this.total,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod selectedPayment =
      AppStorage.getPaymentMethod() ?? PaymentMethod.wallet;
  bool isLoading = false;
  String trxId = '';

  @override
  void initState() {
    super.initState();
    // selectedPayment = !userBalanceState.walletActive
    //     ? PaymentMethod.mainBalance
    //     : PaymentMethod.wallet;
    trxId = DateTime.now().millisecondsSinceEpoch.toString();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (userBalanceState.isGuest()) {
        confirmSignin(context);
        return;
      }
    });
  }

  void confirmPayment() {
    if (AppAuth.pinTransactionRequired()) {
      AppAuth.pinAuthentication(context, (context) {
        popScreen(context);
        execPayment();
      });
    } else {
      confirmDialog(
        context,
        title: 'Konfirmasi',
        msg: 'Lanjutkan pembelian ?',
        confirmAction: execPayment,
        confirmText: 'Ya, lanjutkan',
        cancelText: 'Batal',
      );
    }
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
      totalVcr: widget.totalVcr,
      method: selectedPayment,
    ).then((_) async {
      setState(() {
        isLoading = false;
      });
      await popScreen(context);
      userBalanceState.fetchData();
      transactionState.updateState();
      AppStorage.setPaymentMethod(selectedPayment);
      widget.onPaymentConfirmed();
    }).catchError(_handleError);
  }

  bool sufficientBalance() {
    if (selectedPayment == PaymentMethod.mainBalance) {
      return widget.total <= userBalanceState.balance;
    } else if (selectedPayment == PaymentMethod.creditBalance) {
      return widget.total <= userBalanceState.balanceCredit;
    } else if (selectedPayment == PaymentMethod.wallet) {
      return widget.total <= userBalanceState.walletBalance;
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
              style: Theme.of(context).textTheme.titleMedium,
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
                PaymentMethod.wallet,
                PaymentMethod.mainBalance,
                PaymentMethod.creditBalance
              ].map<DropdownMenuItem<PaymentMethod>>((value) {
                return DropdownMenuItem<PaymentMethod>(
                  value: value,
                  child: paymentMethodLabel[value] != null
                      ? Text(
                          paymentMethodLabel[value]!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      : Text(
                          'Tidak diketahui',
                          style: Theme.of(context).textTheme.bodyMedium,
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
                          const Text('Detail', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(
                            widget.description,
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
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
                          Text(
                            'Saldo',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            formatNumber(getBalance()),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
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
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              formatNumber(e.price),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      const Divider(
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sisa Saldo',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            formatNumber(getBalance() - widget.total),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
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
