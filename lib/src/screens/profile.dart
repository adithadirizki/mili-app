import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/routing.dart';
import 'package:miliv2/src/screens/about.dart';
import 'package:miliv2/src/screens/change_password.dart';
import 'package:miliv2/src/screens/customer_service.dart';
import 'package:miliv2/src/screens/downline.dart';
import 'package:miliv2/src/screens/favorite.dart';
import 'package:miliv2/src/screens/pin_setup.dart';
import 'package:miliv2/src/screens/price_setting.dart';
import 'package:miliv2/src/screens/printer.dart';
import 'package:miliv2/src/screens/privacy.dart';
import 'package:miliv2/src/screens/profile_update.dart';
import 'package:miliv2/src/screens/upgrade.dart';
import 'package:miliv2/src/services/auth.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/profile_picture.dart';

enum historyAction {
  toggleFavorite,
  showDetail,
  print,
  contactCS,
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<AppMenu> menuList1 = [];
  List<AppMenu> menuList2 = [];

  @override
  void initState() {
    super.initState();
    menuList1.add(AppMenu(AppImages.home, 'Home', () {
      popScreen(context);
    }));
    menuList1.add(AppMenu(AppImages.lock, 'Aktifkan PIN', () async {
      pushScreen(
        context,
        (_) => const PINSetupScreen(),
      );
    }));
    menuList1.add(AppMenu(AppImages.sliders, 'Setting Harga', () {
      pushScreen(
        context,
        (_) => const PriceSettingScreen(),
      );
    }));
    menuList1.add(AppMenu(AppImages.printer, 'Printer', () {
      pushScreen(
        context,
        (_) => const PrinterScreen(),
      );
    }));
    //
    menuList2.add(AppMenu(AppImages.key, 'Ubah Password', () {
      pushScreen(
        context,
        (_) => const ChangePasswordScreen(),
      );
    }));
    menuList2.add(AppMenu(AppImages.favorites, 'Nomor Favorit', () {
      pushScreen(
        context,
        (_) => const FavoriteScreen(),
      );
    }));
    menuList2.add(AppMenu(AppImages.downline, 'Downline', () {
      pushScreen(
        context,
        (_) => const DownlineScreen(),
      );
    }));
    menuList2.add(AppMenu(AppImages.headphones, 'Customer Service', () {
      pushScreen(
        context,
        (_) => const CustomerServiceScreen(),
      );
    }));
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      initialize();
    });
  }

  void initialize() {
    userBalanceState.fetchData();
  }

  void logout() {
    if (userBalanceState.isGuest()) {
      RouteStateScope.of(context).go('/signin');
    } else {
      confirmDialog(context, title: 'Konfirmasi', msg: 'Keluar dari aplikasi ?',
          confirmAction: () {
        AppAuthScope.of(context).signOut();
        RouteStateScope.of(context).go('/signin');
      }, confirmText: 'Keluar', cancelText: 'Batal');
    }
  }

  void copyReffNumber() {
    Clipboard.setData(ClipboardData(text: userBalanceState.referralCode));
    snackBarDialog(context, 'Nomor referal disalin');
  }

  void about() {
    pushScreen(
      context,
      (_) => const AboutScreen(title: 'Tentang Aplikasi'),
    );
  }

  void privacy() {
    pushScreen(
      context,
      (_) => const PrivacyScreen(title: 'Syarat dan Ketentuan Aplikasi'),
    );
  }

  void premium() {
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

  Widget itemBuilder1(AppMenu menu) {
    return Container(
      key: ObjectKey(menu),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: menu.action,
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(19),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            ),
            child: Image(
              width: 35,
              image: menu.icon,
              color: const Color(0xFF8C8C8C),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            menu.label,
            style: defaultLabelStyle.copyWith(),
          )
        ],
      ),
    );
  }

  Widget itemBuilder2(AppMenu menu) {
    return ListTile(
      title: Text(menu.label),
      leading: Image(
        image: menu.icon,
        color: const Color(0xFF8C8C8C),
        width: 24,
      ),
      onTap: menu.action,
    );
  }

  Widget withHomeScreenProvider(BuildContext context, Widget child) {
    return UserBalanceScope(
      notifier: userBalanceState,
      child: child,
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      color: AppColors.blue5,
      alignment: Alignment.center,
      child: Stack(
        // fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            top: 35,
            left: 0,
            child: Image(
              image: AppImages.profileBg1,
              width: 50,
            ),
          ),
          // Right
          const Positioned(
            bottom: 0,
            right: 0,
            child: Image(
              image: AppImages.profileBg2,
              width: 80,
            ),
          ),
          Positioned(
            top: 40,
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: const Image(
              image: AppImages.logoWhite,
              width: 80,
            ),
          ),
          Positioned(
            bottom: -25,
            left: 30,
            child: withHomeScreenProvider(context, const ProfilePicture()),
          ),
          const Positioned(
            top: 100,
            left: 26,
            child: Text(
              'Hello,',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  fontFamily: 'Montserrat',
                  fontSize: 28,
                  letterSpacing: -0.30000001192092896,
                  fontWeight: FontWeight.normal,
                  height: 1),
            ),
          ),
          Positioned(
            top: 100,
            left: 120,
            child: userBalanceState.isGuest()
                ? const SizedBox()
                : GestureDetector(
                    child: ClipOval(
                      child: Container(
                        width: 22,
                        height: 22,
                        padding: const EdgeInsets.all(4),
                        color: AppColors.yellow1,
                        child: const Image(
                          image: AppImages.edit,
                          width: 10,
                          height: 10,
                        ),
                      ),
                    ),
                    onTap: () {
                      pushScreen(
                        context,
                        (_) => const ProfileUpdateScreen(),
                      );
                    },
                  ),
          ),
          Positioned(
            top: 130,
            left: 28,
            child: Text(
              UserBalanceScope.of(context).name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color.fromRGBO(255, 199, 0, 1),
                  fontFamily: 'Montserrat',
                  fontSize: 22,
                  letterSpacing: -0.30000001192092896,
                  fontWeight: FontWeight.normal,
                  height: 1),
            ),
          ),
          Positioned(
            top: 115,
            right: 100,
            child: UserBalanceScope.of(context).referralCode != null
                ? GestureDetector(
                    onTap: copyReffNumber,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          UserBalanceScope.of(context).referralCode ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontFamily: 'Roboto',
                              fontSize: 20,
                              letterSpacing: -0.30000001192092896,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        ),
                        const SizedBox(width: 5),
                        const Image(
                          image: AppImages.copy,
                          width: 14,
                        )
                      ],
                    ),
                  )
                : const SizedBox(),
          ),
          Positioned(
            bottom: 20,
            right: 100,
            child: GestureDetector(
              onTap: logout,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Image(image: AppImages.power, width: 20),
                  const SizedBox(width: 5),
                  Text(
                    userBalanceState.isGuest() ? 'Daftar' : 'Log Out',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontFamily: 'Montserrat',
                        // fontSize: 9,
                        letterSpacing: -0.30000001192092896,
                        fontWeight: FontWeight.normal,
                        height: 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: const Color(0xFF0EA8FF),
      //   elevation: 0,
      //   toolbarHeight: 200,
      //   automaticallyImplyLeading: false,
      // ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200.0),
        child: withHomeScreenProvider(context, buildHeader(context)),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Card(
                // color: Colors.white,
                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                elevation: 3,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: menuList1.map(itemBuilder1).toList(),
                  ),
                ),
              ),
              Card(
                // color: Colors.white,
                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                elevation: 3,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(
                    children: menuList2.map(itemBuilder2).toList(),
                  ),
                ),
              ),
              Card(
                // color: Colors.white,
                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                elevation: 3,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 0),
                        child: Text(
                          'Bantuan',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(color: const Color(0xFFCBC9C9)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        child: Row(
                          children: [
                            const Image(
                              image: AppImages.chevronsUp,
                              color: Color(0xFFFFFFFF),
                              width: 24,
                            ),
                            const SizedBox(width: 20),
                            Text(
                              userBalanceState.premium
                                  ? 'Akun Premium'
                                  : 'Upgrade Premium',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        onPressed: premium,
                        style: ElevatedButton.styleFrom(
                          primary: AppColors.yellow1,
                          minimumSize: const Size(200, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        child: Row(
                          children: const [
                            Image(
                              image: AppImages.info,
                              color: Color(0xFFFFFFFF),
                              width: 24,
                            ),
                            SizedBox(width: 20),
                            Text(
                              'Tentang Aplikasi',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        onPressed: about,
                        style: ElevatedButton.styleFrom(
                          primary: AppColors.blue5,
                          minimumSize: const Size(200, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        child: Row(
                          children: const [
                            Image(
                              image: AppImages.checkSquare,
                              color: Color(0xFFFFFFFF),
                              width: 24,
                            ),
                            SizedBox(width: 20),
                            Text(
                              'Syarat dan Ketentuan Aplikasi',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        onPressed: privacy,
                        style: ElevatedButton.styleFrom(
                          primary: AppColors.blue5,
                          minimumSize: const Size(200, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

@immutable
class AppMenu {
  final AssetImage icon;
  final String label;
  final VoidCallback action;

  const AppMenu(this.icon, this.label, this.action);
}
