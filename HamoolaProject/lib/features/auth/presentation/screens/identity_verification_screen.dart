import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../widgets/smart_id_scanner_modal.dart';

/// Screen 14 in Prototype: "بيانات الهوية والتوثيق" (Identity Verification Screen).
/// Directly matches Images 3, 4, 5 from the user:
/// - Header with "بيانات الهوية" and rounded back button
/// - Personal avatar selector with camera icon and orange "+" badge ("الصورة الشخصية")
/// - "توثيق الهوية • حساب مواطن" status pill with amber dot
/// - "توثيق الهوية" heading with "اختياري" tag
/// - Dropdowns: "نوع الهوية" & "الجنسية"
/// - "رقم البطاقة الشخصية" with interactive smart scanner icon ("أو [الماسح الذكي]")
/// - Smart scanner modal autofocuses and auto-populates all official data
/// - "جهة إصدار الهوية", "تاريخ إصدار الهوية", "تاريخ إنتهاء الهوية" with date pickers
/// - "مكان الميلاد" & "تاريخ الميلاد"
/// - 3 Document photo upload cards:
///   1. صورة الهوية من الأمام (`id_front_preview.jpg`)
///   2. صورة الهوية من الخلف (`id_back_preview.jpg`)
///   3. صورة سيلفي مع الهوية (`id_selfie_preview.jpg`)
/// - Delete (X) and "تغيير الصورة" interactive photo management
/// - Sticky bottom actions: "توثيق الحساب" and "تخطي الآن"
class IdentityVerificationScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final ValueChanged<bool>? onVerificationComplete;

  const IdentityVerificationScreen({
    super.key,
    this.onBack,
    this.onSkip,
    this.onVerificationComplete,
  });

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Fields Controllers matching the screenshot
  final _idNumberController = TextEditingController(text: '11010290469');
  final _issuePlaceController = TextEditingController(text: 'حجة');
  final _issueDateController = TextEditingController(text: '2026-4-5');
  final _expiryDateController = TextEditingController(text: '2036-4-4');
  final _birthPlaceController = TextEditingController(text: 'حجة - مبين - الجبر');
  final _birthDateController = TextEditingController(text: '1995-08-12');

  String _idType = 'بطاقة شخصية';
  String _nationality = 'يمني';

  // Photo States matching Image 5
  String? _avatarPath = 'assets/images/avatar_personal_preview.jpg';
  String? _frontPhotoPath = 'assets/images/id_front_preview.jpg';
  String? _backPhotoPath = 'assets/images/id_back_preview.jpg';
  String? _selfiePhotoPath = 'assets/images/id_selfie_preview.jpg';

  bool _isSubmitting = false;

  @override
  void dispose() {
    _idNumberController.dispose();
    _issuePlaceController.dispose();
    _issueDateController.dispose();
    _expiryDateController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _openSmartScanner() {
    SmartIdScannerModal.show(
      context,
      onScannedDataApplied: () {
        setState(() {
          _idNumberController.text = '11010290469';
          _issuePlaceController.text = 'حجة';
          _issueDateController.text = '2026-4-5';
          _expiryDateController.text = '2036-4-4';
          _birthPlaceController.text = 'حجة - مبين - الجبر';
          _birthDateController.text = '1995-08-12';
          _frontPhotoPath = 'assets/images/id_front_preview.jpg';
          _backPhotoPath = 'assets/images/id_back_preview.jpg';
          _selfiePhotoPath = 'assets/images/id_selfie_preview.jpg';
        });
      },
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1950),
      lastDate: DateTime(2050),
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
        controller.text = '${picked.year}-${picked.month}-${picked.day}';
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
                  'اختيار مصدر الصورة',
                  style: GoogleFonts.cairo(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFFE67E22)),
                  title: Text('التقاط بالكاميرا الآن', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _simulatePhotoSelect(target);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF1E3A5F)),
                  title: Text('اختيار من ألبوم الصور', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
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
      if (target == 'avatar') {
        _avatarPath = 'assets/images/avatar_personal_preview.jpg';
      } else if (target == 'front') {
        _frontPhotoPath = 'assets/images/id_front_preview.jpg';
      } else if (target == 'back') {
        _backPhotoPath = 'assets/images/id_back_preview.jpg';
      } else if (target == 'selfie') {
        _selfiePhotoPath = 'assets/images/id_selfie_preview.jpg';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث الصورة بنجاح', style: GoogleFonts.cairo()),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitVerification() {
    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10.0),
              Container(
                width: 64.0,
                height: 64.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF16A34A),
                  size: 40.0,
                ),
              ),
              const SizedBox(height: 18.0),
              Text(
                'تم توثيق الحساب بنجاح ✓',
                style: GoogleFonts.cairo(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                'تم استلام بيانات الهوية والوثائق بنجاح وتم تفعيل جميع ميزات حسابك في منصة حمولة.',
                style: GoogleFonts.cairo(
                  fontSize: 13.0,
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                height: 46.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.onVerificationComplete?.call(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE67E22),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: Text(
                    'متابعة إلى الرئيسية',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppBreakpoints.compactMax),
            child: Column(
              children: [
                // Scrollable Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space2xl,
                      vertical: AppDimensions.spaceMd,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Personal Avatar with Camera icon & "+" badge
                          _buildAvatarSection(isDark),
                          const SizedBox(height: 16.0),

                          // 2. Status Pill Badge: "توثيق الهوية • حساب مواطن"
                          _buildStatusPillBadge(),
                          const SizedBox(height: 12.0),

                          // 3. Section Title with "اختياري" tag
                          _buildSectionTitle(),
                          const SizedBox(height: 18.0),

                          // 4. Dropdowns: نوع الهوية & الجنسية
                          _buildDropdownField(
                            label: 'نوع الهوية',
                            value: _idType,
                            items: const ['بطاقة شخصية', 'جواز سفر', 'بطاقة عائلية'],
                            onChanged: (val) => setState(() => _idType = val!),
                            isDark: isDark,
                          ),
                          const SizedBox(height: 14.0),

                          _buildDropdownField(
                            label: 'الجنسية',
                            value: _nationality,
                            items: const ['يمني', 'أخرى'],
                            onChanged: (val) => setState(() => _nationality = val!),
                            isDark: isDark,
                          ),
                          const SizedBox(height: 14.0),

                          // 5. رقم البطاقة الشخصية with Smart Scanner Button ("أو [الماسح]")
                          _buildIdNumberField(isDark),
                          const SizedBox(height: 14.0),

                          // 6. جهة إصدار الهوية
                          _buildTextFieldWithTopLabel(
                            label: 'جهة إصدار الهوية',
                            controller: _issuePlaceController,
                            icon: Icons.business_outlined,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 14.0),

                          // 7. تاريخ إصدار الهوية
                          _buildDateFieldWithTopLabel(
                            label: 'تاريخ إصدار الهوية',
                            controller: _issueDateController,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 14.0),

                          // 8. تاريخ إنتهاء الهوية
                          _buildDateFieldWithTopLabel(
                            label: 'تاريخ إنتهاء الهوية',
                            controller: _expiryDateController,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 14.0),

                          // 9. مكان الميلاد
                          _buildTextFieldWithTopLabel(
                            label: 'مكان الميلاد',
                            controller: _birthPlaceController,
                            icon: Icons.location_on_outlined,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 14.0),

                          // 10. تاريخ الميلاد
                          _buildDateFieldWithTopLabel(
                            label: 'تاريخ الميلاد',
                            controller: _birthDateController,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 22.0),

                          // 11. Document Photos Upload Section (Image 5)
                          _buildDocumentPhotosSection(isDark),
                          const SizedBox(height: 24.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sticky Bottom Action Bar
                _buildStickyBottomActions(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'بيانات الهوية',
        style: GoogleFonts.cairo(
          fontSize: 18.0,
          fontWeight: FontWeight.w800,
          color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: InkWell(
            onTap: widget.onBack,
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              width: 38.0,
              height: 38.0,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                ),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.0,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection(bool isDark) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              InkWell(
                onTap: () => _handlePhotoUploadOrChange('avatar'),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 90.0,
                  height: 90.0,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE2E8F0),
                      width: 2.0,
                    ),
                  ),
                  child: ClipOval(
                    child: _avatarPath != null
                        ? Image.asset(
                            _avatarPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.camera_alt_outlined,
                              size: 38.0,
                              color: Color(0xFF64748B),
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_outlined,
                            size: 38.0,
                            color: Color(0xFF64748B),
                          ),
                  ),
                ),
              ),
              // Orange "+" Camera badge
              Positioned(
                top: 2.0,
                right: 2.0,
                child: Container(
                  width: 26.0,
                  height: 26.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE67E22),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.0),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            'الصورة الشخصية',
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPillBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8.0,
              height: 8.0,
              decoration: const BoxDecoration(
                color: Color(0xFFE67E22),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: Text(
                'توثيق الهوية • حساب مواطن',
                style: GoogleFonts.cairo(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB45309),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Center(
      child: Column(
        children: [
          Text(
            'توثيق الهوية',
            style: GoogleFonts.cairo(
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(
              'اختياري',
              style: GoogleFonts.cairo(
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.cairo(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        // Floating Top Label
        Positioned(
          top: -10.0,
          right: 14.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
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

  Widget _buildIdNumberField(bool isDark) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1),
            ),
          ),
          child: Row(
            children: [
              // Smart scanner button ("أو [الماسح]")
              Tooltip(
                message: 'مسح ذكي للبطاقة عبر الكاميرا',
                child: InkWell(
                  onTap: _openSmartScanner,
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Color(0xFFE67E22),
                          size: 18.0,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'أو',
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8.0),

              // ID number text input
              Expanded(
                child: TextFormField(
                  controller: _idNumberController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.start,
                  style: GoogleFonts.cairo(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                  ),
                ),
              ),

              // ID Icon
              const Icon(
                Icons.badge_outlined,
                color: Color(0xFF94A3B8),
                size: 20.0,
              ),
            ],
          ),
        ),
        // Floating Top Label
        Positioned(
          top: -10.0,
          right: 14.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            child: Text(
              'رقم البطاقة الشخصية',
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

  Widget _buildTextFieldWithTopLabel({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1),
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
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                  ),
                ),
              ),
              Icon(icon, color: const Color(0xFF94A3B8), size: 18.0),
            ],
          ),
        ),
        // Floating Top Label
        Positioned(
          top: -10.0,
          right: 14.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
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

  Widget _buildDateFieldWithTopLabel({
    required String label,
    required TextEditingController controller,
    required bool isDark,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: () => _selectDate(controller),
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1),
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
                const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xFFEF4444), // Red calendar icon from screenshot
                  size: 18.0,
                ),
              ],
            ),
          ),
        ),
        // Floating Top Label
        Positioned(
          top: -10.0,
          right: 14.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
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

  Widget _buildDocumentPhotosSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رفع صور وثيقة الهوية',
          style: GoogleFonts.cairo(
            fontSize: 14.0,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            // Card 1: صورة الهوية من الأمام
            Expanded(
              child: _buildPhotoUploadCard(
                title: 'صورة الهوية من الأمام',
                photoPath: _frontPhotoPath,
                onDelete: () => setState(() => _frontPhotoPath = null),
                onChange: () => _handlePhotoUploadOrChange('front'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8.0),

            // Card 2: صورة الهوية من الخلف
            Expanded(
              child: _buildPhotoUploadCard(
                title: 'صورة الهوية من الخلف',
                photoPath: _backPhotoPath,
                onDelete: () => setState(() => _backPhotoPath = null),
                onChange: () => _handlePhotoUploadOrChange('back'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8.0),

            // Card 3: صورة سيلفي مع الهوية
            Expanded(
              child: _buildPhotoUploadCard(
                title: 'صورة سيلفي مع الهوية',
                photoPath: _selfiePhotoPath,
                onDelete: () => setState(() => _selfiePhotoPath = null),
                onChange: () => _handlePhotoUploadOrChange('selfie'),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoUploadCard({
    required String title,
    required String? photoPath,
    required VoidCallback onDelete,
    required VoidCallback onChange,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6.0),

          // Photo Preview Box with Delete (X) button
          Stack(
            children: [
              Container(
                height: 70.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
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
                  top: 4.0,
                  right: 4.0,
                  child: InkWell(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(2.0),
                      decoration: const BoxDecoration(
                        color: Color(0xCC0F172A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 12.0),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6.0),

          // Change Photo Button
          InkWell(
            onTap: onChange,
            borderRadius: BorderRadius.circular(6.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_outlined, size: 12.0, color: Color(0xFF64748B)),
                  const SizedBox(width: 3.0),
                  Flexible(
                    child: Text(
                      'تغيير الصورة',
                      style: GoogleFonts.cairo(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildStickyBottomActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 14.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: Column(
        children: [
          // Primary "توثيق الحساب" Button
          SizedBox(
            width: double.infinity,
            height: 48.0,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67E22),
                foregroundColor: Colors.white,
                elevation: 2.0,
                shadowColor: const Color(0x55E67E22),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'توثيق الحساب',
                      style: GoogleFonts.cairo(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8.0),

          // Secondary "تخطي الآن" Button
          SizedBox(
            width: double.infinity,
            height: 42.0,
            child: OutlinedButton(
              onPressed: widget.onSkip,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              child: Text(
                'تخطي الآن',
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
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
