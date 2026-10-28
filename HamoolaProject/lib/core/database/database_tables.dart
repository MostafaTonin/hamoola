/// Schema definitions, table names, column constants, and SQL creation scripts
/// for Hamoola Local SQLite Database.
class DatabaseTables {
  DatabaseTables._();

  static const String databaseName = 'hamoola_app.db';
  static const int databaseVersion = 1;

  // ===========================================================================
  // 1. Users Table
  // ===========================================================================
  static const String tableUsers = 'users';
  static const String colUserId = 'id';
  static const String colUserName = 'name';
  static const String colUserPhone = 'phone';
  static const String colUserCountryCode = 'country_code';
  static const String colUserPassword = 'password';
  static const String colUserRole = 'role';
  static const String colUserAccountType = 'account_type';
  static const String colUserVerificationStatus = 'verification_status';
  static const String colUserIsPhoneVerified = 'is_phone_verified';
  static const String colUserCreatedAt = 'created_at';
  static const String colUserIdentityJson = 'identity_data_json';
  static const String colUserOfficeJson = 'office_data_json';
  static const String colUserDriverJson = 'driver_data_json';

  static const String createUsersTable = '''
    CREATE TABLE $tableUsers (
      $colUserId TEXT PRIMARY KEY,
      $colUserName TEXT NOT NULL,
      $colUserPhone TEXT NOT NULL UNIQUE,
      $colUserCountryCode TEXT NOT NULL DEFAULT '+967',
      $colUserPassword TEXT NOT NULL,
      $colUserRole TEXT NOT NULL,
      $colUserAccountType TEXT NOT NULL,
      $colUserVerificationStatus TEXT NOT NULL,
      $colUserIsPhoneVerified INTEGER NOT NULL DEFAULT 1,
      $colUserCreatedAt TEXT NOT NULL,
      $colUserIdentityJson TEXT,
      $colUserOfficeJson TEXT,
      $colUserDriverJson TEXT
    )
  ''';

  // ===========================================================================
  // 2. Orders Table
  // ===========================================================================
  static const String tableOrders = 'orders';
  static const String colOrderId = 'id';
  static const String colOrderUserId = 'user_id';
  static const String colOrderRole = 'role';
  static const String colOrderTitle = 'title';
  static const String colOrderCargoType = 'cargo_type';
  static const String colOrderOriginCity = 'origin_city';
  static const String colOrderDestCity = 'destination_city';
  static const String colOrderWeight = 'weight_tons';
  static const String colOrderPrice = 'price';
  static const String colOrderStatus = 'status';
  static const String colOrderCreatedAt = 'created_at';
  static const String colOrderDetailsJson = 'details_json';

  static const String createOrdersTable = '''
    CREATE TABLE $tableOrders (
      $colOrderId TEXT PRIMARY KEY,
      $colOrderUserId TEXT NOT NULL,
      $colOrderRole TEXT NOT NULL,
      $colOrderTitle TEXT NOT NULL,
      $colOrderCargoType TEXT NOT NULL,
      $colOrderOriginCity TEXT NOT NULL,
      $colOrderDestCity TEXT NOT NULL,
      $colOrderWeight REAL NOT NULL,
      $colOrderPrice REAL NOT NULL,
      $colOrderStatus TEXT NOT NULL,
      $colOrderCreatedAt TEXT NOT NULL,
      $colOrderDetailsJson TEXT
    )
  ''';

  // ===========================================================================
  // 3. Cargos Table
  // ===========================================================================
  static const String tableCargos = 'cargos';
  static const String colCargoId = 'id';
  static const String colCargoUserId = 'user_id';
  static const String colCargoTitle = 'title';
  static const String colCargoWeight = 'weight';
  static const String colCargoCategory = 'category';
  static const String colCargoStatus = 'status';
  static const String colCargoCreatedAt = 'created_at';
  static const String colCargoDetailsJson = 'details_json';

  static const String createCargosTable = '''
    CREATE TABLE $tableCargos (
      $colCargoId TEXT PRIMARY KEY,
      $colCargoUserId TEXT NOT NULL,
      $colCargoTitle TEXT NOT NULL,
      $colCargoWeight TEXT NOT NULL,
      $colCargoCategory TEXT NOT NULL,
      $colCargoStatus TEXT NOT NULL,
      $colCargoCreatedAt TEXT NOT NULL,
      $colCargoDetailsJson TEXT
    )
  ''';

