import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/models/program.dart';
import 'package:miliv2/src/screens/reward_me.dart';
import 'package:miliv2/src/services/auth.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';

class RewardPremiumScreen extends StatefulWidget {
  final Program program;

  const RewardPremiumScreen({
    Key? key,
    required this.program,
  }) : super(key: key);

  @override
  _RewardPremiumScreenState createState() => _RewardPremiumScreenState();
}

class _RewardPremiumScreenState extends State<RewardPremiumScreen> {
  late AppAuth authState; // get auth state
  bool isLoading = false;
  int totalDownlineHit = 0;
  int totalMyHit = 0;

  @override
  void initState() {
    super.initState();
    getHit();
  }

  void getHit() async {
    DateTime startAt = DateFormat('yyyy-MM-dd').parse(widget.program.startAt);
    DateTime endAt = DateFormat('yyyy-MM-dd').parse(widget.program.endAt);

    Map<String, String> summary = {
      'startDate': formatDate(startAt, format: 'yyyy-MM-dd'),
      'endDate': formatDate(endAt, format: 'yyyy-MM-dd'),
    };

    await Api.getPurchaseSummary(params: summary)
        .then((response) {
          if (response.statusCode == 200) {
            Map<String, dynamic> bodyMap = json.decode(response.body) as Map<String, dynamic>;
            totalMyHit = (bodyMap['success'] as int).toInt();
          }
        })
        .catchError(handleError);

    await Api.getDownlineSummary(params: summary)
        .then((response) {
          if (response.statusCode == 200) {
            Map<String, dynamic> bodyMap = json.decode(response.body) as Map<String, dynamic>;
            totalDownlineHit = (bodyMap['trx'] as int).toInt();
          }
        })
        .catchError(handleError);

    setState(() {});
  }

  FutureOr<void> handleError(Object e) {
    setState(() {
      isLoading = false;
    });
    snackBarDialog(context, e.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar2(
        title: 'Pencapaian Saya',
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue),
                headingTextStyle: const TextStyle(color: Colors.white),
                showBottomBorder: true,
                // columns: [],
                columns: const <DataColumn>[
                  DataColumn(label: Text("Transaksi")),
                  DataColumn(label: Text("Hit")),
                ],
                rows: <DataRow>[
                  DataRow(
                    cells: <DataCell>[
                      const DataCell(Text("Saya")),
                      DataCell(Text(totalMyHit.toString())),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      const DataCell(Text("Downline")),
                      DataCell(Text(totalDownlineHit.toString())),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      const DataCell(Text("Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      DataCell(Text((totalMyHit + totalDownlineHit).toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),
            OutlinedButton(
              onPressed: () {
                pushScreen(context, (_) => const RewardMeScreen(
                  title: 'Reward premium',
                  widgetUrl: 'https://www.mymili.id/premium-reward/',)
                );
              },
              child: const Text('Rincian Reward', style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ]
      ),
    );
  }

  @override
  void dispose() {
    // stopTimer();
    super.dispose();
  }
}