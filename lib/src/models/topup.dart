import 'package:miliv2/src/api/topup.dart';
import 'package:objectbox/objectbox.dart';

@Entity(uid: 8402351909725558156)
class TopupHistory {
  int id;
  int serverId;
  String userId;
  String bank;
  double amount;
  double mutasi;
  @Property(type: PropertyType.date)
  DateTime transactionDate;
  @Property(type: PropertyType.date)
  DateTime confirmedDate;
  @Property(type: PropertyType.date)
  DateTime? paidDate;
  int status;
  String notes;

  TopupHistory({
    this.id = 0,
    required this.serverId,
    required this.userId,
    required this.bank,
    required this.amount,
    required this.mutasi,
    required this.transactionDate,
    required this.confirmedDate,
    this.paidDate,
    required this.status,
    required this.notes,
  });

  factory TopupHistory.fromResponse(TopupHistoryResponse response) =>
      TopupHistory(
        serverId: response.serverId,
        userId: response.userId,
        bank: response.bank,
        amount: response.amount,
        mutasi: response.mutasi,
        transactionDate: response.transactionDate,
        confirmedDate: response.confirmedDate,
        paidDate: response.paidDate,
        status: response.status,
        notes: response.notes,
      );

  bool get isSuccess => status == 1;
  bool get isFailed => status == 2;
  bool get isPending => status == 0;
}
