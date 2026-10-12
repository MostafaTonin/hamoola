import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Screen: "بيانات التاجر" / "بيانات مكتب النقل" (Commercial Verification Screen).
/// Directly matches Images 1 & 2 from the user:
/// - Header with "بيانات التاجر" or "بيانات مكتب النقل" and rounded back button
/// - Status badge: "[📋] بيانات النشاط التجاري والسجل التجاري"
/// - Floating-label style fields:
///   1. "اسم المنشأة / النشاط التجاري" (مؤسسة الأمل للتجارة العامة والاستيراد)
///   2. "نوع النشاط التجاري" (Dropdown: تجارة جملة وتجزئة)
///   3. "رقم السجل التجاري" (CR-1048293)
///   4. "جهة إصدار السجل التجاري" (وزارة الصناعة والتجارة - مكتب الأمانة)
///   5. "تاريخ إصدار السجل التجاري" (2021-08-10) with DatePicker
///   6. "تاريخ انتهاء السجل التجاري" (2026-08-09) with DatePicker
///   7. "عنوان ومقر النشاط التجاري" (صنعاء - شارع الستين الجنوبي - عمارة الأمل)
/// - Documents Section: "[🖼] مستندات التوثيق والاعتماد"
///   4 Photo Cards:
///   - صورة الهوية من الأمام (`id_front_preview.jpg`)
///   - صورة الهوية من الخلف (`id_back_preview.jpg`)
///   - صورة شخصية مع الهوية (`id_selfie_preview.jpg`)
///   - صورة السجل التجاري (`commercial_reg_preview.jpg`)
///   All with (✕) remove and "تغيير الصورة" interactive photo management.
/// - Sticky actions: "توثيق الحساب" & "تخطي الآن"
class CommercialVerificationScreen extends StatefulWidget {
  final String role; // 'تاجر' or 'مكتب نقل'
  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final ValueChanged<bool>? onVerificationComplete;

  const CommercialVerificationScreen({
    super.key,
    this.role = 'تاجر',
    this.onBack,
    this.onSkip,
    this.onVerificationComplete,
  });

  @override
  State<CommercialVerificationScreen> createState() =>
      _CommercialVerificationScreenState();
}

