import 'package:flutter/material.dart';
import 'package:miliv2/src/screens/train_history.dart';
import 'package:miliv2/src/screens/train_order.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';

class TrainHomeScreen extends StatefulWidget {
  final String title;
  const TrainHomeScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<TrainHomeScreen> createState() => _TrainHomeScreenState();
}

class _TrainHomeScreenState extends State<TrainHomeScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, initialIndex: 0, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(title: widget.title),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          TabBar(
            key: const PageStorageKey<String>('tabTrainHome'),
            controller: tabController,
            tabs: [
              Tab(
                child: Text(
                  'Cari Tiket',
                  style: Theme.of(context).textTheme.button,
                ),
              ),
              Tab(
                child: Text(
                  'Pembelian',
                  style: Theme.of(context).textTheme.button,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: const [
                TrainOrder(),
                TrainHistory(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
