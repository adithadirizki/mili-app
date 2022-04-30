import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:miliv2/src/api/train.dart';
import 'package:miliv2/src/config/config.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/models/train_station.dart';
import 'package:miliv2/src/models/user_config.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/utils/parsing.dart';

part 'api.g.dart';

class Api {
  Api._();

  static String _token = '';
  static String _username = '';
  static String _signature = '';
  static String _deviceId = '';

  static List<Function(CustomException)> onErrorCallback = [];

  static void setToken(String token) {
    _token = token;
  }

  static void setUsername(String username) {
    _username = username;
  }

  static void setSignature(String signature) {
    _signature = signature;
  }

  static void setDeviceId(String deviceId) {
    _deviceId = deviceId;
  }

  static void addErrorCallback(Function(CustomException) callback) {
    onErrorCallback.add(callback);
  }

  static http.Response _parseResponse(http.Response response) {
    Map<String, dynamic> bodyMap =
        json.decode(response.body) as Map<String, dynamic>;

    String errorMsg = 'Unknown error';
    if (bodyMap.keys.contains("error_msg")) {
      errorMsg = bodyMap["error_msg"].toString();
    }

    CustomException exception;
    switch (response.statusCode) {
      case 200:
        return response;
      case 400:
        exception = BadRequestException(errorMsg);
        break;
      case 401:
      case 403:
        exception = UnauthorisedException('Unauthorized Access');
        break;
      case 500:
        exception = FetchDataException('Internal Server Error');
        break;
      default:
        exception = FetchDataException('Tidak bisa terhubung ke server');
        break;
    }

    for (var callback in onErrorCallback) {
      callback.call(exception);
    }

    throw exception;
  }

  static Map<String, String>? getRequestHeaders(
      {String contentType = 'application/json'}) {
    if (_token == '') {
      return {"Content-Type": "application/json"};
    }
    return {
      "Content-Type": 'application/json', // 'multipart/form-data'
      'Authorization': 'Bearer ' + _token,
      'Device': _deviceId,
    };
  }

  static Map<String, String>? getSignatureHeaders(
      {required String body, required String ipAddress}) {
    var now = DateTime.now().toIso8601String();
    var req = ipAddress + body + now;
    var signature = sha256.convert(utf8.encode(req)).toString().toUpperCase();
    signature = sha1.convert(utf8.encode(signature)).toString();
    return {
      "Content-Type": 'application/json',
      'Datetime': now,
      'Signature': signature,
    };
  }

  static Future<http.Response> signIn(
      String username, String password, String imei) {
    Map<String, Object> body = <String, Object>{
      'user_id': username,
      'password': password,
      'imei': imei,
    };
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/login'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> requestOTP(OTPType otpType) {
    String type = "";
    switch (otpType) {
      case OTPType.whatsapp:
        type = "WHATSAPP";
        break;
      case OTPType.sms:
        type = "SMS";
        break;
      case OTPType.email:
        type = "EMAIL";
        break;
    }
    Map<String, Object> body = <String, Object>{
      'user_id': _username,
      'imei': _deviceId,
      'otp_type': type,
    };
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/request-otp'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> verifyOTP(String otp) {
    Map<String, Object> body = <String, Object>{
      'imei': _deviceId,
      'otp': otp,
    };
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/verify'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> verifyReferral(String referralCode) {
    Map<String, Object> body = <String, Object>{
      'referral_code': referralCode,
    };
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/verify-referral'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> resetPassword(
      String newPassword, String newPasswordConfirm, String token) {
    Map<String, Object> body = <String, Object>{
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirm,
      'token': token,
    };
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/reset-password'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> register(Map<String, Object> body) {
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/register'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> changePassword(Map<String, Object> body) {
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/change-password'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> guest(String imei, String ipAddress) {
    Map<String, Object> body = <String, Object>{
      'imei': imei,
    };
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/guest'),
          headers: getSignatureHeaders(
              body: json.encode(body), ipAddress: ipAddress),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> clientInfo() {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/client'),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> subscribeMessaging(
      {required String token,
      required String deviceInfo,
      required String appVersion,
      required String osInfo}) {
    Map<String, Object> body = <String, Object>{
      'notification_token': token,
      'imei': _deviceId,
      'merk': deviceInfo,
      'type': appVersion,
      'OS': osInfo,
    };
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/register-notification'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getProfile() {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/profile'),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> updateProfile(Map<String, Object> body) {
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/profile'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.StreamedResponse> updatePhotoProfile(
      List<int> bytes, String filename) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse(AppConfig.baseUrl + '/profile'));

