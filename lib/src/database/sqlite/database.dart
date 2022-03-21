// import 'package:flutter/foundation.dart';
// import 'package:miliv2/src/config/config.dart';
// import 'package:miliv2/src/database/sqlite/migrations.dart' as migration;
// import 'package:path/path.dart' as path;
// import 'package:sqflite/sqflite.dart';
//
// class AppDB {
//   static Database? _db;
//   static final AppDB instance = AppDB._singleton();
//
//   // AppDB._();
//   AppDB._singleton();
//
//   Future<void> _initDB(Database db) async {
//     return db.execute(
//         'CREATE TABLE migrations(version INTEGER PRIMARY KEY, updated INTEGER, script TEXT)');
//   }
//
//   Future<void> _applyMigration(
//       Database db, int oldVersion, int newVersion) async {
//     debugPrint('Upgrade DBVersion from $oldVersion to $newVersion');
//     for (int i = oldVersion + 1; i <= newVersion; i++) {
//       int migrationKey = i;
//       migration.Migration? m = migration.migrations[migrationKey];
//       if (m != null) {
//         debugPrint('Apply migration $migrationKey');
//         for (String script in m.upScripts) {
//           debugPrint('Execution script $script');
//           await db.execute(script);
//         }
//         debugPrint('Finished migration $migrationKey');
//         Map<String, dynamic> data = <String, dynamic>{
//           'version': i,
//           'script': m.upScripts.join(';'),
//           'updated': DateTime.now().millisecondsSinceEpoch
//         };
//         await db.insert('migrations', data,
//             conflictAlgorithm: ConflictAlgorithm.replace);
//         if (m.afterUp != null) {
//           m.afterUp!(db);
//         }
//       }
//     }
//   }
//
//   Future<void> _revertMigration(
//       Database db, int oldVersion, int newVersion) async {
//     debugPrint('Downgrade DBVersion from $oldVersion to $newVersion');
//     for (int i = oldVersion; i > newVersion; i--) {
//       int migrationKey = i;
//       migration.Migration? m = migration.migrations[migrationKey];
//       if (m != null) {
//         if (m.beforeDown != null) {
//           m.beforeDown!(db);
//         }
//         debugPrint('Rollback migration $migrationKey');
//         if (m.downScripts != null) {
//           for (String script in m.downScripts!) {
//             debugPrint('Execution script $script');
//             await db.execute(script);
//           }
//         }
//         debugPrint('Finished migration $migrationKey');
//         await db.execute('delete from migrations where version = ?', [i]);
//       }
//     }
//   }
//
//   Future<Database> openDB() async {
//     final dbPath = await getDatabasesPath();
//     _db ??= await openDatabase(
//       path.join(dbPath, AppConfig.dbName),
//       onCreate: (db, version) async {
//         debugPrint('Init version $version');
//         await _initDB(db);
//         await _applyMigration(db, 1, version);
//       },
//       onUpgrade: _applyMigration,
//       onDowngrade: _revertMigration,
//       version: migration.dbVersion,
//     );
//     return _db!;
//   }
//
//   Future<int> insert(String table, Map<String, Object> data) async {
//     final db = await openDB();
//     return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
//   }
//
//   Future<List<Map<String, Object?>>> getData(String tableName) async {
//     final db = await openDB();
//     var result = await db.query(tableName);
//     return result.toList();
//   }
//
//   Future<List<Map<String, Object?>>> rawQuery(String query,
//       [List<Object?>? params]) async {
//     final db = await openDB();
//     var result = await db.rawQuery(query, params);
//     return result.toList();
//   }
// }
