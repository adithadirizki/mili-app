enum OTPType {
  whatsapp,
  sms,
  email,
}

enum PaymentMethod { mainBalance, creditBalance, wallet, none }

const Map<PaymentMethod, String> paymentMethodLabel = {
  PaymentMethod.mainBalance: 'Koin MILI',
  PaymentMethod.creditBalance: 'Saldo Kredit',
  PaymentMethod.wallet: 'Saldo MILI',
  PaymentMethod.none: 'none',
};

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
const vendorTypeTransferBank = 4;
const vendorTypeVoucher = 5;
const vendorTypePaymentDenom = 6;

const menuGroupTagihan = 'TAGIHAN';
const menuGroupEmoney = 'E-MONEY';
const menuGroupFinance = 'CICILAN';
const menuGroupTelkom = 'TELKOM';
const menuGroupGame = 'GAME';
const menuGroupBank = 'BANK';
const menuGroupAct = 'ACT';
const menuGroupStreaming = 'VOUCHER_TV';
const menuGroupPajak = 'PAJAK';

// key page deeplink
const pageRegister = 'register';
const pageSaldoMili = 'saldo_mili';
const pageTopupSaldoMili = 'topup_saldo_mili';
const pageTransferSaldoMili = 'transfer_saldo_mili';
const pageMutasiSaldoMili = 'mutasi_saldo_mili';
const pageQris = 'qris';
const pageProfile = 'profile';
const pageAktifkanPin = 'aktifkan_pin';
const pageSetHargaJual = 'set_harga_jual';
const pagePrinter = 'printer';
const pageGantiPassword = 'ganti_password';
const pageNomorFavorit = 'nomor_favorit';
const pageDownline = 'downline';
const pageTambahDownline = 'tambah_downline';
const pageUpgradePremium = 'upgrade_premium';
const pageUpdateProfile = 'update_profile';
const pageProgram = 'program';

const pagePulsaData = 'pulsa_data';
const pagePulsa = 'pulsa';
const pagePaketData = 'paket_data';
const pageListrik = 'listrik';
const pageTagihan = 'tagihan';
const pageBpjs = 'bpjs';
const pageEwallet = 'ewallet';
const pageGame = 'game';
const pageTvBerbayar = 'tv_berbayar';
const pageTransferBank = 'transfer_bank';
const pageTopupLainnya = 'topup_lainnya';
const pagePajak = 'pajak';
const pageAktivasi = 'aktivasi';
const pageKeretaApi = 'kereta_api';
const pageTiketPesawat = 'tiket_pesawat';

const pageKoinMili = 'koin_mili';
const pageBeliKoinMili = 'beli_koin_mili';
const pageRiwayatBeliKoinMili = 'riwayat_beli_koin_mili';
const pageKirimKoinMili = 'kirim_koin_mili';
const pageMutasiKoinMili = 'mutasi_koin_mili';
const pageRiwayatTransaksi = 'riwayat_transaksi';
const pageNotifikasi = 'notifikasi';
const pageCustomerService = 'customer_service';