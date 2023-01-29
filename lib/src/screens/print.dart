import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miliv2/src/api/purchase.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/services/printer.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:share_plus/share_plus.dart';

class PrintScreen extends StatefulWidget {
  final PurchaseHistoryDetailResponse history;

  const PrintScreen({
    Key? key,
    required this.history,
  }) : super(key: key);

  @override
  _PrintScreenState createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController textAmountController =
      TextEditingController(text: '0');
  String struct = '';
  List<Map<String, dynamic>>? config;
  List<List<String?>> structList = [];
  bool isLoading = false;
  bool isPostpaid = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (userBalanceState.isGuest()) {
        confirmSignin(context);
        return;
      }
      initialize();
    });
  }

  void initialize() {
    setState(() {
      textAmountController.value = TextEditingValue(
        text: formatNumber(widget.history.struct.total_pay),
        selection: TextSelection.collapsed(
          offset: widget.history.struct.total_pay.toInt().toString().length,
        ),
      );

      struct = widget.history.invoice;
      config = widget.history.config;
    });
  }

  void printStruct() {
    if (formKey.currentState!.validate()) {
      confirmDialog(
        context,
        title: 'Detail Transaksi',
        msg: struct + '\nCetak Struk ?',
        confirmAction: () {
          AppPrinter.printStruct(
              struct: struct, config: config, context: context);
        },
      );
    }
  }

  void shareStruct() {
    if (formKey.currentState!.validate()) {
      final box = context.findRenderObject() as RenderBox?;
      Share.share(struct,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    }
  }

  List<Widget> buildStruct() {
    var structList = widget.history.invoice.split('\n').map((e) {
      var row = e;
      var cols = row.split(':');
      var colLeft = cols[0].trim();
      cols.removeAt(0);
      var colRight = cols.isNotEmpty ? cols.join(':').trim() : null;

      var bill_amount = widget.history.struct.bill_amount;
      var total_pay = widget.history.struct.total_pay;
      var user_price = widget.history.struct.user_price;

      // Replace Harga (pulsa, data, ewallet, prabayar)
      if (colLeft.toLowerCase().contains('harga')) {
        isPostpaid = false;
        if (colRight != null) {
          colRight = 'Rp. ' +
              formatNumber(parseDouble(textAmountController.value.text));
        }
      }

      // Replace Total Tagihan (pln, pdam, pgn, etc)
      if (colLeft.toLowerCase().contains('tagihan') &&
          !colLeft.toLowerCase().contains('bulan')) {
        isPostpaid = true;
        if (colRight != null) {
          if (parseDouble(textAmountController.text) >
              (total_pay - user_price)) {
            colRight = 'Rp. ' + formatNumber(total_pay - user_price);
          } else {
            colRight = 'Rp. ' + formatNumber(bill_amount);
          }
        }
      }

      // Replace Nominal Transfer / Jumlah Transfer (tf bank)
      if (colLeft.toLowerCase().contains('transfer')) {
        isPostpaid = false;
        if (colRight != null) {
          colRight = 'Rp. ' + formatNumber(bill_amount);
        }
      }

      // Replace Biaya Admin / Admin Fee / Admin Bank
      if (colLeft.toLowerCase().contains('admin')) {
        if (colRight != null) {
          if (parseDouble(textAmountController.text) >
                  (total_pay - user_price) &&
              isPostpaid) {
            colRight = 'Rp. ' +
                formatNumber(parseDouble(textAmountController.value.text) -
                    (total_pay - user_price));
          } else {
            colRight = 'Rp. ' +
                formatNumber(
                    parseDouble(textAmountController.value.text) - bill_amount);
          }
        }
      }

      // Replace Total Bayar (tf bank, pascabayar, tagihan)
      if (colLeft.toLowerCase().contains('total bayar')) {
        if (colRight != null) {
          colRight = 'Rp. ' +
              formatNumber(parseDouble(textAmountController.value.text));
        }
      }

      return [colLeft, colRight];
    }).toList();

    var configList = widget.history.config?.map((e) {
      if (e['columns'] != null) {
        dynamic columns = e['columns'];
        int colsLength = columns.length as int;
        int indexRight = colsLength - 1;
        dynamic colLeft = columns[0];
        dynamic colRight = columns[indexRight];

        var bill_amount = widget.history.struct.bill_amount;
        var total_pay = widget.history.struct.total_pay;
        var user_price = widget.history.struct.user_price;

        if (colLeft != null) {
          if (colLeft.toString().toLowerCase().contains('harga')) {
            isPostpaid = false;
            if (colRight != null) {
              colRight['text'] = 'Rp. ' +
                  formatNumber(parseDouble(textAmountController.value.text));
            }
          }

          if (colLeft.toString().toLowerCase().contains('tagihan') &&
              !colLeft.toString().toLowerCase().contains('bulan')) {
            isPostpaid = true;
            if (colRight != null) {
              if (parseDouble(textAmountController.text) >
                  (total_pay - user_price)) {
                colRight['text'] = 'Rp. ' + formatNumber(total_pay);
              } else {
                colRight['text'] = 'Rp. ' + formatNumber(bill_amount);
              }
            }
          }

          if (colLeft.toString().toLowerCase().contains('transfer')) {
            isPostpaid = false;
            if (colRight != null) {
              colRight['text'] = 'Rp. ' + formatNumber(bill_amount);
            }
          }

          if (colLeft.toString().toLowerCase().contains('admin')) {
            if (colRight != null) {
              if (parseDouble(textAmountController.text) >
                      (total_pay - user_price) &&
                  isPostpaid) {
                colRight['text'] = 'Rp. ' +
                    formatNumber(parseDouble(textAmountController.value.text) -
                        (total_pay - user_price));
              } else {
                colRight['text'] = 'Rp. ' +
                    formatNumber(parseDouble(textAmountController.value.text) -
                        bill_amount);
              }
            }
          }

          if (colLeft.toString().toLowerCase().contains('bayar')) {
            if (colRight != null) {
              colRight['text'] = 'Rp. ' +
                  formatNumber(parseDouble(textAmountController.value.text));
            }
          }
        }
      }
      return e;
    }).toList();

    setState(() {
      var _struct = '';
      for (var value in structList) {
        _struct += value[0]!;
        _struct += value[1] == null ? '' : ': ${value[1]!}';
        _struct += '\n';
      }

      struct = _struct;
      config = configList;
    });

    return structList.asMap().entries.map((e) {
      return Row(
        children: [
          Expanded(
              child: Text(e.value[0]!,
                  style:
                      const TextStyle(fontFamily: 'Maven Pro', height: 1.5))),
          e.value[1] != null
              ? Expanded(
                  child: Text(': ' + e.value[1]!,
                      style: const TextStyle(
                          fontFamily: 'Maven Pro',
                          height: 1.5,
                          fontWeight: FontWeight.bold)))
              : const SizedBox(),
        ],
      );
    }).toList();
  }

  void setAmount(double amount) {
    var string = formatNumber(amount);

    setState(() {
      textAmountController.value = TextEditingValue(
        text: string,
        selection: TextSelection.collapsed(
          offset: string.length,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar(title: 'Detail Transaksi'),
      body: Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: const Color(0x804cc6ff),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: buildStruct(),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Row(
                              children: const [
                                Text(
                                  'Masukkan Harga Jual ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('(opsional)'),
                              ],
                            ),
                            Row(
                              children: [
                                const Padding(
                                    padding:
                                        EdgeInsets.only(bottom: 5, right: 5),
                                    child: Text('Rp',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold))),
                                SizedBox(
                                  width: 150,
                                  child: TextFormField(
                                    controller: textAmountController,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: (string) {
                                      var amount = parseDouble(string);
                                      var max_markup =
                                          widget.history.struct.max_markup;
                                      var max =
                                          widget.history.struct.total_pay +
                                              (max_markup ?? 0);
                                      double min = 0;

                                      if (amount < min) {
                                        amount = min;
                                      } else if (max_markup != null &&
                                          amount > max) {
                                        amount = max;
                                      }

                                      // string = formatNumber(amount);
                                      // setState(() {
                                      //   textAmountController.value =
                                      //       TextEditingValue(
                                      //     text: string,
                                      //     selection: TextSelection.collapsed(
                                      //       offset: string.length,
                                      //     ),
                                      //   );
                                      // });
                                      setAmount(amount);
                                    },
                                    validator: (value) {
                                      double min =
                                          widget.history.struct.bill_amount +
                                              widget.history.struct.admin_fee;
                                      var max_markup =
                                          widget.history.struct.max_markup;
                                      var max =
                                          widget.history.struct.total_pay +
                                              (max_markup ?? 0);
                                      if (value == null ||
                                          value.isEmpty ||
                                          value == '0') {
                                        return 'Masukkan Harga Jual';
                                      }
                                      var amount = parseDouble(value);
                                      if (amount < min ||
                                          (max_markup != null &&
                                              amount > max)) {
                                        return 'Jumlah tidak sesuai';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    var amount =
                                        parseDouble(textAmountController.text);
                                    setAmount(amount + 500);
                                  },
                                  child: Text(
                                    '+ 500',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: AppColors.gradientBlue1,
                                        ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    var amount =
                                        parseDouble(textAmountController.text);
                                    setAmount(amount - 500);
                                  },
                                  child: Text(
                                    '- 500',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: AppColors.red1,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              '* Harga Jual merupakan harga yang akan tertera di Struk Transaksi yang akan dicetak.',
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: TextButton(
                        onPressed: shareStruct,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.share,
                              size: 20,
                              color: AppColors.black2,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Bagikan',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: AppColors.black1,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      child: TextButton(
                        onPressed: printStruct,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.print,
                              size: 20,
                              color: AppColors.black2,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Cetak',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: AppColors.black1,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
