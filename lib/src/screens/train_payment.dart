import 'dart:async';

import 'package:flutter/material.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/train.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/data/transaction.dart';
import 'package:miliv2/src/data/user_balance.dart';
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

class TrainPaymentScreen extends StatefulWidget {
  final TrainBookingResponse booking;
  final VoidCallback onPaymentConfirmed;

  const TrainPaymentScreen({
    Key? key,
    required this.booking,
    required this.onPaymentConfirmed,
  }) : super(key: key);

  @override
  _TrainPaymentScreenState createState() => _TrainPaymentScreenState();
}

class _TrainPaymentScreenState extends State<TrainPaymentScreen> {
  PaymentMethod selectedPayment = PaymentMethod.mainBalance;
  bool isLoading = false;
  String trxId = '';

  @override
  void initState() {
    super.initState();
    trxId = DateTime.now().millisecondsSinceEpoch.toString();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (userBalanceState.isGuest()) {
        confirmSignin(context);
      }
    });
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
    Api.payTrainBooking(booking: widget.booking).then((_) async {
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
      return widget.booking.grandTotal <= userBalanceState.balance;
    } else if (selectedPayment == PaymentMethod.creditBalance) {
      return widget.booking.grandTotal <= userBalanceState.balanceCredit;
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
    var data = widget.booking;
    var description = 'Pembelian Tiket Kereta';
    description +=
        '\nDari ${data.departure['name']} (${data.departure['code']}) ke ${data.destination['name']} (${data.destination['code']})';
    description +=
        '\nPenumpang (${data.passengers.map((e) => e['name'] as String).join(',')})';
    description +=
        '\nKeberangkatan ${formatDate(data.departureDatetime, format: 'EEEE, dd MMMM yyyy')} jam ${formatDate(data.departureDatetime, format: 'HH:mm')}';
    description += '\nKereta ${data.trainName} ${data.trainNo}';

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
                PaymentMethod.mainBalance,
                // PaymentMethod.creditBalance
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
                          const Text('Detail'),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodySmall,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              'Jumlah Pembayaran',
                              maxLines: 2,
                              overflow: TextOverflow.fade,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            formatNumber(data.grandTotal),
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
                            formatNumber(
                                getBalance() - widget.booking.grandTotal),
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
