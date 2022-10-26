import 'package:miliv2/src/api/topup_retail.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class TopupRetailHistory {
  int id;
  int serverId;
  String agenid;
  String nohp;
  String customer_name;
  double nominal;
  double? additionalfee;
  int? payment_reff;
  String? kode_pembayaran;
  String channel;
  int status;
  String? sn;
  @Property(type: PropertyType.date)
  DateTime? tanggal_bayar;
  @Property(type: PropertyType.date)
  DateTime created_at;

  TopupRetailHistory({
    this.id = 0,
    required this.serverId,
    required this.agenid,
    required this.nohp,
    required this.customer_name,
    required this.nominal,
    this.additionalfee,
    this.payment_reff,
    this.kode_pembayaran,
    required this.channel,
    required this.status,
    this.sn,
    this.tanggal_bayar,
    required this.created_at,
  });

  factory TopupRetailHistory.fromResponse(
          TopupRetailHistoryResponse response) =>
      TopupRetailHistory(
        serverId: response.serverId,
        agenid: response.agenid,
        nohp: response.nohp,
        customer_name: response.customer_name,
        nominal: response.nominal,
        additionalfee: response.additionalfee,
        payment_reff: response.payment_reff,
        kode_pembayaran: response.kode_pembayaran,
        channel: response.channel,
        status: response.status,
        sn: response.sn,
        tanggal_bayar: response.tanggal_bayar,
        created_at: response.created_at,
      );

  bool get isSuccess => status == 1;
  bool get isFailed => status == 2;
  bool get isPending => status == 0;
  bool get isExpired => status == 3;
}
