import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/topup.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/screens/topup_history.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/balance_card.dart';
import 'package:miliv2/src/widgets/button.dart';
import 'package:miliv2/src/widgets/screen.dart';

class TopupScreen extends StatefulWidget {
  const TopupScreen({Key? key}) : super(key: key);

  @override
  _TopupScreenState createState() => _TopupScreenState();
}

class _TopupScreenState extends State<TopupScreen> {
  final formKey = GlobalKey<FormState>();
  TopupInfoResponse topupInfo = TopupInfoResponse('', [], 0, 1000000);
  final TextEditingController textAmountController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initialize();
    });
  }

  void initialize() {
    void handleResponseInfo(http.Response response) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      setState(() {
        isLoading = false;
        topupInfo =
            TopupInfoResponse.fromJson(bodyMap['data'] as Map<String, dynamic>);
      });
    }

    Api.getTopupInfo().then(handleResponseInfo).catchError(handleError);
  }

  FutureOr<void> handleError(dynamic e) {
    setState(() {
      isLoading = false;
    });
    snackBarDialog(context, e.toString());
  }

  void submitData() {
    if (userBalanceState.isGuest()) {
      confirmSignin(context);
    } else if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      var amount = parseDouble(textAmountController.value.text);
      Api.createTopupTicket(amount).then((response) {
        int? id;
        debugPrint('Tiket ${response}');
        if (response.containsKey('data') &&
            (response['data'] as Map<String, dynamic>).containsKey('id')) {
          id = response['data']['id'] as int;
        }
        replaceScreen(context, (_) => TopupHistoryScreen(openDetail: id));
      }).catchError(handleError);
    }
  }

  Widget bankItem(BankInfo bank) {
    return Card(
      child: ListTile(
        // leading: Icon(Icons.album),
        title: Text(
          bank.accountNumber,
        ),
        subtitle: Text(
          bank.bankName + ' a/n ' + bank.accountName,
        ),
        trailing: TextButton(
          child: const Text(
            'Salin',
          ),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: bank.accountNumber));
            snackBarDialog(context, 'Nomor rekening disalin');
          },
          style: textButtonStyle,
        ),
      ),
    );
  }

  Future<void> openHistory() async {
    pushScreen(
      context,
      (_) => const TopupHistoryScreen(),
    );
  }

  Widget buildBankList(BuildContext context) {
    return Flexible(
      flex: 1,
      fit: FlexFit.tight,
      child: isLoading && topupInfo.banks.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : ListView(
              children: [
                for (var bank in topupInfo.banks) bankItem(bank),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(
        title: 'Topup',
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.list_alt, size: 32),
            color: AppColors.main5,
            onPressed: openHistory,
          ),
        ],
      ),
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
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (string) {
                            var amount = parseDouble(string);
                            if (amount > topupInfo.maxAmount) {
                              amount = topupInfo.maxAmount;
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
                              hint: '1.000.000', label: 'Jumlah Topup'),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value == '0') {
                              return 'Masukkan Jumlah Topup';
                            }
                            var amount = parseDouble(value);
                            if (amount > topupInfo.maxAmount ||
                                amount < topupInfo.minAmount) {
                              return 'Jumlah tidak sesuai';
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
                  buildBankList(context),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    topupInfo.notes,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  AppButton('Kirim', isLoading ? null : submitData),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
