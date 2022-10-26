import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/topup.dart';
import 'package:miliv2/src/config/config.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/screens/topup_history.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/balance_card.dart';
import 'package:miliv2/src/widgets/button.dart';
import 'package:miliv2/src/widgets/screen.dart';

class TopupScreen extends StatefulWidget {
  final String title;

  const TopupScreen({Key? key, this.title = 'Topup'}) : super(key: key);

  @override
  _TopupScreenState createState() => _TopupScreenState();
}

class _TopupScreenState extends State<TopupScreen> {
  final formKey = GlobalKey<FormState>();
  TopupInfoResponse topupInfo = TopupInfoResponse('', [], 0, 1000000, 0, 0);
  final TextEditingController textAmountController = TextEditingController();
  bool isLoading = true;
  Object? selectedMetode;

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
      var type = selectedMetode.toString();

      debugPrint('TOPUP : ${type}');
      if (type == "TIKET") {
        Api.createTopupTicket(amount).then((response) {
          int? id;
          debugPrint('Tiket ${response}');
          if (response.containsKey('data') &&
              (response['data'] as Map<String, dynamic>).containsKey('id')) {
            id = response['data']['id'] as int;
          }
          replaceScreen(context, (_) => TopupHistoryScreen(openDetail: id, metode: 'TIKET',));
        }).catchError(handleError);
      } else {
        Api.createTopupRetail(amount, type).then((response) {
          int? id;
          debugPrint('${type} ${response}');
          if (response.containsKey('data') &&
              (response['data'] as Map<String, dynamic>).containsKey('id')) {
            id = response['data']['id'] as int;
          }
          replaceScreen(context, (_) => TopupHistoryScreen(openDetail: id, metode: 'TOPUP',));
        }).catchError(handleError);
      }
    }
  }

  Widget bankItem(BankInfo bank) {
    return ListTile(
      // leading: Icon(Icons.album),
      title: Text(
        'A/N ' + bank.accountName,
        style: const TextStyle(fontSize: 12),
      ),
      subtitle: Text(
        bank.accountNumber,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      leading: CachedNetworkImage(
        imageUrl: AppConfig.baseUrl + '/' + bank.image,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
        width: 40,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),
      trailing: TextButton(
        child: const Text(
          'Salin',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: bank.accountNumber));
          snackBarDialog(context, 'Nomor rekening disalin');
        },
        style: textButtonStyle,
      )
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
      child: ListView(
              children: [
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    title: Row(
                      children: const [
                        Image(image: AppImages.tiket),
                        SizedBox(width: 10),
                        Text('Tiket (Transfer Bank)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                      ],
                    ),
                    tilePadding: const EdgeInsets.only(left: 0, right: 10),
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    leading: Radio(value: 'TIKET', groupValue: selectedMetode, onChanged: (val) {
                      setState(() {
                        selectedMetode = val;
                      });
                    }),
                    children: [
                      isLoading && topupInfo.banks.isEmpty ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ) : const Center(),
                      for (var bank in topupInfo.banks) bankItem(bank),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Text(
                          topupInfo.notes,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      )
                    ],
                  ),
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    title: Row(
                      children: const [
                        Image(image: AppImages.alfamart, height: 10,),
                        SizedBox(width: 10,),
                        Text('Gerai Alfamart Group', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                      ],
                    ),
                    tilePadding: const EdgeInsets.only(left: 0, right: 10),
                    childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    leading: Radio(value: 'ALFAMART', groupValue: selectedMetode, onChanged: (val) {
                      setState(() {
                        selectedMetode = val;
                      });
                    }),
                    children: isLoading && topupInfo.banks.isEmpty ? [const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )] : [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('1. '),
                          Expanded(
                              child: Text('Minimal pembelian sebesar Rp${formatNumber(topupInfo.min_topup)}.')
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('2. '),
                          Expanded(
                              child: Text('Silahkan pergi ke outlet Alfamart, Alfamidi, Alfaexpress, Dan Dan atau Lawson terdekat.')
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('3. '),
                          Expanded(
                              child: Text('Masukkan nominal pembelian koin yang diinginkan, lalu catat atau cetak Kode Pembayaran yang diterima.'),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('4. '),
                          Expanded(
                            child: Text('Informasikan kepada kasir dengan menyebutkan pembayaran atau top up LINKITA.'),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('5. '),
                          Expanded(
                            child: Text('Berikan Kode Pembayaran ke kasir dan lakukan pembayaran sesuai nominal.'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    title: Row(
                      children: const [
                        Image(image: AppImages.indormaret, height: 10,),
                        SizedBox(width: 10,),
                        Text('Gerai Indomaret', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                      ],
                    ),
                    tilePadding: const EdgeInsets.only(left: 0, right: 10),
                    childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    leading: Radio(value: 'INDOMARET', groupValue: selectedMetode, onChanged: (val) {
                      setState(() {
                        selectedMetode = val;
                      });
                    }),
                    children: isLoading && topupInfo.banks.isEmpty ? [const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )] : [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('1. '),
                          Expanded(
                              child: Text('Minimal pembelian sebesar Rp${formatNumber(topupInfo.min_topup)}.')
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('2. '),
                          Expanded(
                              child: Text('Silahkan pergi ke outlet Indomaret terdekat.')
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('3. '),
                          Expanded(
                            child: Text('Masukkan nominal pembelian koin yang diinginkan, lalu catat atau cetak Kode Pembayaran yang diterima.'),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('4. '),
                          Expanded(
                            child: Text('Informasikan kepada kasir dengan menyebutkan pembayaran atau top up LINKITA.'),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('5. '),
                          Expanded(
                            child: Text('Berikan Kode Pembayaran ke kasir dan lakukan pembayaran sesuai nominal.'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(
        title: widget.title,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.list_alt, size: 32),
            color: AppColors.blue5,
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
              margin: const EdgeInsets.only(top: 30),
              child: Column(
                children: [
                  Form(
                    key: formKey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Padding(
                            padding: EdgeInsets.only(bottom: 15, right: 5),
                            child: Text('Rp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                        ),
                        SizedBox(
                          width: 120,
                          child: TextFormField(
                            controller: textAmountController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (string) {
                              var amount = parseDouble(string);
                              var max = selectedMetode == 'TIKET' ? topupInfo.maxAmount : topupInfo.max_topup;
                              if (amount > max) {
                                amount = max;
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
                              var max = selectedMetode == 'TIKET' ? topupInfo.maxAmount : topupInfo.max_topup;
                              var min = selectedMetode == 'TIKET' ? topupInfo.minAmount : topupInfo.min_topup;
                              if (amount > max ||
                                  amount < min) {
                                return 'Jumlah tidak sesuai';
                              }
                              return null;
                            },
                          )
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Opsi Pembelian Koin'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  buildBankList(context),
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
