import 'package:miliv2/src/api/train.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class TrainStation {
  int id = 0;
  int serverId;
  String code;
  String stationName;
  String stationFullname;
  String city;

  TrainStation({
    this.id = 0,
    required this.serverId,
    required this.code,
    required this.stationName,
    required this.stationFullname,
    required this.city,
  });

  factory TrainStation.fromResponse(TrainStationResponse response) =>
      TrainStation(
        serverId: response.serverId,
        code: response.code,
        stationName: response.stationName,
        stationFullname: response.stationFullname,
        city: response.city,
      );
}
