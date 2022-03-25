import 'package:flutter/material.dart';
import 'package:miliv2/src/models/purchase.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/button.dart';

enum historyAction {
  showDetail,
  showInvoice,
  print,
  contactCS,
  addFavorite,
  purchase,
}

class PurchaseHistoryItem extends StatelessWidget {
  final PurchaseHistory history;
  final VoidCallback Function(historyAction, PurchaseHistory) execAction;
  final VoidCallback Function(PurchaseHistory) openPopup;

  const PurchaseHistoryItem(
      {Key? key,
      required this.history,
      required this.execAction,
      required this.openPopup})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.groupName,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(),
                    ),
                    Text(
                      formatDate(history.transactionDate),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    GestureDetector(
                      child: const Icon(
                        Icons.more_vert_outlined,
                        color: Colors.grey,
                        size: 22,
                      ),
                      onTap: openPopup(history),
                    ),
                    // PopupMenuButton(
                    //     child: const Icon(
                    //       Icons.more_vert_outlined,
                    //       color: Colors.grey,
                    //       size: 22,
                    //     ),
                    //     itemBuilder: (context) => [
                    //           PopupMenuItem(
                    //             child: Text("Detail",
                    //                 style: Theme.of(context)
                    //                     .textTheme
                    //                     .button!
                    //                     .copyWith()),
                    //             value: 1,
                    //           ),
                    //           PopupMenuItem(
                    //             child: Text("Print",
                    //                 style: Theme.of(context)
                    //                     .textTheme
                    //                     .button!
                    //                     .copyWith()),
                    //             value: 2,
                    //           )
                    //         ])
                  ],
                ),
              ],
            ),
            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          history.productName,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: history.isSuccess
                                ? Colors.greenAccent
                                : history.isFailed
                                    ? Colors.redAccent
                                    : Colors.yellow,
                            borderRadius: const BorderRadius.all(
                                Radius.elliptical(15, 15)),
                          ),
                          child: Text(
                            history.isSuccess
                                ? 'Berhasil'
                                : history.isFailed
                                    ? 'Gagal'
                                    : history.isPending
                                        ? 'Sedang diproses'
                                        : history.status,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SelectableText(
                      history.destination,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(),
                    ),
                    const SizedBox(height: 10),
                    history.isSuccess
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(),
                              ),
                              Text(
                                'Rp. ${formatNumber(history.price)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
                const Spacer(),
                AppButton(
                  history.isFailed
                      ? 'Ulang'
                      : history.productCode.startsWith('PAY')
                          ? 'Bayar'
                          : 'Beli',
                  execAction(historyAction.purchase, history),
                  size: const Size(80, 30),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
