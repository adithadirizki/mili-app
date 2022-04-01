import 'dart:async';

import 'package:flutter/material.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/notification.dart' as models;
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';

enum historyAction {
  toggleFavorite,
  showDetail,
  print,
  contactCS,
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final formKey = GlobalKey<FormState>();
  List<models.Notification> items = [];
  final TextEditingController textAmountController = TextEditingController();
  bool isLoading = true;

  late DateTime firstDate;
  late DateTimeRange dateRange;

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    firstDate = DateTime(now.year, now.month - 6);
    dateRange = DateTimeRange(
        start: now.subtract(const Duration(hours: 24 * 28)), end: now);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      initDB();
    });
  }

  Future<void> initDB() async {
    setState(() {
      isLoading = true;
    });

    await AppDB.syncNotification();

    Condition<models.Notification> filterDate = Notification_.notificationDate
        .greaterOrEqual(dateRange.start.millisecondsSinceEpoch)
        .and(Notification_.notificationDate.lessOrEqual(dateRange.end
            .add(const Duration(hours: 24))
            .millisecondsSinceEpoch));

    Condition<models.Notification> filterUser =
        Notification_.userId.equals(userBalanceState.userId);

    final db = AppDB.notificationDB;
    QueryBuilder<models.Notification> query =
        (db.query(filterDate.and(filterUser))
          ..order(Notification_.notificationDate, flags: 1));
    items = query.build().find();

    debugPrint('InitDB Notification ${items.length}');

    setState(() {
      isLoading = false;
    });
  }

  Future<void> onRefresh() {
    return initDB();
  }

  void openFilterDate() async {
    var range = await dateRangeDialog(context,
        initial: dateRange, firstDate: firstDate);
    if (range != null) {
      debugPrint('Date range $range');
      setState(() {
        dateRange = range;
      });
      initDB();
    }
  }

  Widget item(models.Notification history) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      formatDate(history.notificationDate),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            Text(
              history.body,
              // style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItems(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: items.isEmpty
          ? const Center(
              child: Text('Tidak ada data'),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return item(items[index]);
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(
        title: 'Notifikasi',
        actions: <Widget>[
          TextButton(
            child: Text(
              '${formatDate(dateRange.start, format: 'd MMM')} - ${formatDate(dateRange.end, format: 'd MMM')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onPressed: openFilterDate,
          ),
          IconButton(
            onPressed: openFilterDate,
            icon: const Image(
              image: AppImages.calendar,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: buildItems(context),
      ),
    );
  }
}
