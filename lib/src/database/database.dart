import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/customer_service.dart';
import 'package:miliv2/src/api/mutation.dart';
import 'package:miliv2/src/api/notification.dart';
import 'package:miliv2/src/api/product.dart';
import 'package:miliv2/src/api/purchase.dart';
import 'package:miliv2/src/api/topup.dart';
import 'package:miliv2/src/api/train.dart';
import 'package:miliv2/src/api/user_config.dart';
import 'package:miliv2/src/config/config.dart';
import 'package:miliv2/src/models/customer_service.dart';
import 'package:miliv2/src/models/mutation.dart';
import 'package:miliv2/src/models/notification.dart';
import 'package:miliv2/src/models/product.dart';
import 'package:miliv2/src/models/purchase.dart';
import 'package:miliv2/src/models/timestamp.dart';
import 'package:miliv2/src/models/topup.dart';
import 'package:miliv2/src/models/train_station.dart';
import 'package:miliv2/src/models/user_config.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// https://resocoder.com/2021/05/18/objectbox-fast-local-database-for-flutter-with-optional-sync-across-devices/
///
class AppDB {
  static late final Store _db;
  static Map<String, bool> _syncLock = <String, bool>{};

  AppDB._();

  static Store get db => _db;

  static Future<void> initialize() async {
    await getApplicationDocumentsDirectory().then((dir) {
      _db = Store(
        getObjectBoxModel(),
        directory: join(dir.path, AppConfig.dbName),
      );

      // if (Sync.isAvailable()) {
      //   _syncClient = Sync.client(
      //     _store,
      //     Platform.isAndroid ? 'ws://10.0.2.2:9999' : 'ws://127.0.0.1:9999',
      //     SyncCredentials.none(),
      //   );
      //   _syncClient.start();
      // }
    });
  }

  static bool _lockedSyncronize(String apiCode) {
    return _syncLock[apiCode] != null && _syncLock[apiCode] == true;
  }

  static void _lockSyncronize(String apiCode) {
    _syncLock[apiCode] = true;
  }

  static void _unlockSyncronize(String apiCode) {
    _syncLock[apiCode] = false;
  }

  static Box<ApiSyncTime> get timestampDB => _db.box<ApiSyncTime>();
  static Box<Product> get productDB => _db.box<Product>();
  static Box<Vendor> get vendorDB => _db.box<Vendor>();
  static Box<PurchaseHistory> get purchaseHistoryDB =>
      _db.box<PurchaseHistory>();
  static Box<TopupHistory> get topupHistoryDB => _db.box<TopupHistory>();
  static Box<Notification> get notificationDB => _db.box<Notification>();
  static Box<BalanceMutation> get balanceMutationDB =>
      _db.box<BalanceMutation>();
  static Box<CreditMutation> get creditMutationDB => _db.box<CreditMutation>();
  static Box<CustomerService> get customerServiceDB =>
      _db.box<CustomerService>();
  static Box<UserConfig> get userConfigDB => _db.box<UserConfig>();
  static Box<TrainStation> get trainStationDB => _db.box<TrainStation>();

  static DateTime? getLastUpdate(String apiCode) {
    ApiSyncTime? rec = timestampDB
        .query(ApiSyncTime_.apiCode.equals(apiCode))
        .build()
        .findFirst();
    if (null != rec) {
      return DateTime.fromMillisecondsSinceEpoch(rec.timestamp);
    } else {
      return null;
    }
  }

  static ApiSyncTime setLastUpdate(String apiCode, DateTime time) {
    ApiSyncTime? rec = timestampDB
        .query(ApiSyncTime_.apiCode.equals(apiCode))
        .build()
        .findFirst();
    if (null != rec) {
      rec.timestamp = time.millisecondsSinceEpoch;
      timestampDB.put(rec);
    } else {
      rec =
          ApiSyncTime(apiCode: apiCode, timestamp: time.millisecondsSinceEpoch);
      timestampDB.put(rec);
    }
    return rec;
  }

