import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:miliv2/src/api/popup_banner.dart';
import 'package:miliv2/src/services/storage.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class PopupBanner extends StatefulWidget {
  final List<PopupBannerResponse> data;

  const PopupBanner({Key? key, required this.data}) : super(key: key);

  @override
  _PopupBannerState createState() => _PopupBannerState();
}

class _PopupBannerState extends State<PopupBanner> {
  @override
  void initState() {
    super.initState();

    // sort by weight desc
    widget.data.sort((a, b) => b.weight.compareTo(a.weight));
  }

  void closePopup(int id) {
    setState(() {
      widget.data.removeWhere((element) => element.id == id);
    });

    if (widget.data.isEmpty) Navigator.pop(context);
  }

  void dontShowAgain(int id) {
    AppStorage.setDontShowAgainPopupBanner(id.toString());

    closePopup(id);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      alignment: Alignment.center,
      backgroundColor: Colors.transparent,
      child: CarouselSlider(
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height * 0.8,
          enableInfiniteScroll: widget.data.length > 1,
          viewportFraction: 1,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 10),
        ),
        items: widget.data.map((popupBanner) {
          return Builder(
            builder: (context) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                          onTap: () {
                            closePopup(popupBanner.id);
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Text(
                              '[ Tutup ]',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: (popupBanner.url != null)
                          ? () async {
                              if (await canLaunch(popupBanner.url!)) {
                                await launch(popupBanner.url!);
                              } else {
                                snackBarDialog(
                                    context, 'Tidak bisa membuka link');
                              }
                            }
                          : null,
                      child: Image.network(
                        popupBanner.getImageUrl(),
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          dontShowAgain(popupBanner.id);
                        },
                        child: const Text(
                          '[ Jangan tampilkan lagi ]',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
