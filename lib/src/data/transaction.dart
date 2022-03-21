import 'package:flutter/material.dart';

class TransactionState extends ChangeNotifier {
  DateTime lastUpdate = DateTime.now();

  TransactionState();

  void updateState() {
    lastUpdate = DateTime.now();
    notifyListeners();
  }
}

// Initialized
final transactionState = TransactionState();

class UserBalanceScope extends InheritedNotifier<TransactionState> {
  const UserBalanceScope({
    required TransactionState notifier,
    required Widget child,
    Key? key,
  }) : super(key: key, notifier: notifier, child: child);

  static TransactionState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UserBalanceScope>()!.notifier!;
}