class _CommercialVerificationScreenState
    extends State<CommercialVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Pre-filled controllers matching Image 1
  late final TextEditingController _facilityNameController;
  late final TextEditingController _crNumberController;
  late final TextEditingController _crIssuerController;
  late final TextEditingController _crIssueDateController;
  late final TextEditingController _crExpiryDateController;
  late final TextEditingController _addressController;

  String _businessType = 'تجارة جملة وتجزئة';
  final List<String> _businessTypes = [
    'تجارة جملة وتجزئة',
    'نقل وتوزيع بضائع',
    'استيراد وتصدير وتوكيلات',
    'تصنيع ومواد غذائية',
    'مقاولات ومواد بناء',
  ];

  // Document photo states matching Image 2
  String? _frontIdPath = 'assets/images/id_front_preview.jpg';
  String? _backIdPath = 'assets/images/id_back_preview.jpg';
  String? _selfieIdPath = 'assets/images/id_selfie_preview.jpg';
  String? _crDocPath = 'assets/images/commercial_reg_preview.jpg';

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final isOffice = widget.role == 'مكتب نقل';
    _facilityNameController = TextEditingController(
      text: isOffice
          ? 'مكتب الأمانة لنقل البضائع والمهمات'
          : 'مؤسسة الأمل للتجارة العامة والاستيراد',
    );
    _crNumberController = TextEditingController(text: 'CR-1048293');
    _crIssuerController = TextEditingController(
      text: 'وزارة الصناعة والتجارة - مكتب الأمانة',
    );
    _crIssueDateController = TextEditingController(text: '2021-08-10');
    _crExpiryDateController = TextEditingController(text: '2026-08-09');
    _addressController = TextEditingController(
      text: isOffice
          ? 'صنعاء - باب اليمن - شارع تعز'
          : 'صنعاء - شارع الستين الجنوبي - عمارة الأمل',
    );

    if (isOffice) {
      _businessType = 'نقل وتوزيع بضائع';
    }
  }

  @override
  void dispose() {
    _facilityNameController.dispose();
    _crNumberController.dispose();
    _crIssuerController.dispose();
    _crIssueDateController.dispose();
    _crExpiryDateController.dispose();
    _addressController.dispose();
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
                  'اختيار مصدر المستند',
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
        _frontIdPath = 'assets/images/id_front_preview.jpg';
      } else if (target == 'back') {
        _backIdPath = 'assets/images/id_back_preview.jpg';
      } else if (target == 'selfie') {
        _selfieIdPath = 'assets/images/id_selfie_preview.jpg';
      } else if (target == 'cr') {
        _crDocPath = 'assets/images/commercial_reg_preview.jpg';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تحديث المستند بنجاح',
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
                'تم توثيق السجل التجاري بنجاح ✓',
                style: GoogleFonts.cairo(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                'تم اعتماد بيانات السجل التجاري وهوية المنشأة رسميًا، ويمكنك الآن نشر واستقبال الحمولات بكامل الصلاحيات.',
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
    final screenTitle = widget.role == 'مكتب نقل' ? 'بيانات مكتب النقل' : 'بيانات التاجر';

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
            screenTitle,
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

                            // 1. Status Pill matching Image 1
                            _buildStatusPill(),
                            const SizedBox(height: 22.0),

                            // 2. Field: اسم المنشأة / النشاط التجاري
                            _buildFieldCard(
                              label: 'اسم المنشأة / النشاط التجاري',
                              controller: _facilityNameController,
                              icon: Icons.store_mall_directory_outlined,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16.0),

                            // 3. Dropdown: نوع النشاط التجاري
                            _buildBusinessTypeDropdown(isDark),
                            const SizedBox(height: 16.0),

                            // 4. Field: رقم السجل التجاري
                            _buildFieldCard(
                              label: 'رقم السجل التجاري',
                              controller: _crNumberController,
                              icon: Icons.description_outlined,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16.0),

                            // 5. Field: جهة إصدار السجل التجاري
                            _buildFieldCard(
                              label: 'جهة إصدار السجل التجاري',
                              controller: _crIssuerController,
                              icon: Icons.account_balance_outlined,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16.0),

                            // 6. Field: تاريخ إصدار السجل التجاري (DatePicker)
                            _buildDateFieldCard(
                              label: 'تاريخ إصدار السجل التجاري',
                              controller: _crIssueDateController,
                              icon: Icons.calendar_today_outlined,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16.0),

                            // 7. Field: تاريخ انتهاء السجل التجاري (DatePicker)
                            _buildDateFieldCard(
                              label: 'تاريخ انتهاء السجل التجاري',
                              controller: _crExpiryDateController,
                              icon: Icons.calendar_month_outlined,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16.0),

                            // 8. Field: عنوان ومقر النشاط التجاري
                            _buildFieldCard(
                              label: 'عنوان ومقر النشاط التجاري',
                              controller: _addressController,
                              icon: Icons.location_on_outlined,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 24.0),

                            // 9. Documents Section matching Image 2
                            _buildDocumentsSection(isDark),
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
    return Center(
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
              Icons.assignment_outlined,
              color: Color(0xFFE67E22),
              size: 18.0,
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: Text(
                'بيانات النشاط التجاري والسجل التجاري',
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

  Widget _buildBusinessTypeDropdown(bool isDark) {
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
              value: _businessType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
              style: GoogleFonts.cairo(
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
              items: _businessTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _businessType = val);
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
              'نوع النشاط التجاري',
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

  Widget _buildDocumentsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header matching Image 2
        Row(
          children: [
            const Icon(
              Icons.image_outlined,
              color: Color(0xFFE67E22),
              size: 20.0,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                'مستندات التوثيق والاعتماد',
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14.0),

        // Row 1: صورة الهوية من الأمام & صورة الهوية من الخلف
        Row(
          children: [
            Expanded(
              child: _buildDocCard(
                title: 'صورة الهوية من الأمام',
                photoPath: _frontIdPath,
                onDelete: () => setState(() => _frontIdPath = null),
                onChange: () => _handlePhotoUploadOrChange('front'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildDocCard(
                title: 'صورة الهوية من الخلف',
                photoPath: _backIdPath,
                onDelete: () => setState(() => _backIdPath = null),
                onChange: () => _handlePhotoUploadOrChange('back'),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),

        // Row 2: صورة شخصية مع الهوية & صورة السجل التجاري
        Row(
          children: [
            Expanded(
              child: _buildDocCard(
                title: 'صورة شخصية مع الهوية',
                photoPath: _selfieIdPath,
                onDelete: () => setState(() => _selfieIdPath = null),
                onChange: () => _handlePhotoUploadOrChange('selfie'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildDocCard(
                title: 'صورة السجل التجاري',
                photoPath: _crDocPath,
                onDelete: () => setState(() => _crDocPath = null),
                onChange: () => _handlePhotoUploadOrChange('cr'),
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
