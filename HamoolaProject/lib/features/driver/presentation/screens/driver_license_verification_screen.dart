import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/domain/models/auth_simulation_store.dart';
import '../../../auth/domain/models/auth_user.dart';

/// Screen: "بيانات السائق والرخصة" (Driver License Verification Screen).
/// Directly matches Images 3 & 4 from the user:
/// - Header with "بيانات السائق والرخصة" and rounded back button
/// - Status badge: "[🪪] بيانات رخصة القيادة"
/// - Floating-label style fields:
///   1. "رقم رخصة القيادة" (DL-942851)
///   2. "نوع / فئة الرخصة" (Dropdown: نقل ثقيل (شاحنات وقاطرات))
///   3. "جهة إصدار الرخصة" (الإدارة العامة للمرور - تعز)
///   4. "تاريخ إصدار الرخصة" (2021-09-15) with DatePicker
///   5. "تاريخ انتهاء الرخصة" (2026-09-14) with DatePicker
/// - Documents Section: "صور رخصة القيادة"
///   2 Photo Cards:
///   - صورة الرخصة (الأمام) (`license_front_preview.jpg`)
///   - صورة الرخصة (الخلف) (`license_back_preview.jpg`)
///   With (✕) delete button and "تغيير الصورة" interactive photo management.
/// - Sticky actions: "متابعة إلى بيانات المركبة" & "تخطي الآن"
class DriverLicenseVerificationScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext; // Proceed to vehicle verification
  final VoidCallback? onSkip;

  const DriverLicenseVerificationScreen({
    super.key,
    this.onBack,
    this.onNext,
    this.onSkip,
  });

  @override
  State<DriverLicenseVerificationScreen> createState() =>
      _DriverLicenseVerificationScreenState();
}

