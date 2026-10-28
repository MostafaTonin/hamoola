import 'package:flutter/foundation.dart';

import 'cargo_card_item.dart';
import 'merchant_order.dart';

/// Domain model and in-memory state for the Merchant Profile
class MerchantProfile with ChangeNotifier {
  String companyName;
  String contactName;
  String accountType;
  bool isVerified;
  String accountNumber;
  String phoneNumber;
  String email;
  String address;
  String avatarPath;
  int completedTrips;

  MerchantProfile({
    this.companyName = 'مؤسسة النور للتجارة العامة',
    this.contactName = 'محمد أحمد',
    this.accountType = 'حساب تجاري',
    this.isVerified = true,
    this.accountNumber = '783707104',
    this.phoneNumber = '+967 777 123 456',
    this.email = 'info@alnoortrading.com',
    this.address = 'صنعاء، شارع الزبيري - المركز التجاري',
    this.avatarPath = 'assets/images/merchant_company_logo.png',
    this.completedTrips = 24,
  });

  /// Dynamic metrics calculated from simulation dataset
  int get registeredCargosCount {
    final baseCount = CargoCardItem.demoCargos.length;
    // Base simulation offset for active merchant prototype demonstration
    return baseCount > 0 ? baseCount + 9 : 12;
  }

  int get activeOrdersCount {
    final active = MerchantOrder.demoOrders
        .where((o) => o.status != MerchantOrderStatus.completed)
        .length;
    return active > 0 ? active + 6 : 8;
  }

  int get completedTripsCount => completedTrips;

  void updateProfile({
    String? companyName,
    String? contactName,
    String? email,
    String? phoneNumber,
    String? address,
    String? avatarPath,
    bool? isVerified,
  }) {
    if (companyName != null && companyName.trim().isNotEmpty) {
      this.companyName = companyName.trim();
    }
    if (contactName != null && contactName.trim().isNotEmpty) {
      this.contactName = contactName.trim();
    }
    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      this.phoneNumber = phoneNumber.trim();
    }
    if (email != null && email.trim().isNotEmpty) {
      this.email = email.trim();
    }
    if (address != null && address.trim().isNotEmpty) {
      this.address = address.trim();
    }
    if (avatarPath != null && avatarPath.trim().isNotEmpty) {
      this.avatarPath = avatarPath.trim();
    }
    if (isVerified != null) {
      this.isVerified = isVerified;
    }
    notifyListeners();
  }

  void updateCompanyDetails({String? companyName, String? contactName}) {
    updateProfile(companyName: companyName, contactName: contactName);
  }

  static final MerchantProfile instance = MerchantProfile();
}
