import 'package:flutter/material.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/utils/formatter.dart';

class CoinChip extends StatelessWidget {
  final VoidCallback onTap;
  const CoinChip({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white1,
        border: Border.all(color: AppColors.yellow1, width: 2),
        borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(20.0), right: Radius.circular(20.0)),
      ),
      constraints: const BoxConstraints(
        minWidth: 120,
      ),
      padding: const EdgeInsets.only(
        left: 7,
        right: 7,
        top: 5,
        bottom: 5,
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.white1,
        enableFeedback: true,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: const [
                Image(
                  image: AppImages.coinYellow,
                  height: 20,
                  fit: BoxFit.fill,
                ),
                SizedBox(width: 10)
              ],
            ),
            Text(
              '${formatNumber(UserBalanceScope.of(context).balance)} Koin',
              softWrap: false,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.black1, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
