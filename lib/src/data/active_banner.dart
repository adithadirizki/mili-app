import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/banner.dart';

class ActiveBannerState extends ChangeNotifier {
  List<BannerResponse> bannerList = [];
  bool isLoading = false;

  ActiveBannerState();

  void _handleResponse(Response response) {
    Map<String, dynamic> bodyMap =
        json.decode(response.body) as Map<String, dynamic>;
    var pagingResponse = PagingResponse.fromJson(bodyMap);
    bannerList = [];
    for (var e in pagingResponse.data) {
      bannerList.add(BannerResponse.fromJson(e as Map<String, dynamic>));
    }
    debugPrint('Fetch ActiveBannerState success ${bannerList.length}');
    isLoading = false;
    notifyListeners();
  }

  FutureOr<void> _handleError(Object e) {
    debugPrint('Fetch ActiveBannerState error $e');
    throw e;
  }

  Future<void> fetchData() {
    isLoading = true;
    notifyListeners();
    return Api.getActiveBanner().then(_handleResponse).catchError(_handleError);
  }
}

// final activeBannerProvider = ChangeNotifierProvider(create: (context) {
//   return ActiveBannerState();
// });

// Initialized
final activeBannerState = ActiveBannerState();

class ActiveBannerScope extends InheritedNotifier<ActiveBannerState> {
  const ActiveBannerScope({
    required ActiveBannerState notifier,
    required Widget child,
    Key? key,
  }) : super(key: key, notifier: notifier, child: child);

  static ActiveBannerState of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ActiveBannerScope>()!
      .notifier!;
}
