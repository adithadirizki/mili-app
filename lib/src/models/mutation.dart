import 'package:miliv2/src/api/mutation.dart';
import 'package:objectbox/objectbox.dart';

@Entity(uid: 4848374935884315676)
class BalanceMutation {
  int id;
  int serverId;
  String userId;
  @Property(type: PropertyType.date)
  DateTime mutationDate;
  String description;
  String? productCode;
  String? productName;
  String? productDetail;
  double debitAmount;
  double creditAmount;
  double startBalance;
  double endBalance;

  BalanceMutation({
    this.id = 0,
    required this.serverId,
    required this.userId,
    required this.mutationDate,
    required this.description,
    this.productCode,
    this.productName,
    this.productDetail,
    required this.debitAmount,
    required this.creditAmount,
    required this.startBalance,
    required this.endBalance,
  });

  factory BalanceMutation.fromResponse(BalanceMutationResponse response) =>
      BalanceMutation(
        serverId: response.serverId,
        userId: response.userId,
        mutationDate: response.mutationDate,
        description: response.description,
        productCode: response.productCode,
        productName: response.productName,
        productDetail: response.productDetail,
        debitAmount: response.debitAmount,
        creditAmount: response.creditAmount,
        startBalance: response.startBalance,
        endBalance: response.endBalance,
      );
}

@Entity()
class CreditMutation {
  int id;
  int serverId;
  String userId;
  @Property(type: PropertyType.date)
  DateTime mutationDate;
  String description;
  String? productCode;
  String? productName;
  String? productDetail;
  double debitAmount;
  double creditAmount;
  double startBalance;
  double endBalance;

  CreditMutation({
    this.id = 0,
    required this.serverId,
    required this.userId,
    required this.mutationDate,
    required this.description,
    this.productCode,
    this.productName,
    this.productDetail,
    required this.debitAmount,
    required this.creditAmount,
    required this.startBalance,
    required this.endBalance,
  });

  factory CreditMutation.fromResponse(CreditMutationResponse response) =>
      CreditMutation(
        serverId: response.serverId,
        userId: response.userId,
        mutationDate: response.mutationDate,
        description: response.description,
        productCode: response.productCode,
        productName: response.productName,
        productDetail: response.productDetail,
        debitAmount: response.debitAmount,
        creditAmount: response.creditAmount,
        startBalance: response.startBalance,
        endBalance: response.endBalance,
      );
}
