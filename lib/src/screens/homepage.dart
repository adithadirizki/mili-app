import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/data/active_banner.dart';
import 'package:miliv2/src/data/promo.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/reference/flip/screens/bank.dart';
import 'package:miliv2/src/screens/activation_wallet.dart';
import 'package:miliv2/src/screens/change_password.dart';
import 'package:miliv2/src/screens/coin_mili.dart';
import 'package:miliv2/src/screens/customer_service.dart';
import 'package:miliv2/src/screens/downline.dart';
import 'package:miliv2/src/screens/downline_register.dart';
import 'package:miliv2/src/screens/favorite.dart';
import 'package:miliv2/src/screens/history.dart';
import 'package:miliv2/src/screens/home_screen.dart';
import 'package:miliv2/src/screens/mutation.dart';
import 'package:miliv2/src/screens/mutation_wallet.dart';
import 'package:miliv2/src/screens/notification.dart';
import 'package:miliv2/src/screens/otp_verification.dart';
import 'package:miliv2/src/screens/pin_setup.dart';
import 'package:miliv2/src/screens/price_setting.dart';
import 'package:miliv2/src/screens/printer.dart';
import 'package:miliv2/src/screens/profile.dart';
import 'package:miliv2/src/screens/profile_update.dart';
import 'package:miliv2/src/screens/profile_wallet.dart';
import 'package:miliv2/src/screens/program.dart';
import 'package:miliv2/src/screens/promo.dart';
import 'package:miliv2/src/screens/purchase_payment.dart';
import 'package:miliv2/src/screens/purchase_pln.dart';
import 'package:miliv2/src/screens/purchase_pulsa.dart';
import 'package:miliv2/src/screens/qris_scan.dart';
import 'package:miliv2/src/screens/sign_up.dart';
import 'package:miliv2/src/screens/topup.dart';
import 'package:miliv2/src/screens/topup_history.dart';
import 'package:miliv2/src/screens/topup_wallet.dart';
import 'package:miliv2/src/screens/tos_finpay.dart';
import 'package:miliv2/src/screens/train_home.dart';
import 'package:miliv2/src/screens/transfer.dart';
import 'package:miliv2/src/screens/transfer_widget_wallet.dart';
import 'package:miliv2/src/screens/upgrade.dart';
import 'package:miliv2/src/screens/vendor.dart';
import 'package:miliv2/src/services/analytics.dart';
import 'package:miliv2/src/services/auth.dart';
import 'package:miliv2/src/services/biometry.dart';
import 'package:miliv2/src/services/messaging.dart';
import 'package:miliv2/src/services/storage.dart';
import 'package:miliv2/src/theme/images.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/product.dart';
import 'package:miliv2/src/widgets/coin_chip.dart';
import 'package:miliv2/src/widgets/home_bottom_bar.dart';
import 'package:miliv2/src/widgets/pin_verification.dart';
import 'package:overlay_tooltip/overlay_tooltip.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late PageController pageController;
  late TabController tabController;

  final TooltipController tooltipController = TooltipController();

  ScrollController mainScreenScrollController = ScrollController();
  bool isScrollingDown = false;
  bool isShowBottomBar = true;
  int selectedPage = -1;
  final initialPage = 0;

  bool synchronized = false;

  bool locked = false;
  bool pinEnabled = false;
  bool biometricEnabled = false;

  String currentPin = '';
  String newPin = '';

  final newPinState = GlobalKey<PINVerificationState>();
  final confirmPinState = GlobalKey<PINVerificationState>();
  final verifyPinState = GlobalKey<PINVerificationState>();

  AppAuth authState = AppAuth();
  StreamSubscription<Map>? streamSubscription;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: initialPage);
    tabController = TabController(length: 1, initialIndex: 0, vsync: this);
    mainScreenScrollController.addListener(scrollListener);

    tooltipController.setStartWhen((initializedWidgetLength) async {
      await Future<dynamic>.delayed(const Duration(milliseconds: 3000));
      return AppStorage.getFirstInstall() == true;
    });
    tooltipController.onDone(() {
      AppStorage.setFirstInstall(false);

      showPopupBanner(context);
    });

    // // FIXME debug mode
    // AppStorage.setFirstInstall(true);

    initPin();
    listenDynamicLinks();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initProvider();
    });
  }

  void listenDynamicLinks() async {
    streamSubscription = FlutterBranchSdk.initSession().listen((data) async {
      // note: guest is user signed in
      // only user guest
      if (userBalanceState.isGuest()) {
        if (data['key_page'] == pageRegister) {
          // when guest open app for the first time they can't direct to registration page
          // so, referral code is stored in app storage
          AppStorage.setReferralCode(data['referral_code']?.toString());

          pushScreen(
              context,
              (_) => SignUpScreen(
                  onVerified: authState.onSignUp,
                  onBack: () {},
                  referralCode: data['referral_code']?.toString()));
        }
      }

      // can't access to page bellow when user is not signed in
      if (authState.signedIn == false) return;

      // only user register
      if (userBalanceState.isGuest() == false) {
        if (data['key_page'] == pageSaldoMili) {
          profileWalletScreen();
        } else if (data['key_page'] == pageTopupSaldoMili) {
          topupWalletScreen();
        } else if (data['key_page'] == pageTransferSaldoMili) {
          transferWalletScreen();
        } else if (data['key_page'] == pageMutasiSaldoMili) {
          mutationWalletScreen();
        } else if (data['key_page'] == pageQris) {
          qrisScreen();
        } else if (data['key_page'] == pageProfile) {
          pushScreen(
              context,
              (_) => UserBalanceScope(
                    notifier: userBalanceState,
                    child: const ProfileScreen(),
                  ));
        } else if (data['key_page'] == pageAktifkanPin) {
          pushScreen(context, (_) => const PINSetupScreen());
        } else if (data['key_page'] == pageSetHargaJual) {
          pushScreen(context, (_) => const PriceSettingScreen());
        } else if (data['key_page'] == pagePrinter) {
          pushScreen(context, (_) => const PrinterScreen());
        } else if (data['key_page'] == pageGantiPassword) {
          pushScreen(context, (_) => const ChangePasswordScreen());
        } else if (data['key_page'] == pageNomorFavorit) {
          pushScreen(context, (_) => const FavoriteScreen());
        } else if (data['key_page'] == pageDownline) {
          downlineScreen();
        } else if (data['key_page'] == pageTambahDownline) {
          addDownlineScreen();
        } else if (data['key_page'] == pageUpgradePremium) {
          upgradePremiumScreen();
        } else if (data['key_page'] == pageUpdateProfile) {
          profileUpdateScreen();
        }
      }

      // for all user
      if (data['key_page'] == pagePulsaData) {
        pushScreen(context, (_) => const PurchasePulsaScreen());
      } else if (data['key_page'] == pageListrik) {
        pushScreen(context, (_) => const PurchasePLNScreen());
      } else if (data['key_page'] == pageTagihan) {
        if (data['key_subpage'] == null) {
          pushScreen(
            context,
            (_) => const VendorScreen(
              title: 'Tagihan',
              groupName: menuGroupTagihan,
            ),
          );
        } else {
          QueryBuilder<Vendor> queryVendor = AppDB.vendorDB.query(Vendor_
              .productCode
              .equals(data['key_subpage'].toString(), caseSensitive: false)
              .or(Vendor_.inquiryCode.equals(data['key_subpage'].toString(),
                  caseSensitive: false)));
          Vendor? vendor = queryVendor.build().findFirst();
          if (vendor != null) openPurchaseScreen(context, vendor: vendor);
        }
      } else if (data['key_page'] == pageBpjs) {
        pushScreen(
          context,
          (_) => PurchasePaymentScreen(
            vendor: Vendor(
                serverId: 0,
                updatedAt: DateTime.now(),
                imageUrl: '',
                productType: groupTagihan,
                group: '',
                name: 'BPJS Kesehatan',
                title: 'BPJS Kesehatan',
                inquiryCode: 'CEKBPJSKS',
                paymentCode: 'PAYBPJSKS',
                config: '{"min_length": 5, "max_length": 30}'),
          ),
        );
      } else if (data['key_page'] == pageEwallet) {
        if (data['key_subpage'] == null) {
          pushScreen(
            context,
            (_) => const VendorScreen(
              title: 'E-Wallet',
              groupName: menuGroupEmoney,
            ),
          );
        } else {
          QueryBuilder<Vendor> queryVendor = AppDB.vendorDB.query(Vendor_
              .productCode
              .equals(data['key_subpage'].toString(), caseSensitive: false)
              .or(Vendor_.inquiryCode.equals(data['key_subpage'].toString(),
                  caseSensitive: false)));
          Vendor? vendor = queryVendor.build().findFirst();
          if (vendor != null) openPurchaseScreen(context, vendor: vendor);
        }
      } else if (data['key_page'] == pageGame) {
        if (data['key_subpage'] == null) {
          pushScreen(
            context,
            (_) => const VendorScreen(
              title: 'Game',
              groupName: menuGroupGame,
            ),
          );
        } else {
          QueryBuilder<Vendor> queryVendor = AppDB.vendorDB.query(Vendor_
              .productCode
              .equals(data['key_subpage'].toString(), caseSensitive: false)
              .or(Vendor_.inquiryCode.equals(data['key_subpage'].toString(),
                  caseSensitive: false)));
          Vendor? vendor = queryVendor.build().findFirst();
          if (vendor != null) openPurchaseScreen(context, vendor: vendor);
        }
      } else if (data['key_page'] == pageTvBerbayar) {
        if (data['key_subpage'] == null) {
          pushScreen(
            context,
            (_) => const VendorScreen(
              title: 'TV Berbayar',
              groupName: menuGroupStreaming,
            ),
          );
        } else {
          QueryBuilder<Vendor> queryVendor = AppDB.vendorDB.query(Vendor_
              .productCode
              .equals(data['key_subpage'].toString(), caseSensitive: false)
              .or(Vendor_.inquiryCode.equals(data['key_subpage'].toString(),
                  caseSensitive: false)));
          Vendor? vendor = queryVendor.build().findFirst();
          if (vendor != null) openPurchaseScreen(context, vendor: vendor);
        }
      } else if (data['key_page'] == pageTransferBank) {
        if (data['key_subpage'] == null) {
          pushScreen(
            context,
            (_) => const VendorScreen(
              title: 'Transfer Bank',
              groupName: menuGroupBank,
            ),
          );
        } else {
          QueryBuilder<Vendor> queryVendor = AppDB.vendorDB.query(Vendor_
              .productCode
              .equals(data['key_subpage'].toString(), caseSensitive: false)
              .or(Vendor_.inquiryCode.equals(data['key_subpage'].toString(),
                  caseSensitive: false)));
          Vendor? vendor = queryVendor.build().findFirst();
          if (vendor != null) openPurchaseScreen(context, vendor: vendor);
        }
      } else if (data['key_page'] == pageTopupLainnya) {
        if (data['key_subpage'] == null) {
          pushScreen(
            context,
            (_) => const ProductBankFlipScreen(),
          );
        } else {
          QueryBuilder<Vendor> queryVendor = AppDB.vendorDB.query(Vendor_
              .productCode
              .equals(data['key_subpage'].toString(), caseSensitive: false)
              .or(Vendor_.inquiryCode.equals(data['key_subpage'].toString(),
                  caseSensitive: false)));
          Vendor? vendor = queryVendor.build().findFirst();
          if (vendor != null) {
            pushScreen(
              context,
              (_) => ProductBankFlipScreen(selectedVendor: vendor),
            );
          }
        }
      } else if (data['key_page'] == pagePajak) {
        if (data['key_subpage'] == null) {
          pushScreen(
            context,
            (_) => const VendorScreen(
              title: 'Pajak',
              groupName: menuGroupPajak,
            ),
          );
        } else {
          QueryBuilder<Vendor> queryVendor = AppDB.vendorDB.query(Vendor_
              .productCode
              .equals(data['key_subpage'].toString(), caseSensitive: false)
              .or(Vendor_.inquiryCode.equals(data['key_subpage'].toString(),
                  caseSensitive: false)));
          Vendor? vendor = queryVendor.build().findFirst();
          if (vendor != null) openPurchaseScreen(context, vendor: vendor);
        }
      } else if (data['key_page'] == pageAktivasi) {
        if (data['key_subpage'] == null) {
          String title = 'Aktivasi';
          String? productCode;
          Map<String, String> providerList = {
            'actAxis': 'Aktivasi Axis',
            'actIndosat': 'Aktivasi Indosat',
            'actSmartfren': 'Aktivasi Smartfren',
            'actTelkomsel': 'Aktivasi Telkomsel',
            'actXL': 'Aktivasi XL',
          };

          if (data['key_provider'] != null) {
            productCode = data['key_provider'] as String;
            title = providerList[productCode] ?? title;
          }

          pushScreen(
            context,
            (_) => VendorScreen(
              title: title,
              groupName: menuGroupAct,
              productCode: productCode,
            ),
          );
        } else {
          QueryBuilder<Vendor> queryVendor = AppDB.vendorDB.query(Vendor_
              .productCode
              .equals(data['key_subpage'].toString(), caseSensitive: false)
              .or(Vendor_.inquiryCode.equals(data['key_subpage'].toString(),
                  caseSensitive: false)));
          Vendor? vendor = queryVendor.build().findFirst();
          if (vendor != null) openPurchaseScreen(context, vendor: vendor, productCode: data['key_productcode'] as String?);
        }
      } else if (data['key_page'] == pageKeretaApi) {
        pushScreen(
          context,
          (_) => const TrainHomeScreen(
            title: 'Tiket Kereta',
          ),
        );
      } else if (data['key_page'] == pageTiketPesawat) {
        // comming soon
      } else if (data['key_page'] == pageKoinMili) {
        coinScreen();
      } else if (data['key_page'] == pageBeliKoinMili) {
        pushScreen(context, (_) => const TopupScreen(title: 'Beli Koin'));
      } else if (data['key_page'] == pageRiwayatBeliKoinMili) {
        pushScreen(context, (_) => const TopupHistoryScreen());
      } else if (data['key_page'] == pageKirimKoinMili) {
        pushScreen(
            context, (_) => const TransferScreen(title: 'Transfer Koin'));
      } else if (data['key_page'] == pageMutasiKoinMili) {
        pushScreen(context,
            (_) => const MutationScreen(title: 'Mutasi Koin MILI & Kredit'));
      } else if (data['key_page'] == pageRiwayatTransaksi) {
        pushScreen(context, (_) => const HistoryScreen());
      } else if (data['key_page'] == pageNotifikasi) {
        pushScreen(context, (_) => const NotificationScreen());
      } else if (data['key_page'] == pageCustomerService) {
        pushScreen(context, (_) => const CustomerServiceScreen());
      } else if (data['key_page'] == pageProgram) {
        pushScreen(context, (_) => ProgramScreen(code: data['key_subpage'] as String?));
      }
    }, onError: (dynamic error) {
      print('InitSesseion error: ${error.toString()}');
    });
  }

  void profileWalletScreen() {
    if (!userBalanceState.walletActive) {
      pushScreen(context, (_) => TosFinpayScreen(
        title: 'Aktivasi Saldo MILI',
        walletActive: userBalanceState.walletActive,
        walletPremium: userBalanceState.walletPremium,
      ));
      return;
    }
    pushScreen(context, (_) => const ProfileWalletScreen());
  }

  void topupWalletScreen() {
    if (!userBalanceState.walletActive) {
      pushScreen(context, (_) => TosFinpayScreen(
        title: 'Aktivasi Saldo MILI',
        walletActive: userBalanceState.walletActive,
        walletPremium: userBalanceState.walletPremium,
      ));
      return;
    }
    pushScreen(context, (_) => const TopupWalletScreen());
  }

  void transferWalletScreen() {
    if (!userBalanceState.walletActive) {
      pushScreen(context, (_) => TosFinpayScreen(
        title: 'Aktivasi Saldo MILI',
        walletActive: userBalanceState.walletActive,
        walletPremium: userBalanceState.walletPremium,
      ));
      return;
    }
    pushScreen(
        context, (_) => const TransferWidgetWalletScreen(title: 'Kirim Saldo'));
  }

  void mutationWalletScreen() {
    if (!userBalanceState.walletActive) {
      pushScreen(context, (_) => TosFinpayScreen(
        title: 'Aktivasi Saldo MILI',
        walletActive: userBalanceState.walletActive,
        walletPremium: userBalanceState.walletPremium,
      ));
      return;
    }
    pushScreen(context, (_) => const MutationWalletScreen());
  }

  void qrisScreen() {
    if (!userBalanceState.walletActive) {
      pushScreen(context, (_) => TosFinpayScreen(
        title: 'Aktivasi Saldo MILI',
        walletActive: userBalanceState.walletActive,
        walletPremium: userBalanceState.walletPremium,
      ));
      return;
    }
    pushScreen(context, (_) => const QrisScannerScreen());
  }

  void downlineScreen() {
    if (userBalanceState.premium) {
      pushScreen(
        context,
        (_) => const DownlineScreen(),
      );
    } else {
      pushScreen(
        context,
        (_) => const UpgradeScreen(
          title: 'Upgrade Akun',
        ),
      );
    }
  }

  void addDownlineScreen() {
    if (userBalanceState.premium) {
      pushScreen(
        context,
        (_) => const DownlineRegisterScreen(),
      );
    } else {
      pushScreen(
        context,
        (_) => const UpgradeScreen(
          title: 'Upgrade Akun',
        ),
      );
    }
  }

  void upgradePremiumScreen() {
    if (userBalanceState.premium) {
      pushScreen(
        context,
        (_) => const UpgradeScreen(
          title: 'Akun Premium',
          allowUpgrade: false,
        ),
      );
    } else {
      pushScreen(
        context,
        (_) => const UpgradeScreen(
          title: 'Upgrade Akun',
        ),
      );
    }
  }

  void profileUpdateScreen() {
    if (!userBalanceState.isGuest()) {
      pushScreen(context, (_) => const ProfileUpdateScreen());
    }
  }

  FutureOr<Null> _handleError(Object e) async {
    snackBarDialog(context, e.toString());
    if (e is UnauthorisedException) {
      debugPrint('Homepage _handleError  ${e.toString()}');
      AppAuthScope.of(context).signOut();
    }
    return;
  }

  Timer? _timer;
  void beginTimer() {
    debugPrint('Register timer');
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      // Update wallet
      if (userBalanceState.walletActive) {
        await userBalanceState.fetchWallet().catchError(_handleError);
      }
      await userBalanceState.fetchData().catchError(_handleError);
    });
  }

  Future<void> initProvider() async {
    AppAnalytic.setUserId(userBalanceState.userId);
    await AppMessaging.requestPermission(context);
    activeBannerState.fetchData();
    promoState.fetchData();
    await userBalanceState.fetchData().catchError(_handleError);
    await userBalanceState.fetchWallet().catchError(_handleError);
    // Start timer
    beginTimer();
  }

  void walletActivation() {
    pushScreen(
      context,
      (_) => const ActivationWalletScreen(),
    );
  }

  // End Finpay function

  void promo() {
    pushScreen(
      context,
      (_) => const PromoScreen(),
    );
  }

  void initialize() async {
    bool? isFirstInstall = AppStorage.getFirstInstall();
    if (isFirstInstall) {
      tooltipController.start();
      AppStorage.setFirstInstall(false);

      AppDB.syncVendor();
      AppDB.syncUserConfig();
      AppDB.syncCutoff();
      AppDB.syncProduct();
    } else {
      var closeLoader = showLoaderDialog(context, message: 'Memperbarui...');
      AppDB.syncVendor();
      AppDB.syncUserConfig();
      AppDB.syncCutoff();
      await AppDB.syncProduct();
      synchronized = true;
      await closeLoader();
    }

    showPopupBanner(context);

    debugPrint('Completed initialize');
  }

  void initPin() {
    pinEnabled = AppStorage.getPINEnable();
    biometricEnabled = AppStorage.getBiometricEnable();
    debugPrint('Pin enabled $pinEnabled && ${userBalanceState.isGuest()}');
    if (!userBalanceState.isGuest() && pinEnabled) {
      locked = true;
    } else {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        initialize();
      });
    }
  }

  @override
  void dispose() {
    tooltipController.dispose();
    mainScreenScrollController.removeListener(scrollListener);
    tabController.dispose();
    streamSubscription?.cancel();
    if (_timer != null) _timer!.cancel();
    super.dispose();
  }

  void scrollListener() {
    if (mainScreenScrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!isScrollingDown) {
        isScrollingDown = true;
        hideBottomBar();
      }
    }
    if (mainScreenScrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (isScrollingDown) {
        isScrollingDown = false;
        showBottomBar();
      }
    }
  }

  void showBottomBar() {
    setState(() {
      isShowBottomBar = true;
    });
  }

  void hideBottomBar() {
    // setState(() {
    //   isShowBottomBar = false;
    // });
  }

  Future<bool> validatePIN(String pin) async {
    return pin == AppStorage.getPIN();
  }

  void onPINConfirmed(BuildContext ctx) {
    locked = false;
    setState(() {});
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (!locked) {
        initialize();
      }
    });
  }

  Future<bool> setNewPIN(String pin) async {
    newPin = pin;
    return true;
  }

  Future<bool> validateNewPIN(String pin) async {
    return newPin == pin;
  }

  void activatePIN(BuildContext ctx) {
    popScreen(context);
    AppStorage.setPINEnable(true);
    AppStorage.setPIN(newPin);
    setState(() {
      currentPin = newPin;
      newPin = '';
      locked = false;
    });
  }

  void onForgotPIN() {
    void step2(BuildContext context) {
      replaceScreen(
        context,
        (_) => PINVerification.withGradientBackground(
          key: confirmPinState,
          otpLength: 4,
          secured: true,
          title: 'Ganti PIN',
          subTitle: 'Konfirmasi PIN',
          invalidMessage: 'PIN tidak sesuai',
          validateOtp: validateNewPIN,
          onValidateSuccess: activatePIN,
          onInvalid: (_) {
            confirmPinState.currentState!.clearOtp();
          },
          topColor: const Color.fromRGBO(0, 255, 193, 1),
          bottomColor: const Color.fromRGBO(0, 10, 255, 0.9938945174217224),
          themeColor: Colors.white,
          titleColor: Colors.white,
          // icon: Image.asset(
          //   'images/phone_logo.png',
          //   fit: BoxFit.fill,
          // ),
        ),
      );
    }

    void step1(BuildContext context) {
      replaceScreen(
        context,
        (_) => PINVerification.withGradientBackground(
          key: newPinState,
          otpLength: 4,
          secured: true,
          title: 'Ganti PIN',
          subTitle: 'Masukkan PIN Baru',
          invalidMessage: 'PIN tidak sesuai',
          validateOtp: setNewPIN,
          onValidateSuccess: step2,
          onInvalid: (_) {},
          topColor: const Color.fromRGBO(0, 255, 193, 1),
          bottomColor: const Color.fromRGBO(0, 10, 255, 0.9938945174217224),
          themeColor: Colors.white,
          titleColor: Colors.white,
          // icon: Image.asset(
          //   'images/phone_logo.png',
          //   fit: BoxFit.fill,
          // ),
        ),
      );
    }

    if (pinEnabled) {
      pushScreen(
        context,
        (_) => OTPVerificationScreen(
          onBack: () {
            Navigator.of(context).pop();
          },
          onVerified: (response) {
            debugPrint('OTP resp $response');
            step1(context);
          },
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    debugPrint('On pop $synchronized -- $locked');
    if (!synchronized) {
      return false;
    }
    return true;
  }

  void coinScreen() async {
    await userBalanceState.fetchData();
    pushScreen(
        context,
        (_) => const CoinMiliScreen(
              title: 'Koin MILI & Kredit',
            ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (pinEnabled && locked) {
      if (biometricEnabled) {
        authenticateBiometric('Autentikasi untuk masuk aplikasi')
            .then((confirmed) {
          if (confirmed) {
            onPINConfirmed(context);
          }
        });
      }
      return PINVerification.withGradientBackground(
        key: verifyPinState,
        otpLength: 4,
        secured: true,
        title: '',
        subTitle: 'Masukkan PIN',
        invalidMessage: 'PIN tidak sesuai',
        validateOtp: validatePIN,
        onValidateSuccess: onPINConfirmed,
        onInvalid: (_) {
          verifyPinState.currentState!.clearOtp();
        },
        topColor: const Color.fromRGBO(0, 255, 193, 1),
        bottomColor: const Color.fromRGBO(0, 10, 255, 0.9938945174217224),
        themeColor: Colors.white,
        titleColor: Colors.white,
        action: TextButton(
          onPressed: onForgotPIN,
          child: const Text(
            'Lupa PIN',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return OverlayTooltipScaffold(
      tooltipAnimationCurve: Curves.linear,
      tooltipAnimationDuration: const Duration(milliseconds: 700),
      overlayColor: Colors.black.withOpacity(0.8),
      controller: tooltipController,
      builder: (context) => Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
              // backgroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: 70,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Image(
                    image: AppImages.logoColor,
                    height: 40,
                    fit: BoxFit.fill,
                  ),
                  const Spacer(),
                  // IconButton(
                  //   icon: const Icon(
                  //     Icons.workspace_premium_outlined,
                  //     size: 32,
                  //   ),
                  //   color: AppColors.black2,
                  //   onPressed: promo,
                  // ),
                  withBalanceProvider(CoinChip(onTap: coinScreen)),
                ],
              )),
        ),
        bottomNavigationBar: isShowBottomBar
            ? HomeBottomBar(
                pageController: tabController,
                selectedPage: selectedPage,
              )
            : null,
        body: Container(
          padding: const EdgeInsets.only(top: 0, bottom: 0),
          color: Colors.white,
          child: TabBarView(
            key: const PageStorageKey<String>("homepage"),
            controller: tabController,
            children: [
              withHomeScreenProvider(
                context,
                HomeScreen(
                  key: const PageStorageKey<String>('MainPage'),
                  scrollBottomBarController: mainScreenScrollController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // @override
  Widget withHomeScreenProvider(BuildContext context, Widget child) {
    debugPrint('Build withHomeScreenProvider');
    return UserBalanceScope(
      notifier: userBalanceState,
      child: ActiveBannerScope(
        notifier: activeBannerState,
        child: child,
      ),
    );
  }

  // @override
  Widget withBalanceProvider(Widget child) {
    return UserBalanceScope(
      notifier: userBalanceState,
      child: child,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
