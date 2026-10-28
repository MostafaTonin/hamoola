import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/domain/models/auth_simulation_store.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../../auth/presentation/widgets/toll_free_dialer_modal_sheet.dart';
import '../../../merchant/presentation/widgets/merchant_bottom_nav_bar.dart';

/// Screen representing the Driver's "حسابي" (My Account) Screen.
/// Faithfully reproduces the Driver Account mockup:
/// - Top Bar: "< حسابي" with settings gear icon
/// - Driver Profile Card:
///   - Avatar with camera edit badge (assets/images/driver_ahmed_avatar.jpg)
///   - Driver name (e.g. "أحمد محمد سالم")
///   - "سائق في منصة حمولة"
///   - Verification badge ("حساب موثّق ✓", "قيد المراجعة", "يتطلب استكمال البيانات")
///   - Phone number (+967 777 987 654) & Driver ID (رقم السائق: 783707104)
///   - Action button: "تعديل الملف الشخصي"
/// - 3 Professional Statistics Cards:
///   - Green: "حمولة منقولة" (128)
///   - Blue: "طلبات نشطة" (5)
///   - Orange: "رحلة مكتملة" (96)
/// - Section: "بيانات السائق" (المعلومات الشخصية, بيانات الهوية الوطنية, رخصة القيادة, بيانات التواصل, العنوان والموقع)
/// - Section: "بيانات الناقلة" (Truck card, specs, and "تحديث بيانات الناقلة" button)
/// - Section: "الخصوصية والأمان" (6 items, with biometrics toggles)
/// - Section: "الدعم والمساعدة" (6 items)
/// - Section: "إعدادات التطبيق" (3 items: اللغة, المظهر, إعدادات الإشعارات)
/// - Red Tinted "تسجيل الخروج" Button Card
/// - Unified Bottom Navigation Bar with "حسابي" active and center (+) quick actions
class DriverAccountScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onHome;
  final VoidCallback? onOrders;
  final VoidCallback? onMap;
  final VoidCallback? onWallet;
  final VoidCallback? onSupport;
  final VoidCallback? onNotifications;
  final VoidCallback? onLogout;
  final VoidCallback? onVerifyLicense;
  final VoidCallback? onVerifyVehicle;

  final int? transportedCargos;
  final int? activeOrders;
  final int? completedTrips;

  const DriverAccountScreen({
    super.key,
    this.onBack,
    this.onHome,
    this.onOrders,
    this.onMap,
    this.onWallet,
    this.onSupport,
    this.onNotifications,
    this.onLogout,
    this.onVerifyLicense,
    this.onVerifyVehicle,
    this.transportedCargos,
    this.activeOrders,
    this.completedTrips,
  });

  @override
  State<DriverAccountScreen> createState() => _DriverAccountScreenState();
}

class _DriverAccountScreenState extends State<DriverAccountScreen> {
  // Accordion expansion states
  bool _isDriverDataExpanded = true;
  bool _isVehicleDataExpanded = true;
  bool _isSecurityExpanded = true;
  bool _isSupportExpanded = true;
  bool _isSettingsExpanded = true;

  // Toggle switch states
  bool _useBiometricsLogin = true;
  bool _useBiometricsPayment = false;

  // Quick actions modal state
  bool _isQuickActionsOpen = false;

  AuthUser get _currentDriverUser {
    final store = AuthSimulationStore.instance;
    final current = store.currentUser;
    if (current != null && current.role == AuthUserRole.driver) {
      return current;
    }
    try {
      return store.users.firstWhere((u) => u.role == AuthUserRole.driver);
    } catch (_) {
      return store.users.first;
    }
  }

  int get _transportedCargosCount => widget.transportedCargos ?? 128;
  int get _activeOrdersCount => widget.activeOrders ?? 5;
  int get _completedTripsCount => widget.completedTrips ?? 96;

  @override
  void initState() {
    super.initState();
    AuthSimulationStore.instance.addListener(_onStoreUpdated);
  }

  @override
  void dispose() {
    AuthSimulationStore.instance.removeListener(_onStoreUpdated);
    super.dispose();
  }

  void _onStoreUpdated() {
    if (mounted) setState(() {});
  }

  String _formatPhone(String countryCode, String phone) {
    final clean = phone.replaceAll(' ', '').replaceAll('+', '');
    if (clean.startsWith('967') && clean.length == 12) {
      final local = clean.substring(3);
      return '+967 ${local.substring(0, 3)} ${local.substring(3, 6)} ${local.substring(6)}';
    }
    if (clean.length == 9) {
      return '$countryCode ${clean.substring(0, 3)} ${clean.substring(3, 6)} ${clean.substring(6)}';
    }
    return '$countryCode $phone';
  }

