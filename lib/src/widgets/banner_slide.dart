import 'package:flutter/material.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/banner.dart' as models;
import 'package:miliv2/src/theme.dart';
import 'package:objectbox/objectbox.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({Key? key}) : super(key: key);

  @override
  _BannerSliderState createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  late Stream<List<models.Banner>> _stream;
  late Box<models.Banner> _bannerBox;

  @override
  void initState() {
    super.initState();
    _bannerBox = AppDB.db.box<models.Banner>();
    setState(() {
      _stream = _bannerBox
          .query()
          .watch(triggerImmediately: true)
          .map((query) => query.find());
    });
  }

  Widget Function(BuildContext, int) _itemBuilder(
      List<models.Banner> bannerList) {
    print('HomePromo itemBuilder ${bannerList.length}');
    return (context, position) {
      models.Banner promo = bannerList[position];
      return Container(
        margin: const EdgeInsets.only(
            right: 10.0, bottom: 10.0, top: 5.0, left: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(15.0),
              child: GestureDetector(
                onTap: promo.bannerLink != null
                    ? () {
                        launch(promo.bannerLink!, forceWebView: true);
                        // Navigator.pushNamed(
                        //   context,
                        //   '/browser',
                        //   arguments: ScreenArguments(
                        //     promo.title!,
                        //     promo.image!,
                        //   ),
                        // );
                      }
                    : null,
                child: FadeInImage(
                  image: NetworkImage(promo.getImageUrl()),
                  placeholder: AppImages.logoAxis,
                  width: 300,
                ),
              ),
            ),
          ],
        ),
      );
    };
  }

  Widget _buildSlide(List<models.Banner> bannerList) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Promo",
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
          const Divider(),
          SizedBox(
              // height: getProportionateScreenHeight(150),
              height: 150,
              child:
                  // Consumer<ActiveBannerState>(builder: (context, activeBanner, child) {
                  ListView.builder(
                      itemCount: bannerList.length,
                      physics: const ClampingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: _itemBuilder(bannerList))
              // })
              )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<models.Banner>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return _buildSlide(snapshot.data!);
      },
    );
  }
}
