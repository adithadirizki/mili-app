import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/product.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/screens/purchase_aktivasi.dart';
import 'package:miliv2/src/screens/purchase_denom.dart';
import 'package:miliv2/src/screens/purchase_payment.dart';
import 'package:miliv2/src/screens/purchase_payment_product.dart';
import 'package:miliv2/src/screens/purchase_pln.dart';
import 'package:miliv2/src/screens/purchase_pulsa.dart';
import 'package:miliv2/src/screens/purchase_topup.dart';
import 'package:miliv2/src/screens/purchase_voucher.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';

AssetImage getProductLogo(Product product) {
  // FIXME apa memungkinan menggunakan prefix checking ??
  if (product.groupName.contains('INDOSAT')) {
    return AppImages.logoIndosat;
  } else if (product.groupName.contains('TELKOMSEL') ||
      product.groupName.contains('TOPUP PLUS')) {
    return AppImages.logoTelkomsel;
  } else if (product.groupName.contains('XL')) {
    return AppImages.logoXL;
  } else if (product.groupName.contains('THREE') ||
      product.groupName.contains('TRI')) {
    return AppImages.logoTri;
  } else if (product.groupName.contains('AXIS')) {
    return AppImages.logoAxis;
  } else if (product.groupName.contains('SMARTFREN')) {
    return AppImages.logoSmartfren;
  }
  return AppImages.logo;
}

Condition<Product> productQueryBuilder(
    Condition<Product> dbCriteria, String key, String opr, String value) {
  debugPrint('productQueryBuilder $key $opr $value');

  if (![
    'like',
    'not like',
    'in',
    'not in',
    '>',
    '>=',
    '<',
    '<=',
    '=',
    '<>',
    '!=',
    'start'
  ].contains(opr.toLowerCase())) {
    return dbCriteria;
  }

  switch (key) {
    // TODO tambahkan field lainnya, like status, FIXME
    // case 'status':
    //   if (opr == '=') {
    //     dbCriteria =
    //         dbCriteria.and(Product_.status.equals(json.decode(value) as int));
    //   } else if (opr == '!=') {
    //     dbCriteria = dbCriteria
    //         .and(Product_.status.notEquals(json.decode(value) as int));
    //   }
    //   break;
    case 'vtype':
      if (opr == '=') {
        dbCriteria = dbCriteria.and(Product_.code.equals(value));
      } else if (opr == '!=') {
        dbCriteria = dbCriteria.and(Product_.code.notEquals(value));
      } else if (opr == 'start') {
        dbCriteria = dbCriteria.and(Product_.code.startsWith(value));
      }
      break;
    case 'kelompok':
      if (opr == '=') {
        dbCriteria =
            dbCriteria.and(Product_.productGroup.equals(int.parse(value)));
      } else if (opr == '!=') {
        dbCriteria =
            dbCriteria.and(Product_.productGroup.notEquals(int.parse(value)));
      } else if (opr == 'start') {
        dbCriteria = dbCriteria.and(Product_.code.startsWith(value));
      }
      break;
    case 'opr':
      if (opr == '=') {
        dbCriteria = dbCriteria.and(Product_.groupName.equals(value));
      } else if (opr == '!=') {
        dbCriteria = dbCriteria.and(Product_.groupName.notEquals(value));
      } else if (opr == 'start') {
        dbCriteria = dbCriteria.and(Product_.code.startsWith(value));
      }
      break;
  }

  return dbCriteria;
}

void openPurchaseScreen(
  BuildContext context, {
  String? productCode,
  String? groupName,
  String? destination,
  Vendor? vendor,
}) async {
  if (vendor == null && groupName != null) {
    await AppDB.syncVendor();
    QueryBuilder<Vendor> queryBuilder =
        AppDB.vendorDB.query(Vendor_.productGroupNameList.contains(groupName));
    vendor = queryBuilder.build().findFirst();
  }

  // TODO Vendor PDAM belum ketemu

  debugPrint(
      'Open Purchase screen product code ${productCode ?? '-'} dest ${destination ?? '-'} opr ${groupName ?? '-'} vendor ${vendor?.name ?? '-'} config ${vendor?.config ?? '-'}');

  if (productCode != null &&
      (productCode.startsWith('PL') || productCode == 'PAYPLN')) {
    pushScreen(
        context,
        (_) => PurchasePLNScreen(
            productCode: productCode, destination: destination));
  } else if (["PAYMATRIX", "PAYHALO", "PAYXPLOR", "PAYSMART", "PAYTHREE"]
      .contains(productCode)) {
    pushScreen(
        context,
        (_) => PurchasePulsaScreen(
            productCode: productCode, destination: destination));
  } else if (vendor != null) {
    if (vendor.productType == vendorTypeTopup) {
      if (vendor.group == menuGroupAct) {
        pushScreen(
          context,
              (_) => PurchaseAktivasiScreen(vendor: vendor!, productCode: productCode, destination: destination),
        );
        return;
      }
      pushScreen(
        context,
        (_) => PurchaseTopupScreen(vendor: vendor!, destination: destination),
      );
    } else if (vendor.productType == vendorTypePayment) {
      pushScreen(
        context,
        (_) => PurchasePaymentScreen(vendor: vendor!, destination: destination),
      );
    } else if (vendor.productType == vendorTypePaymentWithProduct) {
      pushScreen(
        context,
        (_) => PurchasePaymentProductScreen(
            vendor: vendor!,
            productCode: productCode,
            destination: destination),
      );
    } else if (vendor.productType == vendorTypePaymentDenom) {
      pushScreen(
        context,
        (_) => PurchaseDenomScreen(vendor: vendor!, destination: destination),
      );
    } else if (vendor.productType == vendorTypeVoucher) {
      pushScreen(
        context,
        (_) => PurchaseVoucherScreen(vendor: vendor!),
      );
    } else {
      debugPrint('Unknown vendor type ${vendor.name} ${vendor.productType}');
    }
  } else {
    pushScreen(
        context,
        (_) => PurchasePulsaScreen(
            productCode: productCode, destination: destination));
  }
}

bool isClosed(Cutoff? cutoff) {
  if (cutoff != null) {
    DateTime now = DateTime.now();
    DateTime utc = now.toUtc();
    DateTime wib = utc.add(const Duration(hours: 7));
    String _wib = DateFormat('HHmm').format(wib);
    int timeWib = parseInt(_wib);

    int startTime = parseInt(cutoff.start);
    int endTime = parseInt(cutoff.end);

    debugPrint('Cutoff $startTime $endTime == $timeWib');

    if (startTime > endTime) {
      return timeWib >= parseInt(cutoff.start) ||
          timeWib < parseInt(cutoff.end);
    } else {
      return timeWib >= parseInt(cutoff.start) &&
          timeWib < parseInt(cutoff.end);
    }
  }

  return false;
}