  // ---------------------------------------------------------------------------
  // PROFILE EDIT MODAL
  // ---------------------------------------------------------------------------
  void _openEditProfileDialog() {
    final user = _currentDriverUser;
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: Color(0xFF2563EB), size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تعديل الملف الشخصي للسائق',
                      style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'الاسم الكامل',
                  labelStyle: GoogleFonts.cairo(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  labelStyle: GoogleFonts.cairo(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  final newName = nameCtrl.text.trim();
                  final newPhone = phoneCtrl.text.trim();
                  if (newName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('يرجى إدخال اسم السائق', style: GoogleFonts.cairo()),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  AuthSimulationStore.instance.updateDriverProfile(
                    userId: user.id,
                    name: newName,
                    phone: newPhone.isNotEmpty ? newPhone : null,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تحديث بيانات الملف الشخصي بنجاح', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                      duration: const Duration(seconds: 2),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('حفظ التعديلات', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // VEHICLE UPDATE MODAL
  // ---------------------------------------------------------------------------
  void _openUpdateVehicleDialog() {
    final user = _currentDriverUser;
    final currentVehicle = user.driverData?.vehicleData;

    final plateCtrl = TextEditingController(text: currentVehicle?.plateNumber ?? '12345 | أ ب ج');
    final typeCtrl = TextEditingController(text: currentVehicle?.vehicleType ?? 'شاحنة');
    final categoryCtrl = TextEditingController(text: currentVehicle?.category ?? 'شاحنة نقل بضائع');
    final capacityCtrl = TextEditingController(text: currentVehicle?.maxCapacity ?? '20');
    final unitCtrl = TextEditingController(text: currentVehicle?.capacityUnit ?? 'طن');
    final notesCtrl = TextEditingController(text: currentVehicle?.operatingNotes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.local_shipping_rounded, color: Color(0xFF2563EB), size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تحديث بيانات الناقلة',
                        style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'قم بتعديل بيانات المركبة المسجلة لدى السائق في منصة حمولة',
                  style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryCtrl,
                  decoration: InputDecoration(
                    labelText: 'وصف الناقلة / التصنيف',
                    labelStyle: GoogleFonts.cairo(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: plateCtrl,
                        decoration: InputDecoration(
                          labelText: 'رقم اللوحة',
                          labelStyle: GoogleFonts.cairo(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.pin_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: typeCtrl,
                        decoration: InputDecoration(
                          labelText: 'نوع الناقلة',
                          labelStyle: GoogleFonts.cairo(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.local_shipping_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: capacityCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'سعة الحمولة',
                          labelStyle: GoogleFonts.cairo(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.speed_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: unitCtrl,
                        decoration: InputDecoration(
                          labelText: 'الوحدة',
                          labelStyle: GoogleFonts.cairo(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'ملاحظات التشغيل والوثائق',
                    labelStyle: GoogleFonts.cairo(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final newPlate = plateCtrl.text.trim();
                    if (newPlate.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('يرجى إدخال رقم اللوحة', style: GoogleFonts.cairo()),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final updatedVehicle = (currentVehicle ??
                            const DriverVehicleData(
                              vehicleType: 'شاحنة',
                              category: 'شاحنة نقل بضائع',
                              manufacturer: 'مرسيدس',
                              model: 'أكتروس',
                              year: '2023',
                              plateNumber: '12345 | أ ب ج',
                              color: 'أبيض',
                              maxCapacity: '20',
                              bodyType: 'صندوق مغلق',
                            ))
                        .copyWith(
                      plateNumber: newPlate,
                      vehicleType: typeCtrl.text.trim(),
                      category: categoryCtrl.text.trim(),
                      maxCapacity: capacityCtrl.text.trim(),
                      capacityUnit: unitCtrl.text.trim(),
                      operatingNotes: notesCtrl.text.trim(),
                    );

                    AuthSimulationStore.instance.updateDriverVehicle(
                      userId: user.id,
                      vehicleData: updatedVehicle,
                    );

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم تحديث بيانات الناقلة بنجاح (قيد التوثيق التجريبي)',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                        duration: const Duration(seconds: 2),
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('حفظ بيانات الناقلة',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INFORMATION DIALOGS
  // ---------------------------------------------------------------------------
  void _showInfoSheet({
    required String title,
    required IconData icon,
    required List<MapEntry<String, String>> details,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: const Color(0xFF2563EB), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...details.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.key, style: GoogleFonts.cairo(fontSize: 12.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.value,
                            textAlign: TextAlign.end,
                            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text('إغلاق', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openChangePhotoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.camera_alt_rounded, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('تغيير الصورة الشخصية', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          content: Text(
            'تغيير الصورة متاح تجريبياً في النموذج الأولي. تم اعتماد صورة السائق الرسمية في الملف.',
            style: GoogleFonts.cairo(fontSize: 13, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('حسناً', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _openChangePinDialog() {
    final pinCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('تغيير رمز التأكيد (PIN)', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('أدخل الرمز السري الجديد المكون من 4 أرقام:', style: GoogleFonts.cairo(fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: pinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  hintText: '••••',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء', style: GoogleFonts.cairo())),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تحديث رمز التأكيد بنجاح', style: GoogleFonts.cairo()),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              child: Text('حفظ', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openChangePasswordDialog() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('تغيير كلمة المرور', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPassCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                  labelStyle: GoogleFonts.cairo(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPassCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  labelStyle: GoogleFonts.cairo(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء', style: GoogleFonts.cairo())),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تغيير كلمة المرور بنجاح', style: GoogleFonts.cairo()),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              child: Text('تحديث', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openTermsDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: GoogleFonts.cairo(fontSize: 13, height: 1.6),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إغلاق', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _openSocialChannelsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('قنوات التواصل الرسمية لمنصة حمولة', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.language_rounded, color: Color(0xFF2563EB)),
                title: Text('الموقع الرسمي: www.hamoola.app', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
              ListTile(
                leading: const Icon(Icons.send_rounded, color: Color(0xFF0284C7)),
                title: Text('قناة تيليجرام: @hamoola_drivers', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
              ListTile(
                leading: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF16A34A)),
                title: Text('واتساب خدمة الكباتن: +967 777 000 111', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openReportProblemDialog() {
    final problemCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('الإبلاغ عن مشكلة', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('يرجى كتابة تفاصيل المشكلة التي تواجهك أثناء استخدام التطبيق أو أثناء الرحلة:', style: GoogleFonts.cairo(fontSize: 12.5)),
              const SizedBox(height: 10),
              TextField(
                controller: problemCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'اكتب وصف المشكلة هنا...',
                  hintStyle: GoogleFonts.cairo(fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء', style: GoogleFonts.cairo())),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم استلام البلاغ، وسيقوم فريق الدعم بمتابعته فوراً', style: GoogleFonts.cairo()),
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
              child: Text('إرسال البلاغ', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openHelpRequestDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.headset_mic_rounded, color: Color(0xFF9333EA)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('طلب مساعدة فورية', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          content: Text(
            'فريق الدعم الفني وخدمات الطوارئ اللوجستية متاح على مدار الساعة لمساعدة الكباتن على الطرقات.',
            style: GoogleFonts.cairo(fontSize: 13, height: 1.5),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء', style: GoogleFonts.cairo())),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                TollFreeDialerModalSheet.show(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9333EA)),
              child: Text('اتصال مباشر', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openAppSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('إعدادات التطبيق', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                dense: true,
                leading: const Icon(Icons.language_rounded, color: Color(0xFF2563EB)),
                title: Text('اللغة: العربية (الافتراضية)', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.light_mode_rounded, color: Color(0xFFEA580C)),
                title: Text('المظهر: المظهر الفاتح المعتمد', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.notifications_active_rounded, color: Color(0xFF059669)),
                title: Text('الإشعارات: مفعلة لكافة التنبيهات والطلبات', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('حسناً', style: GoogleFonts.cairo())),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('تأكيد تسجيل الخروج', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في تسجيل الخروج من حساب السائق في منصة حمولة؟',
            style: GoogleFonts.cairo(fontSize: 13, height: 1.5),
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
                if (widget.onLogout != null) {
                  widget.onLogout!();
                } else {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('تسجيل الخروج', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvailabilityToggleModal() {
    final user = _currentDriverUser;
    final isAvailable = user.isDriverAvailable;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('تحديث حالة السائق', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              SwitchListTile(
                value: isAvailable,
                activeThumbColor: const Color(0xFF16A34A),
                title: Text(isAvailable ? 'متاح الآن لاستقبال الطلبات' : 'غير متاح حالياً',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                subtitle: Text('التحكم في ظهورك في سوق الحمولات واستقبال عروض النقل',
                    style: GoogleFonts.cairo(fontSize: 11.5)),
                onChanged: (val) {
                  AuthSimulationStore.instance.setDriverAvailability(userId: user.id, isAvailable: val);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = _currentDriverUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.navyDark : const Color(0xFFF8FAFC),
        bottomNavigationBar: MerchantBottomNavBar(
          currentTab: MerchantNavTab.account,
          isQuickActionsOpen: _isQuickActionsOpen,
          onTabSelected: (tab) {
            if (_isQuickActionsOpen) {
              setState(() => _isQuickActionsOpen = false);
            }
            if (tab == MerchantNavTab.home) {
              if (widget.onHome != null) {
                widget.onHome!();
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            } else if (tab == MerchantNavTab.orders) {
              if (widget.onOrders != null) {
                widget.onOrders!();
              } else {
                _showInfoSheet(
                  title: 'إدارة الطلبات والرحلات',
                  icon: Icons.assignment_rounded,
                  details: [
                    MapEntry('الطلبات النشطة', '$_activeOrdersCount طلبات قيد المتابعة'),
                    MapEntry('الرحلات المكتملة', '$_completedTripsCount رحلة منجزة بنجاح'),
                  ],
                );
              }
            } else if (tab == MerchantNavTab.map) {
              if (widget.onMap != null) {
                widget.onMap!();
              } else {
                _showInfoSheet(
                  title: 'خريطة الحمولات والموانئ',
                  icon: Icons.map_rounded,
                  details: const [
                    MapEntry('محافظة الانطلاق', 'صنعاء - جولة آية'),
                    MapEntry('محافظة الوصول', 'عدن - ميناء المعلا'),
                    MapEntry('تتبع الشاحنات', 'ميزة تتبع GPS نشطة'),
                  ],
                );
              }
            }
          },
          onFabPressed: () {
            setState(() => _isQuickActionsOpen = !_isQuickActionsOpen);
          },
        ),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppBreakpoints.compactMax),
                  child: Column(
                    children: [
                      // 1. Top Bar: "< حسابي" with settings gear
                      _buildHeader(isDark),

                      // 2. Scrollable Body
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spaceMd,
                            vertical: AppDimensions.spaceSm,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Profile Card
                              _buildProfileCard(user, isDark),
                              const SizedBox(height: 14),

                              // 3 Professional Statistics Cards
                              _buildStatisticsRow(isDark),
                              const SizedBox(height: 18),

                              // Section: "بيانات السائق"
                              _buildDriverDataSection(user, isDark),
                              const SizedBox(height: 16),

                              // Section: "بيانات الناقلة" (With inside "تحديث بيانات الناقلة" button)
                              _buildTransporterDataSection(user, isDark),
                              const SizedBox(height: 16),

                              // Section: "الخصوصية والأمان"
                              _buildPrivacySecuritySection(isDark),
                              const SizedBox(height: 16),

                              // Section: "الدعم والمساعدة"
                              _buildSupportSection(isDark),
                              const SizedBox(height: 16),

                              // Section: "إعدادات التطبيق"
                              _buildAppSettingsSection(isDark),
                              const SizedBox(height: 20),

                              // Red Logout Button Card
                              _buildLogoutCard(isDark),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Dimmed Overlay when Quick Actions modal is open
              if (_isQuickActionsOpen) ...[
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _isQuickActionsOpen = false),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.58),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  child: _buildQuickActionsModal(isDark),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. TOP HEADER (رأس الشاشة)
  // ===========================================================================
  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Settings Gear Icon on the Left (in RTL)
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF1E293B), size: 24),
            tooltip: 'إعدادات التطبيق',
            onPressed: _openAppSettingsDialog,
          ),

          // Title: "حسابي" in Center
          Text(
            'حسابي',
            style: GoogleFonts.cairo(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),

          // Back Chevron on the Right (in RTL)
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF1E293B), size: 28),
            tooltip: 'رجوع',
            onPressed: widget.onBack ??
                () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else if (widget.onHome != null) {
                    widget.onHome!();
                  }
                },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. DRIVER PROFILE CARD (بطاقة الملف الشخصي للسائق)
  // ===========================================================================
  Widget _buildProfileCard(AuthUser user, bool isDark) {
    // Dynamic status badge setup
    final status = user.verificationStatus;
    Color badgeColor;
    Color badgeBg;
    String badgeText;
    IconData badgeIcon;

    if (status == AccountVerificationStatus.verified) {
      badgeColor = const Color(0xFF10B981);
      badgeBg = const Color(0xFFECFDF5);
      badgeText = 'حساب موثّق';
      badgeIcon = Icons.check_circle_rounded;
    } else if (status == AccountVerificationStatus.pendingReview) {
      badgeColor = const Color(0xFFF59E0B);
      badgeBg = const Color(0xFFFFFBEB);
      badgeText = 'قيد المراجعة';
      badgeIcon = Icons.access_time_rounded;
    } else {
      badgeColor = const Color(0xFF64748B);
      badgeBg = const Color(0xFFF1F5F9);
      badgeText = 'يتطلب استكمال البيانات';
      badgeIcon = Icons.info_outline_rounded;
    }

    final displayDriverId = user.id == 'USR-DRIVER-01' ? '783707104' : user.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row: Avatar with Camera badge + Name & Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with camera edit badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(0xFFE2E8F0),
                    backgroundImage: const AssetImage('assets/images/driver_ahmed_avatar.jpg'),
                    onBackgroundImageError: (exception, stackTrace) {},
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _openChangePhotoDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Name, Subtitle, Status Pill
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'سائق في منصة حمولة',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Dynamic verification badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badgeIcon, size: 13, color: badgeColor),
                          const SizedBox(width: 4),
                          Text(
                            badgeText,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: badgeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Two Info Items: Phone Number & Driver ID
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 6,
            spacing: 12,
            children: [
              // Phone
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone_outlined, size: 15, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    _formatPhone(user.countryCode, user.phone),
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),

              // Driver ID
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.badge_outlined, size: 15, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    'رقم السائق: $displayDriverId',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // "تعديل الملف الشخصي" Full-Width Action Button
          InkWell(
            onTap: _openEditProfileDialog,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), // Light blue background matching mockup
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF2563EB)),
                  const SizedBox(width: 6),
                  Text(
                    'تعديل الملف الشخصي',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. THREE PROFESSIONAL STATISTICS CARDS (بطاقات الإحصاءات المهنية)
  // ===========================================================================
  Widget _buildStatisticsRow(bool isDark) {
    return Row(
      children: [
        // 1. Green Card: حمولة منقولة
        Expanded(
          child: _buildStatCard(
            title: 'حمولة منقولة',
            count: '$_transportedCargosCount',
            icon: Icons.local_shipping_rounded,
            iconColor: const Color(0xFF16A34A), // Green
            bgColor: const Color(0xFFF0FDF4),
            borderColor: const Color(0xFFBBF7D0),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),

        // 2. Blue Card: طلبات نشطة
        Expanded(
          child: _buildStatCard(
            title: 'طلبات نشطة',
            count: '$_activeOrdersCount',
            icon: Icons.description_rounded,
            iconColor: const Color(0xFF2563EB), // Blue
            bgColor: const Color(0xFFEFF6FF),
            borderColor: const Color(0xFFBFDBFE),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),

        // 3. Orange Card: رحلة مكتملة
        Expanded(
          child: _buildStatCard(
            title: 'رحلة مكتملة',
            count: '$_completedTripsCount',
            icon: Icons.check_box_rounded,
            iconColor: const Color(0xFFEA580C), // Orange
            bgColor: const Color(0xFFFFF7ED),
            borderColor: const Color(0xFFFED7AA),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : borderColor.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 6),
          Text(
            count,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. DRIVER DATA SECTION (قسم بيانات السائق)
  // ===========================================================================
  Widget _buildDriverDataSection(AuthUser user, bool isDark) {
    final identity = user.driverData?.identityData ?? user.identityData;
    final license = user.driverData?.licenseData;

    return _buildSectionCard(
      title: 'بيانات السائق',
      headerIcon: Icons.person_rounded,
      headerIconColor: const Color(0xFF2563EB),
      isExpanded: _isDriverDataExpanded,
      onToggle: () => setState(() => _isDriverDataExpanded = !_isDriverDataExpanded),
      isDark: isDark,
      children: [
        // 1. المعلومات الشخصية
        _buildListRowItem(
          icon: Icons.person_rounded,
          iconBgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'المعلومات الشخصية',
          isDark: isDark,
          onTap: () {
            _showInfoSheet(
              title: 'المعلومات الشخصية للسائق',
              icon: Icons.person_rounded,
              details: [
                MapEntry('الاسم الكامل', user.name),
                MapEntry('مكان وتاريخ الميلاد', '${identity?.birthPlace ?? "صنعاء"} - ${identity?.birthDate ?? "1988-03-12"}'),
                MapEntry('الجنسية', identity?.nationality ?? 'اليمن'),
                MapEntry('الحالة المهنية', 'سائق نقل ثقيل معتمد'),
              ],
            );
          },
        ),
        _buildThinDivider(),

        // 2. بيانات الهوية الوطنية
        _buildListRowItem(
          icon: Icons.badge_rounded,
          iconBgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'بيانات الهوية الوطنية',
          isDark: isDark,
          onTap: () {
            _showInfoSheet(
              title: 'بيانات الهوية الوطنية',
              icon: Icons.badge_rounded,
              details: [
                MapEntry('نوع الوثيقة', identity?.idType ?? 'بطاقة شخصية ذكية'),
                MapEntry('رقم الهوية', identity?.idNumber ?? '11020304050'),
                MapEntry('جهة الإصدار', identity?.issuePlace ?? 'صنعاء - السبعين'),
                MapEntry('تاريخ الإصدار والانتهاء', '${identity?.issueDate ?? "2020-05-10"} / ${identity?.expiryDate ?? "2030-05-09"}'),
                MapEntry('حالة التوثيق', user.verificationStatus.label),
              ],
            );
          },
        ),
        _buildThinDivider(),

        // 3. رخصة القيادة
        _buildListRowItem(
          icon: Icons.credit_card_rounded,
          iconBgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'رخصة القيادة',
          isDark: isDark,
          onTap: () {
            _showInfoSheet(
              title: 'تفاصيل رخصة القيادة',
              icon: Icons.credit_card_rounded,
              details: [
                MapEntry('رقم الرخصة', license?.licenseNumber ?? 'DL-942851'),
                MapEntry('فئة الرخصة', license?.licenseCategory ?? 'نقل ثقيل (شاحنات وقاطرات)'),
                MapEntry('جهة وتاريخ الإصدار', '${license?.issuePlace ?? "مرور تعز"} - ${license?.issueDate ?? "2021-09-15"}'),
                MapEntry('تاريخ الانتهاء', license?.expiryDate ?? '2026-09-14'),
                MapEntry('صلاحية القيادة', 'سارية ومؤهلة لنقل البضائع والمحروقات'),
              ],
            );
          },
        ),
        _buildThinDivider(),

        // 4. بيانات التواصل
        _buildListRowItem(
          icon: Icons.phone_rounded,
          iconBgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'بيانات التواصل',
          isDark: isDark,
          onTap: () {
            _showInfoSheet(
              title: 'بيانات التواصل',
              icon: Icons.phone_rounded,
              details: [
                MapEntry('رقم الهاتف المسجل', user.fullPhoneNumber),
                MapEntry('رمز الدولة', user.countryCode),
                MapEntry('حالة التحقق', user.isPhoneVerified ? 'متحقق منه عبر OTP ✓' : 'غير متحقق'),
              ],
            );
          },
        ),
        _buildThinDivider(),

        // 5. العنوان والموقع
        _buildListRowItem(
          icon: Icons.location_on_rounded,
          iconBgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'العنوان والموقع',
          isDark: isDark,
          onTap: () {
            _showInfoSheet(
              title: 'العنوان والموقع',
              icon: Icons.location_on_rounded,
              details: const [
                MapEntry('المحافظة', 'صنعاء'),
                MapEntry('المدينة / المديرية', 'أمانة العاصمة - السبعين'),
                MapEntry('نطاق العمل الرئيسي', 'خطوط النقل بين المحافظات والموانئ'),
              ],
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // 5. TRANSPORTER DATA SECTION (قسم بيانات الناقلة)
  // ===========================================================================
  Widget _buildTransporterDataSection(AuthUser user, bool isDark) {
    final vehicle = user.driverData?.vehicleData;
    final plateNumber = vehicle?.plateNumber ?? '12345 | أ ب ج';
    final vehicleType = vehicle?.vehicleType ?? 'شاحنة';
    final capacity = '${vehicle?.maxCapacity ?? "20"} ${vehicle?.capacityUnit ?? "طن"}';
    final category = (vehicle?.category != null && vehicle!.category != 'نقل ثقيل')
        ? vehicle.category
        : 'شاحنة نقل بضائع';

    return _buildSectionCard(
      title: 'بيانات الناقلة',
      headerIcon: Icons.local_shipping_rounded,
      headerIconColor: const Color(0xFF2563EB),
      isExpanded: _isVehicleDataExpanded,
      onToggle: () => setState(() => _isVehicleDataExpanded = !_isVehicleDataExpanded),
      isDark: isDark,
      children: [
        // Truck Info Row with Photo on Left (in RTL) and Specs on Right
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Truck image on the Right or Left
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/driver_hero_actros.jpg',
                width: 95,
                height: 75,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 95,
                  height: 75,
                  color: const Color(0xFFE2E8F0),
                  child: const Icon(Icons.local_shipping_rounded, color: Color(0xFF94A3B8), size: 36),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Vehicle Details & Specs
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Verified pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 11, color: Color(0xFF10B981)),
                            const SizedBox(width: 3),
                            Text(
                              'معتمدة',
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Specs list with small icons
                  Row(
                    children: [
                      const Icon(Icons.pin_outlined, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'رقم اللوحة: $plateNumber',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'نوع الناقلة: $vehicleType',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.speed_outlined, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'سعة الحمولة: $capacity',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Action Button inside Transporter card: "تحديث بيانات الناقلة"
        InkWell(
          onTap: _openUpdateVehicleDialog,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF), // Light blue background
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.settings_outlined, size: 16, color: Color(0xFF2563EB)),
                const SizedBox(width: 6),
                Text(
                  'تحديث بيانات الناقلة',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 6. PRIVACY & SECURITY SECTION (قسم الخصوصية والأمان)
  // ===========================================================================
  Widget _buildPrivacySecuritySection(bool isDark) {
    return _buildSectionCard(
      title: 'الخصوصية والأمان',
      headerIcon: Icons.shield_rounded,
      headerIconColor: const Color(0xFF2563EB),
      isExpanded: _isSecurityExpanded,
      onToggle: () => setState(() => _isSecurityExpanded = !_isSecurityExpanded),
      isDark: isDark,
      children: [
        // 1. تغيير رمز التأكيد
        _buildListRowItem(
          icon: Icons.lock_rounded,
          iconBgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'تغيير رمز التأكيد',
          isDark: isDark,
          onTap: _openChangePinDialog,
        ),
        _buildThinDivider(),

        // 2. تغيير كلمة المرور
        _buildListRowItem(
          icon: Icons.key_rounded,
          iconBgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'تغيير كلمة المرور',
          isDark: isDark,
          onTap: _openChangePasswordDialog,
        ),
        _buildThinDivider(),

        // 3. استخدام البصمة لتسجيل الدخول
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'استخدام البصمة لتسجيل الدخول',
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              Switch(
                value: _useBiometricsLogin,
                activeThumbColor: const Color(0xFF2563EB),
                onChanged: (val) {
                  setState(() => _useBiometricsLogin = val);
                },
              ),
            ],
          ),
        ),
        _buildThinDivider(),

        // 4. استخدام البصمة لتأكيد الدفع
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'استخدام البصمة لتأكيد الدفع',
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              Switch(
                value: _useBiometricsPayment,
                activeThumbColor: const Color(0xFF2563EB),
                onChanged: (val) {
                  setState(() => _useBiometricsPayment = val);
                },
              ),
            ],
          ),
        ),
        _buildThinDivider(),

        // 5. سياسة الخصوصية
        _buildListRowItem(
          icon: Icons.description_rounded,
          iconBgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'سياسة الخصوصية',
          isDark: isDark,
          onTap: () {
            _openTermsDialog(
              title: 'سياسة الخصوصية لمنصة حمولة',
              content: 'تلتزم منصة حمولة بحماية بيانات السائقين ومواقع الشاحنات وأرقام الهواتف وبيانات الدفع ولا تتم مشاركتها إلا لأغراض إتمام عقود النقل الرسمية وتأمين البضائع.',
            );
          },
        ),
        _buildThinDivider(),

        // 6. الشروط والأحكام
        _buildListRowItem(
          icon: Icons.assignment_rounded,
          iconBgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'الشروط والأحكام',
          isDark: isDark,
          onTap: () {
            _openTermsDialog(
              title: 'الشروط والأحكام الخاصة بالسائقين',
              content: 'تشمل شروط تقديم خدمات النقل عبر منصة حمولة: الالتزام بسلامة الحمولة، الحضور في موعد التحميل المحدد، توثيق وثيقة الاستلام والتفريغ، وعدم فرض أي رسوم غير مسجلة في العرض المعتمد.',
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // 7. SUPPORT & HELP SECTION (قسم الدعم والمساعدة)
  // ===========================================================================
  Widget _buildSupportSection(bool isDark) {
    return _buildSectionCard(
      title: 'الدعم والمساعدة',
      headerIcon: Icons.headset_mic_rounded,
      headerIconColor: const Color(0xFF9333EA), // Purple
      isExpanded: _isSupportExpanded,
      onToggle: () => setState(() => _isSupportExpanded = !_isSupportExpanded),
      isDark: isDark,
      children: [
        // 1. خدمة العملاء
        _buildListRowItem(
          icon: Icons.chat_rounded,
          iconBgColor: const Color(0xFFF1F5F9),
          iconColor: const Color(0xFF0F172A),
          title: 'خدمة العملاء',
          isDark: isDark,
          onTap: () {
            if (widget.onSupport != null) {
              widget.onSupport!();
            } else {
              _showInfoSheet(
                title: 'خدمة العملاء لكباتن حمولة',
                icon: Icons.chat_rounded,
                details: const [
                  MapEntry('ساعات العمل', '24 ساعة على مدار الأسبوع'),
                  MapEntry('الرقم المجاني', '800-HAMOOLA (800-4266)'),
                  MapEntry('البريد الإلكتروني', 'support@hamoola.app'),
                ],
              );
            }
          },
        ),
        _buildThinDivider(),

        // 2. مواقع التواصل
        _buildListRowItem(
          icon: Icons.share_rounded,
          iconBgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'مواقع التواصل',
          isDark: isDark,
          onTap: _openSocialChannelsSheet,
        ),
        _buildThinDivider(),

        // 3. الرقم المجاني
        _buildListRowItem(
          icon: Icons.phone_rounded,
          iconBgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'الرقم المجاني',
          isDark: isDark,
          onTap: () => TollFreeDialerModalSheet.show(context),
        ),
        _buildThinDivider(),

        // 4. نقاط الخدمة
        _buildListRowItem(
          icon: Icons.location_on_rounded,
          iconBgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'نقاط الخدمة',
          isDark: isDark,
          onTap: () {
            _showInfoSheet(
              title: 'نقاط خدمة وفحص الشاحنات',
              icon: Icons.location_on_rounded,
              details: const [
                MapEntry('نقطة صنعاء', 'طريق المطار - محطة حمولة اللوجستية'),
                MapEntry('نقطة الحديدة', 'شارع الميناء - مجمع النقل الثقيل'),
                MapEntry('نقطة عدن', 'البريقة - مركز صيانة الشاحنات'),
              ],
            );
          },
        ),
        _buildThinDivider(),

        // 5. الإبلاغ عن مشكلة
        _buildListRowItem(
          icon: Icons.warning_rounded,
          iconBgColor: const Color(0xFFFEF2F2),
          iconColor: const Color(0xFFDC2626),
          title: 'الإبلاغ عن مشكلة',
          isDark: isDark,
          onTap: _openReportProblemDialog,
        ),
        _buildThinDivider(),

        // 6. طلب مساعدة
        _buildListRowItem(
          icon: Icons.headset_mic_rounded,
          iconBgColor: const Color(0xFFFAF5FF),
          iconColor: const Color(0xFF9333EA),
          title: 'طلب مساعدة',
          isDark: isDark,
          onTap: _openHelpRequestDialog,
        ),
      ],
    );
  }

  // ===========================================================================
  // 8. APP SETTINGS SECTION (قسم إعدادات التطبيق)
  // ===========================================================================
  Widget _buildAppSettingsSection(bool isDark) {
    return _buildSectionCard(
      title: 'إعدادات التطبيق',
      headerIcon: Icons.settings_rounded,
      headerIconColor: const Color(0xFF2563EB),
      isExpanded: _isSettingsExpanded,
      onToggle: () => setState(() => _isSettingsExpanded = !_isSettingsExpanded),
      isDark: isDark,
      children: [
        // 1. اللغة
        _buildListRowItem(
          icon: Icons.language_rounded,
          iconBgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'اللغة',
          trailingText: 'العربية',
          isDark: isDark,
          onTap: () {
            _showInfoSheet(
              title: 'لغة التطبيق',
              icon: Icons.language_rounded,
              details: const [
                MapEntry('اللغة النشطة', 'العربية (اليمن) ✓'),
                MapEntry('اللغات المتاحة', 'العربية مدعومة حالياً بالكامل'),
              ],
            );
          },
        ),
        _buildThinDivider(),

        // 2. المظهر
        _buildListRowItem(
          icon: Icons.wb_sunny_rounded,
          iconBgColor: const Color(0xFFFFF7ED),
          iconColor: const Color(0xFFEA580C),
          title: 'المظهر',
          trailingText: 'الفاتح',
          isDark: isDark,
          onTap: () {
            _showInfoSheet(
              title: 'مظهر التطبيق',
              icon: Icons.wb_sunny_rounded,
              details: const [
                MapEntry('النمط الحالي', 'المظهر الفاتح المعتمد ✓'),
                MapEntry('المظهر الداكن', 'متاح تلقائياً بحسب إعدادات النظام'),
              ],
            );
          },
        ),
        _buildThinDivider(),

        // 3. إعدادات الإشعارات
        _buildListRowItem(
          icon: Icons.notifications_rounded,
          iconBgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'إعدادات الإشعارات',
          isDark: isDark,
          onTap: () {
            _showInfoSheet(
              title: 'تفضيلات إشعارات السائق',
              icon: Icons.notifications_rounded,
              details: const [
                MapEntry('تنبيهات الحمولات الجديدة', 'مفعلة ✓'),
                MapEntry('عروض الأسعار المعتمدة', 'مفعلة ✓'),
                MapEntry('إشعارات الدفع والتحصيل', 'مفعلة ✓'),
              ],
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // 9. LOGOUT BUTTON CARD (زر تسجيل الخروج)
  // ===========================================================================
  Widget _buildLogoutCard(bool isDark) {
    return InkWell(
      onTap: _confirmLogout,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2), // Light pink/red background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFEE2E2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Color(0xFFE11D48), size: 20),
            const SizedBox(width: 8),
            Text(
              'تسجيل الخروج',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFE11D48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 10. QUICK ACTIONS MODAL (+)
  // ===========================================================================
  Widget _buildQuickActionsModal(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark Navy
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4 Quadrants
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                Column(
                  children: [
                    // Top Row
                    Expanded(
                      child: Row(
                        children: [
                          // Top Right: تحديث الحالة
                          Expanded(
                            child: _buildQuadrantItem(
                              title: 'تحديث الحالة',
                              icon: Icons.power_settings_new_rounded,
                              iconBg: const Color(0xFF059669),
                              onTap: () {
                                setState(() => _isQuickActionsOpen = false);
                                _showAvailabilityToggleModal();
                              },
                            ),
                          ),
                          // Top Left: الطلبات المتاحة
                          Expanded(
                            child: _buildQuadrantItem(
                              title: 'الطلبات المتاحة',
                              icon: Icons.local_shipping_rounded,
                              iconBg: const Color(0xFF2563EB),
                              onTap: () {
                                setState(() => _isQuickActionsOpen = false);
                                if (widget.onHome != null) {
                                  widget.onHome!();
                                } else if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Row
                    Expanded(
                      child: Row(
                        children: [
                          // Bottom Right: طلب مساعدة
                          Expanded(
                            child: _buildQuadrantItem(
                              title: 'طلب مساعدة',
                              icon: Icons.headset_mic_rounded,
                              iconBg: const Color(0xFF9333EA),
                              onTap: () {
                                setState(() => _isQuickActionsOpen = false);
                                _openHelpRequestDialog();
                              },
                            ),
                          ),
                          // Bottom Left: الإبلاغ عن مشكلة
                          Expanded(
                            child: _buildQuadrantItem(
                              title: 'الإبلاغ عن مشكلة',
                              icon: Icons.warning_amber_rounded,
                              iconBg: const Color(0xFFDC2626),
                              onTap: () {
                                setState(() => _isQuickActionsOpen = false);
                                _openReportProblemDialog();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Dividing Lines forming (+)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuadrantItem({
    required String title,
    required IconData icon,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconBg.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // HELPER WIDGETS
  // ===========================================================================
  Widget _buildSectionCard({
    required String title,
    required IconData headerIcon,
    required Color headerIconColor,
    required bool isExpanded,
    required VoidCallback onToggle,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Header Row
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(headerIcon, color: headerIconColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF64748B),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListRowItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    String? trailingText,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 4),
            ],
            const Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThinDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Divider(height: 1, color: Color(0xFFF8FAFC)),
    );
  }
}
