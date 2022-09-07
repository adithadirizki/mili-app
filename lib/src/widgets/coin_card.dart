import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/screens/mutation.dart';
import 'package:miliv2/src/screens/topup.dart';
import 'package:miliv2/src/screens/transfer.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/images.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';

class CoinCard extends StatelessWidget {
  const CoinCard({Key? key}) : super(key: key);

  void topupScreen(BuildContext context) {
    pushScreen(context, (_) => const TopupScreen(title: 'Beli Koin'));
  }

  void transferScreen(BuildContext context) {
    pushScreen(context, (_) => const TransferScreen(title: 'Transfer Koin'));
  }

  void mutasiScreen(BuildContext context) {
    pushScreen(context,
        (_) => const MutationScreen(title: 'Mutasi Koin MILI & Kredit'));
  }

  Widget buildMainBalance(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            const Image(
              image: AppImages.coinYellow,
              width: 20,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: FittedBox(
                child: Text(
                  paymentMethodLabel[PaymentMethod.mainBalance]!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text(
            //   'Rp',
            //   style: Theme.of(context)
            //       .textTheme
            //       .bodySmall!
            //       .copyWith(fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(width: 3),
            Flexible(
              child: FittedBox(
                child: Text(
                  formatNumber(userBalanceState.balance),
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
      ],
    );
  }

  Widget buildCreditBalance(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            const Image(
              image: AppImages.iconBalance,
              width: 20,
              color: AppColors.red2,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: FittedBox(
                child: Text(
                  paymentMethodLabel[PaymentMethod.creditBalance]!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text(
            //   'Rp',
            //   style: Theme.of(context)
            //       .textTheme
            //       .bodySmall!
            //       .copyWith(fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(width: 3),
            Flexible(
              child: FittedBox(
                child: Text(
                  formatNumber(userBalanceState.balanceCredit),
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
      ],
    );
  }

  Widget buildButton(BuildContext context, AppMenu menu) {
    return GestureDetector(
      onTap: menu.action,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.yellow1,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            padding: EdgeInsets.all(5),
            child: Image(
              image: menu.icon,
              height: 32,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            menu.label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.visible,
            maxLines: 2,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 200,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.elliptical(20, 20)),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff00D1FF), Color(0xff00ADD2)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding:
                const EdgeInsets.only(left: 15, top: 15, right: 15, bottom: 15),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.elliptical(18, 18)),
              color: Colors.white,
            ),
            clipBehavior: Clip.hardEdge,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 1,
                  child: buildMainBalance(context),
                ),
                Container(
                  width: 2,
                  height: 50,
                  color: AppColors.blue5,
                  margin: EdgeInsets.only(left: 10, right: 15),
                ),
                Expanded(
                  flex: 1,
                  child: buildCreditBalance(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(width: 20),
              buildButton(
                  context,
                  AppMenu(AppImages.topup, 'Beli Koin',
                      () => topupScreen(context))),
              buildButton(
                  context,
                  AppMenu(AppImages.transfer, 'Kirim Koin',
                      () => transferScreen(context))),
              buildButton(
                  context,
                  AppMenu(
                      AppImages.mutasi, 'Mutasi', () => mutasiScreen(context))),
              const SizedBox(width: 20),
            ],
          ),
          const SizedBox(height: 10),
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
