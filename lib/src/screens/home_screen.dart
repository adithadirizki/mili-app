import 'dart:async';

import 'package:flutter/material.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/widgets/home_balance.dart';
import 'package:miliv2/src/widgets/home_menu.dart';
import 'package:miliv2/src/widgets/home_promo.dart';

class HomeScreen extends StatefulWidget {
  final ScrollController scrollBottomBarController;

  const HomeScreen({Key? key, required this.scrollBottomBarController})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    initialize();
    debugPrint('Init HomeScreen');
  }

  Future<void> Function() refreshBalance(BuildContext context) {
    return userBalanceState.fetchData;
  }

  void initialize() {}

  @override
  Widget build(BuildContext context) {
    debugPrint('Build HomeScreen');
    return mainBuild(context);
  }

  Widget mainBuild(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshBalance(context),
      child: ListView(
        controller: widget.scrollBottomBarController,
        physics: const ClampingScrollPhysics(),
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: const HomeBalance(),
          ),
          Container(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            child: const HomeMenu(key: ValueKey('Home Menu')),
          ),
          Container(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 5.0),
            child: const HomePromo(key: ValueKey('Home Promo')),
          ),
        ],
      ),
    );
  }
}
