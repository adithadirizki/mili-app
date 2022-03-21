import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/screens/history.dart';
import 'package:miliv2/src/screens/topup.dart';
import 'package:miliv2/src/screens/transfer.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/style.dart';
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
          colors: [Color(0xff0196DD), Color(0xff01C9D0)],
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
                    children: const [
                      Image(
                        image: AppImages.iconBalance,
                        width: 20,
                      ),
                      SizedBox(width: 5),
                      Text('Saldo'),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Rp'),
                      const SizedBox(width: 3),
                      // Consumer<UserBalanceState>(builder: (_, ref, __) {
                      Flexible(
                        child: FittedBox(
                          child: Text(
                            formatNumber(UserBalanceScope.of(context).balance),
                            softWrap: false,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Color(0xFF505050),
                              fontFamily: 'Montserrat Alternates',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // })
                    ],
                  ),
                  const Text(
                    'Saldo Kredit',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Color(0xFF00C2FF),
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                    ),
                  ),
                  // Consumer<UserBalanceState>(builder: (_, ref, __) {
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        formatNumber(
                            UserBalanceScope.of(context).balanceCredit),
                        style: const TextStyle(
                          color: Color(0xFF00C2FF),
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                        width: 35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLabel.topup,
                      style: defaultLabelStyle.copyWith(color: Colors.white),
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
                        width: 32,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLabel.transfer,
                      style: defaultLabelStyle.copyWith(color: Colors.white),
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
                        width: 32,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLabel.history,
                      style: defaultLabelStyle.copyWith(color: Colors.white),
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
