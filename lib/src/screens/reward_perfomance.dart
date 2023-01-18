import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/models/program.dart';
import 'package:miliv2/src/screens/reward.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';

class RewardPerfomanceScreen extends StatefulWidget {
  final Program program;

  const RewardPerfomanceScreen({Key? key, required this.program}) : super(key: key);

  @override
  _RewardPerfomanceScreenState createState() => _RewardPerfomanceScreenState();
}

class _RewardPerfomanceScreenState extends State<RewardPerfomanceScreen> {
  bool isLoading = true;
  int myHit = 0;
  int downlineHit = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initialize();
    });
  }

  void initialize() {
    setState(() {
      isLoading = true;
    });
    Api.programSummary(widget.program.serverId.toString()).then((response) {
      Map<String, dynamic> bodyMap = json.decode(response.body) as Map<String, dynamic>;
      myHit = bodyMap['data']['me'] as int;
      downlineHit = bodyMap['data']['downline'] as int;
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(
        title: widget.program.title,
        elevation: 0,
      ),
      body: (isLoading) ? const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ) :
      Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: double.infinity,
            child: DataTable(
              showBottomBorder: true,
              headingRowColor: MaterialStateProperty.resolveWith((_) {
                return Colors.blue;
              }),
              columns: const <DataColumn>[
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'Transaksi',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'Hit',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
              rows: <DataRow>[
                DataRow(
                  cells: <DataCell>[
                    const DataCell(Text('Saya')),
                    DataCell(Text(formatNumber(myHit.toDouble()))),
                  ],
                ),
                DataRow(
                  cells: <DataCell>[
                    const DataCell(Text('Downline')),
                    DataCell(Text(formatNumber(downlineHit.toDouble()))),
                  ],
                ),
                DataRow(
                  cells: <DataCell>[
                    const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNumber((myHit + downlineHit).toDouble()), style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
            ),
            child: CachedNetworkImage(
              imageUrl: widget.program.getImageUrl(),
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              width: double.infinity,
              height: 180,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.fill,
                  ),
                ),
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: () {
                pushScreen(context, (_) => RewardScreen(title: widget.program.title, url: widget.program.link ?? ''));
              },
              style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) {
                return Colors.blue;
              })),
              child: const Text('Detail Reward')
          ),
        ],
      ),
    );
  }
}
