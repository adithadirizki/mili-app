import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/purchase.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';
import 'package:miliv2/src/widgets/screen.dart';
import 'package:miliv2/src/widgets/wallet_card.dart';

class TransferWalletScreen extends StatefulWidget {
  final String title;
  final String? userId;

  const TransferWalletScreen(
      {Key? key, this.title = 'Transfer Saldo MyFinPay', this.userId})
      : super(key: key);

  @override
  _TransferWalletScreenState createState() => _TransferWalletScreenState();
}

class _TransferWalletScreenState extends State<TransferWalletScreen> {
  final formKey = GlobalKey<FormState>();
  TransferInquiryResponse? inquiryResponse;
  final TextEditingController textAmountController = TextEditingController();
  final TextEditingController textUserIdController = TextEditingController();
  final TextEditingController textDescController = TextEditingController();
  bool isLoading = false;

  TransferInfoResponse transferInfo = TransferInfoResponse('', 50000, 1000000);

  @override
  void initState() {
    super.initState();
    textUserIdController.text = widget.userId ?? '';
    WidgetsBinding.instance?.addPostFrameCallback((_) {
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

  void confirmation() {
    var amount = parseDouble(textAmountController.value.text);
    var userId = textUserIdController.value.text;
    if (formKey.currentState!.validate()) {
      confirmDialog(context,
          title: 'Transfer Saldo',
          msg:
              'Lanjutkan transfer saldo sebesar ${formatNumber(amount)} ke $userId ?',
          confirmAction: execTransfer,
          confirmText: 'Ya, lanjutkan',
          cancelText: 'Batal');
    }
  }

  void execTransfer() {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      var amount = parseDouble(textAmountController.value.text);
      var userId = textUserIdController.value.text;
      var desc = textDescController.value.text;
      Api.walletTransfer(amount, userId, desc).then((response) {
        Map<String, dynamic> bodyMap =
            json.decode(response.body) as Map<String, dynamic>;

        setState(() {
          isLoading = false;
        });
        userBalanceState.fetchWallet();
        popScreenWithCallback<bool>(context, true);
      }).catchError(handleError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(title: widget.title),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          children: [
            const WalletCard(),
            FlexBoxGray(
              margin: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
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
                        ),
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
                            if (amount > userBalanceState.walletBalance) {
                              return 'Saldo tidak mencukupi';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: textDescController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.singleLineFormatter,
                          ],
                          // onChanged: (string) {
                          //   textDescController.value = TextEditingValue(
                          //     text: string,
                          //     selection: TextSelection.collapsed(
                          //       offset: string.length,
                          //     ),
                          //   );
                          // },
                          decoration:
                              generateInputDecoration(label: 'Keterangan'),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value == '0') {
                              return 'Masukkan Keterangan';
                            }
                            return null;
                          },
                        ),
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
                  AppButton('Kirim', isLoading ? null : confirmation),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
