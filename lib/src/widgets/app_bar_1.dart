import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';

class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;

  const SimpleAppBar({Key? key, this.title, this.actions}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 100,
      primary: true,
      // title: title != null ? Text(title!, style: const TextStyle(color: AppColors.blue1),) : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 5),
          GestureDetector(
            // icon: const Icon(Icons.backspace_outlined),
            child: const Text('Kembali',
                style: TextStyle(color: AppColors.blue1, fontSize: 16)),
            onTap: () {
              Navigator.maybePop(context);
            },
          ),
          const SizedBox(height: 5),
          // Text((title != null ? title! : ''), style: const TextStyle(color: Color(0xff505050), fontSize: 22))
          Text(
            (title != null ? title! : ''),
            style: Theme.of(context).textTheme.subtitle1,
          )
        ],
      ),
      actions: actions,
      leadingWidth: 100,
      automaticallyImplyLeading: false,
      // leading: Builder(
      //   builder: (context) {
      //     return IconButton(
      //       // icon: const Icon(Icons.backspace_outlined),
      //       icon: Text('Kembali'),
      //       onPressed: () { Navigator.maybePop(context); },
      //       tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      //     );
      //   },
      // ),
    );
  }
}

class SimpleAppBar2 extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;

  const SimpleAppBar2({Key? key, this.title, this.actions}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title ?? '',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline6,
      ),
      actions: actions,
      centerTitle: true,
      // backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Image(
          image: AppImages.back,
        ),
        // tooltip: AppLabel.backNavigation,
        onPressed: () {
          // Navigator.maybePop(context);
          // authState.signOut();
          // routeState.go('/signin');
          // widget.onBack();
          Navigator.maybePop(context);
        },
      ),
      elevation: 0.5,
    );
  }
}
