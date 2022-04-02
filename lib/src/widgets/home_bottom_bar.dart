import 'package:flutter/material.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/screens/customer_service.dart';
import 'package:miliv2/src/screens/mutation.dart';
import 'package:miliv2/src/screens/notification.dart';
import 'package:miliv2/src/screens/profile.dart';
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
      //margin: EdgeInsets.only(left: 20, right: 20),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Container(
        height: 60.0,
        // margin: const EdgeInsets.only(left: 12.0, right: 12.0),
        //color: Theme.of(context).backgroundColor,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.elliptical(30, 30),
              topRight: Radius.elliptical(30, 30)),
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
            IconButton(
              onPressed: () {
                // gotoPage(0);
                pushScreen(
                  context,
                  (_) => const MutationScreen(),
                );
              },
              icon: const Image(
                image: AppImages.note,
                width: 32,
              ),
            ),
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
            const SizedBox(
              width: 50.0,
            ),
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
          ],
        ),
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
          top: -25,
          left: MediaQuery.of(context).size.width / 2 - 25,
          child: FloatingActionButton(
            isExtended: false,
            onPressed: () {
              gotoPage(0);
            },
            backgroundColor: AppColors.blue5,
            tooltip: "Home",
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // color: AppColors.blue5,
                border: Border.all(color: Colors.white, width: 2.5),
                borderRadius: const BorderRadius.all(Radius.circular(40)),
              ),
              clipBehavior: Clip.antiAlias,
              child: const Image(
                image: AppImages.logonavbar,
                width: 80,
              ),
            ),
            elevation: 2.0,
          ),
        ),
      ],
    );
  }
}
