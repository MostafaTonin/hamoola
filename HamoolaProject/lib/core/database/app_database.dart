import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database_tables.dart';

/// Central Singleton Database Manager for Hamoola.
/// Manages SQLite connection lifecycle, migrations, and platform compatibility.
class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  factory AppDatabase() => instance;

  AppDatabase._internal();

  Database? _db;

  /// Returns active database instance or initializes it on first access.
  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await initDatabase();
    return _db!;
  }

  /// Initializes the SQLite database.
  /// If [isInMemory] is true (e.g. during automated tests), uses in-memory SQLite database.
  Future<Database> initDatabase({bool isInMemory = false}) async {
    // 1. Setup SQLite Factory for Desktop (Windows/Linux/macOS) and Testing
    if (kIsWeb) {
      // In web or mock environments, fallback safely
    } else if (Platform.isWindows ||
        Platform.isLinux ||
        Platform.isMacOS ||
        isInMemory) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    if (isInMemory) {
      final db = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: DatabaseTables.databaseVersion,
          onCreate: _onCreate,
        ),
      );
      _db = db;
      return db;
    }

    // 2. Resolve database file path on device
    String dbPath;
    if (Platform.isAndroid) {
      dbPath = p.join(await getDatabasesPath(), DatabaseTables.databaseName);
    } else if (Platform.isIOS) {
      final dir = await getLibraryDirectory();
      dbPath = p.join(dir.path, DatabaseTables.databaseName);
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      dbPath = p.join(appDocDir.path, DatabaseTables.databaseName);
    }

    // Ensure parent directory exists
    final dir = Directory(p.dirname(dbPath));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: DatabaseTables.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );

    _db = db;
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DatabaseTables.createUsersTable);
    await db.execute(DatabaseTables.createOrdersTable);
    await db.execute(DatabaseTables.createCargosTable);
    await db.execute(DatabaseTables.createTripsTable);
    await db.execute(DatabaseTables.createWalletTransactionsTable);
    await db.execute(DatabaseTables.createOfficeDriversTable);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future schema upgrades and migrations will be placed here
  }

  /// Closes database connection cleanly
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }

  /// Clears all tables (used during factory reset or testing)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(DatabaseTables.tableUsers);
    await db.delete(DatabaseTables.tableOrders);
    await db.delete(DatabaseTables.tableCargos);
    await db.delete(DatabaseTables.tableTrips);
    await db.delete(DatabaseTables.tableWalletTransactions);
    await db.delete(DatabaseTables.tableOfficeDrivers);
  }
}
