import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/data/active_banner.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/screens/activation_wallet.dart';
import 'package:miliv2/src/screens/coin_mili.dart';
import 'package:miliv2/src/screens/home_screen.dart';
import 'package:miliv2/src/screens/otp_verification.dart';
import 'package:miliv2/src/services/analytics.dart';
import 'package:miliv2/src/services/auth.dart';
import 'package:miliv2/src/services/biometry.dart';
import 'package:miliv2/src/services/messaging.dart';
import 'package:miliv2/src/services/storage.dart';
import 'package:miliv2/src/theme/images.dart';
import 'package:miliv2/src/utils/dialog.dart';
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

  final TooltipController _controller = TooltipController();

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

  @override
  void initState() {
    _controller.setStartWhen((initializedWidgetLength) async {
      await Future<dynamic>.delayed(const Duration(milliseconds: 3000));
      return AppStorage.getFirstInstall() == true;
    });

    _controller.onDone(() {
      AppStorage.setFirstInstall(false);
    });

    super.initState();
    pageController = PageController(initialPage: initialPage);
    tabController = TabController(length: 1, initialIndex: 0, vsync: this);
    mainScreenScrollController.addListener(scrollListener);

    initPin();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      AppDB.syncCutoff();
      initProvider();
    });
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
    await userBalanceState.fetchData().then((value) {
      bool? isFirstInstall = AppStorage.getFirstInstall();
      if (userBalanceState.groupName == 'GUEST' && isFirstInstall) {
        _controller.start();
        AppStorage.setFirstInstall(false);
      } else if (isFirstInstall) {
        _controller.start();
        AppStorage.setFirstInstall(false);
      }
    }).catchError(_handleError);
    await userBalanceState.fetchWallet().then((_) {
      // // Init Wallet Activation
      // if (!userBalanceState.walletActive) {
      //   // Activation wallet
      //   walletActivation();
      // }
    }).catchError(_handleError);
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

  void initialize() async {
    var closeLoader = showLoaderDialog(context, message: 'Memperbarui...');
    AppDB.syncVendor();
    AppDB.syncUserConfig();
    await AppDB.syncProduct();
    // await AppDB.syncHistory();
    // await AppDB.syncTopupHistory();
    // await AppDB.syncBalanceMutation();
    // await AppDB.syncCreditMutation();
    synchronized = true;
    await closeLoader();
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
    _controller.dispose();
    mainScreenScrollController.removeListener(scrollListener);
    tabController.dispose();
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
      controller: _controller,
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
      )
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
