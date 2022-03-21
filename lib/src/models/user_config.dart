import 'dart:convert';

import 'package:miliv2/src/api/user_config.dart';
import 'package:objectbox/objectbox.dart';

@Entity(uid: 305973175816696135)
class UserConfig {
  int id = 0;
  int serverId;
  String name;
  String userId;
  String? config;
  @Property(type: PropertyType.date)
  DateTime lastUpdate;

  UserConfig({
    this.id = 0,
    required this.serverId,
    required this.name,
    required this.lastUpdate,
    required this.userId,
    this.config,
  });

  factory UserConfig.fromResponse(UserConfigResponse response) => UserConfig(
        serverId: response.serverId,
        name: response.name,
        config: json.encode(response.config),
        lastUpdate: response.lastUpdate,
        userId: response.userId,
      );

  Map<String, dynamic> get configMap => config == null
      ? <String, dynamic>{}
      : json.decode(config!) as Map<String, dynamic>;
}
