import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:miliv2/src/theme/theme.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

void confirmDialog(BuildContext context,
    {required String msg,
    required void Function() confirmAction,
    String? title,
    String? confirmText,
    String? cancelText,
    void Function()? cancelAction}) {
  showDialog<Widget>(
    context: context,
    builder: (ctx) {
      return SimpleDialog(
        title: title != null
            ? Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              )
            : null,
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
            child: SelectableText(
              msg,
              textAlign: TextAlign.left,
              // style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: cancelAction != null
                      ? () async {
                          await Navigator.of(context).maybePop();
                          cancelAction();
                        }
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: cancelText != null
                      ? Text(
                          cancelText,
                          // style: Theme.of(context).textTheme.button,
                        )
                      : const Text(
                          'Tidak',
                          // style: Theme.of(context).textTheme.button,
                        ),
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.of(context).maybePop();
                    confirmAction();
                  },
                  child: confirmText != null
                      ? Text(
                          confirmText,
                          // style: Theme.of(context).textTheme.button,
                        )
                      : const Text(
                          'Ya',
                          // style: Theme.of(context).textTheme.button,
                        ),
                )
              ],
            ),
          ),
        ],
      );
    },
  );
}

void infoDialog(BuildContext context, {required String msg, String? title}) {
  showDialog<Widget>(
    context: context,
    builder: (ctx) {
      return SimpleDialog(
        title: title != null
            ? Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            : null,
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
            child: SelectableText(
              msg,
              textAlign: TextAlign.left,
              // style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Tutup',
                    // style: Theme.of(context).textTheme.button,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

// TODO CupertinoPicker

// TODO CupertinoSheet

// TODO CupertinoDatePicker https://github.com/JohannesMilke/cupertino_datepicker_example/tree/master/lib/page
// SizedBox(
//         height: 180,
//         child: CupertinoDatePicker(
//           minimumYear: 2015,
//           maximumYear: DateTime.now().year,
//           initialDateTime: dateTime,
//           mode: CupertinoDatePickerMode.date,
//           onDateTimeChanged: (dateTime) =>
//               setState(() => this.dateTime = dateTime),
//         ),
//       );
// }
// Widget buildCustomPicker() => SizedBox(
//       height: 300,
//       child: CupertinoPicker(
//         itemExtent: 64,
//         diameterRatio: 0.7,
//         looping: true,
//         onSelectedItemChanged: (index) => setState(() => this.index = index),
//         // selectionOverlay: Container(),
//         selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
//           background: Colors.pink.withOpacity(0.12),
//         ),
//         children: Utils.modelBuilder<String>(
//           values,
//           (index, value) {
//             final isSelected = this.index == index;
//             final color = isSelected ? Colors.pink : Colors.black;
//
//             return Center(
//               child: Text(
//                 value,
//                 style: TextStyle(color: color, fontSize: 24),
//               ),
//             );
//           },
//         ),
//       ),
//     );
// }

/// Alternativaly: You can display an Android Styled Bottom Sheet instead of an iOS styled bottom Sheet
// static void showSheet(
//   BuildContext context, {
//   required Widget child,
// }) =>
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => child,
//     );

// void showSheet(
//   BuildContext context, {
//   required Widget child,
//   required VoidCallback onPressed,
// }) =>
//     showCupertinoModalPopup<String>(
//       context: context,
//       builder: (context) => CupertinoActionSheet(
//         actions: [
//           child,
//         ],
//         cancelButton: CupertinoActionSheetAction(
//           child: Text('Done'),
//           onPressed: onPressed,
//         ),
//       ),
//     );

void snackBarDialog(BuildContext context, String text,
    {String? title, int duration = 1000}) {
  showTopSnackBar(
    context,
    ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 0,
        maxHeight: 200,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xDD505050),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  title != null
                      ? Text(
                          title,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        )
                      : const SizedBox(height: 0),
                  Flexible(
                    flex: 1,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(
                        text,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.clear,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    ),
    showOutAnimationDuration: const Duration(milliseconds: 1000),
    hideOutAnimationDuration: const Duration(milliseconds: 300),
    displayDuration: Duration(milliseconds: duration),
    // CustomSnackBar.info(
    //   message: text,
    //   messagePadding: EdgeInsets.all(10),
    //   icon: const Icon(
    //     Icons.info_outline,
    //     size: 48,
    //     color: Colors.white,
    //   ),
    //   iconPositionLeft: 10,
    //   iconPositionTop: -10,
    //   iconRotationAngle: 0,
    // ),
  );
}

void simpleSnackBarDialog(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Text(text, style: const TextStyle(fontSize: 12)),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    backgroundColor: const Color(0xDD505050),
    elevation: 0,
    action: SnackBarAction(
      label: 'Tutup',
      textColor: Colors.white,
      onPressed: () {},
    ),
    // margin: EdgeInsets.only(
    //     bottom: MediaQuery.of(context).size.height - 250, right: 20, left: 20),
  );

  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(snackBar);
}

Future<DateTimeRange?> dateRangeDialog(BuildContext context,
    {DateTimeRange? initial, required DateTime firstDate, DateTime? lastDate}) {
  return showDateRangePicker(
    context: context,
    initialEntryMode: DatePickerEntryMode.calendar,
    initialDateRange: initial,
    firstDate: firstDate,
    lastDate: lastDate ?? DateTime.now(),
    cancelText: 'Batal',
    saveText: 'Ok',
    fieldStartLabelText: 'Tgl Awal',
    fieldEndLabelText: 'Tgl Akhir',
    errorFormatText: 'Format salah',
    errorInvalidRangeText: 'Range tanggal tidak sesuai',
    helpText: 'Pilih tanggal',
    builder: (context, child) {
      return Theme(
        data: lightTheme.copyWith(
          appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
        ),
        child: child!,
      );
    },
  );
}

Future<T?> bottomSheetDialog<T>(
    {required BuildContext context, double? minHeight, required Widget child}) {
  return showModalBottomSheet<T?>(
    context: context,
    builder: (context) {
      return ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight ?? 100.0),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: child,
        ),
      );
    },
  );
}

typedef WidgetBuilderCallback = Widget Function(BuildContext);

void pushScreen(BuildContext context, WidgetBuilderCallback builder) {
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: builder,
    ),
  );
}

Future<T?> pushScreenWithCallback<T>(
    BuildContext context, WidgetBuilderCallback builder) {
  return Navigator.of(context).push<T>(
    MaterialPageRoute<T>(
      builder: builder,
    ),
  );
}

void replaceScreen(BuildContext context, WidgetBuilderCallback builder) {
  Navigator.of(context).pushReplacement<void, void>(
    MaterialPageRoute<void>(
      builder: builder,
    ),
  );
}

Future<void> popScreenWithCallback<T>(BuildContext context, T? result) async {
  Navigator.of(context).pop(result);
}

Future<void> popScreen(BuildContext context) async {
  await Navigator.of(context).maybePop();
}
