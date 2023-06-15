enum OTPType {
  whatsapp,
  sms,
  email,
}

enum PaymentMethod { mainBalance, creditBalance }

const Map<PaymentMethod, String> paymentMethodLabel = {
  PaymentMethod.mainBalance: 'Saldo Utama',
  PaymentMethod.creditBalance: 'Saldo Kredit',
};

const partnerId = '13';

// const List<String> outletTypes = [
//   'Counter HP',
//   'Toko Kelontong',
//   'Warung Makan',
//   'Koperasi',
//   'Retail'
// ];

// enum ProductGroup { pulsa, topup, listrik, voucher, data, tagihan, lainnya }
//
// enum ProductStatus { open, unavailable, closed }

// Product
const groupPulsa = 1;
const groupTopup = 2;
const groupListrik = 3;
const groupVoucher = 4;
const groupData = 5;
const groupTagihan = 6;

const int statusOpen = 0;
const int statusUnavailable = 1;
const int statusClosed = 2;

// Vendor
const vendorTypeTopup = 1;
const vendorTypePayment = 2;
const vendorTypePaymentWithProduct = 3;
const vendorTypePaymentDenom = 4;
const vendorTypeVoucher = 5;

const menuGroupTagihan = 'TAGIHAN';
const menuGroupEmoney = 'E-MONEY';
const menuGroupFinance = 'CICILAN';
const menuGroupTelkom = 'TELKOM';
const menuGroupGame = 'GAME';
const menuGroupBank = 'BANK';
const menuGroupAct = 'ACT';
const menuGroupStreaming = 'VOUCHER_TV';
