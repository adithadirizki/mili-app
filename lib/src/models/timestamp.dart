import 'package:objectbox/objectbox.dart';

@Entity(uid: 2401040545417390310)
class ApiSyncTime {
  int id;
  String apiCode;
  int timestamp;

  ApiSyncTime({
    this.id = 0,
    required this.apiCode,
    required this.timestamp,
  });
}
