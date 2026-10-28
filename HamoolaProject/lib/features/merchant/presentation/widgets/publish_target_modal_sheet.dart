import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/models/transport_order_draft.dart';

/// Modal sheet for selecting the publishing target audience (Image 3)
class PublishTargetModalSheet extends StatefulWidget {
  final PublishTarget initialTarget;
  final ValueChanged<PublishTarget> onConfirmTarget;

  const PublishTargetModalSheet({
    super.key,
    this.initialTarget = PublishTarget.allDrivers,
    required this.onConfirmTarget,
  });

  static Future<PublishTarget?> show(
    BuildContext context, {
    PublishTarget initialTarget = PublishTarget.allDrivers,
  }) {
    return showModalBottomSheet<PublishTarget>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PublishTargetModalSheet(
        initialTarget: initialTarget,
        onConfirmTarget: (target) {
          Navigator.of(ctx).pop(target);
        },
      ),
    );
  }

  @override
  State<PublishTargetModalSheet> createState() =>
      _PublishTargetModalSheetState();
}

class _PublishTargetModalSheetState extends State<PublishTargetModalSheet> {
  late PublishTarget _selectedTarget;

  @override
  void initState() {
    super.initState();
    _selectedTarget = widget.initialTarget;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.navyDark : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXl),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Row: Close (X) button & Drag handle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22.0),
                  color: isDark ? AppColors.textWhite : const Color(0xFF64748B),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppStrings.cancelBtn,
                ),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 44), // Balanced placeholder
              ],
            ),
            const SizedBox(height: 10),

            // Header Icon Badge (Orange Send Icon)
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Color(0xFFEA580C),
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              AppStrings.publishTargetTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),

            // Subtitle
            Text(
              AppStrings.publishTargetSubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),

            // 4 Target Options (Cards with Radio Selection)
            _buildTargetOptionCard(
              target: PublishTarget.allDrivers,
              title: AppStrings.targetAllDrivers,
              subtitle: 'نشر الطلب على جميع السائقين المعتمدين في منطقتك.',
              icon: Icons.sports_motorsports_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 10),

            _buildTargetOptionCard(
              target: PublishTarget.specificDriver,
              title: AppStrings.targetSpecificDriver,
              subtitle: 'اختيار سائق معين من قائمة السائقين المعتمدين.',
              icon: Icons.person_search_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 10),

            _buildTargetOptionCard(
              target: PublishTarget.allOffices,
              title: AppStrings.targetAllOffices,
              subtitle: 'نشر الطلب على جميع مكاتب النقل المعتمدة.',
              icon: Icons.domain_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 10),

            _buildTargetOptionCard(
              target: PublishTarget.specificOffice,
              title: AppStrings.targetSpecificOffice,
              subtitle: 'اختيار مكتب نقل معين من قائمة المكاتب المعتمدة.',
              icon: Icons.apartment_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Continue Button (زر متابعة)
            ElevatedButton(
              onPressed: () => widget.onConfirmTarget(_selectedTarget),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'متابعة',
                    style: GoogleFonts.cairo(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
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

  Widget _buildTargetOptionCard({
    required PublishTarget target,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedTarget == target;

    return InkWell(
      onTap: () => setState(() => _selectedTarget = target),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFFFFBEB))
              : (isDark
                  ? const Color(0xFF1E293B)
                  : Colors.white),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF59E0B)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4.0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Radio Circle
            Container(
              width: 20.0,
              height: 20.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF94A3B8),
                  width: isSelected ? 5.5 : 1.5,
                ),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12.0),

            // Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textWhite
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 11.0,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10.0),

            // Icon Badge
            Container(
              width: 38.0,
              height: 38.0,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFEF3C7)
                    : (isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20.0,
                color: isSelected
                    ? const Color(0xFFB45309)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
