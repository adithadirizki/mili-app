import 'package:flutter/material.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/reference/flip/screens/bank.dart';
import 'package:miliv2/src/reference/flip/screens/page_bank_inquiry.dart';
import 'package:miliv2/src/screens/customer_service.dart';
import 'package:miliv2/src/screens/history.dart';
import 'package:miliv2/src/screens/profile.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/utils/dialog.dart';

void alertDialogFlip(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(text)),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          child: const Icon(
            Icons.clear,
            color: Colors.grey,
          ),
        ),
      ],
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    backgroundColor: Colors.black,
    elevation: 0,
  );

  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(snackBar);
}

void confirmDialogFlip({
  required BuildContext context,
  required String title,
  String description = '',
  String confirmText = 'Ya, Lanjutkan',
  String cancelText = 'Tidak, Kembali',
  void Function()? onConfirm,
  void Function()? onCancel,
}) {
  showDialog<Widget>(
    context: context,
    builder: (ctx) {
      return Dialog(
        insetPadding: const EdgeInsets.all(30),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      child: Text(confirmText),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          overflow: TextOverflow.fade,
                        ),
                        primary: const Color(0xFFFF5731),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  SizedBox(width: (onCancel == null ? 0 : 10)),
                  (onCancel == null)
                      ? const SizedBox()
                      : Expanded(
                          child: ElevatedButton(
                            onPressed: onCancel,
                            child: Text(
                              cancelText,
                              style: const TextStyle(
                                color: Color(0xFFFF5731),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                overflow: TextOverflow.fade,
                              ),
                              // minimumSize: const Size.fromHeight(45),
                              primary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: const BorderSide(
                                  width: 2,
                                  color: Color(0xFFFF5731),
                                ),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showTransferButtonFlip({
  required BuildContext context,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Stack(
      alignment: Alignment.center,
      children: [
        // Center horizontally.
        Positioned(
          bottom: 0,
          child: Container(
            height: 75,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(color: Colors.white),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 20),
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Column(
                      children: const [
                        Image(image: AppImages.flipHome, height: 22),
                        SizedBox(height: 5),
                        Text(
                          'Beranda',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      pushScreen(context, (_) => const HistoryScreen());
                    },
                    child: Column(
                      children: const [
                        Image(image: AppImages.flipHistory, height: 22),
                        SizedBox(height: 5),
                        Text(
                          'Transaksi',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showTransferOptionFlip(context: context);
                    },
                    child: Column(
                      children: const [
                        Image(image: AppImages.flipTransfer, height: 60),
                        Text(
                          'Transfer',
                          style: TextStyle(
                            color: Color(0xFFFF5731),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      pushScreen(context, (_) => const CustomerServiceScreen());
                    },
                    child: Column(
                      children: const [
                        Image(image: AppImages.flipHelp, height: 22),
                        SizedBox(height: 5),
                        Text(
                          'Bantuan',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      pushScreen(
                        context,
                        (_) => UserBalanceScope(
                          notifier: userBalanceState,
                          child: const ProfileScreen(),
                        ),
                      );
                    },
                    child: Column(
                      children: const [
                        Image(image: AppImages.flipProfile, height: 22),
                        SizedBox(height: 5),
                        Text(
                          'Akun',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

void showTransferOptionFlip({
  required BuildContext context,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(15.0),
      ),
    ),
    backgroundColor: Colors.white,
    builder: (_) => Container(
      padding: const EdgeInsets.only(top: 30, left: 15, right: 15, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(),
            child: const Text(
              'Pilih Opsi Transfer',
              style: TextStyle(
                // color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(
                width: 2,
                color: Colors.black12,
              ),
            ),
            child: InkWell(
              highlightColor: Colors.white24,
              onTap: () {
                pushScreen(
                  context,
                  (_) => const ProductBankFlipScreen(),
                );
              },
              child: const ListTile(
                contentPadding:
                    EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                leading: CircleAvatar(
                  radius: 18.0,
                  backgroundColor: Colors.transparent,
                  child: Image(image: AppImages.flipTransfer),
                ),
                title: Text(
                  'Rekening Bank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Transfer ke 1 bank di satu waktu',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ListTileStyle.drawer,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void showDestinationBankFlip({
  required BuildContext context,
  required List<Vendor> items,
  Vendor? selectedVendor,
  String? destination,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(25.0),
      ),
    ),
    backgroundColor: Colors.white,
    builder: (_) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: PageBankInquiryFlip(
        items: items,
        selectedVendor: selectedVendor,
        destination: destination,
      ),
    ),
  );
}
