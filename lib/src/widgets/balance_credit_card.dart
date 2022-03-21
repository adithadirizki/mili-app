import 'package:flutter/material.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/theme/images.dart';
import 'package:miliv2/src/utils/formatter.dart';

class BalanceCreditCard extends StatelessWidget {
  const BalanceCreditCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              'Saldo Kredit',
              style: Theme.of(context)
                  .textTheme
                  .button!
                  .copyWith(color: Colors.white),
            ),
          ),
          Container(
            alignment: const Alignment(-1, 0),
            margin: const EdgeInsets.only(left: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Image(
                  image: AppImages.wallet,
                  width: 48,
                ),
                // const Icon(
                //   Icons.account_balance_wallet_outlined,
                //   size: 64,
                // ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  'Rp',
                  style: Theme.of(context)
                      .textTheme
                      .button!
                      .copyWith(color: Colors.white),
                ),
                const SizedBox(
                  width: 5,
                ),
                Flexible(
                  child: Text(
                    formatNumber(userBalanceState.balanceCredit),
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.button!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
