import 'package:flutter/material.dart';

/// Available business and individual roles in the Hamula Platform
enum AuthUserRole {
  client, // عميل (أفراد ومواطنون لنقل الأثاث والمحاصيل والمواد دون سجل تجاري)
  driver, // سائق (كباتن النقل الثقيل والشاحنات)
  merchant, // تاجر (مؤسسات وأصحاب أنشطة تجارية)
  office, // مكتب نقل (مكاتب وشركات النقل والوساطة المعتمدة)
}

extension AuthUserRoleExtension on AuthUserRole {
  String get label {
    switch (this) {
      case AuthUserRole.client:
        return 'عميل';
      case AuthUserRole.driver:
        return 'سائق';
      case AuthUserRole.merchant:
        return 'تاجر';
      case AuthUserRole.office:
        return 'مكتب نقل';
    }
  }

  IconData get icon {
    switch (this) {
      case AuthUserRole.client:
        return Icons.person_outline_rounded;
      case AuthUserRole.driver:
        return Icons.local_shipping_outlined;
      case AuthUserRole.merchant:
        return Icons.storefront_outlined;
      case AuthUserRole.office:
        return Icons.apartment_outlined;
    }
  }

  String get description {
    switch (this) {
      case AuthUserRole.client:
        return 'طلب نقل أثاث، بضائع شخصية، منتجات زراعية أو مواد بناء';
      case AuthUserRole.driver:
        return 'تقديم خدمات النقل وقبول عروض الحمولات وتحقيق الدخل';
      case AuthUserRole.merchant:
        return 'إدارة ونقل شحنات المؤسسة والتجارة بعقود رسمية';
      case AuthUserRole.office:
        return 'إدارة أساطيل النقل وربط الحمولات بالشاحنات المعتمدة';
    }
  }
}

/// Official verification status of the account
enum AccountVerificationStatus {
  unverified, // غير موثق (الحالة الافتراضية لأي حساب جديد)
  pendingReview, // طلب التوثيق قيد المراجعة
  verified, // موثق ومعتمد
}

extension AccountVerificationStatusExtension on AccountVerificationStatus {
  String get label {
    switch (this) {
      case AccountVerificationStatus.unverified:
        return 'غير موثق';
      case AccountVerificationStatus.pendingReview:
        return 'قيد المراجعة';
      case AccountVerificationStatus.verified:
        return 'موثق ومعتمد';
    }
  }

  Color get color {
    switch (this) {
      case AccountVerificationStatus.unverified:
        return const Color(0xFF94A3B8); // Slate grey
      case AccountVerificationStatus.pendingReview:
        return const Color(0xFFF59E0B); // Amber
      case AccountVerificationStatus.verified:
        return const Color(0xFF10B981); // Emerald green
    }
  }
}

/// Model representing submitted client identity data
class ClientIdentityData {
  final String fullName;
  final String nationality;
  final String idType;
  final String idNumber;
  final String issuePlace;
  final String issueDate;
  final String? expiryDate;
  final String birthPlace;
  final String birthDate;
  final String? frontPhotoPath;
  final String? backPhotoPath;
  final String? personalPhotoPath;
  final String? selfiePhotoPath;
  final DateTime submittedAt;

  const ClientIdentityData({
    required this.fullName,
    this.nationality = 'اليمن',
    this.idType = 'بطاقة شخصية',
    required this.idNumber,
    required this.issuePlace,
    required this.issueDate,
    this.expiryDate,
    required this.birthPlace,
    required this.birthDate,
    this.frontPhotoPath,
    this.backPhotoPath,
    this.personalPhotoPath,
    this.selfiePhotoPath,
    required this.submittedAt,
  });

