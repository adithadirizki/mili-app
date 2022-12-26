import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:miliv2/src/data/active_banner.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePromo extends StatefulWidget {
  const HomePromo({Key? key}) : super(key: key);

  @override
  _HomePromoState createState() => _HomePromoState();
}

class _HomePromoState extends State<HomePromo> {
  // List<BannerResponse> bannerList = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Provider.of<ActiveBannerState>(context, listen: false).fetchData();
    // print('init home promo');
  }

  @override
  Widget build(BuildContext context) {
    var activeBanner = ActiveBannerScope.of(context);

    return Container(
        child: Column(children: [
      CarouselSlider(
        options: CarouselOptions(
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastLinearToSlowEaseIn,
            pauseAutoPlayOnTouch: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            onPageChanged: (index, reason) {
              setState(() {
                currentIndex = index;
              });
            }),
        items: activeBanner.bannerList.map((promo) {
          return Container(
            margin: const EdgeInsets.only(
              bottom: 50,
              top: 20,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 5.0,
                ),
              ],
            ),
            child: ClipRRect(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(10.0),
              child: GestureDetector(
                onTap: (promo.bannerLink != null &&
                        promo.bannerLink!.isNotEmpty)
                    ? () async {
                        if (await canLaunch(promo.bannerLink!)) {
                          debugPrint('Launch ${promo.bannerLink}');
                          await launch(promo.bannerLink!);
                        } else {
                          snackBarDialog(context, 'Tidak bisa membuka link');
                        }
                      }
                    : null,
                child: CachedNetworkImage(
                  imageUrl: promo.getImageUrl(),
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  width: 400,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        // colorFilter:
                        //     ColorFilter.mode(Colors.red, BlendMode.colorBurn),
                      ),
                    ),
                    alignment: Alignment.topRight,
                    child: (promo.bannerLink != null &&
                            promo.bannerLink!.isNotEmpty)
                        ? const Icon(
                            Icons.info_outlined,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
      Transform.translate(
        offset: const Offset(0, -40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: activeBanner.bannerList.asMap().entries.map((e) {
            return Container(
              width: currentIndex == e.key ? 20 : 7.0,
              height: 7.0,
              margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 2.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: currentIndex == e.key
                      ? Colors.blue
                      : Colors.blue.withOpacity(0.3)),
            );
          }).toList(),
        ),
      ),
    ]));
  }
}