class _DriverLicenseVerificationScreenState
    extends State<DriverLicenseVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _licenseNumberController =
      TextEditingController(text: 'DL-942851');
  final TextEditingController _licenseIssuerController =
      TextEditingController(text: 'الإدارة العامة للمرور - تعز');
  final TextEditingController _licenseIssueDateController =
      TextEditingController(text: '2021-09-15');
  final TextEditingController _licenseExpiryDateController =
      TextEditingController(text: '2026-09-14');

  String _licenseCategory = 'نقل ثقيل (شاحنات وقاطرات)';
  final List<String> _licenseCategories = [
    'نقل ثقيل (شاحنات وقاطرات)',
    'نقل ثقيل',
    'نقل متوسط (شاحنات دينا)',
    'نقل متوسط',
    'عمومي',
    'عمومي درجة أولى',
    'خصوصي',
    'نقل خفيف (وانيت ودبابات)',
  ];

  String? _frontLicensePath = 'assets/images/license_front_preview.jpg';
  String? _backLicensePath = 'assets/images/license_back_preview.jpg';

  @override
  void initState() {
    super.initState();
    final user = AuthSimulationStore.instance.currentUser;
    final savedLicense = user?.driverData?.licenseData;
    if (savedLicense != null) {
      if (savedLicense.licenseNumber.isNotEmpty) {
        _licenseNumberController.text = savedLicense.licenseNumber;
      }
      if (savedLicense.issuePlace.isNotEmpty) {
        _licenseIssuerController.text = savedLicense.issuePlace;
      }
      if (savedLicense.issueDate.isNotEmpty) {
        _licenseIssueDateController.text = savedLicense.issueDate;
      }
      if (savedLicense.expiryDate.isNotEmpty) {
        _licenseExpiryDateController.text = savedLicense.expiryDate;
      }
      if (savedLicense.licenseCategory.isNotEmpty) {
        _licenseCategory = savedLicense.licenseCategory;
      }
      if (savedLicense.frontPhotoPath != null) {
        _frontLicensePath = savedLicense.frontPhotoPath;
      }
      if (savedLicense.backPhotoPath != null) {
        _backLicensePath = savedLicense.backPhotoPath;
      }
    }
  }

  @override
  void dispose() {
    _licenseNumberController.dispose();
    _licenseIssuerController.dispose();
    _licenseIssueDateController.dispose();
    _licenseExpiryDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2045),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE67E22),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _handlePhotoUploadOrChange(String target) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'اختيار صورة رخصة القيادة',
                  style: GoogleFonts.cairo(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFFE67E22),
                  ),
                  title: Text(
                    'التقاط بالكاميرا الآن',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _simulatePhotoSelect(target);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF1E3A5F),
                  ),
                  title: Text(
                    'اختيار من ألبوم الصور',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _simulatePhotoSelect(target);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _simulatePhotoSelect(String target) {
    setState(() {
      if (target == 'front') {
        _frontLicensePath = 'assets/images/license_front_preview.jpg';
      } else if (target == 'back') {
        _backLicensePath = 'assets/images/license_back_preview.jpg';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تحديث صورة الرخصة بنجاح',
          style: GoogleFonts.cairo(),
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleContinue() {
    if (_formKey.currentState?.validate() ?? true) {
      final licenseData = DriverLicenseData(
        licenseNumber: _licenseNumberController.text.trim(),
        licenseCategory: _licenseCategory,
        issuePlace: _licenseIssuerController.text.trim(),
        issueDate: _licenseIssueDateController.text.trim(),
        expiryDate: _licenseExpiryDateController.text.trim(),
        frontPhotoPath: _frontLicensePath,
        backPhotoPath: _backLicensePath,
      );
      final user = AuthSimulationStore.instance.currentUser;
      if (user != null) {
        AuthSimulationStore.instance.saveDriverProgress(
          userId: user.id,
          licenseData: licenseData,
        );
      }
      widget.onNext?.call();
    }
  }

  void _handleSkip() {
    final user = AuthSimulationStore.instance.currentUser;
    if (user != null) {
      AuthSimulationStore.instance.skipDriverVerification(user.id);
    }
    widget.onSkip?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          elevation: 0.5,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: widget.onBack ?? () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  size: 16.0,
                ),
              ),
            ),
          ),
          title: Text(
            'بيانات السائق والرخصة',
            style: GoogleFonts.cairo(
              fontSize: 18.0,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppBreakpoints.compactMax),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceLg,
                        vertical: AppDimensions.spaceMd,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8.0),

                            // 1. Status Pill matching Image 3
                            _buildStatusPill(),
                            const SizedBox(height: 22.0),

                            // 2. Field: رقم رخصة القيادة
                            _buildFieldCard(
                              label: 'رقم رخصة القيادة',
                              controller: _licenseNumberController,
                              icon: Icons.badge_outlined,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16.0),

                            // 3. Dropdown: نوع / فئة الرخصة
                            _buildCategoryDropdown(isDark),
                            const SizedBox(height: 16.0),

                            // 4. Field: جهة إصدار الرخصة
                            _buildFieldCard(
                              label: 'جهة إصدار الرخصة',
                              controller: _licenseIssuerController,
                              icon: Icons.account_balance_outlined,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16.0),

                            // 5. Field: تاريخ إصدار الرخصة (DatePicker)
                            _buildDateFieldCard(
                              label: 'تاريخ إصدار الرخصة',
                              controller: _licenseIssueDateController,
                              icon: Icons.calendar_today_outlined,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16.0),

                            // 6. Field: تاريخ انتهاء الرخصة (DatePicker)
                            _buildDateFieldCard(
                              label: 'تاريخ انتهاء الرخصة',
                              controller: _licenseExpiryDateController,
                              icon: Icons.calendar_month_outlined,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 24.0),

                            // 7. Documents Section matching Image 4
                            _buildLicenseDocumentsSection(isDark),
                            const SizedBox(height: 24.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Sticky Bottom Actions matching Screenshot
                  _buildBottomActions(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill() {
    return Column(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.badge_outlined,
                  color: Color(0xFFE67E22),
                  size: 18.0,
                ),
                const SizedBox(width: 8.0),
                Flexible(
                  child: Text(
                    'بيانات رخصة القيادة',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB45309),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'أدخل بيانات رخصة القيادة للتحقق من أهليتك لتقديم خدمة النقل في حمولة.',
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFieldCard({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1),
              width: 1.1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  style: GoogleFonts.cairo(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Icon(icon, color: const Color(0xFF94A3B8), size: 20.0),
            ],
          ),
        ),
        Positioned(
          top: -8.0,
          right: 14.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textSubtle : const Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateFieldCard({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: () => _pickDate(controller),
          borderRadius: BorderRadius.circular(14.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1),
                width: 1.1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text,
                    style: GoogleFonts.cairo(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Icon(icon, color: const Color(0xFFEF4444), size: 20.0),
              ],
            ),
          ),
        ),
        Positioned(
          top: -8.0,
          right: 14.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textSubtle : const Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(bool isDark) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1),
              width: 1.1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _licenseCategory,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
              style: GoogleFonts.cairo(
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
              items: _licenseCategories.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _licenseCategory = val);
                }
              },
            ),
          ),
        ),
        Positioned(
          top: -8.0,
          right: 14.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            child: Text(
              'نوع / فئة الرخصة',
              style: GoogleFonts.cairo(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textSubtle : const Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLicenseDocumentsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header matching Image 4
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'صور رخصة القيادة',
            style: GoogleFonts.cairo(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 14.0),

        // 2 Side-by-side Photo Cards matching Image 4
        Row(
          children: [
            Expanded(
              child: _buildDocCard(
                title: 'صورة الرخصة (الأمام)',
                photoPath: _frontLicensePath,
                onDelete: () => setState(() => _frontLicensePath = null),
                onChange: () => _handlePhotoUploadOrChange('front'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildDocCard(
                title: 'صورة الرخصة (الخلف)',
                photoPath: _backLicensePath,
                onDelete: () => setState(() => _backLicensePath = null),
                onChange: () => _handlePhotoUploadOrChange('back'),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocCard({
    required String title,
    required String? photoPath,
    required VoidCallback onDelete,
    required VoidCallback onChange,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),

          // Image preview box
          Stack(
            children: [
              Container(
                height: 82.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: photoPath != null
                      ? Image.asset(
                          photoPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.camera_alt_outlined, color: Color(0xFF94A3B8), size: 24.0),
                        ),
                ),
              ),
              if (photoPath != null)
                Positioned(
                  top: 6.0,
                  left: 6.0,
                  child: InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(12.0),
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: const BoxDecoration(
                        color: Color(0xCC0F172A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 13.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8.0),

          // Change photo action button (clean bordered container)
          InkWell(
            onTap: onChange,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              height: 32.0,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Center(
                child: Text(
                  'تغيير الصورة',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : const Color(0xFF334155),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48.0,
            child: ElevatedButton(
              onPressed: _handleContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67E22),
                foregroundColor: Colors.white,
                elevation: 2.0,
                shadowColor: const Color(0x55E67E22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                'متابعة إلى بيانات المركبة',
                style: GoogleFonts.cairo(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            height: 44.0,
            child: OutlinedButton(
              onPressed: _handleSkip,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE2E8F0),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                'تخطي الآن',
                style: GoogleFonts.cairo(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