  ClientIdentityData copyWith({
    String? fullName,
    String? nationality,
    String? idType,
    String? idNumber,
    String? issuePlace,
    String? issueDate,
    String? expiryDate,
    String? birthPlace,
    String? birthDate,
    String? frontPhotoPath,
    String? backPhotoPath,
    String? personalPhotoPath,
    String? selfiePhotoPath,
    DateTime? submittedAt,
  }) {
    return ClientIdentityData(
      fullName: fullName ?? this.fullName,
      nationality: nationality ?? this.nationality,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      issuePlace: issuePlace ?? this.issuePlace,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      birthPlace: birthPlace ?? this.birthPlace,
      birthDate: birthDate ?? this.birthDate,
      frontPhotoPath: frontPhotoPath ?? this.frontPhotoPath,
      backPhotoPath: backPhotoPath ?? this.backPhotoPath,
      personalPhotoPath: personalPhotoPath ?? this.personalPhotoPath,
      selfiePhotoPath: selfiePhotoPath ?? this.selfiePhotoPath,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}

/// Model representing driver's license details
class DriverLicenseData {
  final String licenseNumber;
  final String licenseCategory; // نقل ثقيل (شاحنات وقاطرات)، نقل متوسط، عمومي، خصوصي
  final String issuePlace;
  final String issueDate;
  final String expiryDate;
  final String? frontPhotoPath;
  final String? backPhotoPath;

  const DriverLicenseData({
    required this.licenseNumber,
    required this.licenseCategory,
    required this.issuePlace,
    required this.issueDate,
    required this.expiryDate,
    this.frontPhotoPath,
    this.backPhotoPath,
  });

  DriverLicenseData copyWith({
    String? licenseNumber,
    String? licenseCategory,
    String? issuePlace,
    String? issueDate,
    String? expiryDate,
    String? frontPhotoPath,
    String? backPhotoPath,
  }) {
    return DriverLicenseData(
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseCategory: licenseCategory ?? this.licenseCategory,
      issuePlace: issuePlace ?? this.issuePlace,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      frontPhotoPath: frontPhotoPath ?? this.frontPhotoPath,
      backPhotoPath: backPhotoPath ?? this.backPhotoPath,
    );
  }
}

/// Model representing transporter vehicle details
class DriverVehicleData {
  final String vehicleType; // شاحنة نقل، قاطرة مع مقطورة، دينا، شاحنة تبريد، قلاب، ناقلة أخرى
  final String category; // نقل ثقيل، نقل متوسط
  final String manufacturer; // مرسيدس، مان، فولفو، إيسوزو
  final String model; // أكتروس، FH، إلخ
  final String year; // 2023
  final String plateNumber; // 7198 د ح ي
  final String color; // أبيض
  final String maxCapacity; // 25
  final String capacityUnit; // طن
  final String bodyType; // صندوق مغلق، جوانب، سطحة، تبريد، قلاب، صهريج
  final String? volume; // 65 م³
  final int? trailersCount;
  final String? frontPhotoPath;
  final String? backPhotoPath;
  final String? sidePhotoPath;
  final String? platePhotoPath;
  final String? documentsPhotoPath;
  final List<String> cargoTypes;
  final List<String> serviceAreas;
  final String? operatingNotes;

  const DriverVehicleData({
    required this.vehicleType,
    required this.category,
    required this.manufacturer,
    required this.model,
    required this.year,
    required this.plateNumber,
    required this.color,
    required this.maxCapacity,
    this.capacityUnit = 'طن',
    required this.bodyType,
    this.volume,
    this.trailersCount,
    this.frontPhotoPath,
    this.backPhotoPath,
    this.sidePhotoPath,
    this.platePhotoPath,
    this.documentsPhotoPath,
    this.cargoTypes = const ['بضائع عامة', 'أثاث وعفش', 'مواد بناء', 'محاصيل زراعية'],
    this.serviceAreas = const ['صنعاء', 'عدن', 'تعز', 'الحديدة', 'حضرموت'],
    this.operatingNotes,
  });

  DriverVehicleData copyWith({
    String? vehicleType,
    String? category,
    String? manufacturer,
    String? model,
    String? year,
    String? plateNumber,
    String? color,
    String? maxCapacity,
    String? capacityUnit,
    String? bodyType,
    String? volume,
    int? trailersCount,
    String? frontPhotoPath,
    String? backPhotoPath,
    String? sidePhotoPath,
    String? platePhotoPath,
    String? documentsPhotoPath,
    List<String>? cargoTypes,
    List<String>? serviceAreas,
    String? operatingNotes,
  }) {
    return DriverVehicleData(
      vehicleType: vehicleType ?? this.vehicleType,
      category: category ?? this.category,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      year: year ?? this.year,
      plateNumber: plateNumber ?? this.plateNumber,
      color: color ?? this.color,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      capacityUnit: capacityUnit ?? this.capacityUnit,
      bodyType: bodyType ?? this.bodyType,
      volume: volume ?? this.volume,
      trailersCount: trailersCount ?? this.trailersCount,
      frontPhotoPath: frontPhotoPath ?? this.frontPhotoPath,
      backPhotoPath: backPhotoPath ?? this.backPhotoPath,
      sidePhotoPath: sidePhotoPath ?? this.sidePhotoPath,
      platePhotoPath: platePhotoPath ?? this.platePhotoPath,
      documentsPhotoPath: documentsPhotoPath ?? this.documentsPhotoPath,
      cargoTypes: cargoTypes ?? this.cargoTypes,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      operatingNotes: operatingNotes ?? this.operatingNotes,
    );
  }
}

/// Container representing the full driver verification submission
class DriverVerificationData {
  final ClientIdentityData? identityData;
  final DriverLicenseData? licenseData;
  final DriverVehicleData? vehicleData;
  final DateTime submittedAt;

  const DriverVerificationData({
    this.identityData,
    this.licenseData,
    this.vehicleData,
    required this.submittedAt,
  });

  DriverVerificationData copyWith({
    ClientIdentityData? identityData,
    DriverLicenseData? licenseData,
    DriverVehicleData? vehicleData,
    DateTime? submittedAt,
  }) {
    return DriverVerificationData(
      identityData: identityData ?? this.identityData,
      licenseData: licenseData ?? this.licenseData,
      vehicleData: vehicleData ?? this.vehicleData,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}

/// Model representing merchant enterprise and commercial register verification data
class MerchantEnterpriseData {
  final String enterpriseName; // اسم المنشأة أو النشاط التجاري
  final String businessType; // نوع النشاط التجاري
  final String crNumber; // رقم السجل التجاري
  final String crIssuer; // جهة إصدار السجل التجاري
  final String? crIssueDate; // تاريخ إصدار السجل التجاري
  final String? crExpiryDate; // تاريخ انتهاء السجل التجاري
  final String address; // عنوان المنشأة أو موقعها
  final String? businessDescription; // وصف مختصر للنشاط
  final String? crPhotoPath; // صورة السجل التجاري
  final String? frontIdPath; // صورة الهوية من الأمام
  final String? backIdPath; // صورة الهوية من الخلف
  final String? selfieIdPath; // صورة شخصية مع الهوية
  final String? taxCardPath; // صورة البطاقة الضريبية أو ترخيص
  final DateTime submittedAt;

  const MerchantEnterpriseData({
    required this.enterpriseName,
    this.businessType = 'تجارة جملة وتجزئة',
    this.crNumber = '10294812',
    this.crIssuer = 'وزارة الصناعة والتجارة',
    this.crIssueDate,
    this.crExpiryDate,
    this.address = 'صنعاء',
    this.businessDescription,
    this.crPhotoPath,
    this.frontIdPath,
    this.backIdPath,
    this.selfieIdPath,
    this.taxCardPath,
    required this.submittedAt,
  });

  MerchantEnterpriseData copyWith({
    String? enterpriseName,
    String? businessType,
    String? crNumber,
    String? crIssuer,
    String? crIssueDate,
    String? crExpiryDate,
    String? address,
    String? businessDescription,
    String? crPhotoPath,
    String? frontIdPath,
    String? backIdPath,
    String? selfieIdPath,
    String? taxCardPath,
    DateTime? submittedAt,
  }) {
    return MerchantEnterpriseData(
      enterpriseName: enterpriseName ?? this.enterpriseName,
      businessType: businessType ?? this.businessType,
      crNumber: crNumber ?? this.crNumber,
      crIssuer: crIssuer ?? this.crIssuer,
      crIssueDate: crIssueDate ?? this.crIssueDate,
      crExpiryDate: crExpiryDate ?? this.crExpiryDate,
      address: address ?? this.address,
      businessDescription: businessDescription ?? this.businessDescription,
      crPhotoPath: crPhotoPath ?? this.crPhotoPath,
      frontIdPath: frontIdPath ?? this.frontIdPath,
      backIdPath: backIdPath ?? this.backIdPath,
      selfieIdPath: selfieIdPath ?? this.selfieIdPath,
      taxCardPath: taxCardPath ?? this.taxCardPath,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}

/// Model representing transport office enterprise and commercial register verification data
class OfficeEnterpriseData {
  final String officeName; // اسم مكتب النقل التجاري
  final String activityType; // نوع نشاط المكتب (نقل ثقيل وبضائع، وساطة لوجستية، شحن وتوزيع)
  final String crNumber; // رقم السجل التجاري
  final String crIssuer; // جهة إصدار السجل التجاري
  final String? crIssueDate; // تاريخ إصدار السجل التجاري
  final String? crExpiryDate; // تاريخ انتهاء السجل التجاري
  final String address; // عنوان مقر المكتب
  final String? city; // المدينة / المحافظة
  final String? region; // المنطقة
  final String? businessDescription; // وصف مختصر لخدمات المكتب
  final String? logoPath; // شعار أو أيقونة المكتب
  final String? crPhotoPath; // صورة السجل التجاري
  final String? frontIdPath; // صورة الهوية من الأمام
  final String? backIdPath; // صورة الهوية من الخلف
  final String? selfieIdPath; // صورة شخصية مع الهوية
  final String? taxCardPath; // صورة البطاقة الضريبية أو ترخيص النقل
  final int fleetCount; // عدد أسطول الشاحنات التابع للمكتب
  final DateTime? submittedAt;

  const OfficeEnterpriseData({
    required this.officeName,
    this.activityType = 'نقل ثقيل وبضائع بين المحافظات',
    this.crNumber = 'CR-7729104',
    this.crIssuer = 'وزارة الصناعة والتجارة - مكتب النقل',
    this.crIssueDate,
    this.crExpiryDate,
    this.address = 'صنعاء - شارع تعز - جولة 45',
    this.city = 'صنعاء',
    this.region = 'أمانة العاصمة',
    this.businessDescription = 'خدمات شحن ونقل بضائع وتأجير شاحنات وقاطرات لجميع المحافظات',
    this.logoPath,
    this.crPhotoPath,
    this.frontIdPath,
    this.backIdPath,
    this.selfieIdPath,
    this.taxCardPath,
    this.fleetCount = 18,
    this.submittedAt,
  });

  OfficeEnterpriseData copyWith({
    String? officeName,
    String? activityType,
    String? crNumber,
    String? crIssuer,
    String? crIssueDate,
    String? crExpiryDate,
    String? address,
    String? city,
    String? region,
    String? businessDescription,
    String? logoPath,
    String? crPhotoPath,
    String? frontIdPath,
    String? backIdPath,
    String? selfieIdPath,
    String? taxCardPath,
    int? fleetCount,
    DateTime? submittedAt,
  }) {
    return OfficeEnterpriseData(
      officeName: officeName ?? this.officeName,
      activityType: activityType ?? this.activityType,
      crNumber: crNumber ?? this.crNumber,
      crIssuer: crIssuer ?? this.crIssuer,
      crIssueDate: crIssueDate ?? this.crIssueDate,
      crExpiryDate: crExpiryDate ?? this.crExpiryDate,
      address: address ?? this.address,
      city: city ?? this.city,
      region: region ?? this.region,
      businessDescription: businessDescription ?? this.businessDescription,
      logoPath: logoPath ?? this.logoPath,
      crPhotoPath: crPhotoPath ?? this.crPhotoPath,
      frontIdPath: frontIdPath ?? this.frontIdPath,
      backIdPath: backIdPath ?? this.backIdPath,
      selfieIdPath: selfieIdPath ?? this.selfieIdPath,
      taxCardPath: taxCardPath ?? this.taxCardPath,
      fleetCount: fleetCount ?? this.fleetCount,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}

/// Model representing an authenticated or simulated user in Hamula
class AuthUser {
  final String id;
  final String name;
  final String phone;
  final String countryCode;
  final String password;
  final AuthUserRole role;
  final AccountVerificationStatus verificationStatus;
  final bool isPhoneVerified;
  final DateTime createdAt;
  final ClientIdentityData? identityData;
  final DriverVerificationData? driverData;
  final MerchantEnterpriseData? merchantData;
  final OfficeEnterpriseData? officeData;
  final String accountType;
  final bool isDriverAvailable;

  const AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    this.countryCode = '+967',
    required this.password,
    required this.role,
    this.verificationStatus = AccountVerificationStatus.unverified,
    this.isPhoneVerified = false,
    required this.createdAt,
    this.accountType = 'شخصي',
    this.identityData,
    this.driverData,
    this.merchantData,
    this.officeData,
    this.isDriverAvailable = true,
  });

  String get fullPhoneNumber => '$countryCode $phone';
  String get fullName => name;
  String get displayName => name.split(' ').first;

  AuthUser copyWith({
    String? id,
    String? name,
    String? phone,
    String? countryCode,
    String? password,
    AuthUserRole? role,
    AccountVerificationStatus? verificationStatus,
    bool? isPhoneVerified,
    DateTime? createdAt,
    String? accountType,
    ClientIdentityData? identityData,
    DriverVerificationData? driverData,
    MerchantEnterpriseData? merchantData,
    OfficeEnterpriseData? officeData,
    bool? isDriverAvailable,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      password: password ?? this.password,
      role: role ?? this.role,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      accountType: accountType ?? this.accountType,
      identityData: identityData ?? this.identityData,
      driverData: driverData ?? this.driverData,
      merchantData: merchantData ?? this.merchantData,
      officeData: officeData ?? this.officeData,
      isDriverAvailable: isDriverAvailable ?? this.isDriverAvailable,
    );
  }
}
