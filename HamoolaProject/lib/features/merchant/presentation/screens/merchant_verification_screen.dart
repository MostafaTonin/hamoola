import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

enum KycVerificationStatus {
  incomplete,
  pendingReview,
  verified,
}

/// Screen for Merchant Enterprise KYC & Commercial Register Verification.
/// Provides enterprise info form, official document uploads, verification progress,
/// and approval workflow with an instant-approval demo switch.
class MerchantVerificationScreen extends StatefulWidget {
  final KycVerificationStatus initialStatus;
  final VoidCallback? onBack;
  final ValueChanged<bool>? onVerificationComplete;

  const MerchantVerificationScreen({
    super.key,
    this.initialStatus = KycVerificationStatus.incomplete,
    this.onBack,
    this.onVerificationComplete,
  });

  @override
  State<MerchantVerificationScreen> createState() =>
      _MerchantVerificationScreenState();
}

class _MerchantVerificationScreenState
    extends State<MerchantVerificationScreen> {
  late KycVerificationStatus _status;

  final TextEditingController _companyNameController =
      TextEditingController(text: 'مؤسسة الأمل التجارية والاستيراد');
  final TextEditingController _crNumberController =
      TextEditingController(text: 'CR-108249');
  final TextEditingController _taxNumberController =
      TextEditingController(text: 'TAX-884920');
  final TextEditingController _authPersonController =
      TextEditingController(text: 'محمد أحمد اليماني (1019283746)');

  bool _crDocUploaded = true;
  bool _idDocUploaded = true;
  bool _authDocUploaded = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _crNumberController.dispose();
    _taxNumberController.dispose();
    _authPersonController.dispose();
    super.dispose();
  }

  Future<void> _submitForReview() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _status = KycVerificationStatus.pendingReview;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'تم استلام بيانات التوثيق وهي قيد المراجعة والتدقيق',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _instantApproveDemo() {
    setState(() {
      _status = KycVerificationStatus.verified;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'تم اعتماد وتوثيق المنشأة رسميًا ✓ (وضع العرض)',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );

    widget.onVerificationComplete?.call(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.navyDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
              size: 20,
            ),
            onPressed: widget.onBack ?? () => Navigator.maybePop(context),
          ),
          title: Text(
            AppStrings.merchantKycTitle,
            style: GoogleFonts.cairo(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: _buildStatusPill(isDark),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.compactMax,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceMd,
                  vertical: AppDimensions.spaceSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Progress Step Tracker
                    _buildStepTracker(isDark),
                    const SizedBox(height: 16),

                    // 2. Status Banner (if verified or pending)
                    if (_status == KycVerificationStatus.verified) ...[
                      _buildVerifiedBanner(isDark),
                      const SizedBox(height: 16),
                    ] else if (_status == KycVerificationStatus.pendingReview) ...[
                      _buildPendingBanner(isDark),
                      const SizedBox(height: 16),
                    ],

                    // 3. Enterprise Info Form Fields
                    _buildEnterpriseInfoSection(isDark),
                    const SizedBox(height: 18),

                    // 4. Document Uploads Section
                    _buildDocumentsSection(isDark),
                    const SizedBox(height: 24),

                    // 5. Actions / Submit Button
                    _buildActionButtons(isDark),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(bool isDark) {
    Color bg;
    Color textColor;
    String label;

    switch (_status) {
      case KycVerificationStatus.incomplete:
        bg = AppColors.warning.withValues(alpha: 0.15);
        textColor = AppColors.warning;
        label = 'غير مكتمل';
        break;
      case KycVerificationStatus.pendingReview:
        bg = AppColors.info.withValues(alpha: 0.15);
        textColor = AppColors.info;
        label = 'قيد التدقيق';
        break;
      case KycVerificationStatus.verified:
        bg = AppColors.success.withValues(alpha: 0.15);
        textColor = AppColors.success;
        label = 'موثق ✓';
        break;
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: textColor.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }

  /// 3-Step Verification Progress Indicator
  Widget _buildStepTracker(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(
            stepNumber: '1',
            label: 'الهاتف',
            isComplete: true,
            isActive: false,
            isDark: isDark,
          ),
          _buildStepDivider(isDark, isCompleted: true),
          _buildStepItem(
            stepNumber: '2',
            label: 'بيانات المنشأة',
            isComplete: _status == KycVerificationStatus.verified,
            isActive: _status != KycVerificationStatus.verified,
            isDark: isDark,
          ),
          _buildStepDivider(isDark,
              isCompleted: _status == KycVerificationStatus.verified),
          _buildStepItem(
            stepNumber: '3',
            label: 'الاعتماد',
            isComplete: _status == KycVerificationStatus.verified,
            isActive: _status == KycVerificationStatus.pendingReview,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String stepNumber,
    required String label,
    required bool isComplete,
    required bool isActive,
    required bool isDark,
  }) {
    Color circleBg;
    Color circleColor;
    Widget child;

    if (isComplete) {
      circleBg = AppColors.success.withValues(alpha: 0.15);
      circleColor = AppColors.success;
      child = const Icon(Icons.check_rounded, size: 14, color: AppColors.success);
    } else if (isActive) {
      circleBg = AppColors.primaryGold;
      circleColor = const Color(0xFF0F172A);
      child = Text(
        stepNumber,
        style: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF0F172A),
        ),
      );
    } else {
      circleBg = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
      circleColor = isDark ? AppColors.textSubtle : const Color(0xFF94A3B8);
      child = Text(
        stepNumber,
        style: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: circleColor,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: circleBg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: child,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.5,
            fontWeight: isActive || isComplete
                ? FontWeight.w800
                : FontWeight.w600,
            color: isActive
                ? AppColors.primaryGold
                : isComplete
                    ? (isDark ? AppColors.textWhite : const Color(0xFF0F172A))
                    : (isDark ? AppColors.textSubtle : const Color(0xFF94A3B8)),
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(bool isDark, {required bool isCompleted}) {
    return Container(
      width: 20,
      height: 2,
      color: isCompleted
          ? AppColors.success.withValues(alpha: 0.5)
          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
    );
  }

  Widget _buildVerifiedBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x1A10B981),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0x3310B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_rounded,
                color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.kycVerifiedStatus,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  'حسابك معتمد بالكامل — كافة ميزات النشر والتعامل المالي متاحة.',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSubtle
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x1A3B82F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0x333B82F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.hourglass_top_rounded,
                color: Color(0xFF3B82F6), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.kycPendingReviewStatus,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2563EB),
                  ),
                ),
                Text(
                  'الطلب تحت التدقيق والمطابقة من إدارة حمولة. يمكنك متابعة التحديثات هنا.',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSubtle
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnterpriseInfoSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'البيانات الرسمية للمنشأة',
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        // Company Name
        _buildInputField(
          controller: _companyNameController,
          label: AppStrings.companyNameField,
          icon: Icons.business_rounded,
          isDark: isDark,
        ),
        const SizedBox(height: 10),

        // CR Number
        _buildInputField(
          controller: _crNumberController,
          label: AppStrings.crNumberField,
          icon: Icons.badge_outlined,
          isDark: isDark,
        ),
        const SizedBox(height: 10),

        // Tax Number
        _buildInputField(
          controller: _taxNumberController,
          label: AppStrings.taxNumberField,
          icon: Icons.receipt_long_outlined,
          isDark: isDark,
        ),
        const SizedBox(height: 10),

        // Authorized Person
        _buildInputField(
          controller: _authPersonController,
          label: AppStrings.authorizedPersonField,
          icon: Icons.person_outline_rounded,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textSubtle : const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          enabled: _status != KycVerificationStatus.verified,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: Icon(icon, size: 18, color: AppColors.primaryGold),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFCBD5E1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryGold,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFE2E8F0),
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
        Text(
          'الوثائق والمستندات الرسمية',
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        // 1. CR Document Card
        _buildDocumentCard(
          title: AppStrings.crDocTitle,
          subtitle: AppStrings.crDocSub,
          isUploaded: _crDocUploaded,
          fileName: 'commercial_register_2026.pdf',
          icon: Icons.document_scanner_rounded,
          isDark: isDark,
          onToggleUpload: () => setState(() => _crDocUploaded = !_crDocUploaded),
        ),
        const SizedBox(height: 10),

        // 2. ID Document Card
        _buildDocumentCard(
          title: AppStrings.nationalIdDocTitle,
          subtitle: AppStrings.nationalIdDocSub,
          isUploaded: _idDocUploaded,
          fileName: 'manager_national_id.jpg',
          icon: Icons.credit_card_rounded,
          isDark: isDark,
          onToggleUpload: () => setState(() => _idDocUploaded = !_idDocUploaded),
        ),
        const SizedBox(height: 10),

        // 3. Authorization Doc Card (Optional)
        _buildDocumentCard(
          title: AppStrings.authorizationDocTitle,
          subtitle: AppStrings.authorizationDocSub,
          isUploaded: _authDocUploaded,
          fileName: 'official_stamp_authorization.pdf',
          icon: Icons.verified_outlined,
          isDark: isDark,
          isOptional: true,
          onToggleUpload: () =>
              setState(() => _authDocUploaded = !_authDocUploaded),
        ),
      ],
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required bool isUploaded,
    required String fileName,
    required IconData icon,
    required bool isDark,
    required VoidCallback onToggleUpload,
    bool isOptional = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUploaded
              ? AppColors.success.withValues(alpha: 0.3)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isUploaded
                  ? AppColors.success.withValues(alpha: 0.12)
                  : const Color(0x2EF59E0B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isUploaded ? AppColors.success : AppColors.primaryGold,
            ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle or File Chip
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textWhite
                              : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isOptional) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'اختياري',
                          style: GoogleFonts.cairo(
                            fontSize: 9.5,
                            color: isDark
                                ? AppColors.textSubtle
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                if (isUploaded)
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 13, color: AppColors.success),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          fileName,
                          style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 10.5,
                      color: isDark
                          ? AppColors.textSubtle
                          : AppColors.textMutedLight,
                    ),
                  ),
              ],
            ),
          ),

          // Upload / Remove Action Button
          ElevatedButton(
            onPressed: _status == KycVerificationStatus.verified
                ? null
                : onToggleUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: isUploaded
                  ? (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9))
                  : AppColors.primaryGold,
              foregroundColor: isUploaded
                  ? (isDark ? AppColors.textWhite : const Color(0xFF0F172A))
                  : const Color(0xFF0F172A),
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              isUploaded ? 'استبدال' : 'رفع ملف',
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        // 1. Submit for Verification Button
        if (_status != KycVerificationStatus.verified) ...[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitForReview,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0F172A),
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                _status == KycVerificationStatus.pendingReview
                    ? 'تحديث بيانات التدقيق'
                    : AppStrings.submitKycBtn,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: const Color(0xFF0F172A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // 2. Demo Instant Approve Action Button
        Container(
          width: double.infinity,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.4),
            ),
          ),
          child: TextButton.icon(
            onPressed: _status == KycVerificationStatus.verified
                ? () {
                    setState(() => _status = KycVerificationStatus.incomplete);
                    widget.onVerificationComplete?.call(false);
                  }
                : _instantApproveDemo,
            icon: Icon(
              _status == KycVerificationStatus.verified
                  ? Icons.lock_reset_rounded
                  : Icons.verified_user_rounded,
              size: 17,
              color: AppColors.success,
            ),
            label: Text(
              _status == KycVerificationStatus.verified
                  ? 'إلغاء الاعتماد (لتجربة الحساب المقيد)'
                  : AppStrings.kycInstantApproveDemoBtn,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.success,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
