import 'package:flutter/material.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/screens/history.dart';
import 'package:miliv2/src/screens/topup.dart';
import 'package:miliv2/src/screens/transfer.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';

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

  void topupScreen() {
    pushScreen(context, (_) => const TopupScreen());
  }

  void transferScreen() {
    pushScreen(context, (_) => const TransferScreen());
  }

  void historyScreen() {
    pushScreen(context, (_) => const HistoryScreen());
  }

  @override
  Widget build(BuildContext context) {
    print('Build HomeBalance');
    return Container(
      height: 120,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.elliptical(20, 20)),
        // color: Color(0xFF00C2FF)
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.blue3, AppColors.blue4],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Box Left
          GestureDetector(
            onTap: userBalanceState.fetchData,
            child: Container(
              width: 150,
              // margin: EdgeInsets.all(15),
              padding:
                  const EdgeInsets.only(left: 20, top: 5, right: 10, bottom: 5),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.elliptical(18, 18)),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                            'Saldo',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Rp',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 3),
                      // Consumer<UserBalanceState>(builder: (_, ref, __) {
                      Flexible(
                        child: FittedBox(
                          child: Text(
                            formatNumber(UserBalanceScope.of(context).balance),
                            softWrap: false,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color: AppColors.black1,
                                    fontWeight: FontWeight.bold),
                            // style: const TextStyle(
                            //   color: Color(0xFF505050),
                            //   fontFamily: 'Montserrat Alternates',
                            //   fontSize: 16,
                            //   fontWeight: FontWeight.bold,
                            // ),
                          ),
                        ),
                      ),
                      // })
                    ],
                  ),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        'Saldo Kredit',
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: AppColors.blue4),
                        // style: TextStyle(
                        //   color: Color(0xFF00C2FF),
                        //   fontFamily: 'Montserrat',
                        //   fontSize: 12,
                        // ),
                      ),
                    ),
                  ),
                  // Consumer<UserBalanceState>(builder: (_, ref, __) {
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        formatNumber(
                            UserBalanceScope.of(context).balanceCredit),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.blue4,
                            fontWeight: FontWeight.bold),
                        // style: const TextStyle(
                        //   color: Color(0xFF00C2FF),
                        //   fontFamily: 'Montserrat',
                        //   fontSize: 16,
                        //   fontWeight: FontWeight.bold,
                        // ),
                      ),
                    ),
                  ),
                  // })
                ],
              ),
            ),
          ),
          // Icons
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 5),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: topupScreen,
                      child: const Image(
                        image: AppImages.topup,
                        height: 32,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLabel.topup,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: transferScreen,
                      child: const Image(
                        image: AppImages.transfer,
                        height: 32,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLabel.transfer,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: historyScreen,
                      child: const Image(
                        image: AppImages.history,
                        height: 32,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLabel.history,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(width: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
