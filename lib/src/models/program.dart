import 'package:miliv2/src/api/program.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Program {
  int id;
  String code;
  String title;
  bool isActive;
  bool isOpened;
  String startAt;
  String endAt;

  Program(
      {this.id = 0,
      required this.code,
      required this.title,
      required this.isActive,
      required this.isOpened,
      required this.startAt,
      required this.endAt});

  factory Program.fromResponse(ProgramResponse response) => Program(
    code: response.code,
    title: response.title,
    isActive: response.isActive,
    isOpened: response.isOpened,
    startAt: response.startAt,
    endAt: response.endAt,
  );
}
