import 'package:flutter/material.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/screens/price_paket_data.dart';
import 'package:miliv2/src/screens/price_product.dart';
import 'package:miliv2/src/screens/price_pulsa.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';

class PriceSettingScreen extends StatefulWidget {
  const PriceSettingScreen({Key? key}) : super(key: key);

  @override
  _PriceSettingScreenState createState() => _PriceSettingScreenState();
}

class _PriceSettingScreenState extends State<PriceSettingScreen> {
  List<_AppMenu> menuList = [];

  @override
  void initState() {
    super.initState();
    menuList.add(_AppMenu(AppImages.menuPulsa, 'Pulsa', () {
      pushScreen(context, (_) => const PricePulsaScreen());
    }));
    menuList.add(_AppMenu(AppImages.menuPaketData, 'Paket Data', () {
      pushScreen(context, (_) => const PricePaketDataScreen());
    }));
    menuList.add(_AppMenu(AppImages.menuListrik, 'Listrik', () {
      openPriceSetting('Harga Listrik', null, ['PLN PASCA', 'PLN1600']);
    }));
    menuList.add(_AppMenu(AppImages.menuTagihan, 'Tagihan', () {
      openPriceSetting('Harga Tagihan', menuGroupTagihan, null);
    }));
    menuList.add(_AppMenu(AppImages.menuBPJS, 'BPJS Kesehatan', () {
      openPriceSetting('Harga BPJS Kesehatan', null, ['BPJS']);
    }));
    menuList.add(_AppMenu(AppImages.menuEmoney, 'E-Wallet', () {
      openPriceSetting('Harga E-Wallet', menuGroupEmoney, null);
    }));
    // menuList.add(_AppMenu(AppImages.menuCicilan, 'Finance', () {
    //   openPriceSetting(menuGroupFinance, null);
    // }));
    // menuList.add(_AppMenu(AppImages.menuTelkom, 'Telkom', () {
    //   openPriceSetting('Harga Telkom', menuGroupTelkom, null);
    // }));
    menuList.add(_AppMenu(AppImages.menuGame, 'Game', () {
      openPriceSetting('Harga Game', menuGroupGame, null);
    }));
    menuList.add(_AppMenu(AppImages.menuTV, 'TV Berbayar', () {
      openPriceSetting('Harga TV Berbayar', menuGroupStreaming, null);
    }));
    // menuList.add(_AppMenu(AppImages.menuEmoney, 'Transfer Bank', () {
    //   openPriceSetting('Harga Transfer Bank', menuGroupBank, null);
    // }));
    menuList.add(_AppMenu(AppImages.menuPajak, 'Pajak', () {
      openPriceSetting('Harga Pajak', menuGroupPajak, null);
    }));
    menuList.add(_AppMenu(AppImages.menuEmoney, 'Aktivasi', () {
      openPriceSetting('Harga Aktivasi', menuGroupAct, null);
    }));
    // menuList.add(_AppMenu(AppImages.menuKAI, 'Kereta API', () {
    //   openPriceSetting('Harga Tiket Kereta', null, ['KAI']);
    // }));
  }

  void openPriceSetting(
      String title, String? vendorGroup, List<String>? productGroups) {
    pushScreen(
        context,
        (_) => PriceProductScreen(
              title: title,
              vendorGroup: vendorGroup,
              productGroups: productGroups,
            ));
  }

  Widget itemBuilder(_AppMenu menu) {
    return Card(
      elevation: 0,
      child: ListTile(
        contentPadding:
            const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        leading: Container(
          width: 32,
          height: 32,
          // decoration: BoxDecoration(
          //   border: Border.all(color: Color(0xffCECECE), width: 0.5),
          //   color: const Color(0xffFBFBFB),
          //   borderRadius: const BorderRadius.all(Radius.elliptical(96, 96)),
          // ),
          padding: const EdgeInsets.all(0.5),
          child: Image(
            image: menu.icon,
          ),
        ),
        title: Text(
          menu.label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        // subtitle:
        //     vendor.description.isNotEmpty ? Text(vendor.description) : null,
        // enabled: vendor.status == statusOpen,
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
        ),
        onTap: menu.action,
      ),
    );
  }

  Widget buildList(BuildContext context) {
    if (menuList.isEmpty) {
      return Center(
        child: Text(
          'Layanan tidak tersedia',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      key: const PageStorageKey<String>('listVendor'),
      physics: const ClampingScrollPhysics(),
      itemCount: menuList.length,
      itemBuilder: (context, index) {
        return itemBuilder(menuList[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar2(
        title: 'Set Harga Jual',
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: buildList(context),
      ),
    );
  }
}

@immutable
class _AppMenu {
  final AssetImage icon;
  final String label;
  final VoidCallback action;

  const _AppMenu(this.icon, this.label, this.action);
}
