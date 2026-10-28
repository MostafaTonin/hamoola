import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/models/auth_simulation_store.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../../auth/presentation/widgets/biometric_modal_sheet.dart';
import '../../../auth/presentation/widgets/toll_free_dialer_modal_sheet.dart';
import '../../domain/models/transport_office_trips_store.dart';
import '../widgets/office_verification_details_sheet.dart';

/// Transport Office "My Account" (حسابي) Screen:
/// - Exact visual fidelity matching the reference image.
/// - Clear corporate identity (Enterprise Name, Subtitle, Verified Badge).
/// - Contact & Manager Info row with phone and copyable Manager ID.
/// - Full-width "تعديل الملف الشخصي" (Edit Profile) button.
/// - 4 interactive stats cards (الرحلات المنجزة, طلبات نشطة, رحلة مكتملة, التقييم العام).
/// - Accordion 1: "بيانات المكتب" (تحديث السجل التجاري, تحديث بيانات التواصل والموقع).
/// - Standalone Option: "تحديث ملف المسؤول" (Separated personal identity vs commercial data).
/// - Accordion 2: "الأمان والخصوصية" (رمز التحقق, كلمة المرور, بصمة الدخول, بصمة الدفع, الشروط, الخصوصية).
/// - Section: "الدعم والمساعدة" (خدمة العملاء, مواقع التواصل, الرقم المجاني, نقاط الخدمة).
/// - Section: "إعدادات التطبيق" (اللغة, المظهر, إعدادات الإشعارات).
/// - Danger Option: "طلب حذف الحساب" with confirmation & compliance check.
/// - Red Tinted Action: "تسجيل الخروج من الحساب" with confirmation dialog and clean session clearance.
/// - 5-Item Bottom Navigation Bar matching the app with central red (+) FAB and active "حسابي" tab.
class TransportOfficeAccountScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onVerifyNow;
  final VoidCallback? onLogout;
  final VoidCallback? onSupport;
  final VoidCallback? onTerms;

  const TransportOfficeAccountScreen({
    super.key,
    this.onBack,
    this.onVerifyNow,
    this.onLogout,
    this.onSupport,
    this.onTerms,
  });

  @override
  State<TransportOfficeAccountScreen> createState() =>
      _TransportOfficeAccountScreenState();
}

