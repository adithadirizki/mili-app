import 'package:miliv2/src/api/program.dart';
import 'package:miliv2/src/config/config.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Program {
  int id;
  int serverId;
  String code;
  String title;
  String description;
  String url;
  String? link;

  Program({
    this.id = 0,
    required this.serverId,
    required this.code,
    required this.title,
    required this.description,
    required this.url,
    this.link,
  });

  factory Program.fromResponse(ProgramResponse response) =>
      Program(
        serverId: response.id,
        code: response.code,
        title: response.title,
        description: response.description,
        url: response.url,
        link: response.link,
      );

  String getImageUrl() {
    return AppConfig.baseUrl + '/' + url;
  }
}
