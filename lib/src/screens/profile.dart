import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miliv2/src/config/config.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/program.dart';
import 'package:miliv2/src/routing.dart';
import 'package:miliv2/src/screens/about.dart';
import 'package:miliv2/src/screens/change_password.dart';
import 'package:miliv2/src/screens/customer_service.dart';
import 'package:miliv2/src/screens/downline.dart';
import 'package:miliv2/src/screens/faq.dart';
import 'package:miliv2/src/screens/favorite.dart';
import 'package:miliv2/src/screens/pin_setup.dart';
import 'package:miliv2/src/screens/price_setting.dart';
import 'package:miliv2/src/screens/printer.dart';
import 'package:miliv2/src/screens/privacy.dart';
import 'package:miliv2/src/screens/profile_update.dart';
import 'package:miliv2/src/screens/reward.dart';
import 'package:miliv2/src/screens/reward_perfomance.dart';
import 'package:miliv2/src/screens/system_info.dart';
import 'package:miliv2/src/screens/upgrade.dart';
import 'package:miliv2/src/services/auth.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/utils/device.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/profile_picture.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late String version = '';

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
    }));
    menuList2.add(AppMenu(AppImages.headphones, 'Customer Service', () {
      pushScreen(
        context,
        (_) => const CustomerServiceScreen(),
      );
    }));
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initialize();
    });
  }

  void initialize() async {
    version = await getAppVersion();
    userBalanceState.fetchData();
    initDB();
  }

  void initDB() async {
    await AppDB.syncProgram();

    final programDB = AppDB.programDB;
    Program? programProgram = programDB.query().build().findFirst();

    if (programProgram != null) {
      menuList2.add(AppMenu(AppImages.reward, programProgram.title, () {
        // premium - show perfomance, direct link webview
        // non-premium - don't show perfomance, direct link webview
        if (programProgram.link != null) {
          pushScreen(context, (_) {
            if (userBalanceState.premium) {
              return RewardScreen(
                  title: programProgram.title,
                  url: AppConfig.baseUrl + '/programs/summary/' + programProgram.serverId.toString()
              );
            } else {
              return RewardScreen(
                  title: programProgram.title, url: programProgram.link ?? '');
            }
          });
        }
      }));
    }

    setState(() {});
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

  void faq() {
    pushScreen(
      context,
          (_) => const FaqScreen(title: 'FAQ'),
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

  void system() {
    pushScreen(
      context,
      (_) => const SystemInfoScreen(title: 'Informasi Sistem'),
    );
  }

  void playStore() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.sridata.mili';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      snackBarDialog(context, 'Tidak bisa membuka link');
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
            // style: defaultLabelStyle.copyWith(),
            style: Theme.of(context).textTheme.bodyMedium,
          )
        ],
      ),
    );
  }

  Widget itemBuilder2(AppMenu menu) {
    return ListTile(
      title: Text(
        menu.label,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
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
          Positioned(
            top: 100,
            left: 26,
            child: Text(
              'Hello,',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: AppColors.white1),
              // style: TextStyle(
              //     color: Color.fromRGBO(255, 255, 255, 1),
              //     fontFamily: 'Montserrat',
              //     fontSize: 28,
              //     letterSpacing: -0.30000001192092896,
              //     fontWeight: FontWeight.normal,
              //     height: 1),
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
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: AppColors.yellow1),
              // style: const TextStyle(
              //     color: Color.fromRGBO(255, 199, 0, 1),
              //     fontFamily: 'Montserrat',
              //     fontSize: 22,
              //     letterSpacing: -0.30000001192092896,
              //     fontWeight: FontWeight.normal,
              //     height: 1),
            ),
          ),
          Positioned(
            top: 105,
            right: 100,
            child: UserBalanceScope.of(context).referralCode != null
                ? Text(
                    'Kode Referral',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: AppColors.white1),)
                : const SizedBox(),
          ),
          Positioned(
            top: 130,
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
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: AppColors.white1),
                          // style: const TextStyle(
                          //     color: Color.fromRGBO(255, 255, 255, 1),
                          //     fontFamily: 'Roboto',
                          //     fontSize: 20,
                          //     letterSpacing: -0.30000001192092896,
                          //     fontWeight: FontWeight.normal,
                          //     height: 1),
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
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: AppColors.white1),
                    // style: const TextStyle(
                    //     color: Color.fromRGBO(255, 255, 255, 1),
                    //     fontFamily: 'Montserrat',
                    //     // fontSize: 9,
                    //     letterSpacing: -0.30000001192092896,
                    //     fontWeight: FontWeight.normal,
                    //     height: 1),
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
                              .bodyMedium!
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
                              // style: const TextStyle(color: Colors.white),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white1),
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
                          children: [
                            const Image(
                              image: AppImages.info,
                              color: Color(0xFFFFFFFF),
                              width: 24,
                            ),
                            const SizedBox(width: 20),
                            Text(
                              'Tentang Aplikasi',
                              // style: TextStyle(color: Colors.white),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white1),
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
                          children: [
                            const Image(
                              image: AppImages.mutasi,
                              color: Color(0xFFFFFFFF),
                              width: 24,
                            ),
                            const SizedBox(width: 20),
                            Text(
                              'FAQ',
                              // style: TextStyle(color: Colors.white),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white1),
                            ),
                          ],
                        ),
                        onPressed: faq,
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
                          children: [
                            const Image(
                              image: AppImages.checkSquare,
                              color: Color(0xFFFFFFFF),
                              width: 24,
                            ),
                            const SizedBox(width: 20),
                            Text(
                              'Syarat dan Ketentuan Aplikasi',
                              // style: TextStyle(color: Colors.white),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white1),
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
                      OutlinedButton(
                        child: Row(
                          children: [
                            // const Image(
                            //   image: AppImages.info,
                            //   color: Color(0xFFFFFFFF),
                            //   width: 24,
                            // ),
                            const Icon(Icons.wifi_protected_setup_rounded,
                                color: Colors.white),
                            const SizedBox(width: 20),
                            Text(
                              'Perbarui Aplikasi',
                              // style: TextStyle(color: Colors.white),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white1),
                            ),
                          ],
                        ),
                        onPressed: playStore,
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
              TextButton(
                onPressed: system,
                child: Text(
                  'Versi $version',
                  style: Theme.of(context).textTheme.bodySmall,
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
