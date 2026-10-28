import 'package:flutter/foundation.dart';
import '../../../../features/common/domain/models/app_notification.dart';

/// Status of endorsement for a driver relative to an office.
enum DriverEndorsementStatus {
  none, // Not endorsed by this office
  endorsed, // Currently endorsed (مزكّى)
  cancelled, // Endorsement was previously cancelled by this office
}

/// Information about an office that endorses a driver.
class EndorsingOfficeInfo {
  final String officeId;
  final String officeName;
  final String officeLogo;

  const EndorsingOfficeInfo({
    required this.officeId,
    required this.officeName,
    this.officeLogo = 'assets/images/merchant_company_logo.png',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EndorsingOfficeInfo &&
          runtimeType == other.runtimeType &&
          officeId == other.officeId;

  @override
  int get hashCode => officeId.hashCode;
}

/// Model representing a driver within the Transport Office endorsement ecosystem.
class EndorsedDriver {
  final String id;
  final String name;
  final String accountNumber;
  final String city;
  final String avatarAsset;
  final DriverEndorsementStatus status;
  final List<EndorsingOfficeInfo> endorsingOffices;
  final String phone;

  const EndorsedDriver({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.city,
    required this.avatarAsset,
    this.status = DriverEndorsementStatus.none,
    this.endorsingOffices = const [],
    this.phone = '771000000',
  });

  int get totalEndorsingOfficesCount => endorsingOffices.length;

  EndorsedDriver copyWith({
    String? id,
    String? name,
    String? accountNumber,
    String? city,
    String? avatarAsset,
    DriverEndorsementStatus? status,
    List<EndorsingOfficeInfo>? endorsingOffices,
    String? phone,
  }) {
    return EndorsedDriver(
      id: id ?? this.id,
      name: name ?? this.name,
      accountNumber: accountNumber ?? this.accountNumber,
      city: city ?? this.city,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      status: status ?? this.status,
      endorsingOffices: endorsingOffices ?? this.endorsingOffices,
      phone: phone ?? this.phone,
    );
  }
}

/// Central store managing driver endorsements, cancellations, notifications, and real-time synchronization.
class TransportOfficeDriversStore extends ChangeNotifier {
  static final TransportOfficeDriversStore instance = TransportOfficeDriversStore._internal();

  TransportOfficeDriversStore._internal() {
    _initializeDefaultData();
  }

  static const String currentOfficeId = 'OFFICE-01';
  static const String currentOfficeName = 'مكتب النور للنقل السريع';
  static const String currentOfficeLogo = 'assets/images/merchant_company_logo.png';

  final List<EndorsedDriver> _allDrivers = [];
  final List<AppNotification> _notifications = [];

  // Expose unmodifiable notifications
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  void _initializeDefaultData() {
    _allDrivers.clear();
    _notifications.clear();

    const currentOffice = EndorsingOfficeInfo(
      officeId: currentOfficeId,
      officeName: currentOfficeName,
      officeLogo: currentOfficeLogo,
    );

    const otherOffice1 = EndorsingOfficeInfo(
      officeId: 'OFFICE-02',
      officeName: 'مكتب الوفاق للنقل',
      officeLogo: 'assets/images/merchant_company_logo.png',
    );

    const otherOffice2 = EndorsingOfficeInfo(
      officeId: 'OFFICE-03',
      officeName: 'مكتب الجزيرة للنقل البري',
      officeLogo: 'assets/images/merchant_company_logo.png',
    );

    // Initial 4 endorsed drivers matching Image 1
    _allDrivers.addAll([
      const EndorsedDriver(
        id: 'DRV-101',
        name: 'أحمد محمد',
        accountNumber: '10482',
        city: 'صنعاء',
        avatarAsset: 'assets/images/driver_ahmed_avatar.jpg',
        status: DriverEndorsementStatus.endorsed,
        endorsingOffices: [currentOffice, otherOffice1],
        phone: '771234567',
      ),
      const EndorsedDriver(
        id: 'DRV-102',
        name: 'محمد عبدالله',
        accountNumber: '10735',
        city: 'تعز',
        avatarAsset: 'assets/images/avatar_personal_preview.jpg',
        status: DriverEndorsementStatus.endorsed,
        endorsingOffices: [currentOffice, otherOffice2],
        phone: '772345678',
      ),
      const EndorsedDriver(
        id: 'DRV-103',
        name: 'سالم علي',
        accountNumber: '11290',
        city: 'عدن',
        avatarAsset: 'assets/images/id_selfie_preview.jpg',
        status: DriverEndorsementStatus.endorsed,
        endorsingOffices: [currentOffice],
        phone: '773456789',
      ),
      const EndorsedDriver(
        id: 'DRV-104',
        name: 'خالد صالح',
        accountNumber: '11845',
        city: 'الحديدة',
        avatarAsset: 'assets/images/driver_ahmed_avatar.jpg',
        status: DriverEndorsementStatus.endorsed,
        endorsingOffices: [currentOffice, otherOffice1, otherOffice2],
        phone: '774567890',
      ),
      // Drivers available for endorsement search matching Image 2
      const EndorsedDriver(
        id: 'DRV-201',
        name: 'ناصر حسين',
        accountNumber: '12567',
        city: 'إب',
        avatarAsset: 'assets/images/avatar_personal_preview.jpg',
        status: DriverEndorsementStatus.none,
        endorsingOffices: [otherOffice1],
        phone: '775678901',
      ),
      const EndorsedDriver(
        id: 'DRV-202',
        name: 'ناصر محمد',
        accountNumber: '13021',
        city: 'صنعاء',
        avatarAsset: 'assets/images/driver_ahmed_avatar.jpg',
        status: DriverEndorsementStatus.none,
        endorsingOffices: [],
        phone: '776789012',
      ),
      const EndorsedDriver(
        id: 'DRV-203',
        name: 'ناصر علي',
        accountNumber: '13876',
        city: 'تعز',
        avatarAsset: 'assets/images/id_selfie_preview.jpg',
        status: DriverEndorsementStatus.none,
        endorsingOffices: [otherOffice2],
        phone: '777890123',
      ),
      const EndorsedDriver(
        id: 'DRV-204',
        name: 'ناصر صالح',
        accountNumber: '14233',
        city: 'الحديدة',
        avatarAsset: 'assets/images/driver_ahmed_avatar.jpg',
        status: DriverEndorsementStatus.none,
        endorsingOffices: [],
        phone: '778901234',
      ),
      const EndorsedDriver(
        id: 'DRV-205',
        name: 'ناصر عبدالله',
        accountNumber: '14891',
        city: 'ذمار',
        avatarAsset: 'assets/images/avatar_personal_preview.jpg',
        status: DriverEndorsementStatus.none,
        endorsingOffices: [otherOffice1],
        phone: '779012345',
      ),
    ]);
  }

  /// Reset to clean default state (useful for test runs)
  void resetToDefault() {
    _initializeDefaultData();
    notifyListeners();
  }

  /// Returns only drivers who currently have an active endorsement from the current office.
  List<EndorsedDriver> get endorsedDrivers {
    return _allDrivers
        .where((d) => d.status == DriverEndorsementStatus.endorsed)
        .toList();
  }

  /// Find driver by ID
  EndorsedDriver? findDriverById(String driverId) {
    try {
      return _allDrivers.firstWhere((d) => d.id == driverId);
    } catch (_) {
      return null;
    }
  }

  /// Search drivers by name or account number across all registered drivers in Hamoola.
  List<EndorsedDriver> searchDrivers(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return List.unmodifiable(_allDrivers);
    }
    return _allDrivers.where((d) {
      final matchName = d.name.toLowerCase().contains(trimmed);
      final matchAccount = d.accountNumber.toLowerCase().contains(trimmed);
      return matchName || matchAccount;
    }).toList();
  }

  /// Filter currently endorsed drivers by search query (for Screen 1)
  List<EndorsedDriver> searchEndorsedDrivers(String query) {
    final active = endorsedDrivers;
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return active;
    return active.where((d) {
      final matchName = d.name.toLowerCase().contains(trimmed);
      final matchAccount = d.accountNumber.toLowerCase().contains(trimmed);
      return matchName || matchAccount;
    }).toList();
  }

  /// Endorse a driver by the current office.
  Future<bool> endorseDriver(String driverId, {bool simulateError = false}) async {
    if (simulateError) {
      return false;
    }

    final index = _allDrivers.indexWhere((d) => d.id == driverId);
    if (index == -1) return false;

    final driver = _allDrivers[index];
    if (driver.status == DriverEndorsementStatus.endorsed) {
      // Already endorsed, no duplicate
      return true;
    }

    const currentOffice = EndorsingOfficeInfo(
      officeId: currentOfficeId,
      officeName: currentOfficeName,
      officeLogo: currentOfficeLogo,
    );

    final updatedOffices = List<EndorsingOfficeInfo>.from(driver.endorsingOffices);
    if (!updatedOffices.contains(currentOffice)) {
      updatedOffices.add(currentOffice);
    }

    _allDrivers[index] = driver.copyWith(
      status: DriverEndorsementStatus.endorsed,
      endorsingOffices: updatedOffices,
    );

    // Push notification to the driver
    _notifications.insert(
      0,
      AppNotification(
        id: 'NTF-END-${DateTime.now().millisecondsSinceEpoch}',
        title: 'تزكية جديدة من مكتب نقل',
        body: 'قام $currentOfficeName بتزكيتك ككابتن نقل بري معتمد لديه.',
        category: NotificationCategory.system,
        timeAgo: 'الآن',
      ),
    );

    notifyListeners();
    return true;
  }

  /// Cancel endorsement for a driver by the current office.
  Future<bool> cancelEndorsement(String driverId, {bool simulateError = false}) async {
    if (simulateError) {
      return false;
    }

    final index = _allDrivers.indexWhere((d) => d.id == driverId);
    if (index == -1) return false;

    final driver = _allDrivers[index];
    if (driver.status != DriverEndorsementStatus.endorsed) {
      return true;
    }

    final updatedOffices = driver.endorsingOffices
        .where((o) => o.officeId != currentOfficeId)
        .toList();

    _allDrivers[index] = driver.copyWith(
      status: DriverEndorsementStatus.cancelled,
      endorsingOffices: updatedOffices,
    );

    // Push cancellation notification to driver
    _notifications.insert(
      0,
      AppNotification(
        id: 'NTF-CANCEL-${DateTime.now().millisecondsSinceEpoch}',
        title: 'إلغاء تزكية من مكتب نقل',
        body: 'قام $currentOfficeName بإلغاء التزكية من ملفك الشخصي.',
        category: NotificationCategory.system,
        timeAgo: 'الآن',
      ),
    );

    notifyListeners();
    return true;
  }

  /// Re-endorse a driver whose endorsement was previously cancelled.
  Future<bool> reEndorseDriver(String driverId, {bool simulateError = false}) async {
    return endorseDriver(driverId, simulateError: simulateError);
  }

  /// Retrieve all endorsing offices for a driver
  List<EndorsingOfficeInfo> getEndorsingOfficesForDriver(String driverId) {
    final driver = findDriverById(driverId);
    return driver?.endorsingOffices ?? const [];
  }
}
