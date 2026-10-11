import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Screen: "بيانات مركبتك" (Driver Vehicle Verification Screen - Step 2).
/// Directly matches the user's screenshots:
/// - Header with "بيانات مركبتك" and rounded back button
/// - Section 1 Status badge: "[🚚] بيانات المركبة الأساسية"
///   1. "نوع المركبة" (Dropdown: شاحنة نقل)
///   2. "فئة المركبة" (نقل ثقيل)
///   3. "الماركة" (مرسيدس)
///   4. "الموديل" (أكتروس)
///   5. "سنة الصنع" (2023)
///   6. "رقم اللوحة" (7198 د ح ي)
///   7. "لون المركبة" (أبيض)
/// - Section 2 Status badge: "[⬡] قدرات المركبة"
///   8. "الحمولة القصوى" (25)
///   9. "وحدة القياس" (Dropdown: طن)
///   10. "نوع الهيكل" (Dropdown: صندوق مغلق)
///   11. "سعة المركبة (اختياري)" (65 م³)
/// - Section 3: "صور المركبة"
///   4 Photo Cards (2x2 grid):
///   1. صورة المركبة من الأمام (`vehicle_front_preview.jpg`)
///   2. صورة المركبة من الخلف (`vehicle_back_preview.jpg`)
///   3. صورة جانبية للمركبة (`vehicle_side_preview.jpg`)
///   4. صورة لوحة المركبة (`vehicle_plate_preview.jpg`)
///   With (✕) delete button and "تغيير الصورة" interactive photo management.
/// - Sticky actions: "توثيق الحساب" & "تخطي الآن"
class DriverVehicleVerificationScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final ValueChanged<bool>? onVerificationComplete;

  const DriverVehicleVerificationScreen({
    super.key,
    this.onBack,
    this.onSkip,
    this.onVerificationComplete,
  });

  @override
  State<DriverVehicleVerificationScreen> createState() =>
      _DriverVehicleVerificationScreenState();
}

