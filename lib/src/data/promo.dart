import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/promo.dart';

class PromoState extends ChangeNotifier {
  List<PromoResponse> promoList = [];
  bool isLoading = false;

  PromoState();

  void _handleResponse(Response response) {
    Map<String, dynamic> bodyMap =
        json.decode(response.body) as Map<String, dynamic>;
    var pagingResponse = PagingResponse.fromJson(bodyMap);
    promoList = [];
    for (var e in pagingResponse.data) {
      promoList.add(PromoResponse.fromJson(e as Map<String, dynamic>));
    }
    debugPrint('Fetch PromoState success ${promoList.length}');
    isLoading = false;
    notifyListeners();
  }

  FutureOr<void> _handleError(Object e) {
    debugPrint('Fetch PromoState error $e');
    throw e;
  }

  Future<void> fetchData() {
    isLoading = true;
    notifyListeners();
    return Api.promoList().then(_handleResponse).catchError(_handleError);
  }
}

// Initialized
final promoState = PromoState();

class PromoScope extends InheritedNotifier<PromoState> {
  const PromoScope({
    required PromoState notifier,
    required Widget child,
    Key? key,
  }) : super(key: key, notifier: notifier, child: child);

  static PromoState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PromoScope>()!.notifier!;
}