class _TransportOfficeAccountScreenState
    extends State<TransportOfficeAccountScreen>
    with SingleTickerProviderStateMixin {
  // Accordion expansion states
  bool _isOfficeDataExpanded = true;
  bool _isSecurityExpanded = true;
  bool _isSupportExpanded = true;
  bool _isSettingsExpanded = true;

  // Biometrics & Notification toggles
  bool _useBiometricsLogin = true;
  bool _useBiometricsPayment = false;
  bool _notifyNewOrders = true;
  bool _notifyTripUpdates = true;
  bool _notifyWalletTransactions = true;
  bool _notifyMarketing = false;

  // FAB animation controller for rotating + to ×
  late final AnimationController _fabAnimController;
  bool _isFabSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    AuthSimulationStore.instance.addListener(_onAuthStoreChanged);
    TransportOfficeTripsStore.instance.addListener(_onTripsStoreChanged);
  }

  @override
  void dispose() {
    AuthSimulationStore.instance.removeListener(_onAuthStoreChanged);
    TransportOfficeTripsStore.instance.removeListener(_onTripsStoreChanged);
    _fabAnimController.dispose();
    super.dispose();
  }

  void _onAuthStoreChanged() {
    if (mounted) setState(() {});
  }

  void _onTripsStoreChanged() {
    if (mounted) setState(() {});
  }

  AuthUser get _officeUser {
    final store = AuthSimulationStore.instance;
    final current = store.currentUser;
    if (current != null && current.role == AuthUserRole.office) {
      return current;
    }
    return store.getDemoUserByRole(AuthUserRole.office) ??
        AuthUser(
          id: 'USR-OFFICE-01',
          name: 'صالح مسعد العمري',
          phone: '774567890',
          password: 'password123',
          role: AuthUserRole.office,
          verificationStatus: AccountVerificationStatus.verified,
          createdAt: DateTime(2026, 7, 10),
          officeData: const OfficeEnterpriseData(
            officeName: 'مكتب النقل السريع',
            activityType: 'مكتب نقل معتمد',
            crNumber: 'CR-7729104',
            crIssuer: 'وزارة الصناعة والتجارة - مكتب النقل',
            crIssueDate: '2021-06-15',
            crExpiryDate: '2027-06-14',
            address: 'صنعاء - شارع تعز - جولة 45',
            city: 'صنعاء',
            region: 'أمانة العاصمة',
            fleetCount: 18,
          ),
          identityData: ClientIdentityData(
            fullName: 'صالح مسعد العمري',
            idNumber: '987654321',
            issuePlace: 'صنعاء - السبعين',
            issueDate: '2018-09-10',
            birthPlace: 'صنعاء',
            birthDate: '1982-11-04',
            submittedAt: DateTime(2026, 7, 10),
          ),
        );
  }

  // Stats calculation
  int get _completedTripsCount {
    final trips = TransportOfficeTripsStore.instance.allTrips;
    final inStore = trips.where((t) => t.status == OfficeTripStatus.completed).length;
    return inStore > 0 ? inStore + 120 : 128; // Dynamic base matching screenshot 128
  }

  int get _activeOrdersCount => 5; // Matches screenshot: 5 طلبات نشطة
  int get _availableOrdersCount => 96; // Matches screenshot: 96
  double get _generalRating => 4.8; // Matches screenshot: 4.8

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = _officeUser;
    final officeData = user.officeData;
    final identityData = user.identityData;

    final managerName = identityData?.fullName ?? user.name;
    final officeName = officeData?.officeName ?? 'مكتب النقل السريع';
    final activityType = officeData?.activityType ?? 'مكتب نقل معتمد';
    final managerPhone = user.phone.startsWith('+967')
        ? user.phone
        : '+967 ${user.phone.replaceFirst(RegExp(r'^0'), '')}';
    final managerId = identityData?.idNumber ?? '987654321';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          elevation: 0.5,
          leading: IconButton(
            key: const Key('account_appbar_settings_btn'),
            icon: const Icon(Icons.settings_outlined, size: 23.0),
            tooltip: 'إعدادات التطبيق',
            onPressed: _openAppSettingsSheet,
          ),
          title: Text(
            'حسابي',
            style: GoogleFonts.cairo(
              fontSize: 18.0,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              key: const Key('account_appbar_back_btn'),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20.0),
              tooltip: 'رجوع',
              onPressed: widget.onBack ?? () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.transportOfficeHome);
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            children: [
              // 1. Office Profile Card
              _buildOfficeProfileCard(
                officeName: officeName,
                activityType: activityType,
                managerPhone: managerPhone,
                managerId: managerId,
                user: user,
                isDark: isDark,
              ),
              const SizedBox(height: 14.0),

              // 2. 4 Stats Cards Row
              _buildStatsRow(isDark),
              const SizedBox(height: 14.0),

              // 3. Section «بيانات المكتب» (Office Data Accordion)
              _buildOfficeDataAccordion(isDark, user),
              const SizedBox(height: 12.0),

              // 4. Standalone Option «تحديث ملف المسؤول» (Manager Profile Update)
              _buildManagerProfileCard(isDark, managerName, user),
              const SizedBox(height: 12.0),

              // 5. Section «الأمان والخصوصية» (Security & Privacy Accordion)
              _buildSecurityAccordion(isDark),
              const SizedBox(height: 12.0),

              // 6. Section «الدعم والمساعدة» (Support & Assistance)
              _buildSupportAccordion(isDark),
              const SizedBox(height: 12.0),

              // 7. Section «إعدادات التطبيق» (App Settings)
              _buildSettingsAccordion(isDark),
              const SizedBox(height: 14.0),

              // 8. Option «طلب حذف الحساب» (Delete Account Request)
              _buildDeleteAccountCard(isDark),
              const SizedBox(height: 12.0),

              // 9. Option «تسجيل الخروج» (Logout)
              _buildLogoutCard(isDark),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context, isDark),
      ),
    );
  }

  // ===========================================================================
  // SECTION 1: Office Profile Card
  // ===========================================================================
  Widget _buildOfficeProfileCard({
    required String officeName,
    required String activityType,
    required String managerPhone,
    required String managerId,
    required AuthUser user,
    required bool isDark,
  }) {
    final isVerified = user.verificationStatus == AccountVerificationStatus.verified;
    final isPending = user.verificationStatus == AccountVerificationStatus.pendingReview;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Top Identity Row: Logo Avatar + Office Details + Verified Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Office Logo Avatar with Office Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 70.0,
                    height: 70.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF3FF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFDBEAFE),
                        width: 2.0,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_shipping_rounded,
                        color: Color(0xFF2563EB),
                        size: 38.0,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 24.0,
                      height: 24.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D4ED8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          width: 2.0,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.apartment_rounded,
                          color: Colors.white,
                          size: 13.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14.0),

              // Enterprise Name & Activity Subtitle & Verification Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      officeName,
                      key: const Key('office_name_text'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      activityType,
                      key: const Key('office_activity_text'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6.0),

                    // Verification Pill
                    InkWell(
                      onTap: () {
                        if (isPending) {
                          OfficeVerificationDetailsSheet.show(
                            context,
                            user: user,
                            onApproved: () => setState(() {}),
                          );
                        } else if (!isVerified && widget.onVerifyNow != null) {
                          widget.onVerifyNow!();
                        }
                      },
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: isVerified
                              ? const Color(0xFFDCFCE7)
                              : isPending
                                  ? const Color(0xFFFEF3C7)
                                  : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: isVerified
                                ? const Color(0xFF86EFAC)
                                : isPending
                                    ? const Color(0xFFFDE68A)
                                    : const Color(0xFFFECACA),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isVerified
                                  ? Icons.check_circle_rounded
                                  : isPending
                                      ? Icons.hourglass_top_rounded
                                      : Icons.warning_amber_rounded,
                              size: 13.5,
                              color: isVerified
                                  ? const Color(0xFF16A34A)
                                  : isPending
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFFDC2626),
                            ),
                            const SizedBox(width: 5.0),
                            Text(
                              isVerified
                                  ? 'حساب موثق'
                                  : isPending
                                      ? 'قيد مراجعة الاعتماد'
                                      : 'غير موثق — توثيق الآن',
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: isVerified
                                    ? const Color(0xFF16A34A)
                                    : isPending
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Divider(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            height: 1.0,
          ),
          const SizedBox(height: 10.0),

          // Contact Details Row: Phone + Manager ID with Copy
          Row(
            children: [
              // Phone (Right side in RTL)
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 16.0,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6.0),
                    Expanded(
                      child: Text(
                        managerPhone,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 18.0,
                width: 1.0,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 12.0),

              // Manager ID with copy action (Left side in RTL)
              Expanded(
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: managerId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم نسخ رقم المسؤول: $managerId',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: const Color(0xFF2563EB),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          'رقم المسؤول: $managerId',
                          key: const Key('office_manager_id_text'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6.0),
                      const Icon(
                        Icons.copy_rounded,
                        size: 15.0,
                        color: Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Full Width Button: تعديل الملف الشخصي
          SizedBox(
            width: double.infinity,
            height: 42.0,
            child: ElevatedButton(
              key: const Key('edit_office_profile_btn'),
              onPressed: () => _openEditProfileSheet(user),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEFF6FF),
                foregroundColor: const Color(0xFF2563EB),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(
                    color: Color(0xFFDBEAFE),
                    width: 0.8,
                  ),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'تعديل الملف الشخصي',
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Icon(Icons.edit_outlined, size: 16.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION 2: 4 Stats Cards Row
  // ===========================================================================
  Widget _buildStatsRow(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // 1. الرحلات المنجزة (Green)
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_shipping_rounded,
                value: '$_completedTripsCount',
                title: 'رحلة منجزة',
                bgColor: const Color(0xFFECFDF5),
                borderColor: const Color(0xFFA7F3D0),
                accentColor: const Color(0xFF16A34A),
                isDark: isDark,
                onTap: () => context.push(AppRoutes.transportOfficeTrips),
              ),
            ),
            const SizedBox(width: 8.0),

            // 2. طلبات نشطة (Blue)
            Expanded(
              child: _buildStatCard(
                icon: Icons.description_rounded,
                value: '$_activeOrdersCount',
                title: 'طلبات نشطة',
                bgColor: const Color(0xFFEFF6FF),
                borderColor: const Color(0xFFBFDBFE),
                accentColor: const Color(0xFF2563EB),
                isDark: isDark,
                onTap: () => context.push(AppRoutes.transportOfficeOrders),
              ),
            ),
            const SizedBox(width: 8.0),

            // 3. رحلة مكتملة / طلبات متاحة (Orange)
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_box_rounded,
                value: '$_availableOrdersCount',
                title: 'رحلة مكتملة',
                bgColor: const Color(0xFFFFF7ED),
                borderColor: const Color(0xFFFED7AA),
                accentColor: const Color(0xFFEA580C),
                isDark: isDark,
                onTap: () => context.push(AppRoutes.transportOfficeOrders),
              ),
            ),
            const SizedBox(width: 8.0),

            // 4. التقييم العام (Purple)
            Expanded(
              child: _buildStatCard(
                icon: Icons.star_rounded,
                value: '$_generalRating',
                title: 'التقييم العام',
                bgColor: const Color(0xFFFAF5FF),
                borderColor: const Color(0xFFE9D5FF),
                accentColor: const Color(0xFF9333EA),
                isDark: isDark,
                onTap: _openRatingDetailsSheet,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String title,
    required Color bgColor,
    required Color borderColor,
    required Color accentColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : bgColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : borderColor,
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accentColor, size: 22.0),
            const SizedBox(height: 4.0),
            Text(
              value,
              maxLines: 1,
              style: GoogleFonts.cairo(
                fontSize: 16.0,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION 3: «بيانات المكتب» (Office Data Accordion)
  // ===========================================================================
  Widget _buildOfficeDataAccordion(bool isDark, AuthUser user) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        children: [
          // Header Row
          InkWell(
            onTap: () {
              setState(() {
                _isOfficeDataExpanded = !_isOfficeDataExpanded;
              });
            },
            borderRadius: BorderRadius.circular(14.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF2563EB),
                    size: 20.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'بيانات المكتب',
                    style: GoogleFonts.cairo(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isOfficeDataExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF64748B),
                    size: 22.0,
                  ),
                ],
              ),
            ),
          ),

          if (_isOfficeDataExpanded) ...[
            Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              height: 1.0,
            ),
            // Option 1: تحديث السجل التجاري
            _buildActionTile(
              title: 'تحديث السجل التجاري',
              icon: Icons.description_outlined,
              isDark: isDark,
              onTap: () => _openUpdateCommercialRegistrationSheet(user),
            ),
            Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              height: 1.0,
            ),
            // Option 2: تحديث بيانات التواصل والموقع
            _buildActionTile(
              title: 'تحديث بيانات التواصل والموقع',
              icon: Icons.location_on_outlined,
              isDark: isDark,
              onTap: () => _openUpdateContactAndLocationSheet(user),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION 4: Standalone «تحديث ملف المسؤول»
  // ===========================================================================
  Widget _buildManagerProfileCard(bool isDark, String managerName, AuthUser user) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ),
      child: _buildActionTile(
        title: 'تحديث ملف المسؤول',
        icon: Icons.person_outline_rounded,
        isDark: isDark,
        onTap: () => _openUpdateManagerProfileSheet(user),
      ),
    );
  }

  // ===========================================================================
  // SECTION 5: «الأمان والخصوصية» (Security Accordion)
  // ===========================================================================
  Widget _buildSecurityAccordion(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        children: [
          // Header Row
          InkWell(
            onTap: () {
              setState(() {
                _isSecurityExpanded = !_isSecurityExpanded;
              });
            },
            borderRadius: BorderRadius.circular(14.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_rounded,
                    color: Color(0xFF2563EB),
                    size: 20.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'الأمان والخصوصية',
                    style: GoogleFonts.cairo(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isSecurityExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF64748B),
                    size: 22.0,
                  ),
                ],
              ),
            ),
          ),

          if (_isSecurityExpanded) ...[
            Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              height: 1.0,
            ),
            // أ. تغيير رمز التأكيد / رمز التحقق
            _buildActionTile(
              title: 'تغيير رمز التحقق',
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
              onTap: _openChangePinDialog,
            ),
            Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              height: 1.0,
            ),
            // ب. تغيير كلمة المرور
            _buildActionTile(
              title: 'تغيير كلمة المرور',
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
              onTap: _openChangePasswordDialog,
            ),
            Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              height: 1.0,
            ),
            // ج. استخدام البصمة لتسجيل الدخول
            _buildSwitchTile(
              title: 'استخدام البصمة لتسجيل الدخول',
              icon: Icons.fingerprint_rounded,
              value: _useBiometricsLogin,
              isDark: isDark,
              onChanged: (val) {
                if (val) {
                  BiometricModalSheet.show(
                    context,
                    onSuccess: () {
                      setState(() => _useBiometricsLogin = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم تفعيل المصادقة بالبصمة لتسجيل الدخول بنجاح',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                          ),
                          backgroundColor: const Color(0xFF16A34A),
                        ),
                      );
                    },
                  );
                } else {
                  setState(() => _useBiometricsLogin = false);
                }
              },
            ),
            Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              height: 1.0,
            ),
            // د. استخدام البصمة لتأكيد عملية الدفع
            _buildSwitchTile(
              title: 'استخدام البصمة لتأكيد عملية الدفع',
              icon: Icons.fingerprint_rounded,
              value: _useBiometricsPayment,
              isDark: isDark,
              onChanged: (val) {
                if (val) {
                  BiometricModalSheet.show(
                    context,
                    onSuccess: () {
                      setState(() => _useBiometricsPayment = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم تفعيل تأكيد الدفع والتحويلات بالبصمة الحيوية',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                          ),
                          backgroundColor: const Color(0xFF16A34A),
                        ),
                      );
                    },
                  );
                } else {
                  setState(() => _useBiometricsPayment = false);
                }
              },
            ),
            Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              height: 1.0,
            ),
            // هـ. الشروط والأحكام
            _buildActionTile(
              title: 'الشروط والأحكام',
              icon: Icons.article_outlined,
              isDark: isDark,
              onTap: widget.onTerms ?? () => context.push(AppRoutes.terms),
            ),
            Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              height: 1.0,
            ),
            // و. سياسة الخصوصية
            _buildActionTile(
              title: 'سياسة الخصوصية',
              icon: Icons.shield_outlined,
              isDark: isDark,
              onTap: _openPrivacyPolicySheet,
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION 6: «الدعم والمساعدة» (Support & Assistance)
  // ===========================================================================
  Widget _buildSupportAccordion(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        children: [
          // Header Row
          InkWell(
            onTap: () {
              setState(() {
                _isSupportExpanded = !_isSupportExpanded;
              });
            },
            borderRadius: BorderRadius.circular(14.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.headset_mic_rounded,
                    color: Color(0xFF2563EB),
                    size: 20.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'الدعم والمساعدة',
                    style: GoogleFonts.cairo(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isSupportExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF64748B),
                    size: 22.0,
                  ),
                ],
              ),
            ),
          ),

          if (_isSupportExpanded) ...[
            Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              height: 1.0,
            ),
            // 1. خدمة العملاء
            _buildActionTile(
              title: 'خدمة العملاء',
              icon: Icons.support_agent_rounded,
              isDark: isDark,
              onTap: widget.onSupport ?? () => context.push(AppRoutes.customerSupport),
            ),
            Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              height: 1.0,
            ),
            // 2. مواقع التواصل
            _buildActionTile(
              title: 'مواقع التواصل',
              icon: Icons.share_outlined,
              isDark: isDark,
              onTap: _openSocialMediaSheet,
            ),
            Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              height: 1.0,
            ),
            // 3. الرقم المجاني
            _buildActionTile(
              title: 'الرقم المجاني',
              icon: Icons.phone_in_talk_outlined,
              isDark: isDark,
              onTap: () => TollFreeDialerModalSheet.show(context),
            ),
            Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              height: 1.0,
            ),
            // 4. نقاط الخدمة
            _buildActionTile(
              title: 'نقاط الخدمة',
              icon: Icons.store_mall_directory_outlined,
              isDark: isDark,
              onTap: _openServicePointsSheet,
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION 7: «إعدادات التطبيق» (App Settings)
  // ===========================================================================
  Widget _buildSettingsAccordion(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        children: [
          // Header Row
          InkWell(
            onTap: () {
              setState(() {
                _isSettingsExpanded = !_isSettingsExpanded;
              });
            },
            borderRadius: BorderRadius.circular(14.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.settings_outlined,
                    color: Color(0xFF2563EB),
                    size: 20.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'إعدادات التطبيق',
                    style: GoogleFonts.cairo(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isSettingsExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF64748B),
                    size: 22.0,
                  ),
                ],
              ),
            ),
          ),

          if (_isSettingsExpanded) ...[
            Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              height: 1.0,
            ),
            // أ. اللغة
            _buildActionTile(
              title: 'اللغة: العربية (الافتراضية)',
              icon: Icons.language_rounded,
              isDark: isDark,
              onTap: _openLanguageSelector,
            ),
            Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              height: 1.0,
            ),
            // ب. المظهر
            _buildActionTile(
              title: 'المظهر: فاتح',
              icon: Icons.brightness_6_outlined,
              isDark: isDark,
              onTap: _openThemeSelector,
            ),
            Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              height: 1.0,
            ),
            // ج. إعدادات الإشعارات
            _buildActionTile(
              title: 'إعدادات الإشعارات',
              icon: Icons.notifications_active_outlined,
              isDark: isDark,
              onTap: _openNotificationSettingsSheet,
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION 8: «طلب حذف الحساب»
  // ===========================================================================
  Widget _buildDeleteAccountCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: const Color(0xFFFEE2E2),
          width: 0.9,
        ),
      ),
      child: InkWell(
        onTap: _openDeleteAccountDialog,
        borderRadius: BorderRadius.circular(14.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFDC2626),
                    size: 20.0,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طلب حذف الحساب',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                    Text(
                      'تقديم طلب رسمي لإلغاء وتصفية الحساب التجاري',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 11.0,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14.0,
                color: Color(0xFFDC2626),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION 9: «تسجيل الخروج»
  // ===========================================================================
  Widget _buildLogoutCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: const Color(0xFFFECACA),
          width: 0.8,
        ),
      ),
      child: InkWell(
        onTap: _confirmLogout,
        borderRadius: BorderRadius.circular(14.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Color(0xFFDC2626),
                size: 20.0,
              ),
              const SizedBox(width: 8.0),
              Flexible(
                child: Text(
                  'تسجيل الخروج من الحساب',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HELPER TILES
  // ===========================================================================
  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 34.0,
              height: 34.0,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: const Color(0xFF2563EB),
                  size: 18.0,
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 13.0,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 34.0,
            height: 34.0,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Icon(
                icon,
                color: const Color(0xFF2563EB),
                size: 18.0,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              activeThumbColor: const Color(0xFF2563EB),
              activeTrackColor: const Color(0xFFBFDBFE),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // INTERACTIVE SHEETS & DIALOGS
  // ===========================================================================

  /// 1. Edit Profile Sheet
  void _openEditProfileSheet(AuthUser user) {
    final officeData = user.officeData;
    final officeNameCtrl = TextEditingController(
      text: officeData?.officeName ?? 'مكتب النقل السريع',
    );
    final activityTypeCtrl = TextEditingController(
      text: officeData?.activityType ?? 'مكتب نقل معتمد',
    );
    final managerNameCtrl = TextEditingController(
      text: user.identityData?.fullName ?? user.name,
    );
    final phoneCtrl = TextEditingController(
      text: user.phone,
    );
    final addressCtrl = TextEditingController(
      text: officeData?.address ?? 'صنعاء - شارع تعز - جولة 45',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.0)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            top: 20.0,
            left: 20.0,
            right: 20.0,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_note_rounded, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'تعديل بيانات الملف الشخصي',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20.0),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  label: 'اسم مكتب النقل',
                  controller: officeNameCtrl,
                  icon: Icons.apartment_rounded,
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  label: 'نوع النشاط والخدمات',
                  controller: activityTypeCtrl,
                  icon: Icons.local_shipping_outlined,
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  label: 'اسم المسؤول المفوض',
                  controller: managerNameCtrl,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  label: 'رقم الهاتف المسجل',
                  controller: phoneCtrl,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  label: 'عنوان المقر الرئيسي',
                  controller: addressCtrl,
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: double.infinity,
                  height: 46.0,
                  child: ElevatedButton(
                    onPressed: () {
                      if (officeNameCtrl.text.trim().isEmpty ||
                          managerNameCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'يرجى إدخال اسم المكتب واسم المسؤول بشكل صحيح',
                              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                            ),
                            backgroundColor: const Color(0xFFDC2626),
                          ),
                        );
                        return;
                      }

                      final updatedOfficeData = (user.officeData ??
                              const OfficeEnterpriseData(officeName: 'مكتب النقل'))
                          .copyWith(
                        officeName: officeNameCtrl.text.trim(),
                        activityType: activityTypeCtrl.text.trim(),
                        address: addressCtrl.text.trim(),
                      );

                      final updatedIdentityData = (user.identityData ??
                              ClientIdentityData(
                                fullName: '',
                                idNumber: '',
                                issuePlace: '',
                                issueDate: '',
                                birthPlace: '',
                                birthDate: '',
                                submittedAt: DateTime(2026, 7, 10),
                              ))
                          .copyWith(
                        fullName: managerNameCtrl.text.trim(),
                      );

                      final updatedUser = user.copyWith(
                        name: managerNameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        officeData: updatedOfficeData,
                        identityData: updatedIdentityData,
                      );

                      AuthSimulationStore.instance.registerUser(updatedUser);
                      Navigator.pop(ctx);
                      setState(() {});

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم حفظ تعديلات الملف الشخصي بنجاح',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                          ),
                          backgroundColor: const Color(0xFF16A34A),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'حفظ التعديلات',
                      style: GoogleFonts.cairo(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 2. Commercial Registration Update Sheet
  void _openUpdateCommercialRegistrationSheet(AuthUser user) {
    final officeData = user.officeData;
    final crNumberCtrl = TextEditingController(
      text: officeData?.crNumber ?? 'CR-7729104',
    );
    final crIssuerCtrl = TextEditingController(
      text: officeData?.crIssuer ?? 'وزارة الصناعة والتجارة - مكتب النقل',
    );
    final crExpiryCtrl = TextEditingController(
      text: officeData?.crExpiryDate ?? '2027-06-14',
    );

    bool hasAttachment = true;
    String attachmentName = 'commercial_reg_official_2026.pdf';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.0)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              top: 20.0,
              left: 20.0,
              right: 20.0,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.description_rounded, color: Color(0xFF2563EB)),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'تحديث بيانات السجل التجاري',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20.0),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),

                  // Legal Compliance Notice
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFFD97706),
                          size: 18.0,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            'ملاحظة: تخضع أي تعديلات في وثائق السجل التجاري لمراجعة وتدقيق فريق الامتثال والرقابة قبل الاعتماد النهائي لضمان سلامة التعاملات.',
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              color: const Color(0xFF92400E),
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  _buildTextField(
                    label: 'رقم السجل التجاري',
                    controller: crNumberCtrl,
                    icon: Icons.confirmation_number_outlined,
                  ),
                  const SizedBox(height: 12.0),
                  _buildTextField(
                    label: 'جهة الإصدار الرسمية',
                    controller: crIssuerCtrl,
                    icon: Icons.account_balance_outlined,
                  ),
                  const SizedBox(height: 12.0),
                  _buildTextField(
                    label: 'تاريخ انتهاء السجل التجاري',
                    controller: crExpiryCtrl,
                    icon: Icons.calendar_month_outlined,
                  ),
                  const SizedBox(height: 14.0),

                  // Attachment Box
                  Text(
                    'وثيقة السجل التجاري الرسمية (PDF أو صورة عالية الدقة):',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.file_upload_outlined, color: Color(0xFF2563EB)),
                          onPressed: () {
                            setSheetState(() {
                              hasAttachment = true;
                              attachmentName = 'updated_cr_license_signed.pdf';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم اختيار وثيقة السجل التجاري بنجاح',
                                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                                ),
                                duration: const Duration(seconds: 2),
                                backgroundColor: const Color(0xFF2563EB),
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasAttachment ? attachmentName : 'لم يتم إرفاق ملف بعد',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w700,
                                  color: hasAttachment ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                                ),
                              ),
                              Text(
                                hasAttachment ? 'حجم الملف: 1.4 MB — تم الفحص' : 'انقر على زر الرفع لإرفاق السجل الجديد',
                                style: GoogleFonts.cairo(
                                  fontSize: 10.5,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (hasAttachment)
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18.0),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 46.0,
                    child: ElevatedButton(
                      onPressed: () {
                        if (crNumberCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'يرجى كتابة رقم السجل التجاري',
                                style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                              ),
                              backgroundColor: const Color(0xFFDC2626),
                            ),
                          );
                          return;
                        }

                        final updatedOffice = (user.officeData ??
                                const OfficeEnterpriseData(officeName: 'مكتب النقل'))
                            .copyWith(
                          crNumber: crNumberCtrl.text.trim(),
                          crIssuer: crIssuerCtrl.text.trim(),
                          crExpiryDate: crExpiryCtrl.text.trim(),
                        );

                        final updatedUser = user.copyWith(officeData: updatedOffice);
                        AuthSimulationStore.instance.registerUser(updatedUser);
                        Navigator.pop(ctx);
                        setState(() {});

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم إرسال تحديثات السجل التجاري بنجاح، وستتم مراجعتها من قبل الإدارة خلال 24 ساعة',
                              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                            ),
                            duration: const Duration(seconds: 4),
                            backgroundColor: const Color(0xFF16A34A),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        'إرسال التحديثات للمراجعة',
                        style: GoogleFonts.cairo(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 3. Contact & Location Update Sheet
  void _openUpdateContactAndLocationSheet(AuthUser user) {
    final officeData = user.officeData;
    final phoneCtrl = TextEditingController(text: user.phone);
    final altPhoneCtrl = TextEditingController(text: '771234567');
    final emailCtrl = TextEditingController(text: 'support@al-amana-trans.com');
    final cityCtrl = TextEditingController(text: officeData?.city ?? 'صنعاء');
    final addressCtrl = TextEditingController(
      text: officeData?.address ?? 'صنعاء - شارع تعز - جولة 45',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.0)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            top: 20.0,
            left: 20.0,
            right: 20.0,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'تحديث بيانات التواصل والموقع',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20.0),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  label: 'رقم الهاتف الأساسي',
                  controller: phoneCtrl,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  label: 'رقم هاتف بديل / خط الطوارئ',
                  controller: altPhoneCtrl,
                  icon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  label: 'البريد الإلكتروني التجاري',
                  controller: emailCtrl,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  label: 'المحافظة / المدينة',
                  controller: cityCtrl,
                  icon: Icons.location_city_outlined,
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  label: 'العنوان التفصيلي ومقر المكتب',
                  controller: addressCtrl,
                  icon: Icons.pin_drop_outlined,
                ),
                const SizedBox(height: 14.0),

                // Location Picker Simulator
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location_rounded, color: Color(0xFF2563EB)),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إحداثيات المقر على الخريطة:',
                              style: GoogleFonts.cairo(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '15.3412° N, 44.2081° E — صنعاء',
                              style: GoogleFonts.cairo(
                                fontSize: 11.0,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم تثبيت الموقع الجغرافي للمكتب بنجاح',
                                style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                              ),
                              backgroundColor: const Color(0xFF16A34A),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_location_alt_rounded, size: 16.0),
                        label: Text(
                          'تحديث',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 46.0,
                  child: ElevatedButton(
                    onPressed: () {
                      final updatedOffice = (user.officeData ??
                              const OfficeEnterpriseData(officeName: 'مكتب النقل'))
                          .copyWith(
                        city: cityCtrl.text.trim(),
                        address: addressCtrl.text.trim(),
                      );

                      final updatedUser = user.copyWith(
                        phone: phoneCtrl.text.trim(),
                        officeData: updatedOffice,
                      );

                      AuthSimulationStore.instance.registerUser(updatedUser);
                      Navigator.pop(ctx);
                      setState(() {});

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم حفظ بيانات التواصل والموقع بنجاح',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                          ),
                          backgroundColor: const Color(0xFF16A34A),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'حفظ التغييرات',
                      style: GoogleFonts.cairo(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 4. Manager Profile Update Sheet
  void _openUpdateManagerProfileSheet(AuthUser user) {
    final identityData = user.identityData;
    final nameCtrl = TextEditingController(
      text: identityData?.fullName ?? user.name,
    );
    final idNumberCtrl = TextEditingController(
      text: identityData?.idNumber ?? '987654321',
    );
    final idTypeCtrl = TextEditingController(
      text: identityData?.idType ?? 'بطاقة شخصية',
    );
    final issuePlaceCtrl = TextEditingController(
      text: identityData?.issuePlace ?? 'صنعاء - السبعين',
    );
    final issueDateCtrl = TextEditingController(
      text: identityData?.issueDate ?? '2018-09-10',
    );
    final phoneCtrl = TextEditingController(
      text: user.phone,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.0)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            top: 20.0,
            left: 20.0,
            right: 20.0,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.badge_rounded, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'تحديث ملف المسؤول القانوني',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20.0),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),

                // Note on separation
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_person_outlined, color: Color(0xFF2563EB), size: 18.0),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'تخص هذه البيانات المسؤول المفوض قانونياً بإدارة مكتب النقل، وتُعامل بسرية وأمان تام.',
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            color: const Color(0xFF1E40AF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                _buildTextField(
                  label: 'الاسم الكامل للمسؤول',
                  controller: nameCtrl,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  label: 'نوع وثيقة الهوية',
                  controller: idTypeCtrl,
                  icon: Icons.credit_card_rounded,
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  label: 'رقم البطاقة الشخصية / الهوية الوطنية',
                  controller: idNumberCtrl,
                  icon: Icons.fingerprint_rounded,
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  label: 'جهة وتاريخ الإصدار',
                  controller: issuePlaceCtrl,
                  icon: Icons.account_balance_outlined,
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  label: 'رقم الهاتف المباشر للمسؤول',
                  controller: phoneCtrl,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20.0),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 46.0,
                  child: ElevatedButton(
                    onPressed: () {
                      final updatedIdentity = (user.identityData ??
                              ClientIdentityData(
                                fullName: '',
                                idNumber: '',
                                issuePlace: '',
                                issueDate: '',
                                birthPlace: '',
                                birthDate: '',
                                submittedAt: DateTime(2026, 7, 10),
                              ))
                          .copyWith(
                        fullName: nameCtrl.text.trim(),
                        idNumber: idNumberCtrl.text.trim(),
                        idType: idTypeCtrl.text.trim(),
                        issuePlace: issuePlaceCtrl.text.trim(),
                        issueDate: issueDateCtrl.text.trim(),
                      );

                      final updatedUser = user.copyWith(
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        identityData: updatedIdentity,
                      );

                      AuthSimulationStore.instance.registerUser(updatedUser);
                      Navigator.pop(ctx);
                      setState(() {});

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم تحديث ملف وبيانات المسؤول بنجاح',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                          ),
                          backgroundColor: const Color(0xFF16A34A),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'حفظ ملف المسؤول',
                      style: GoogleFonts.cairo(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 5. Change PIN Dialog
  void _openChangePinDialog() {
    final currentPinCtrl = TextEditingController();
    final newPinCtrl = TextEditingController();
    final confirmPinCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Row(
            children: [
              const Icon(Icons.dialpad_rounded, color: Color(0xFF2563EB)),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'تغيير رمز التحقق / التأكيد',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16.0),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'رمز التأكيد الحالي (4 أرقام)',
                  labelStyle: GoogleFonts.cairo(fontSize: 12.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: newPinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'رمز التأكيد الجديد (4 أرقام)',
                  labelStyle: GoogleFonts.cairo(fontSize: 12.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: confirmPinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'تأكيد الرمز الجديد',
                  labelStyle: GoogleFonts.cairo(fontSize: 12.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPinCtrl.text.length != 4 ||
                    newPinCtrl.text != confirmPinCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'يرجى التأكد من تطابق الرمز الجديد المكون من 4 أرقام',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                      ),
                      backgroundColor: const Color(0xFFDC2626),
                    ),
                  );
                  return;
                }

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تحديث رمز التحقق بنجاح',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                    ),
                    backgroundColor: const Color(0xFF16A34A),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: Text('تأكيد التغيير', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  /// 6. Change Password Dialog
  void _openChangePasswordDialog() {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Row(
            children: [
              const Icon(Icons.lock_reset_rounded, color: Color(0xFF2563EB)),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'تغيير كلمة المرور',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16.0),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPassCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                  labelStyle: GoogleFonts.cairo(fontSize: 12.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
              const SizedBox(height: 12.0),
              TextField(
                controller: newPassCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الجديدة (6 أحرف أو أكثر)',
                  labelStyle: GoogleFonts.cairo(fontSize: 12.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
              const SizedBox(height: 12.0),
              TextField(
                controller: confirmPassCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور الجديدة',
                  labelStyle: GoogleFonts.cairo(fontSize: 12.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPassCtrl.text.length < 6 ||
                    newPassCtrl.text != confirmPassCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'يرجى التأكد من أن كلمة المرور لا تقل عن 6 أحرف ومتطابقة',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                      ),
                      backgroundColor: const Color(0xFFDC2626),
                    ),
                  );
                  return;
                }

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تحديث كلمة المرور بنجاح',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                    ),
                    backgroundColor: const Color(0xFF16A34A),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: Text('حفظ', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  /// 7. Delete Account Dialog
  void _openDeleteAccountDialog() {
    final trips = TransportOfficeTripsStore.instance.allTrips;
    final activeTrips = trips.where(
      (t) =>
          t.status == OfficeTripStatus.inProgress ||
          t.status == OfficeTripStatus.pendingStart,
    ).length;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'طلب حذف الحساب التجاري',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16.0),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سيؤدي تقديم طلب حذف الحساب إلى بدء إجراءات التصفية القانونية والمالية لحساب مكتب النقل.',
                style: GoogleFonts.cairo(fontSize: 12.5, height: 1.5),
              ),
              const SizedBox(height: 10.0),
              if (activeTrips > 0)
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'تنبيه: يوجد حالياً $activeTrips رحلات جارية أو بانتظار البدء. لا يمكن إتمام الحذف إلا بعد تسليم كافة الحمولات وتصفية المستحقات.',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      color: const Color(0xFFB91C1C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Text(
                  'سيقوم قسم الامتثال والرقابة بمراجعة عدم وجود مطالبات مالية معلقة وتأكيد الطلب خلال 3 أيام عمل.',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('تراجع', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم إرسال طلب حذف الحساب بنجاح، وسيتواصل معك فريق الامتثال للمتابعة',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                    ),
                    duration: const Duration(seconds: 4),
                    backgroundColor: const Color(0xFF2563EB),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'تأكيد إرسال الطلب',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 8. Social Media Sheet
  void _openSocialMediaSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'قنوات حمولة الرسمية',
                style: GoogleFonts.cairo(fontSize: 16.5, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12.0),
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF16A34A)),
                title: Text('واتساب الدعم المباشر: +967 777 000 000', style: GoogleFonts.cairo(fontSize: 13.0, fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('جارٍ فتح تطبيق واتساب...', style: GoogleFonts.cairo())),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.tag_rounded, color: Color(0xFF0F172A)),
                title: Text('منصة إكس (تويتر سابقاً): @Hamoola_YE', style: GoogleFonts.cairo(fontSize: 13.0, fontWeight: FontWeight.w700)),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.public_rounded, color: Color(0xFF2563EB)),
                title: Text('الموقع الإلكتروني: www.hamoola.app', style: GoogleFonts.cairo(fontSize: 13.0, fontWeight: FontWeight.w700)),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 9. Service Points Sheet
  void _openServicePointsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مراكز ونقاط خدمة حمولة المعتمدة',
                style: GoogleFonts.cairo(fontSize: 16.5, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12.0),
              ListTile(
                leading: const Icon(Icons.location_on_rounded, color: Color(0xFF2563EB)),
                title: Text('صنعاء: شارع حدة - مجمع التوفير', style: GoogleFonts.cairo(fontSize: 13.0, fontWeight: FontWeight.w700)),
                subtitle: Text('أوقات الدوام: 8:00 ص - 8:00 م', style: GoogleFonts.cairo(fontSize: 11.0)),
              ),
              ListTile(
                leading: const Icon(Icons.location_on_rounded, color: Color(0xFF2563EB)),
                title: Text('عدن: المنصورة - شارع التسعين', style: GoogleFonts.cairo(fontSize: 13.0, fontWeight: FontWeight.w700)),
                subtitle: Text('أوقات الدوام: 8:30 ص - 7:30 م', style: GoogleFonts.cairo(fontSize: 11.0)),
              ),
              ListTile(
                leading: const Icon(Icons.location_on_rounded, color: Color(0xFF2563EB)),
                title: Text('الحديدة: شارع الميناء - أمام مصلحة الجمارك', style: GoogleFonts.cairo(fontSize: 13.0, fontWeight: FontWeight.w700)),
                subtitle: Text('أوقات الدوام: 8:00 ص - 6:00 م', style: GoogleFonts.cairo(fontSize: 11.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 10. Privacy Policy Sheet
  void _openPrivacyPolicySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.65,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'سياسة الخصوصية وحماية البيانات',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(fontSize: 16.0, fontWeight: FontWeight.w900),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Expanded(
                  child: ListView(
                    children: [
                      Text(
                        'تلتزم منصة حمولة بحماية البيانات التجارية والشخصية لمكاتب النقل والسائقين والتجار.\n\n'
                        '1. جمع البيانات:\n'
                        'نجمع فقط البيانات اللازمة لإتمام عمليات الشحن، والتحقق القانوني، والتوثيق التجاري.\n\n'
                        '2. سرية الوثائق الرسمية:\n'
                        'تُحفظ وثائق السجل التجاري والهويات في خوادم مشفرة ولا تتم مشاركتها مع أطراف ثالثة دون إذن مسبق.\n\n'
                        '3. بيانات التتبع الجغرافي:\n'
                        'يتم استخدام نظام الملاحة والتتبع حصراً أثناء سريان الرحلة لتأمين الحمولة وتقديم تقارير دقيقة للمرسل والمستلم.',
                        style: GoogleFonts.cairo(fontSize: 13.0, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 11. App Settings Sheet (Language, Theme, Notifications)
  void _openAppSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إعدادات التطبيق',
                style: GoogleFonts.cairo(fontSize: 16.5, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12.0),
              ListTile(
                leading: const Icon(Icons.language_rounded, color: Color(0xFF2563EB)),
                title: Text('تغيير لغة التطبيق', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                subtitle: Text('العربية (المعتمدة حالياً)', style: GoogleFonts.cairo(fontSize: 11.5)),
                trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 14.0),
                onTap: () {
                  Navigator.pop(ctx);
                  _openLanguageSelector();
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_6_outlined, color: Color(0xFF2563EB)),
                title: Text('مظهر التطبيق', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                subtitle: Text('فاتح / ليلي / تلقائي', style: GoogleFonts.cairo(fontSize: 11.5)),
                trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 14.0),
                onTap: () {
                  Navigator.pop(ctx);
                  _openThemeSelector();
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined, color: Color(0xFF2563EB)),
                title: Text('إعدادات الإشعارات والتنبيهات', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                subtitle: Text('الطلبات، حركة الشاحنات، والمحفظة', style: GoogleFonts.cairo(fontSize: 11.5)),
                trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 14.0),
                onTap: () {
                  Navigator.pop(ctx);
                  _openNotificationSettingsSheet();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 12. Language Selector Dialog
  void _openLanguageSelector() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SimpleDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text(
            'اختيار لغة التطبيق',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16.0),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم اعتماد اللغة العربية',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                    ),
                    backgroundColor: const Color(0xFF16A34A),
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18.0),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'العربية (المعتمدة والافتراضية)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'اللغة الإنجليزية قيد استكمال الترجمة التجريبية',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                    ),
                    backgroundColor: const Color(0xFF2563EB),
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.radio_button_unchecked_rounded, color: Color(0xFF94A3B8), size: 18.0),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'English (Experimental)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 13. Theme Selector Dialog
  void _openThemeSelector() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SimpleDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text(
            'اختيار مظهر التطبيق',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16.0),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('المظهر الفاتح هو المظهر المعتمد للمكتب', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                    backgroundColor: const Color(0xFF16A34A),
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18.0),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'المظهر الفاتح (Light)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تفعيل وضع التوافق الليلي', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                    backgroundColor: const Color(0xFF2563EB),
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.radio_button_unchecked_rounded, color: Color(0xFF94A3B8), size: 18.0),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'المظهر الليلي (Dark)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم ضبط المظهر تلقائياً حسب إعدادات الجهاز', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                    backgroundColor: const Color(0xFF2563EB),
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.radio_button_unchecked_rounded, color: Color(0xFF94A3B8), size: 18.0),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'تلقائي حسب مظهر الجهاز (System)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 14. Notification Settings Sheet
  void _openNotificationSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إعدادات التنبيهات والإشعارات',
                  style: GoogleFonts.cairo(fontSize: 16.5, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12.0),
                SwitchListTile(
                  value: _notifyNewOrders,
                  activeThumbColor: const Color(0xFF2563EB),
                  title: Text('تنبيهات الطلبات المتاحة والحمولات الجديدة', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                  onChanged: (val) {
                    setSheetState(() => _notifyNewOrders = val);
                    setState(() => _notifyNewOrders = val);
                  },
                ),
                SwitchListTile(
                  value: _notifyTripUpdates,
                  activeThumbColor: const Color(0xFF2563EB),
                  title: Text('تحديثات حركة السائقين ومسار الرحلات', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                  onChanged: (val) {
                    setSheetState(() => _notifyTripUpdates = val);
                    setState(() => _notifyTripUpdates = val);
                  },
                ),
                SwitchListTile(
                  value: _notifyWalletTransactions,
                  activeThumbColor: const Color(0xFF2563EB),
                  title: Text('إشعارات المحفظة والعمليات المالية', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                  onChanged: (val) {
                    setSheetState(() => _notifyWalletTransactions = val);
                    setState(() => _notifyWalletTransactions = val);
                  },
                ),
                SwitchListTile(
                  value: _notifyMarketing,
                  activeThumbColor: const Color(0xFF2563EB),
                  title: Text('الرسائل التسويقية والعروض الترويجية', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                  onChanged: (val) {
                    setSheetState(() => _notifyMarketing = val);
                    setState(() => _notifyMarketing = val);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 15. Rating Details Sheet
  void _openRatingDetailsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 28.0),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'التقييم العام: 4.8 من 5.0',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(fontSize: 17.0, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      '98% تقييم إيجابي',
                      style: GoogleFonts.cairo(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              _buildRatingCriterion('الالتزام بالمواعيد وموعد التحميل', 0.99),
              const SizedBox(height: 8.0),
              _buildRatingCriterion('سلامة البضائع والمعدات المنقولة', 0.98),
              const SizedBox(height: 8.0),
              _buildRatingCriterion('احترافية السائقين المعتمدين', 0.97),
              const SizedBox(height: 8.0),
              _buildRatingCriterion('سرعة الاستجابة وخدمة العملاء', 0.96),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingCriterion(String label, double percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8.0),
            Text('${(percent * 100).toInt()}%', style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 4.0),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6.0,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
          ),
        ),
      ],
    );
  }

  /// 16. Confirm Logout Dialog
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Row(
            children: [
              const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'تأكيد تسجيل الخروج',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16.0),
                ),
              ),
            ],
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في تسجيل الخروج من حساب مكتب النقل؟',
            style: GoogleFonts.cairo(fontSize: 13.0, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                AuthSimulationStore.instance.logout();
                AppPreferences.instance.clearUserSession();
                if (widget.onLogout != null) {
                  widget.onLogout!();
                } else {
                  context.go(AppRoutes.login);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: Text('تسجيل الخروج', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // BOTTOM NAVIGATION BAR
  // ===========================================================================
  Widget _buildBottomNavigationBar(BuildContext context, bool isDark) {
    return Container(
      key: const Key('account_bottom_nav_bar'),
      height: 72.0,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10.0,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. الرئيسية
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'الرئيسية',
                isActive: false,
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.transportOfficeHome);
                  }
                },
              ),

              // 2. الخريطة
              _buildNavItem(
                icon: Icons.location_on_outlined,
                label: 'الخريطة',
                isActive: false,
                onTap: () => context.push(AppRoutes.driverCargoMap),
              ),

              // 3. Middle Floating (+) Button (NO TEXT UNDER IT)
              SizedBox(
                width: 56.0,
                child: Center(child: _buildCenterFab()),
              ),

              // 4. طلباتي
              _buildNavItem(
                icon: Icons.assignment_rounded,
                label: 'طلباتي',
                isActive: false,
                onTap: () => context.push(AppRoutes.transportOfficeOrders),
              ),

              // 5. حسابي (ACTIVE - Royal Blue #1D4ED8)
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'حسابي',
                isActive: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? const Color(0xFF1D4ED8) : const Color(0xFF64748B);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 22.0),
                const SizedBox(height: 1.0),
                Text(
                  label,
                  maxLines: 1,
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterFab() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleQuickActionsSheet,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48.0,
          height: 48.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFDC2626), // Hamoola Red FAB
            boxShadow: [
              BoxShadow(
                color: Color(0x40DC2626),
                blurRadius: 8.0,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: 0.125).animate(_fabAnimController),
            child: const Icon(Icons.add, color: Colors.white, size: 28.0),
          ),
        ),
      ),
    );
  }

  void _toggleQuickActionsSheet() {
    if (_isFabSheetOpen) {
      Navigator.of(context).maybePop();
      return;
    }

    _fabAnimController.forward();
    setState(() => _isFabSheetOpen = true);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A), // Dark Navy
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 28.0),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                const SizedBox(height: 18.0),
                Text(
                  'إجراءات سريعة لمكتب النقل',
                  style: GoogleFonts.cairo(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20.0),

                // 2x2 Grid of Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.toggle_on_rounded,
                        label: 'تحديث الحالة',
                        color: const Color(0xFF10B981),
                        onTap: () {
                          Navigator.pop(sheetCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'مكتب النقل متاح الآن لاستقبال وتوزيع الحمولات',
                                style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                              ),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.local_shipping_rounded,
                        label: 'رحلاتي الجارية',
                        color: const Color(0xFF2563EB),
                        onTap: () {
                          Navigator.pop(sheetCtx);
                          context.push(AppRoutes.transportOfficeTrips);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14.0),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.headset_mic_rounded,
                        label: 'طلب مساعدة',
                        color: const Color(0xFF9333EA),
                        onTap: () {
                          Navigator.pop(sheetCtx);
                          TollFreeDialerModalSheet.show(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.warning_amber_rounded,
                        label: 'الإبلاغ عن مشكلة',
                        color: const Color(0xFFDC2626),
                        onTap: () {
                          Navigator.pop(sheetCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم استلام بلاغك وسيتواصل معك الدعم الفني فوراً',
                                style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                              ),
                              backgroundColor: const Color(0xFFDC2626),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        _fabAnimController.reverse();
        setState(() => _isFabSheetOpen = false);
      }
    });
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF1E293B),
      borderRadius: BorderRadius.circular(14.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Icon(icon, color: color, size: 24.0)),
              ),
              const SizedBox(height: 8.0),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.0,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6.0),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.cairo(fontSize: 13.5, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 18.0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
