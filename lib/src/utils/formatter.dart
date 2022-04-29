import 'package:intl/intl.dart';

const String locale = "id_ID";

String formatNumber(double number, {String? format}) {
  var f = NumberFormat(format ?? "#,###.#", locale);
  return f.format(number);
}

double parseDouble(String string) {
  return string.isEmpty
      ? 0
      : double.parse(string.replaceAll(RegExp('[^0-9]'), ''));
}

int parseInt(String string) {
  return string.isEmpty
      ? 0
      : int.parse(string.replaceAll(RegExp('[^0-9]'), ''));
}

String formatDate(DateTime date, {String? format}) {
  return DateFormat(format ?? 'd MMM yy HH:mm:ss', locale)
      .format(date.toLocal());
}

String printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

String getDestinationPrefix(String destination) {
  destination = destination.padRight(7, '0');
  if (destination[0] == '0') {
    destination = destination.replaceFirst('0', '+62');
  } else if (destination.substring(0, 3) == '62') {
    destination = destination.replaceFirst('62', '+62');
  }

  return destination.substring(0, 6);
}