    var headers = getRequestHeaders();
    request.headers.addAll(headers!);

    request.files
        .add(http.MultipartFile.fromBytes('photo', bytes, filename: filename));

    return request.send();
  }

  static Future<http.StreamedResponse> upgrade(
      {required String idCardNumber,
      required int province,
      required int city,
      required int district,
      required int village,
      required String postCode,
      required String address,
      required List<int>? photo}) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse(AppConfig.baseUrl + '/profile/upgrade'));

    var headers = getRequestHeaders();
    request.headers.addAll(headers!);

    if (photo != null) {
      request.files.add(http.MultipartFile.fromBytes('id_card_photo', photo,
          filename: idCardNumber));
    }

    request.fields.addAll(<String, String>{
      // 'agenid': userId,
      'id_card_number': idCardNumber,
      'province': province.toString(),
      'district': city.toString(),
      'sub_district': district.toString(),
      'village': village.toString(),
      'postal_code': postCode,
      'address': address,
    });

    return request.send();
  }

  static Future<http.Response> getProvince() {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/regions/provinces'),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getCity(int? provinceId) {
    Map<String, Object> params = <String, Object>{
      'filter': json.encode(<String, dynamic>{'province_id': provinceId}),
    };
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/regions/regencies')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getDistrict(int? cityId) {
    Map<String, Object> params = <String, Object>{
      'filter': json.encode(<String, dynamic>{'regency_id': cityId}),
    };
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/regions/districts')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getVillage(int? districtId) {
    Map<String, Object> params = <String, Object>{
      'filter': json.encode(<String, dynamic>{'district_id': districtId}),
    };
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/regions/sub-districts')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getActiveBanner() {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/active-banners'),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getTopupInfo() {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/balance/info'),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<Map<String, dynamic>> createTopupTicket(double amount) {
    Map<String, Object> body = <String, Object>{
      "total": amount,
    };
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/balance'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse)
        .then((response) => json.decode(response.body) as Map<String, dynamic>);
  }

  static Future<http.Response> cancelTopupTicket(int id) {
    Map<String, Object> body = <String, Object>{
      'id': id,
    };
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/balance/cancel'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  // TODO ganti semua response paging ke PagingResponse<T>
  static Future<PagingResponse> getTopupHistory({Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/balance/history')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse)
        .then((response) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);
      return pagingResponse;
    });
  }

  static Future<http.Response> getTransferInfo() {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/purchase/transfer-info'),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> inquiryTransfer(double amount, String userId) {
    Map<String, Object> body = <String, Object>{
      "amount": amount,
      "user_id": userId,
    };
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/purchase/user/inquiry'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> transferBalance(double amount, String userId) {
    Map<String, Object> body = <String, Object>{
      "amount": amount,
      "user_id": userId,
    };
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/purchase/transfer-deposit'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getAllProducts({Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/products/all')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getProductVendor({Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/products/vendor')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getProductCriteria(String productCode) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/products/criteria/$productCode'),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getPdamArea(String productCode) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/products/pdam'),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> purchaseProduct(
      {required String trxId,
      required String productCode,
      required String destination,
      required PaymentMethod method}) {
    Map<String, Object> body = <String, Object>{
      'transaction_id': trxId,
      'product_code': productCode,
      'transaction_number': destination,
      'payment_type':
          method == PaymentMethod.creditBalance ? 'credit' : 'balance'
    };
    debugPrint('purchaseProduct $body');
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/purchase'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> inquiryPayment({
    required String trxId,
    required String inquiryCode,
    required String destination,
    double? amount,
    String? productCode,
  }) {
    Map<String, Object> body = <String, Object>{
      'transaction_id': trxId,
      'product_code': inquiryCode,
      'transaction_number': destination
    };
    if (amount != null) {
      body['amount'] = amount;
    }
    if (productCode != null) {
      body['vtype'] = productCode;
    }
    debugPrint('inquiryPayment $body');
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/purchase/inquiry'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getPurchaseHistory(
      {Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/purchase/history')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getPurchaseDetail(int pruchaseId,
      {Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/purchase/print/$pruchaseId')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getFavorite({Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/purchase/favorite')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> addFavorite(
      String name, String productCode, String destination) {
    Map<String, Object> body = <String, Object>{
      'name': name,
      'product_code': productCode,
      'transaction_number': destination
    };
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/purchase/favorite'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> updateFavorite(int id, String name) {
    Map<String, Object> body = <String, Object>{
      'name': name,
    };
    return http
        .put(
          Uri.parse(AppConfig.baseUrl + '/purchase/favorite/$id'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> removeFavorite(int id) {
    return http
        .delete(
          Uri.parse(AppConfig.baseUrl + '/purchase/favorite/$id'),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getBalanceMutation(
      {Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/mutasi')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getCreditMutation(
      {Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/credit/mutasi')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getNotification({Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/notification/history')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getCustomerService(
      {Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/customer-service')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.StreamedResponse> sendImageMessage(
      List<int> bytes, String filename, String userId) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse(AppConfig.baseUrl + '/customer-service'));

    var headers = getRequestHeaders();
    request.headers.addAll(headers!);

    request.files
        .add(http.MultipartFile.fromBytes('photo', bytes, filename: filename));
    request.fields.addAll(<String, String>{
      'body': filename,
      'agenid': userId,
    });

    return request.send();
  }

  static Future<http.Response> sendMessage(String message, String userId) {
    Map<String, Object> body = <String, Object>{
      'body': message,
      'agenid': userId,
    };
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/customer-service'),
          headers: getRequestHeaders(contentType: 'multipart/form-data'),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> saveUserConfig(UserConfig config) {
    Map<String, Object?> body = <String, Object?>{
      'name': config.name,
      'config': config.configMap
    };
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/user-config'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getUserConfig({Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/user-config')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getPrintSample({Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/print-sample')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getOutletType({Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/outlet-types')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getDownline({Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/downline')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> registerDownline(
      {required String name,
      required String phoneNumber,
      required String outletType,
      required String email,
      required double markup,
      required String address}) {
    Map<String, Object?> body = <String, Object?>{
      'name': name,
      'phone_number': phoneNumber,
      'markup': markup,
      'email': email,
      'outlet_type': outletType,
      'address': address,
    };
    debugPrint('Downline register $body');
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/downline'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getDownlineSummary(
      {Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/downline/summary')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getDownlineLastTransaction(
      {Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/downline/last-transaction')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> updateDownline(String userId,
      {required double markup}) {
    Map<String, Object?> body = <String, Object?>{
      'markup': markup,
    };
    return http
        .put(
          Uri.parse(AppConfig.baseUrl + '/downline/$userId'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> getPriceSetting({Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/product-price')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<http.Response> updatePriceSetting(
      String productCode, double price) {
    Map<String, Object> body = <String, Object>{
      'vtype': productCode,
      'price': price
    };
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/product-price'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<PagingResponse> getTrainStation({Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/kai/stations')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse)
        .then((response) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);
      return pagingResponse;
    });
  }

  static Future<Map<String, dynamic>> getTrainSchedule({
    required TrainStation departure,
    required TrainStation destination,
    required int numAdult,
    required int numChild,
    required DateTime date,
  }) {
    Map<String, dynamic> params = <String, Object?>{
      'departure': departure.code,
      'destination': destination.code,
      'adult': numAdult.toString(),
      'child': numChild.toString(),
      'date': formatDate(date, format: 'yyyy-MM-dd'),
    };
    debugPrint('Get schedules params $params');
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/kai/schedules')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse)
        .then((response) {
      debugPrint('Response ${response.body}');
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      return bodyMap;
    });
  }

  static Future<http.Response> createTrainBooking({
    required TrainStation departure,
    required TrainStation destination,
    required int numAdult,
    required int numChild,
    required TrainScheduleResponse train,
    required List<TrainPassengerAdultData> adultPassengers,
    required List<TrainPassengerChildData> childPassengers,
  }) {
    Map<String, dynamic> body = <String, Object?>{
      'departure': departure.code,
      'destination': destination.code,
      'adult': numAdult.toString(),
      'child': numChild.toString(),
      'date': formatDate(train.departureDatetime, format: 'yyyy-MM-dd'),
      'train_no': train.trainNo,
      'train_name': train.trainName,
      'class': train.detail.classCode,
      'sub_class': train.detail.subClass,
      'depart_datetime':
          formatDate(train.departureDatetime, format: 'yyyy-MM-dd HH:mm:ss'),
      'arrival_datetime':
          formatDate(train.arrivalDatetime, format: 'yyyy-MM-dd HH:mm:ss'),
      'adultPassengers': adultPassengers,
      'childPassengers': childPassengers,
    };
    debugPrint('Create train booking $body');
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/kai/bookings'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse);
  }

  static Future<PagingResponse> getTrainBookingList(
      {Map<String, Object>? params}) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/kai/bookings')
              .replace(queryParameters: params),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse)
        .then((response) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);
      return pagingResponse;
    });
  }

  static Future<Map<String, dynamic>> getTrainBookingDetail({
    required TrainBookingResponse booking,
  }) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/kai/bookings/${booking.bookingId}'),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse)
        .then((response) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      return bodyMap;
    });
  }

  static Future<http.Response> payTrainBooking({
    required TrainBookingResponse booking,
  }) {
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/kai/payment/${booking.bookingId}'),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse);
  }

  static Future<Map<String, dynamic>> getTrainSeatMap({
    required TrainBookingResponse booking,
  }) {
    return http
        .get(
          Uri.parse(AppConfig.baseUrl + '/kai/seatmaps/${booking.bookingId}'),
          headers: getRequestHeaders(),
        )
        .then(_parseResponse)
        .then((response) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      return bodyMap;
    });
  }

  static Future<Map<String, dynamic>> changeTrainSeat({
    required int passengerId,
    required String wagonCode,
    required String wagonNo,
    required TrainRowData seat,
  }) {
    Map<String, dynamic> body = <String, Object?>{
      'wagon_code': wagonCode,
      'wagon_no': wagonNo,
      'row': seat.row.toString(),
      'column': seat.column.toString(),
      'seat_row': seat.seatRow.toString(),
      'seat_column': seat.seatColumn,
    };
    debugPrint('Change seat $body');
    return http
        .post(
          Uri.parse(AppConfig.baseUrl + '/kai/seats/$passengerId'),
          headers: getRequestHeaders(),
          body: json.encode(body),
        )
        .then(_parseResponse)
        .then((response) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      return bodyMap;
    });
  }
}

@JsonSerializable()
class ErrorResponse {
  @JsonKey(name: 'error_msg')
  final String errorMessage;

  @JsonKey(name: 'status_code')
  final int statusCode;

  ErrorResponse(this.errorMessage, this.statusCode);

  factory ErrorResponse.fromString(String body) =>
      _$ErrorResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}

@JsonSerializable()
class PagingResponse {
  @JsonKey(name: 'offset', fromJson: offsetLimitEncoder)
  final int offset;

  @JsonKey(name: 'limit', fromJson: offsetLimitEncoder)
  final int limit;

  @JsonKey(name: 'total')
  final int total;

  @JsonKey(name: 'data')
  final List<dynamic> data;

  PagingResponse(this.offset, this.limit, this.total, this.data);

  factory PagingResponse.fromString(String body) =>
      _$PagingResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory PagingResponse.fromJson(Map<String, dynamic> json) =>
      _$PagingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PagingResponseToJson(this);
}

class CustomException implements Exception {
  final dynamic _message;
  final String? _prefix;

  CustomException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends CustomException {
  FetchDataException([String? message]) : super(message, "");
}

class BadRequestException extends CustomException {
  BadRequestException([String? message]) : super(message, "");
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([String? message]) : super(message, "");
}

class InvalidInputException extends CustomException {
  InvalidInputException([String? message]) : super(message, "");
}
