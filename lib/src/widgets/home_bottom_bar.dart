import 'dart:async';

import 'package:flutter/material.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/screens/activation_wallet.dart';
import 'package:miliv2/src/screens/customer_service.dart';
import 'package:miliv2/src/screens/history.dart';
import 'package:miliv2/src/screens/notification.dart';
import 'package:miliv2/src/screens/profile.dart';
import 'package:miliv2/src/screens/qris_scan.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/utils/dialog.dart';

class HomeBottomBar extends StatefulWidget {
  final TabController pageController;
  final int selectedPage;

  const HomeBottomBar(
      {Key? key, required this.pageController, required this.selectedPage})
      : super(key: key);

  @override
  _HomeBottomBarState createState() => _HomeBottomBarState();
}

class _HomeBottomBarState extends State<HomeBottomBar> {
  // int selectedIndex = 0;

  void gotoPage(int page) {
    widget.pageController.animateTo(page);
    // if (widget.pageController.hasClients) {
    //   widget.pageController.animateToPage(
    //     page,
    //     duration: const Duration(milliseconds: 400),
    //     curve: Curves.easeInOut,
    //   );
    // }
    // setState(() {
    //   selectedIndex = page;
    // });
  }

  Widget buildMenuBar() {
    return Container(
      height: 70.0,
      // margin: const EdgeInsets.only(left: 12.0, right: 12.0),
      //color: Theme.of(context).backgroundColor,
      decoration: const BoxDecoration(
        // borderRadius: BorderRadius.only(
        //     topLeft: Radius.elliptical(30, 30),
        //     topRight: Radius.elliptical(30, 30)),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        // color: Color(0xFF00C2FF)
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff0196DD), Color(0xff01C9D0)],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              IconButton(
                onPressed: () {
                  // gotoPage(0);
                  pushScreen(
                    context,
                    (_) => const HistoryScreen(),
                  );
                },
                icon: const Image(
                  image: AppImages.history,
                  width: 26,
                ),
              ),
              Flexible(
                child: Text(
                  AppLabel.history,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1,
                        overflow: TextOverflow.visible,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
              const SizedBox(height: 2.0),
            ],
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {
                  // gotoPage(1);
                  pushScreen(
                    context,
                    (_) => const NotificationScreen(),
                  );
                },
                icon: const Image(
                  image: AppImages.notification,
                  width: 32,
                ),
              ),
              Flexible(
                child: Text(
                  'Notifikasi',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1,
                        overflow: TextOverflow.visible,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
              const SizedBox(height: 2.0),
            ],
          ),
          const SizedBox(
            width: 10.0,
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {
                  // gotoPage(3);
                  pushScreen(
                    context,
                    (_) => const CustomerServiceScreen(),
                  );
                },
                icon: const Image(
                  image: AppImages.chat,
                  width: 32,
                ),
              ),
              Flexible(
                child: Text(
                  'Chat CS',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1,
                        overflow: TextOverflow.visible,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
              const SizedBox(height: 2.0),
            ],
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {
                  // gotoPage(4);
                  if (userBalanceState.isGuest()) {
                    confirmSignin(context);
                  } else {
                    pushScreen(
                      context,
                      (_) => UserBalanceScope(
                        notifier: userBalanceState,
                        child: const ProfileScreen(),
                      ),
                    );
                  }
                },
                icon: const Image(
                  image: AppImages.user,
                  width: 32,
                ),
              ),
              Flexible(
                child: Text(
                  'Profil',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1,
                        overflow: TextOverflow.visible,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
              const SizedBox(height: 2.0),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // double selectedIndex = dialog.dart.pageController.page ?? -1;
    int selectedIndex = widget.selectedPage;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        buildMenuBar(),
        Positioned(
          top: -32,
          left: MediaQuery.of(context).size.width / 2 - 30,
          child: SizedBox(
            width: 70,
            height: 70,
            child: Expanded(
              child: FloatingActionButton(
                isExtended: false,
                onPressed: () async {
                  if (!userBalanceState.walletActive) {
                    pushScreen(context, (_) => const ActivationWalletScreen());
                    return;
                  }
                  var code = await pushScreenWithCallback<String>(
                    context,
                    (_) => const QrisScannerScreen(),
                  );
                  // debugPrint('Read code $code');
                  if (code != null) {
                    Timer(const Duration(milliseconds: 200), () {
                      infoDialog(context, msg: code);
                    });
                  }
                },
                backgroundColor: AppColors.red2,
                splashColor: AppColors.red2,
                focusColor: AppColors.red2,
                foregroundColor: AppColors.red2,
                tooltip: 'Pembayaran QRIS',
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    // color: AppColors.blue5,
                    border: Border.all(color: Colors.white, width: 4),
                    borderRadius: const BorderRadius.all(Radius.circular(40)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: const Image(
                    fit: BoxFit.fitWidth,
                    image: AppImages.logoQris,
                    // width: 100,
                  ),
                ),
                elevation: 2.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
