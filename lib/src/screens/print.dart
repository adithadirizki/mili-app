import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:miliv2/src/api/purchase.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/services/printer.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';

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
  final TextEditingController textAmountController = TextEditingController(text: '0');
  String struct = '';
  List<Map<String, dynamic>>? config;
  List<List<String?>> structList = [];
  bool isLoading = false;

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
          AppPrinter.printStruct(struct: struct, config: config, context: context);
        },
      );
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

      // Replace Harga (pulsa, data, ewallet, prabayar)
      if (colLeft.toLowerCase().contains('harga')) {
        if (colRight != null && parseDouble(colRight) == total_pay) {
          colRight = 'Rp. ' + NumberFormat('#,###').format(parseDouble(textAmountController.value.text));
        }
      }

      // Replace Total Tagihan / Nominal Transfer / Jumlah Transfer (plnpasca, tf bank)
      if (colLeft.toLowerCase().contains('tagihan') || colLeft.toLowerCase().contains('transfer')) {
        if (colRight != null && parseDouble(colRight) == bill_amount) {
          colRight = 'Rp. ' + NumberFormat('#,###').format(bill_amount);
        }
      }

      // Replace Biaya Admin / Admin Fee / Admin Bank
      if (colLeft.toLowerCase().contains('admin')) {
        if (colRight != null && parseDouble(colRight) == total_pay - bill_amount) {
          colRight = 'Rp. ' + NumberFormat('#,###').format(parseDouble(textAmountController.value.text) - bill_amount);
        }
      }

      // Replace Total Bayar (tf bank, pascabayar, tagihan)
      if (colLeft.toLowerCase().contains('total bayar')) {
        if (colRight != null && parseDouble(colRight) == total_pay) {
          colRight = 'Rp. ' + NumberFormat('#,###').format(parseDouble(textAmountController.value.text));
        }
      }

      return [colLeft, colRight];
    }).toList();

    var configList = widget.history.config?.map((e) {
      if (e['columns'] != null) {
        dynamic columns = e['columns'];
        dynamic colLeft = columns[0];
        int colsLength = columns.length as int;
        int colRight = colsLength - 1;

        var bill_amount = widget.history.struct.bill_amount;

        if (colLeft != null && colLeft.toString().toLowerCase().contains('harga')) {
          if (e['columns'][colRight] != null) {
            e['columns'][colRight]['text'] = 'Rp. ' + NumberFormat('#,###').format(parseDouble(textAmountController.value.text));
          }
        }

        if (colLeft != null && (colLeft.toString().toLowerCase().contains('tagihan') || colLeft.toString().toLowerCase().contains('transfer'))) {
          if (e['columns'][colRight] != null) {
            e['columns'][colRight]['text'] = 'Rp. ' + NumberFormat('#,###').format(bill_amount);
          }
        }

        if (colLeft != null && colLeft.toString().toLowerCase().contains('admin')) {
          if (e['columns'][colRight] != null) {
            e['columns'][colRight]['text'] = 'Rp. ' + NumberFormat('#,###').format(parseDouble(textAmountController.value.text) - bill_amount);
          }
        }

        if (colLeft != null && colLeft.toString().toLowerCase().contains('bayar')) {
          if (e['columns'][colRight] != null) {
            e['columns'][colRight]['text'] = 'Rp. ' + NumberFormat('#,###').format(parseDouble(textAmountController.value.text));
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
              child: Text(e.value[0]!, style: const TextStyle(fontFamily: 'Maven Pro', height: 1.5))
          ),
          e.value[1] != null ? Expanded(
              child: Text(': ' + e.value[1]!, style: const TextStyle(fontFamily: 'Maven Pro', height: 1.5, fontWeight: FontWeight.bold))
          ) : const SizedBox(),
        ],
      );
    }).toList();
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: buildStruct(),
                          ),
                        )
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Row(
                              children: const [
                                Text('Masukkan Harga Jual ', style: TextStyle(fontWeight: FontWeight.bold),),
                                Text('(opsional)'),
                              ],
                            ),
                            Row(
                              children: [
                                const Padding(
                                    padding: EdgeInsets.only(bottom: 5, right: 5),
                                    child: Text('Rp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                                ),
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
                                        var max_markup = widget.history.struct.max_markup;
                                        var max = widget.history.struct.total_pay + (max_markup ?? 0);
                                        double min = 0;

                                        if (amount < min) {
                                          amount = min;
                                        } else if (max_markup != null && amount > max) {
                                          amount = max;
                                        }

                                        string = formatNumber(amount);

                                        setState(() {
                                          textAmountController.value = TextEditingValue(
                                            text: string,
                                            selection: TextSelection.collapsed(
                                              offset: string.length,
                                            ),
                                          );
                                        });
                                      },
                                      validator: (value) {
                                        double min = widget.history.struct.bill_amount + widget.history.struct.admin_fee;
                                        var max_markup = widget.history.struct.max_markup;
                                        var max = widget.history.struct.total_pay + (max_markup ?? 0);
                                        if (value == null ||
                                            value.isEmpty ||
                                            value == '0') {
                                          return 'Masukkan Harga Jual';
                                        }
                                        var amount = parseDouble(value);
                                        if (amount < min || (max_markup != null && amount > max)) {
                                          return 'Jumlah tidak sesuai';
                                        }
                                        return null;
                                      },
                                    )
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const Text('* Harga Jual merupakan harga yang akan tertera di Struk Transaksi yang akan dicetak.',
                              style: TextStyle(
                                fontSize: 10
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: AppButton('Cetak', printStruct),
            )
          ],
        )
      ),
    );
  }
}
