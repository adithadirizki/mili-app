import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/screens/purchase_payment.dart';
import 'package:miliv2/src/screens/purchase_pln.dart';
import 'package:miliv2/src/screens/purchase_pulsa.dart';
import 'package:miliv2/src/screens/train_home.dart';
import 'package:miliv2/src/screens/vendor.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/utils/dialog.dart';

class HomeMenu extends StatefulWidget {
  const HomeMenu({Key? key}) : super(key: key);

  @override
  _HomeMenuState createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  List<AppMenu> menuList = [];

  // void onMenuPress(AppMenu item) {
  //   print('onMenuPress ' + item.label);
  // }

  @override
  void initState() {
    super.initState();
    menuList.add(AppMenu(AppImages.menuPulsa, 'Pulsa & Data', () {
      pushScreen(context, (_) => const PurchasePulsaScreen());
    }));
    menuList.add(AppMenu(AppImages.menuListrik, 'Listrik', () {
      pushScreen(context, (_) => const PurchasePLNScreen());
    }));
    menuList.add(AppMenu(AppImages.menuTagihan, 'Tagihan', () {
      pushScreen(
        context,
        (_) => const VendorScreen(
          title: 'Tagihan',
          groupName: menuGroupTagihan,
        ),
      );
    }));
    menuList.add(AppMenu(AppImages.menuBPJS, 'BPJS', () {
      pushScreen(
        context,
        (_) => PurchasePaymentScreen(
          vendor: Vendor(
            serverId: 0,
            updatedAt: DateTime.now(),
            imageUrl: '',
            productType: groupTagihan,
            group: '',
            name: 'BPJS Kesehatan',
            title: 'BPJS Kesehatan',
            inquiryCode: 'CEKBPJSKS',
            paymentCode: 'PAYBPJSKS',
          ),
        ),
      );
    }));
    menuList.add(AppMenu(AppImages.menuEmoney, 'E-Wallet', () {
      pushScreen(
        context,
        (_) => const VendorScreen(
          title: 'E-Money',
          groupName: menuGroupEmoney,
        ),
      );
    }));
    // menuList.add(AppMenu(AppImages.menuCicilan, 'Finance', () {
    //   pushScreen(
    //     context,
    //     (_) => const VendorScreen(
    //       title: 'Finance',
    //       groupName: menuGroupFinance,
    //     ),
    //   );
    // }));
    menuList.add(AppMenu(AppImages.menuTelkom, 'Telkom', () {
      pushScreen(
        context,
        (_) => const VendorScreen(
          title: 'Telkom',
          groupName: menuGroupTelkom,
        ),
      );
    }));
    menuList.add(AppMenu(AppImages.menuGame, 'Game', () {
      pushScreen(
        context,
        (_) => const VendorScreen(
          title: 'Game',
          groupName: menuGroupGame,
        ),
      );
    }));
    menuList.add(AppMenu(AppImages.menuCicilan, 'Transfer Bank', () {
      pushScreen(
        context,
        (_) => const VendorScreen(
          title: 'Transfer Bank',
          groupName: menuGroupBank,
        ),
      );
    }));
    menuList.add(AppMenu(AppImages.menuEmoney, 'Aktivasi', () {
      pushScreen(
        context,
        (_) => const VendorScreen(
          title: 'Aktivasi',
          groupName: menuGroupAct,
        ),
      );
    }));
    menuList.add(AppMenu(AppImages.menuTV, 'Streaming', () {
      pushScreen(
        context,
        (_) => const VendorScreen(
          title: 'Streaming',
          groupName: menuGroupStreaming,
        ),
      );
    }));
    menuList.add(AppMenu(AppImages.menuKAI, 'Kereta Api', () {
      pushScreen(
        context,
        (_) => const TrainHomeScreen(
          title: 'Tiket Kereta',
        ),
      );
    }));
    // menuList.add(AppMenu(AppImages.menuMore, 'More', () {
    //   // // TODO Show reordering menu page
    //   // showSnackBar(context, 'Will coming soon');
    //   pushScreen(
    //     context,
    //     (_) => const SplashScreen(),
    //   );
    // }));
  }

  FutureOr<void> handleError(Object e) {
    snackBarDialog(context, e.toString());
  }

  Widget itemBuilder(BuildContext context, int position) {
    AppMenu menu = menuList[position];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: menu.action,
      key: ObjectKey(menu),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffCECECE), width: 0.5),
              //borderRadius: BorderRadius.all(Radius.circular(20.0))
              color: const Color(0xffFBFBFB),
              borderRadius: const BorderRadius.all(Radius.elliptical(69, 69)),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Image(
              image: menu.icon,
            ),
          ),
          const SizedBox(height: 6.0),
          Flexible(
            child: Text(
              menu.label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              maxLines: 2,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1, overflow: TextOverflow.visible),
            ),
          ),
          const SizedBox(height: 20),
          // Flexible(
          //   child: Text(
          //     menu.label,
          //     textAlign: TextAlign.center,
          //     overflow: TextOverflow.visible,
          //     maxLines: 2,
          //     style: Theme.of(context)
          //         .textTheme
          //         .bodyMedium
          //         ?.copyWith(height: 1, overflow: TextOverflow.visible),
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 250,
          maxHeight: 600,
        ),
        child: GridView.builder(
          physics: const ClampingScrollPhysics(),
          itemCount: menuList.length,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 7,
          ),
          itemBuilder: itemBuilder,
          clipBehavior: Clip.antiAlias,
        ),
      ),
    );
  }
}

@immutable
class AppMenu {
  final AssetImage icon;
  final String label;
  final VoidCallback action;

  const AppMenu(this.icon, this.label, this.action);
}
