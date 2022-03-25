import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/purchase.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/routing.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/balance_card.dart';
import 'package:miliv2/src/widgets/button.dart';
import 'package:miliv2/src/widgets/screen.dart';

class TransferScreen extends StatefulWidget {
  final String? userId;

  const TransferScreen({Key? key, this.userId}) : super(key: key);

  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final formKey = GlobalKey<FormState>();
  TransferInquiryResponse? inquiryResponse;
  final TextEditingController textAmountController = TextEditingController();
  final TextEditingController textUserIdController = TextEditingController();
  bool isLoading = false;

  TransferInfoResponse transferInfo = TransferInfoResponse('', 50000, 1000000);

  @override
  void initState() {
    super.initState();
    textUserIdController.text = widget.userId ?? '';
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      initialize();
    });
  }

  void initialize() {
    void handleResponseInfo(http.Response response) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      debugPrint('Info $bodyMap');
      setState(() {
        isLoading = false;
        transferInfo = TransferInfoResponse.fromJson(
            bodyMap['data'] as Map<String, dynamic>);
      });
    }

    Api.getTransferInfo().then(handleResponseInfo).catchError(handleError);
  }

  FutureOr<void> handleError(Object e) {
    setState(() {
      isLoading = false;
    });
    snackBarDialog(context, e.toString());
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

  void inquiry() {
    if (userBalanceState.isGuest()) {
      confirmSignin();
    } else if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      var amount = parseDouble(textAmountController.value.text);
      var userId = textUserIdController.value.text;
      Api.inquiryTransfer(amount, userId).then((response) {
        Map<String, dynamic> bodyMap =
            json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          isLoading = false;
          inquiryResponse = TransferInquiryResponse.fromJson(bodyMap);
        });
      }).catchError(handleError);
    }
  }

  void confirmation() {
    var amount = parseDouble(textAmountController.value.text);
    var userId = textUserIdController.value.text;
    confirmDialog(context,
        title: 'Transfer Saldo',
        msg:
            'Lanjutkan transfer saldo sebesar ${formatNumber(amount)} ke $userId ?',
        confirmAction: execTransfer,
        confirmText: 'Ya, lanjutkan',
        cancelText: 'Batal');
  }

  void execTransfer() {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      var amount = parseDouble(textAmountController.value.text);
      var userId = textUserIdController.value.text;
      Api.transferBalance(amount, userId).then((response) {
        Map<String, dynamic> bodyMap =
            json.decode(response.body) as Map<String, dynamic>;

        setState(() {
          isLoading = false;
        });
        userBalanceState.fetchData();
        popScreenWithCallback<bool>(context, true);
      }).catchError(handleError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar(title: 'Transfer'),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          children: [
            const BalanceCard(),
            FlexBoxGray(
              margin: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: textAmountController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (string) {
                            if (inquiryResponse != null) {
                              setState(() {
                                inquiryResponse = null;
                              });
                            }
                            var amount = parseDouble(string);
                            if (amount > transferInfo.maxAmount) {
                              amount = transferInfo.maxAmount;
                            } else if (amount < 0) {
                              amount = 0;
                            }
                            string = formatNumber(amount);
                            textAmountController.value = TextEditingValue(
                              text: string,
                              selection: TextSelection.collapsed(
                                offset: string.length,
                              ),
                            );
                          },
                          decoration: generateInputDecoration(
                              hint: '1.000.000', label: 'Jumlah Transfer'),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value == '0') {
                              return 'Masukkan Jumlah Transfer';
                            }
                            var amount = parseDouble(value);
                            if (amount > transferInfo.maxAmount ||
                                amount < transferInfo.minAmount) {
                              return 'Jumlah tidak sesuai';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: textUserIdController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (string) {
                            if (inquiryResponse != null) {
                              setState(() {
                                inquiryResponse = null;
                              });
                            }
                          },
                          decoration: generateInputDecoration(
                              hint: '08xxxxxxxxxx', label: 'Nomor Penerima'),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value == '0') {
                              return 'Masukkan Nomor Penerima';
                            }
                            return null;
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // for (var bank in topupInfo.banks) _bankInfoBuilder(bank),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: inquiryResponse != null
                          ? Text(
                              inquiryResponse!.inquiryDetail,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(),
                            )
                          : isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : null,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      inquiryResponse == null
                          ? Text(
                              transferInfo.notes,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(),
                            )
                          : const Text(''),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  inquiryResponse == null
                      ? AppButton('Lanjutkan', isLoading ? null : inquiry)
                      : AppButton('Kirim', isLoading ? null : confirmation),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