  static Future<void> syncProduct({int offset = 0}) async {
    const apiCode = 'product-all';

    if (_lockedSyncronize(apiCode)) {
      return;
    }
    _lockSyncronize(apiCode);

    const limit = 50;
    DateTime? lastUpdate = getLastUpdate(apiCode);
    String timestamp = lastUpdate == null ? '' : lastUpdate.toIso8601String();

    Map<String, String> params = {
      'offset': offset.toString(),
      'limit': limit.toString(),
      'sort': json.encode({'updated_at': 'asc'}),
      'filter': json.encode({'updated_at': '>=|$timestamp'})
    };

    debugPrint('syncProduct with params $params');

    return Api.getAllProducts(params: params).then((response) async {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);

      debugPrint('syncProduct data length ${pagingResponse.data.length}');

      for (var data in pagingResponse.data) {
        try {
          ProductResponse res =
              ProductResponse.fromJson(data as Map<String, dynamic>);

          if (res.code.isNotEmpty) {
            Product? prev = productDB
                .query(Product_.code.equals(res.code))
                .build()
                .findFirst();
            if (prev != null) {
              // TODO ganti ke factory
              prev.code = res.code;
              prev.productName = res.productName;
              prev.groupName = res.groupName;
              prev.description = res.description ?? '';
              prev.status = res.status;
              prev.voucherType = res.voucherType;
              prev.productGroup = res.productGroup;
              prev.promo = res.promo;
              prev.prefix = res.prefix ?? '';
              prev.nominal = res.nominal;
              // prev.userPrice = res.price;
              prev.markup = res.markup;
              prev.priceLevel1 = res.priceLevel1;
              prev.priceLevel2 = res.priceLevel2;
              prev.priceLevel3 = res.priceLevel3;
              prev.priceLevel4 = res.priceLevel4;
              prev.priceLevel5 = res.priceLevel5;
              prev.priceLevel6 = res.priceLevel6;
              prev.priceLevel7 = res.priceLevel7;
              prev.priceLevel8 = res.priceLevel8;
              prev.priceLevel9 = res.priceLevel9;
              prev.priceLevel10 = res.priceLevel10;
              prev.updatedDate = res.updatedAt;
              productDB.put(prev);

              setLastUpdate(apiCode, res.updatedAt);
            } else {
              Product product = Product.fromResponse(res);
              productDB.put(product);

              setLastUpdate(apiCode, res.updatedAt);
            }
          }
        } catch (error) {
          debugPrint('syncProduct error $error at $data');
        }
      }

      debugPrint(
          'syncProduct lastUpdate $timestamp get ${pagingResponse.data.length} item from ${pagingResponse.total} ');

      _unlockSyncronize(apiCode);
      // Get next page
      if (pagingResponse.data.length >= limit) {
        DateTime? veryLastUpdate = getLastUpdate(apiCode);
        if (lastUpdate == veryLastUpdate) {
          offset += limit;
        } else {
          offset = 0;
        }
        return await syncProduct(offset: offset);
      }
    }).catchError((dynamic e) {
      _unlockSyncronize(apiCode);
      debugPrint('syncProduct error $e');
    });
  }

  static Future<void> syncVendor({int offset = 0}) async {
    const apiCode = 'vendor-list';

    if (_lockedSyncronize(apiCode)) {
      return;
    }
    _lockSyncronize(apiCode);

    const limit = 50;
    DateTime? lastUpdate = getLastUpdate(apiCode);
    String timestamp = lastUpdate == null ? '' : lastUpdate.toIso8601String();

    Map<String, String> params = {
      'offset': offset.toString(),
      'limit': limit.toString(),
      'sort': json.encode({'updated_at': 'asc'}),
      'filter': json.encode({'updated_at': '>=|$timestamp'})
    };

    debugPrint('syncVendor with params $params');

    return Api.getProductVendor(params: params).then((response) async {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);

      debugPrint('syncVendor data length ${pagingResponse.data.length}');

      for (var data in pagingResponse.data) {
        VendorResponse res =
            VendorResponse.fromJson(data as Map<String, dynamic>);

        debugPrint(
            'syncVendor id: ${res.serverId} name: ${res.name} vendorGroup: ${res.group} productGroups: ${res.productGroupNameList} config: ${res.config}');

        Vendor? prev = vendorDB
            .query(Vendor_.serverId.equals(res.serverId))
            .build()
            .findFirst();
        if (prev != null) {
          prev.name = res.name;
          prev.description = res.description ?? '';
          prev.title = res.title ?? '';
          prev.imageUrl = res.imageUrl;
          prev.group = res.group;
          prev.inquiryCode = res.inquiryCode ?? '';
          prev.paymentCode = res.paymentCode ?? '';
          prev.productCode = res.productCode ?? '';
          prev.config = json.encode(res.config);
          prev.productGroupNameList = res.productGroupNameList;
          prev.productType = res.productType;
          prev.updatedAt = res.updatedAt;
          vendorDB.put(prev);

          setLastUpdate(apiCode, res.updatedAt);
        } else {
          Vendor vendor = Vendor.fromResponse(res);
          vendorDB.put(vendor);

          setLastUpdate(apiCode, res.updatedAt);
        }
      }

      debugPrint(
          'syncVendor lastUpdate $timestamp get ${pagingResponse.data.length} item from ${pagingResponse.total} ');

      _unlockSyncronize(apiCode);
      // Get next page
      if (pagingResponse.data.length >= limit) {
        DateTime? veryLastUpdate = getLastUpdate(apiCode);
        if (lastUpdate == veryLastUpdate) {
          offset += limit;
        } else {
          offset = 0;
        }
        return await syncVendor(offset: offset);
      }
    }).catchError((dynamic e) {
      _unlockSyncronize(apiCode);
      debugPrint('syncVendor error $e');
    });
  }

  static Future<void> syncHistory({int offset = 0}) async {
    const apiCode = 'purchase-history';

    if (_lockedSyncronize(apiCode)) {
      return;
    }
    _lockSyncronize(apiCode);

    const limit = 50;
    DateTime? lastUpdate = getLastUpdate(apiCode);
    String timestamp = lastUpdate == null ? '' : lastUpdate.toIso8601String();

    Map<String, String> params = {
      'offset': offset.toString(),
      'limit': limit.toString(),
      'sort': json.encode({'tanggal': 'asc'}),
      'filter': json.encode({'tglsukses': '>|$timestamp'})
    };

    debugPrint('syncHistory with params $params');

    return Api.getPurchaseHistory(params: params).then((response) async {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);

      debugPrint('syncHistory data length ${pagingResponse.data.length}');

      for (var data in pagingResponse.data) {
        try {
          PurchaseHistoryResponse res =
              PurchaseHistoryResponse.fromJson(data as Map<String, dynamic>);

          PurchaseHistory? prev = purchaseHistoryDB
              .query(PurchaseHistory_.serverId.equals(res.serverId))
              .build()
              .findFirst();

          if (prev != null) {
            prev.status = res.status;
            purchaseHistoryDB.put(prev);
            setLastUpdate(apiCode, res.transactionDate);
          } else {
            PurchaseHistory history = PurchaseHistory.fromResponse(res);
            purchaseHistoryDB.put(history);
            setLastUpdate(apiCode, res.transactionDate);
          }
        } catch (error) {
          debugPrint('syncHistory error $error at $data');
        }
      }

      debugPrint(
          'syncHistory lastUpdate $timestamp get ${pagingResponse.data.length} item from ${pagingResponse.total} ');

      _unlockSyncronize(apiCode);
      // Get next page
      if (pagingResponse.data.length >= limit) {
        DateTime? veryLastUpdate = getLastUpdate(apiCode);
        if (lastUpdate == veryLastUpdate) {
          offset += limit;
        } else {
          offset = 0;
        }
        return await syncHistory(offset: offset);
      }
    }).catchError((dynamic e) {
      _unlockSyncronize(apiCode);
      debugPrint('syncHistory error $e');
    });
  }

  static Future<void> syncTopupHistory() async {
    const apiCode = 'topup-history';

    if (_lockedSyncronize(apiCode)) {
      return;
    }
    _lockSyncronize(apiCode);

    const limit = 50;
    DateTime? lastUpdate = getLastUpdate(apiCode);
    String timestamp = lastUpdate == null ? '' : lastUpdate.toIso8601String();

    Map<String, String> params = {
      'limit': limit.toString(),
      'sort': json.encode({'tanggal': 'asc'}),
      'filter': json.encode({'tanggal_aktif': '>|$timestamp'})
    };

    debugPrint('syncTopupHistory with params $params');

    return Api.getTopupHistory(params: params).then((pagingResponse) async {
      debugPrint('syncTopupHistory data length ${pagingResponse.data.length}');

      for (var data in pagingResponse.data) {
        try {
          TopupHistoryResponse res =
              TopupHistoryResponse.fromJson(data as Map<String, dynamic>);

          TopupHistory? prev = topupHistoryDB
              .query(TopupHistory_.serverId.equals(res.serverId))
              .build()
              .findFirst();

          if (prev != null) {
            prev.transactionDate = res.transactionDate;
            prev.confirmedDate = res.confirmedDate;
            prev.paidDate = res.paidDate;
            prev.status = res.status;
            prev.notes = res.notes;
            prev.bank = res.bank;
            prev.amount = res.amount;
            topupHistoryDB.put(prev);
            setLastUpdate(apiCode, res.transactionDate);
          } else {
            TopupHistory history = TopupHistory.fromResponse(res);
            topupHistoryDB.put(history);
            setLastUpdate(apiCode, res.transactionDate);
          }
        } catch (error) {
          debugPrint('syncTopupHistory error $error at $data');
        }
      }

      debugPrint(
          'syncTopupHistory lastUpdate $timestamp get ${pagingResponse.data.length} item from ${pagingResponse.total} ');

      _unlockSyncronize(apiCode);
      // Get next page
      if (pagingResponse.data.length >= limit) {
        return await syncTopupHistory();
      }
    }).catchError((dynamic e) {
      _unlockSyncronize(apiCode);
      debugPrint('syncTopupHistory error $e');
    });
  }

  static Future<void> syncNotification() async {
    const apiCode = 'notification-history2';

    if (_lockedSyncronize(apiCode)) {
      return;
    }
    _lockSyncronize(apiCode);

    const limit = 50;
    DateTime? lastUpdate = getLastUpdate(apiCode);
    String timestamp = lastUpdate == null ? '' : lastUpdate.toIso8601String();

    Map<String, String> params = {
      'limit': limit.toString(),
      'sort': json.encode({'id': 'asc'}),
      'filter': json.encode({'updated_at': '>|$timestamp'})
    };

    debugPrint('syncNotification with params $params');

    return Api.getNotification(params: params).then((response) async {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);

      debugPrint('syncNotification data length ${pagingResponse.data.length}');

      for (var data in pagingResponse.data) {
        NotificationResponse res =
            NotificationResponse.fromJson(data as Map<String, dynamic>);

        Notification? prev = notificationDB
            .query(Notification_.serverId.equals(res.serverId))
            .build()
            .findFirst();

        if (prev != null) {
          notificationDB.put(prev);
          setLastUpdate(apiCode, res.notificationDate);
        } else {
          Notification notif = Notification.fromResponse(res);
          notificationDB.put(notif);
          setLastUpdate(apiCode, res.notificationDate);
        }
      }

      debugPrint(
          'syncNotification lastUpdate $timestamp get ${pagingResponse.data.length} item from ${pagingResponse.total} ');

      _unlockSyncronize(apiCode);
      // Get next page
      if (pagingResponse.data.length >= limit) {
        return await syncNotification();
      }
    }).catchError((dynamic e) {
      _unlockSyncronize(apiCode);
      debugPrint('syncNotification error $e');
    });
  }

  static Future<void> syncBalanceMutation() async {
    const apiCode = 'balance-mutation4';

    if (_lockedSyncronize(apiCode)) {
      return;
    }
    _lockSyncronize(apiCode);

    const limit = 50;
    DateTime? lastUpdate = getLastUpdate(apiCode);
    String timestamp = lastUpdate == null ? '' : lastUpdate.toIso8601String();

    Map<String, String> params = {
      'limit': limit.toString(),
      'sort': json.encode({'tanggal': 'asc'}),
      'filter': json.encode({'tanggal': '>|$timestamp'})
    };

    debugPrint('syncBalanceMutation with params $params');

    return Api.getBalanceMutation(params: params).then((response) async {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);

      debugPrint(
          'syncBalanceMutation data length ${pagingResponse.data.length}');

      for (var data in pagingResponse.data) {
        BalanceMutationResponse res =
            BalanceMutationResponse.fromJson(data as Map<String, dynamic>);

        BalanceMutation? prev = balanceMutationDB
            .query(BalanceMutation_.serverId.equals(res.serverId))
            .build()
            .findFirst();

        if (prev != null) {
          prev.userId = res.userId;
          prev.mutationDate = res.mutationDate;
          prev.description = res.description;
          prev.productCode = res.productCode;
          prev.productName = res.productName;
          prev.productDetail = res.productDetail;
          prev.debitAmount = res.debitAmount;
          prev.creditAmount = res.creditAmount;
          prev.startBalance = res.startBalance;
          prev.endBalance = res.endBalance;
          balanceMutationDB.put(prev);
          setLastUpdate(apiCode, res.mutationDate);
        } else {
          BalanceMutation notif = BalanceMutation.fromResponse(res);
          balanceMutationDB.put(notif);
          setLastUpdate(apiCode, res.mutationDate);
        }
      }

      debugPrint(
          'syncBalanceMutation lastUpdate $timestamp get ${pagingResponse.data.length} item from ${pagingResponse.total} ');

      _unlockSyncronize(apiCode);
      // Get next page
      if (pagingResponse.data.length >= limit) {
        return await syncBalanceMutation();
      }
    }).catchError((dynamic e) {
      _unlockSyncronize(apiCode);
      debugPrint('syncBalanceMutation error $e');
    });
  }

  static Future<void> syncCreditMutation() async {
    const apiCode = 'credit-mutation';

    if (_lockedSyncronize(apiCode)) {
      return;
    }
    _lockSyncronize(apiCode);

    const limit = 50;
    DateTime? lastUpdate = getLastUpdate(apiCode);
    String timestamp = lastUpdate == null ? '' : lastUpdate.toIso8601String();

    Map<String, String> params = {
      'limit': limit.toString(),
      'sort': json.encode({'created_at': 'asc'}),
      'filter': json.encode({'created_at': '>|$timestamp'})
    };

    debugPrint('syncCreditMutation with params $params');

    return Api.getCreditMutation(params: params).then((response) async {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);

      debugPrint(
          'syncCreditMutation data length ${pagingResponse.data.length}');

      for (var data in pagingResponse.data) {
        try {
          CreditMutationResponse res =
              CreditMutationResponse.fromJson(data as Map<String, dynamic>);

          CreditMutation? prev = creditMutationDB
              .query(CreditMutation_.serverId.equals(res.serverId))
              .build()
              .findFirst();

          if (prev != null) {
            prev.userId = res.userId;
            prev.mutationDate = res.mutationDate;
            prev.description = res.description;
            prev.productCode = res.productCode;
            prev.productName = res.productName;
            prev.productDetail = res.productDetail;
            prev.debitAmount = res.debitAmount;
            prev.creditAmount = res.creditAmount;
            prev.startBalance = res.startBalance;
            prev.endBalance = res.endBalance;
            creditMutationDB.put(prev);
            setLastUpdate(apiCode, res.mutationDate);
          } else {
            CreditMutation notif = CreditMutation.fromResponse(res);
            creditMutationDB.put(notif);
            setLastUpdate(apiCode, res.mutationDate);
          }
        } catch (error) {
          debugPrint('syncCreditMutation error $error at $data');
        }
      }

      debugPrint(
          'syncCreditMutation lastUpdate $timestamp get ${pagingResponse.data.length} item from ${pagingResponse.total} ');

      _unlockSyncronize(apiCode);
      // Get next page
      if (pagingResponse.data.length >= limit) {
        return await syncCreditMutation();
      }
    }).catchError((dynamic e) {
      _unlockSyncronize(apiCode);
      debugPrint('syncCreditMutation error $e');
    });
  }

  static Future<void> syncCustomerService() async {
    const apiCode = 'customer-service';

    if (_lockedSyncronize(apiCode)) {
      return;
    }
    _lockSyncronize(apiCode);

    const limit = 50;
    DateTime? lastUpdate = getLastUpdate(apiCode);
    String timestamp = lastUpdate == null ? '' : lastUpdate.toIso8601String();

    Map<String, String> params = {
      'limit': limit.toString(),
      'sort': json.encode({'tanggal': 'asc'}),
      'filter': json.encode({'tanggal': '>|$timestamp'})
    };

    debugPrint('syncCustomerService with params $params');

    return Api.getCustomerService(params: params).then((response) async {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);

      debugPrint(
          'syncCustomerService data length ${pagingResponse.data.length}');

      for (var data in pagingResponse.data) {
        CustomerServiceResponse res =
            CustomerServiceResponse.fromJson(data as Map<String, dynamic>);

        CustomerService? prev = customerServiceDB
            .query(CustomerService_.serverId.equals(res.serverId))
            .build()
            .findFirst();

        if (prev != null) {
          prev.userId = res.userId;
          prev.message = res.message;
          prev.messageDate = res.messageDate;
          prev.message = res.message;
          prev.status = res.status;
          prev.photo = res.photo;
          customerServiceDB.put(prev);
          setLastUpdate(apiCode, res.messageDate);
        } else {
          CustomerService message = CustomerService.fromResponse(res);
          customerServiceDB.put(message);
          setLastUpdate(apiCode, res.messageDate);
        }
      }

      debugPrint(
          'syncCustomerService lastUpdate $timestamp get ${pagingResponse.data.length} item from ${pagingResponse.total} ');

      _unlockSyncronize(apiCode);
      // Get next page
      if (pagingResponse.data.length >= limit) {
        return await syncCustomerService();
      }
    }).catchError((dynamic e) {
      _unlockSyncronize(apiCode);
      debugPrint('syncCustomerService error $e');
    });
  }

  static Future<void> syncUserConfig() async {
    const apiCode = 'user-config';

    if (_lockedSyncronize(apiCode)) {
      return;
    }
    _lockSyncronize(apiCode);

    const limit = 50;
    DateTime? lastUpdate = getLastUpdate(apiCode);
    String timestamp = lastUpdate == null ? '' : lastUpdate.toIso8601String();

    Map<String, String> params = {
      'limit': limit.toString(),
      'sort': json.encode({'updated_at': 'asc'}),
      'filter': json.encode({'updated_at': '>|$timestamp'})
    };

    debugPrint('syncUserConfig with params $params');

    return Api.getUserConfig(params: params).then((response) async {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);

      debugPrint('syncUserConfig data length ${pagingResponse.data.length}');

      for (var data in pagingResponse.data) {
        UserConfigResponse res =
            UserConfigResponse.fromJson(data as Map<String, dynamic>);

        UserConfig? prev = userConfigDB
            .query(UserConfig_.serverId.equals(res.serverId))
            .build()
            .findFirst();

        if (prev != null) {
          prev.name = res.name;
          prev.config = res.config != null ? json.encode(res.config) : null;
          userConfigDB.put(prev);
          setLastUpdate(apiCode, res.lastUpdate);
        } else {
          UserConfig message = UserConfig.fromResponse(res);
          userConfigDB.put(message);
          setLastUpdate(apiCode, res.lastUpdate);
        }
      }

      debugPrint(
          'syncCustomerService lastUpdate $timestamp get ${pagingResponse.data.length} item from ${pagingResponse.total} ');

      _unlockSyncronize(apiCode);
      // Get next page
      if (pagingResponse.data.length >= limit) {
        return await syncUserConfig();
      }
    }).catchError((dynamic e) {
      _unlockSyncronize(apiCode);
      debugPrint('syncUserConfig error $e');
    });
  }

  static Future<void> syncPriceSetting() async {
    const apiCode = 'price-setting';

    if (_lockedSyncronize(apiCode)) {
      return;
    }
    _lockSyncronize(apiCode);

    const limit = 50;
    DateTime? lastUpdate = getLastUpdate(apiCode);
    String timestamp = lastUpdate == null ? '' : lastUpdate.toIso8601String();

    Map<String, String> params = {
      'limit': limit.toString(),
      'sort': json.encode({'updated_at': 'asc'}),
      'filter': json.encode({'updated_at': '>|$timestamp'})
    };

    debugPrint('syncPriceSetting with params $params');

    return Api.getPriceSetting(params: params).then((response) async {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);

      debugPrint('syncPriceSetting data length ${pagingResponse.data.length}');
      debugPrint('syncPriceSetting data length ${bodyMap}');

      for (var data in pagingResponse.data) {
        try {
          PriceSettingResponse res =
              PriceSettingResponse.fromJson(data as Map<String, dynamic>);

          if (res.productCode.isNotEmpty) {
            Product? product = productDB
                .query(Product_.code.equals(res.productCode))
                .build()
                .findFirst();

            if (product != null) {
              product.priceSetting = res.price; // Update harga setting
              productDB.put(product);

              setLastUpdate(apiCode, res.updatedAt);
            }
          }
        } catch (error) {
          debugPrint('syncPriceSetting error $error at $data');
        }
      }

      debugPrint(
          'syncPriceSetting lastUpdate $timestamp get ${pagingResponse.data.length} item from ${pagingResponse.total} ');

      _unlockSyncronize(apiCode);
      // Get next page
      if (pagingResponse.data.length >= limit) {
        return await syncPriceSetting();
      }
    }).catchError((dynamic e) {
      _unlockSyncronize(apiCode);
      debugPrint('syncPriceSetting error $e');
    });
  }

  static Future<void> syncTrainStation({int offset = 0}) async {
    const apiCode = 'train-station';

    if (_lockedSyncronize(apiCode)) {
      return;
    }
    _lockSyncronize(apiCode);

    const limit = 50;
    DateTime? lastUpdate = getLastUpdate(apiCode);
    String timestamp = lastUpdate == null ? '' : lastUpdate.toIso8601String();

    Map<String, String> params = {
      'offset': offset.toString(),
      'limit': limit.toString(),
      'sort': json.encode({'updated_at': 'asc'}),
      'filter': json.encode({'updated_at': '>|$timestamp'})
    };

    debugPrint('syncTrainStation with params $params');

    return Api.getTrainStation(params: params).then((pagingResponse) async {
      debugPrint('syncTrainStation data length ${pagingResponse.data.length}');

      for (var data in pagingResponse.data) {
        try {
          TrainStationResponse res =
              TrainStationResponse.fromJson(data as Map<String, dynamic>);

          TrainStation? prev = trainStationDB
              .query(TrainStation_.serverId.equals(res.serverId))
              .build()
              .findFirst();

          if (prev != null) {
            prev.code = res.code;
            prev.stationName = res.stationName;
            prev.stationFullname = res.stationFullname;
            prev.city = res.city;
            trainStationDB.put(prev);
            setLastUpdate(apiCode, res.updatedDate);
          } else {
            TrainStation station = TrainStation.fromResponse(res);
            trainStationDB.put(station);
            setLastUpdate(apiCode, res.updatedDate);
          }
        } catch (error) {
          debugPrint('syncTrainStation error $error at $data');
        }
      }

      debugPrint(
          'syncTrainStation lastUpdate $timestamp get ${pagingResponse.data.length} item from ${pagingResponse.total} ');

      _unlockSyncronize(apiCode);
      // Get next page
      if (pagingResponse.data.length >= limit) {
        DateTime? veryLastUpdate = getLastUpdate(apiCode);
        if (lastUpdate == veryLastUpdate) {
          offset += limit;
        } else {
          offset = 0;
        }
        return await syncTrainStation(offset: offset);
      }
    }).catchError((dynamic e) {
      _unlockSyncronize(apiCode);
      debugPrint('syncTrainStation error $e');
    });
  }
}
