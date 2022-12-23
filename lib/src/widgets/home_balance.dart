import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/screens/activation_wallet.dart';
import 'package:miliv2/src/screens/history.dart';
import 'package:miliv2/src/screens/mutation_wallet.dart';
import 'package:miliv2/src/screens/profile_wallet.dart';
import 'package:miliv2/src/screens/topup.dart';
import 'package:miliv2/src/screens/topup_wallet.dart';
import 'package:miliv2/src/screens/transfer.dart';
import 'package:miliv2/src/screens/transfer_widget_wallet.dart';
import 'package:miliv2/src/screens/upgrade_wallet.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/custom_tooltip.dart';
import 'package:overlay_tooltip/overlay_tooltip.dart';

class HomeBalance extends StatefulWidget {
  const HomeBalance({Key? key}) : super(key: key);

  @override
  _HomeBalanceState createState() => _HomeBalanceState();
}

class _HomeBalanceState extends State<HomeBalance> {
  @override
  void initState() {
    super.initState();
  }

  void profileWalletScreen() {
    if (!userBalanceState.walletActive) {
      pushScreen(context, (_) => const ActivationWalletScreen());
      return;
    }
    pushScreen(context, (_) => const ProfileWalletScreen());
  }

  void topupWalletScreen() {
    if (!userBalanceState.walletActive) {
      pushScreen(context, (_) => const ActivationWalletScreen());
      return;
    }
    pushScreen(context, (_) => const TopupWalletScreen());
  }

  void transferWalletScreen() {
    if (!userBalanceState.walletActive) {
      pushScreen(context, (_) => const ActivationWalletScreen());
      return;
    } else if (!userBalanceState.walletPremium) {
      pushScreen(context,
          (_) => const UpgradeWalletScreen(title: 'Upgrade Saldo MILI'));
      return;
    }
    pushScreen(
        context, (_) => const TransferWidgetWalletScreen(title: 'Kirim Saldo'));
  }

  void upgradeWalletScreen() {
    pushScreen(context, (_) => const UpgradeWalletScreen());
  }

  void topupScreen() {
    pushScreen(context, (_) => const TopupScreen());
  }

  void transferScreen() {
    pushScreen(context, (_) => const TransferScreen());
  }

  void historyScreen() {
    pushScreen(context, (_) => const HistoryScreen());
  }

  void mutationWalletScreen() {
    if (!userBalanceState.walletActive) {
      pushScreen(context, (_) => const ActivationWalletScreen());
      return;
    }
    pushScreen(context, (_) => const MutationWalletScreen());
  }

  Widget buildBalanceCard() {
    return GestureDetector(
      // onTap: userBalanceState.fetchData,
      onTap: profileWalletScreen,
      child: Container(
        width: 160,
        // margin: EdgeInsets.all(15),
        padding: const EdgeInsets.only(left: 15, top: 5, right: 10, bottom: 5),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.elliptical(18, 18)),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Image(
                  image: AppImages.iconBalance,
                  width: 20,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: FittedBox(
                    child: Text(
                      paymentMethodLabel[PaymentMethod.wallet]!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Rp',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: FittedBox(
                    child: Text(
                      formatNumber(UserBalanceScope.of(context).walletBalance),
                      softWrap: false,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.black1, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Tap for details',
                  textAlign: TextAlign.start,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.black2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(AppMenu menu) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 32,
        // minHeight: 32,
        maxWidth: 60,
        // maxHeight: 60,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: menu.action,
            child: Image(
              image: menu.icon,
              height: 32,
            ),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: Text(
              menu.label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              maxLines: 2,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Build HomeBalance');
    return Container(
      height: 110,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.elliptical(20, 20)),
        // color: Color(0xFF00C2FF)
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.gradientBlue1, AppColors.gradientBlue2],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 40,
            child: OverlayTooltipItem(
              displayIndex: 1,
              child: buildBalanceCard(),
              tooltip: (controller) => Transform.translate(
                offset: const Offset(0, 10),
                child: MTooltip(title: 'Saldo', description: 'Ini adalah jumlah saldo kamu untuk transaksi semua produk.', controller: controller),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            // fit: FlexFit.tight,
            flex: 60,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OverlayTooltipItem(
                  displayIndex: 2,
                  child: buildButton(AppMenu(AppImages.topup, 'Topup Saldo', topupWalletScreen)),
                  tooltipHorizontalPosition: TooltipHorizontalPosition.CENTER,
                  tooltip: (controller) => Transform.translate(
                    offset: const Offset(0, 10),
                    // padding: const EdgeInsets.only(top: 10),
                    child: MTooltip(title: 'Top up saldo', description: 'Isi saldo kamu disini, Melalui virtual account berbagai bank & merchant.', controller: controller),
                  ),
                ),
                buildButton(AppMenu(AppImages.transfer, 'Transfer Saldo',
                    transferWalletScreen)),
                buildButton(AppMenu(
                    AppImages.mutasi, 'Mutasi Saldo', mutationWalletScreen)),
                const SizedBox(width: 5),
              ],
            ),
          ),
        ],
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
