import 'package:miliv2/src/config/config.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Banner {
  int id = 0;
  String url;
  String? title;
  String? description;
  String? bannerLink;
  int weight = 0;

  Banner(
      {this.id = 0,
      required this.url,
      this.title,
      this.description,
      this.bannerLink,
      this.weight = 0});

  String getImageUrl() {
    return AppConfig.baseUrl + '/' + url;
  }
}
