// import 'package:connectivity/connectivity.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
//
// class ConnectivityChangeNotifier extends ChangeNotifier {
//   ConnectivityChangeNotifier() {
//     Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
//       resultHandler(result);
//     });
//   }
//
//   ConnectivityResult _connectivityResult = ConnectivityResult.none;
//   String _svgUrl = 'assets/serverDown.svg';
//   String _pageText = 'Currently connected to no network. Please connect to a wifi network!';
//   bool _showAlert = false;
//
//   ConnectivityResult get connectivity => _connectivityResult;
//
//   String get svgUrl => _svgUrl;
//   String get pageText => _pageText;
//   bool get showAlert => _showAlert;
//
//   void resultHandler(ConnectivityResult result) {
//     _connectivityResult = result;
//     if (result == ConnectivityResult.none) {
//       _showAlert = true;
//       _svgUrl = 'assets/serverDown.svg';
//       _pageText =
//           'Currently connected to no network. Please connect to a wifi network!';
//     } else if (result == ConnectivityResult.mobile) {
//       _showAlert = false;
//       _svgUrl = 'assets/noWifi.svg';
//       _pageText =
//           'Currently connected to a celluar network. Please connect to a wifi network!';
//     } else if (result == ConnectivityResult.wifi) {
//       _showAlert = false;
//       _svgUrl = 'assets/connected.svg';
//       _pageText = 'Connected to a wifi network!';
//     }
//     notifyListeners();
//   }
//
//   void initialLoad() async {
//     ConnectivityResult connectivityResult =
//         await (Connectivity().checkConnectivity());
//     resultHandler(connectivityResult);
//   }
//
//   Widget errmsg(String text, bool show){
//     if (show == true){
//       return Container(
//         //padding: EdgeInsets.all(10.00),
//         margin: EdgeInsets.only(bottom: 10.00),
//         color: Colors.red,
//         child: Row(
//           children: [
//             Container(
//               margin: EdgeInsets.only(left: 10.00),
//               child: Icon(Icons.info, color: Colors.white,),
//             ),
//             Flexible(
//                 child: Padding(
//                     padding: const EdgeInsets.fromLTRB(10.0, 0, 10, 0),
//                     child: Text(
//                       text,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.white),
//                     )
//                 )
//             ),
//             Container(
//               margin: EdgeInsets.only(right: 6.00),
//               child: IconButton(
//                 icon: Icon(Icons.settings, color: Colors.white,),
//                 tooltip: 'Setting',
//                 onPressed: () {
//
//                 },
//                 // onPressed: ()=> AppSettings.openAppSettings(),
//               ),
//             ),
//           ],
//         ),
//       );
//     }else{
//       return Container();
//     }
//   }
// }
