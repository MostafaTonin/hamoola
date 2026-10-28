import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../features/auth/domain/models/auth_user.dart';
import '../app_database.dart';
import '../database_tables.dart';

/// Data Access Object for Users in SQLite database.
class UserDao {
  final AppDatabase _dbManager;

  UserDao({AppDatabase? dbManager}) : _dbManager = dbManager ?? AppDatabase.instance;

  Future<Database> get _db => _dbManager.database;

  /// Inserts a new user or replaces existing user by ID.
  Future<void> insertOrUpdateUser(AuthUser user) async {
    final db = await _db;
    final row = _userToRow(user);
    await db.insert(
      DatabaseTables.tableUsers,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Inserts multiple users in a single transaction (used for seeding).
  Future<void> insertUsersBatch(List<AuthUser> users) async {
    final db = await _db;
    final batch = db.batch();
    for (final user in users) {
      batch.insert(
        DatabaseTables.tableUsers,
        _userToRow(user),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Retrieves user by unique ID.
  Future<AuthUser?> getUserById(String id) async {
    final db = await _db;
    final List<Map<String, dynamic>> results = await db.query(
      DatabaseTables.tableUsers,
      where: '${DatabaseTables.colUserId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return _rowToUser(results.first);
  }

  /// Retrieves user by phone number.
  Future<AuthUser?> getUserByPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final db = await _db;
    final List<Map<String, dynamic>> results = await db.query(
      DatabaseTables.tableUsers,
      where: '${DatabaseTables.colUserPhone} = ?',
      whereArgs: [cleanPhone],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return _rowToUser(results.first);
  }

  /// Retrieves all users in the system.
  Future<List<AuthUser>> getAllUsers() async {
    final db = await _db;
    final List<Map<String, dynamic>> results = await db.query(
      DatabaseTables.tableUsers,
      orderBy: '${DatabaseTables.colUserCreatedAt} DESC',
    );

    return results.map(_rowToUser).toList();
  }

  /// Deletes a user by ID.
  Future<int> deleteUser(String id) async {
    final db = await _db;
    return await db.delete(
      DatabaseTables.tableUsers,
      where: '${DatabaseTables.colUserId} = ?',
      whereArgs: [id],
    );
  }

  /// Returns total number of registered users.
  Future<int> getUsersCount() async {
    final db = await _db;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseTables.tableUsers}'),
    );
    return count ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Serialization Helpers
  // ---------------------------------------------------------------------------
  Map<String, dynamic> _userToRow(AuthUser user) {
    return {
      DatabaseTables.colUserId: user.id,
      DatabaseTables.colUserName: user.name,
      DatabaseTables.colUserPhone: user.phone,
      DatabaseTables.colUserCountryCode: user.countryCode,
      DatabaseTables.colUserPassword: user.password,
      DatabaseTables.colUserRole: user.role.name,
      DatabaseTables.colUserAccountType: user.accountType,
      DatabaseTables.colUserVerificationStatus: user.verificationStatus.name,
      DatabaseTables.colUserIsPhoneVerified: user.isPhoneVerified ? 1 : 0,
      DatabaseTables.colUserCreatedAt: user.createdAt.toIso8601String(),
      DatabaseTables.colUserIdentityJson:
          user.identityData != null ? jsonEncode(_identityToJson(user.identityData!)) : null,
      DatabaseTables.colUserOfficeJson:
          user.officeData != null ? jsonEncode(_officeToJson(user.officeData!)) : null,
      DatabaseTables.colUserDriverJson:
          user.driverData != null ? jsonEncode(_driverToJson(user.driverData!)) : null,
    };
  }

  AuthUser _rowToUser(Map<String, dynamic> row) {
    final roleName = row[DatabaseTables.colUserRole] as String;
    final role = AuthUserRole.values.firstWhere(
      (r) => r.name == roleName,
      orElse: () => AuthUserRole.client,
    );

    final statusName = row[DatabaseTables.colUserVerificationStatus] as String;
    final verificationStatus = AccountVerificationStatus.values.firstWhere(
      (s) => s.name == statusName,
      orElse: () => AccountVerificationStatus.unverified,
    );

    ClientIdentityData? identityData;
    if (row[DatabaseTables.colUserIdentityJson] != null) {
      try {
        final decoded = jsonDecode(row[DatabaseTables.colUserIdentityJson] as String);
        identityData = _identityFromJson(decoded as Map<String, dynamic>);
      } catch (_) {}
    }

    OfficeEnterpriseData? officeData;
    if (row[DatabaseTables.colUserOfficeJson] != null) {
      try {
        final decoded = jsonDecode(row[DatabaseTables.colUserOfficeJson] as String);
        officeData = _officeFromJson(decoded as Map<String, dynamic>);
      } catch (_) {}
    }

    DriverVerificationData? driverData;
    if (row[DatabaseTables.colUserDriverJson] != null) {
      try {
        final decoded = jsonDecode(row[DatabaseTables.colUserDriverJson] as String);
        driverData = _driverFromJson(decoded as Map<String, dynamic>);
      } catch (_) {}
    }

    return AuthUser(
      id: row[DatabaseTables.colUserId] as String,
      name: row[DatabaseTables.colUserName] as String,
      phone: row[DatabaseTables.colUserPhone] as String,
      countryCode: row[DatabaseTables.colUserCountryCode] as String? ?? '+967',
      password: row[DatabaseTables.colUserPassword] as String,
      role: role,
      accountType: row[DatabaseTables.colUserAccountType] as String? ?? 'شخصي',
      verificationStatus: verificationStatus,
      isPhoneVerified: (row[DatabaseTables.colUserIsPhoneVerified] as int? ?? 1) == 1,
      createdAt: DateTime.tryParse(row[DatabaseTables.colUserCreatedAt] as String) ??
          DateTime.now(),
      identityData: identityData,
      officeData: officeData,
      driverData: driverData,
    );
  }

  Map<String, dynamic> _identityToJson(ClientIdentityData data) => {
        'fullName': data.fullName,
        'nationality': data.nationality,
        'idType': data.idType,
        'idNumber': data.idNumber,
        'issuePlace': data.issuePlace,
        'issueDate': data.issueDate,
        'expiryDate': data.expiryDate,
        'birthPlace': data.birthPlace,
        'birthDate': data.birthDate,
        'frontPhotoPath': data.frontPhotoPath,
        'backPhotoPath': data.backPhotoPath,
        'personalPhotoPath': data.personalPhotoPath,
        'selfiePhotoPath': data.selfiePhotoPath,
        'submittedAt': data.submittedAt.toIso8601String(),
      };

  ClientIdentityData _identityFromJson(Map<String, dynamic> json) => ClientIdentityData(
        fullName: json['fullName'] as String? ?? '',
        nationality: json['nationality'] as String? ?? 'يمني',
        idType: json['idType'] as String? ?? 'بطاقة شخصية',
        idNumber: json['idNumber'] as String? ?? '',
        issuePlace: json['issuePlace'] as String? ?? '',
        issueDate: json['issueDate'] as String? ?? '',
        expiryDate: json['expiryDate'] as String?,
        birthPlace: json['birthPlace'] as String? ?? '',
        birthDate: json['birthDate'] as String? ?? '',
        frontPhotoPath: json['frontPhotoPath'] as String?,
        backPhotoPath: json['backPhotoPath'] as String?,
        personalPhotoPath: json['personalPhotoPath'] as String?,
        selfiePhotoPath: json['selfiePhotoPath'] as String?,
        submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> _officeToJson(OfficeEnterpriseData data) => {
        'officeName': data.officeName,
        'activityType': data.activityType,
        'crNumber': data.crNumber,
        'crIssuer': data.crIssuer,
        'crIssueDate': data.crIssueDate,
        'crExpiryDate': data.crExpiryDate,
        'address': data.address,
        'city': data.city,
        'region': data.region,
        'businessDescription': data.businessDescription,
        'logoPath': data.logoPath,
        'crPhotoPath': data.crPhotoPath,
        'fleetCount': data.fleetCount,
        'submittedAt': data.submittedAt?.toIso8601String(),
      };

  OfficeEnterpriseData _officeFromJson(Map<String, dynamic> json) => OfficeEnterpriseData(
        officeName: json['officeName'] as String? ?? '',
        activityType: json['activityType'] as String? ?? 'مكتب نقل معتمد',
        crNumber: json['crNumber'] as String? ?? '',
        crIssuer: json['crIssuer'] as String? ?? '',
        crIssueDate: json['crIssueDate'] as String?,
        crExpiryDate: json['crExpiryDate'] as String?,
        address: json['address'] as String? ?? '',
        city: json['city'] as String?,
        region: json['region'] as String?,
        businessDescription: json['businessDescription'] as String?,
        logoPath: json['logoPath'] as String?,
        crPhotoPath: json['crPhotoPath'] as String?,
        fleetCount: json['fleetCount'] as int? ?? 18,
        submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? ''),
      );

  Map<String, dynamic> _driverToJson(DriverVerificationData data) => {
        'licenseNumber': data.licenseData?.licenseNumber,
        'vehicleType': data.vehicleData?.vehicleType,
        'plateNumber': data.vehicleData?.plateNumber,
        'submittedAt': data.submittedAt.toIso8601String(),
      };

  DriverVerificationData _driverFromJson(Map<String, dynamic> json) => DriverVerificationData(
        identityData: null,
        licenseData: DriverLicenseData(
          licenseNumber: json['licenseNumber'] as String? ?? '',
          licenseType: 'نقل ثقيل عمومي',
          issuePlace: 'صنعاء',
          issueDate: '2020-01-01',
          expiryDate: '2030-01-01',
          submittedAt: DateTime.now(),
        ),
        vehicleData: DriverVehicleData(
          vehicleType: json['vehicleType'] as String? ?? 'تريلا جوانب',
          plateNumber: json['plateNumber'] as String? ?? '',
          manufactureYear: '2021',
          maxCapacityTons: 25.0,
          submittedAt: DateTime.now(),
        ),
        submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? '') ?? DateTime.now(),
      );
}