  // ===========================================================================
  // 4. Trips Table
  // ===========================================================================
  static const String tableTrips = 'trips';
  static const String colTripId = 'id';
  static const String colTripOrderId = 'order_id';
  static const String colTripDriverId = 'driver_id';
  static const String colTripOfficeId = 'office_id';
  static const String colTripRole = 'role';
  static const String colTripStatus = 'status';
  static const String colTripOriginCity = 'origin_city';
  static const String colTripDestCity = 'destination_city';
  static const String colTripDriverName = 'driver_name';
  static const String colTripTruckType = 'truck_type';
  static const String colTripPlateNumber = 'plate_number';
  static const String colTripCreatedAt = 'created_at';
  static const String colTripMilestonesJson = 'milestones_json';

  static const String createTripsTable = '''
    CREATE TABLE $tableTrips (
      $colTripId TEXT PRIMARY KEY,
      $colTripOrderId TEXT NOT NULL,
      $colTripDriverId TEXT,
      $colTripOfficeId TEXT,
      $colTripRole TEXT NOT NULL,
      $colTripStatus TEXT NOT NULL,
      $colTripOriginCity TEXT NOT NULL,
      $colTripDestCity TEXT NOT NULL,
      $colTripDriverName TEXT NOT NULL,
      $colTripTruckType TEXT NOT NULL,
      $colTripPlateNumber TEXT NOT NULL,
      $colTripCreatedAt TEXT NOT NULL,
      $colTripMilestonesJson TEXT
    )
  ''';

  // ===========================================================================
  // 5. Wallet Transactions Table
  // ===========================================================================
  static const String tableWalletTransactions = 'wallet_transactions';
  static const String colTxId = 'id';
  static const String colTxUserId = 'user_id';
  static const String colTxRole = 'role';
  static const String colTxType = 'type';
  static const String colTxAmount = 'amount';
  static const String colTxTitle = 'title';
  static const String colTxReferenceId = 'reference_id';
  static const String colTxDate = 'date';
  static const String colTxStatus = 'status';
  static const String colTxDetailsJson = 'details_json';

  static const String createWalletTransactionsTable = '''
    CREATE TABLE $tableWalletTransactions (
      $colTxId TEXT PRIMARY KEY,
      $colTxUserId TEXT NOT NULL,
      $colTxRole TEXT NOT NULL,
      $colTxType TEXT NOT NULL,
      $colTxAmount REAL NOT NULL,
      $colTxTitle TEXT NOT NULL,
      $colTxReferenceId TEXT NOT NULL,
      $colTxDate TEXT NOT NULL,
      $colTxStatus TEXT NOT NULL,
      $colTxDetailsJson TEXT
    )
  ''';

  // ===========================================================================
  // 6. Office Drivers Table
  // ===========================================================================
  static const String tableOfficeDrivers = 'office_drivers';
  static const String colOfficeDriverId = 'id';
  static const String colOfficeDriverOfficeId = 'office_id';
  static const String colOfficeDriverName = 'name';
  static const String colOfficeDriverPhone = 'phone';
  static const String colOfficeDriverNationalId = 'national_id';
  static const String colOfficeDriverLicense = 'license_number';
  static const String colOfficeDriverTruckType = 'truck_type';
  static const String colOfficeDriverIsEndorsed = 'is_endorsed';
  static const String colOfficeDriverStatus = 'status';
  static const String colOfficeDriverRating = 'rating';

  static const String createOfficeDriversTable = '''
    CREATE TABLE $tableOfficeDrivers (
      $colOfficeDriverId TEXT PRIMARY KEY,
      $colOfficeDriverOfficeId TEXT NOT NULL,
      $colOfficeDriverName TEXT NOT NULL,
      $colOfficeDriverPhone TEXT NOT NULL,
      $colOfficeDriverNationalId TEXT NOT NULL,
      $colOfficeDriverLicense TEXT NOT NULL,
      $colOfficeDriverTruckType TEXT NOT NULL,
      $colOfficeDriverIsEndorsed INTEGER NOT NULL DEFAULT 1,
      $colOfficeDriverStatus TEXT NOT NULL,
      $colOfficeDriverRating REAL NOT NULL DEFAULT 4.8
    )
  ''';
}
