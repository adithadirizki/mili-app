import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:miliv2/src/config/config.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/program.dart';
import 'package:miliv2/src/screens/reward.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';

class ProgramScreen extends StatefulWidget {
  final String title;
  final String? code;

  const ProgramScreen({Key? key, this.title = 'Program Reward', this.code}) : super(key: key);

  @override
  _ProgramScreenState createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  bool isLoading = true;

  List<Program> programList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initDB();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initDB() async {
    setState(() {
      isLoading = true;
    });

    await AppDB.syncProgram();
    final programDB = AppDB.programDB;
    programList = programDB.query().build().find();

    if (widget.code != null) {
      Program program = programList.firstWhere((e) => e.code == widget.code);
      openProgram(program);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> onRefresh() {
    return initDB();
  }

  void openProgram(Program program) {
    pushScreen(
      context,
      (_) => RewardScreen(
        title: program.title,
        url: AppConfig.baseUrl +
            '/programs/summary/' +
            program.serverId.toString(),
      ),
    );
  }

  Widget item(Program program) {
    return Card(
      child: GestureDetector(
        onTap: () => openProgram(program),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              clipBehavior: Clip.hardEdge,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
              child: CachedNetworkImage(
                imageUrl: program.getImageUrl(),
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                width: double.infinity,
                height: 150,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            program.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_right_alt),
                    ],
                  ),
                  const Divider(),
                  Text(
                    program.description,
                    maxLines: 20,
                    softWrap: true,
                    style: const TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItems(BuildContext context) {
    if (isLoading && programList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: programList.isEmpty
          ? const Center(
              child: Text('Tidak ada program'),
            )
          : Column(
              children: [
                Flexible(
                  child: ListView.builder(
                    itemCount: programList.length,
                    itemBuilder: (context, index) {
                      return item(programList[index]);
                    },
                  ),
                ),
                isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const SizedBox()
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(
        title: widget.title,
        elevation: 0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: buildItems(context),
            ),
          ),
        ],
      ),
    );
  }
}
