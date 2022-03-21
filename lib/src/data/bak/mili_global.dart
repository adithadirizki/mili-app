// import 'package:flutter/material.dart';
// import 'mili_service.dart';
//
// class MiliGlobal {
//   double appBarHeight = 100.0;
//   static String platformImei = 'Unknown';
//   static String uniqueId = "Unknown";
//   static final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
//   static MiliUser ?miliUser;
//   void hideSnackBar() {
//
//   }
//
//   void showSnackBar(String info){
//     rootScaffoldMessengerKey.currentState?.showSnackBar(
//         SnackBar(
//           backgroundColor: Colors.red,
//           content: Text(info),
//           duration: const Duration(seconds: 3),
//           action: SnackBarAction(
//             label: 'ACTION',
//             onPressed: () { },
//           ),
//         )
//     );
//   }
//
//   void removeSnackBar(){
//
//   }
// }