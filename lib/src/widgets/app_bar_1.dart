import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';

// Alias class for temporary
class SimpleAppBar extends SimpleAppBar2 {
  final String? title;
  final double? elevation;
  final Widget? widget;
  final List<Widget>? actions;

  const SimpleAppBar(
      {Key? key, this.title, this.actions, this.widget, this.elevation})
      : super(key: key);
}

class SimpleAppBar3 extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final double? elevation;
  final Widget? widget;
  final List<Widget>? actions;

  const SimpleAppBar3(
      {Key? key, this.title, this.actions, this.widget, this.elevation})
      : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // backgroundColor: Colors.white,
      elevation: elevation ?? 0,
      toolbarHeight: 100,
      primary: true,
      // title: title != null ? Text(title!, style: const TextStyle(color: AppColors.blue1),) : null,
      title: widget ??
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 5),
              GestureDetector(
                // icon: const Icon(Icons.backspace_outlined),
                child: Text(
                  'Kembali',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppColors.blue2),
                ),
                onTap: () {
                  Navigator.maybePop(context);
                },
              ),
              const SizedBox(height: 5),
              // Text((title != null ? title! : ''), style: const TextStyle(color: Color(0xff505050), fontSize: 22))
              Text(
                (title != null ? title! : ''),
                style: Theme.of(context).textTheme.titleMedium,
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
  final double? elevation;
  final Widget? widget;
  final List<Widget>? actions;

  const SimpleAppBar2(
      {Key? key, this.title, this.actions, this.widget, this.elevation})
      : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: widget ??
          Text(
            title ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
      actions: actions,
      centerTitle: true,
      // backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Image(
          image: AppImages.back,
          width: 34,
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
      elevation: elevation ?? 0.5,
    );
  }
}
