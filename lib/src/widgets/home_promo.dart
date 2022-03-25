import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:miliv2/src/api/banner.dart';
import 'package:miliv2/src/data/active_banner.dart';

class HomePromo extends StatefulWidget {
  const HomePromo({Key? key}) : super(key: key);

  @override
  _HomePromoState createState() => _HomePromoState();
}

class _HomePromoState extends State<HomePromo> {
  // List<BannerResponse> bannerList = [];

  @override
  void initState() {
    super.initState();
    // Provider.of<ActiveBannerState>(context, listen: false).fetchData();
    // print('init home promo');
  }

  Widget Function(BuildContext, int) _itemBuilder(
      List<BannerResponse> bannerList) {
    return (context, position) {
      BannerResponse promo = bannerList[position];
      return Container(
        margin: const EdgeInsets.only(
          right: 10.0,
          bottom: 10.0,
          top: 5.0,
          left: 5.0,
        ),
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
        child: ClipRRect(
          clipBehavior: Clip.hardEdge,
          borderRadius: BorderRadius.circular(10.0),
          child: GestureDetector(
            onTap: () {
              // Navigator.pushNamed(
              //   context,
              //   '/browser',
              //   arguments: ScreenArguments(
              //     promo.title!,
              //     promo.image!,
              //   ),
              // );
            },
            child: CachedNetworkImage(
              imageUrl: promo.getImageUrl(),
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              width: 300,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    // colorFilter:
                    //     ColorFilter.mode(Colors.red, BlendMode.colorBurn),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Build HomePromo');
    var activeBanner = ActiveBannerScope.of(context);
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Promo',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              // Row(
              //   children: [
              //     Text(
              //       'Please wait...',
              //       style: Theme.of(context).textTheme.titleSmall,
              //     ),
              //     const SizedBox(width: 20),
              //     const SizedBox(
              //       width: 15,
              //       height: 15,
              //       child: Center(
              //         child: CircularProgressIndicator(
              //           color: AppColors.blue1,
              //         ),
              //       ),
              //     )
              //   ],
              // ),
            ],
          ),
          const Divider(),
          SizedBox(
            // height: getProportionateScreenHeight(150),
            height: 150,
            child: ListView.builder(
              key: const PageStorageKey('bannerlist'),
              itemCount: activeBanner.bannerList.length,
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: _itemBuilder(activeBanner.bannerList),
            ),
          ),
        ],
      ),
    );
  }
}
