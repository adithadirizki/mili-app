// import 'package:flutter/cupertino.dart';
// import 'package:sqflite/sqflite.dart';
//
// const dbVersion = 2;
//
// @immutable
// class Migration {
//   final List<String> upScripts;
//   final List<String>? downScripts;
//   final Function(Database)? afterUp;
//   final Function(Database)? beforeDown;
//
//   const Migration(
//       {required this.upScripts,
//       this.downScripts,
//       this.afterUp,
//       this.beforeDown});
// }
//
// /// Don't modify existing script
// /// Just create new one
// final Map<int, Migration> migrations = {
//   2: Migration(
//       upScripts: const [
//         'CREATE TABLE products(code TEXT PRIMARY KEY, name TEXT, price REAL);',
//       ],
//       downScripts: const [
//         'DROP TABLE products;'
//       ],
//       afterUp: (db) {
//         Map<String, Object?> data = {
//           'code': 'XR10',
//           'name': 'XL 10RB',
//           'price': 10000
//         };
//         db.insert("products", data);
//       }),
// };