class _DriverVehicleVerificationScreenState
    extends State<DriverVehicleVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic vehicle controllers
  final TextEditingController _categoryController =
      TextEditingController(text: 'نقل ثقيل');
  final TextEditingController _brandController =
      TextEditingController(text: 'مرسيدس');
  final TextEditingController _modelController =
      TextEditingController(text: 'أكتروس');
  final TextEditingController _yearController =
      TextEditingController(text: '2023');
  final TextEditingController _plateNumberController =
      TextEditingController(text: '7198 د ح ي');
  final TextEditingController _colorController =
      TextEditingController(text: 'أبيض');

  // Capability controllers
  final TextEditingController _maxCapacityController =
      TextEditingController(text: '25');
  final TextEditingController _volumeController =
      TextEditingController(text: '65 م³');

  String _vehicleType = 'شاحنة نقل';
  final List<String> _vehicleTypes = [
    'شاحنة نقل',
    'شاحنة تبريد (براد)',
    'قاطرة سطحة',
    'شاحنة قلاب',
    'شاحنة صهريج (تانكر)',
  ];

  String _capacityUnit = 'طن';
  final List<String> _capacityUnits = [
    'طن',
    'كيلوغرام',
  ];

  String _bodyType = 'صندوق مغلق';
  final List<String> _bodyTypes = [
    'صندوق مغلق',
    'صندوق مفتوح (جوانب)',
    'سطحة بدون جوانب',
    'براد تبريد وتجميد',
    'صهريج سوائل',
  ];

  // 4 Photo States matching Screenshot
  String? _frontPhotoPath = 'assets/images/vehicle_front_preview.jpg';
  String? _backPhotoPath = 'assets/images/vehicle_back_preview.jpg';
  String? _sidePhotoPath = 'assets/images/vehicle_side_preview.jpg';
  String? _platePhotoPath = 'assets/images/vehicle_plate_preview.jpg';

  bool _isSubmitting = false;

  @override
  void dispose() {
    _categoryController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateNumberController.dispose();
    _colorController.dispose();
    _maxCapacityController.dispose();
    _volumeController.dispose();
    super.dispose();
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
                  'اختيار صورة المركبة',
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
        _frontPhotoPath = 'assets/images/vehicle_front_preview.jpg';
      } else if (target == 'back') {
        _backPhotoPath = 'assets/images/vehicle_back_preview.jpg';
      } else if (target == 'side') {
        _sidePhotoPath = 'assets/images/vehicle_side_preview.jpg';
      } else if (target == 'plate') {
        _platePhotoPath = 'assets/images/vehicle_plate_preview.jpg';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تحديث الصورة بنجاح',
          style: GoogleFonts.cairo(),
        ),
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
                'تم توثيق بيانات السائق والمركبة بنجاح ✓',
                style: GoogleFonts.cairo(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                'تم اعتماد رخصة القيادة وبيانات الشاحنة بنجاح، يمكنك الآن استقبال وتقديم عروض النقل.',
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'متابعة إلى الرئيسية',
                    style: GoogleFonts.cairo(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
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
            'بيانات مركبتك',
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
                    child: RawScrollbar(
                      thumbColor: const Color(0xFFF59E0B).withValues(alpha: 0.7),
                      radius: const Radius.circular(4.0),
                      thickness: 4.0,
                      thumbVisibility: true,
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

                            // Section 1: بيانات المركبة الأساسية
                            _buildSectionPill(
                              icon: Icons.local_shipping_outlined,
                              label: 'بيانات المركبة الأساسية',
                            ),
                            const SizedBox(height: 22.0),

                            // 1. نوع المركبة (Dropdown)
                            _buildDropdownField(
                              label: 'نوع المركبة',
                              value: _vehicleType,
                              items: _vehicleTypes,
                              onChanged: (val) => setState(() => _vehicleType = val),
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16.0),

                            // 2. فئة المركبة
                            _buildFieldCard(
                              label: 'فئة المركبة',
                              controller: _categoryController,
                              icon: Icons.crop_square_rounded,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16.0),

                            // 3. الماركة
                            _buildFieldCard(
                              label: 'الماركة',
                              controller: _brandController,
                              icon: Icons.donut_large_rounded,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16.0),

                            // 4. الموديل
                            _buildFieldCard(
                              label: 'الموديل',
                              controller: _modelController,
                              icon: Icons.directions_car_outlined,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16.0),

                            // 5. سنة الصنع
                            _buildFieldCard(
                              label: 'سنة الصنع',
                              controller: _yearController,
                              icon: Icons.calendar_today_outlined,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16.0),

                            // 6. رقم اللوحة
                            _buildFieldCard(
                              label: 'رقم اللوحة',
                              controller: _plateNumberController,
                              icon: Icons.featured_play_list_outlined,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16.0),

                            // 7. لون المركبة
                            _buildFieldCard(
                              label: 'لون المركبة',
                              controller: _colorController,
                              icon: Icons.circle_outlined,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 24.0),

                            // Section 2: قدرات المركبة
                            _buildSectionPill(
                              icon: Icons.hexagon_outlined,
                              label: 'قدرات المركبة',
                            ),
                            const SizedBox(height: 22.0),

                            // 8. الحمولة القصوى
                            _buildFieldCard(
                              label: 'الحمولة القصوى',
                              controller: _maxCapacityController,
                              icon: Icons.arrow_upward_rounded,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16.0),

                            // 9. وحدة القياس (Dropdown)
                            _buildDropdownField(
                              label: 'وحدة القياس',
                              value: _capacityUnit,
                              items: _capacityUnits,
                              onChanged: (val) => setState(() => _capacityUnit = val),
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16.0),

                            // 10. نوع الهيكل (Dropdown)
                            _buildDropdownField(
                              label: 'نوع الهيكل',
                              value: _bodyType,
                              items: _bodyTypes,
                              onChanged: (val) => setState(() => _bodyType = val),
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16.0),

                            // 11. سعة المركبة (اختياري)
                            _buildFieldCard(
                              label: 'سعة المركبة (اختياري)',
                              controller: _volumeController,
                              icon: Icons.check_box_outline_blank_rounded,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 24.0),

                            // Section 3: صور المركبة (4 Cards matching screenshot)
                            _buildVehiclePhotosSection(isDark),
                            const SizedBox(height: 24.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                  // Sticky Bottom Actions
                  _buildBottomActions(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionPill({
    required IconData icon,
    required String label,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFD97706),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8.0),
            Icon(
              icon,
              color: const Color(0xFFD97706),
              size: 18.0,
            ),
          ],
        ),
      ),
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

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    required bool isDark,
  }) {
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
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
              style: GoogleFonts.cairo(
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
              items: items.map((t) {
                return DropdownMenuItem<String>(
                  value: t,
                  child: Text(t),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  onChanged(val);
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

  Widget _buildVehiclePhotosSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'صور المركبة',
            style: GoogleFonts.cairo(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 14.0),

        // Row 1: صورة المركبة من الخلف & صورة المركبة من الأمام
        Row(
          children: [
            Expanded(
              child: _buildDocCard(
                title: 'صورة المركبة من الخلف',
                photoPath: _backPhotoPath,
                onDelete: () => setState(() => _backPhotoPath = null),
                onChange: () => _handlePhotoUploadOrChange('back'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildDocCard(
                title: 'صورة المركبة من الأمام',
                photoPath: _frontPhotoPath,
                onDelete: () => setState(() => _frontPhotoPath = null),
                onChange: () => _handlePhotoUploadOrChange('front'),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),

        // Row 2: صورة لوحة المركبة & صورة جانبية للمركبة
        Row(
          children: [
            Expanded(
              child: _buildDocCard(
                title: 'صورة لوحة المركبة',
                photoPath: _platePhotoPath,
                onDelete: () => setState(() => _platePhotoPath = null),
                onChange: () => _handlePhotoUploadOrChange('plate'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildDocCard(
                title: 'صورة جانبية للمركبة',
                photoPath: _sidePhotoPath,
                onDelete: () => setState(() => _sidePhotoPath = null),
                onChange: () => _handlePhotoUploadOrChange('side'),
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
                height: 80.0,
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

          // Change photo action button (clean bordered container matching screenshot)
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
              onPressed: _isSubmitting ? null : _submitVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67E22),
                foregroundColor: Colors.white,
                elevation: 2.0,
                shadowColor: const Color(0x55E67E22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
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
          SizedBox(
            width: double.infinity,
            height: 44.0,
            child: OutlinedButton(
              onPressed: widget.onSkip ?? () => Navigator.maybePop(context),
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
