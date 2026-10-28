import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/models/auth_simulation_store.dart';
import '../../../auth/domain/models/auth_user.dart';

/// Bottom sheet to review submitted transport office verification details,
/// and provide a simulation button to instantly approve verification for testing.
class OfficeVerificationDetailsSheet extends StatelessWidget {
  final AuthUser user;
  final VoidCallback onApproved;

  const OfficeVerificationDetailsSheet({
    super.key,
    required this.user,
    required this.onApproved,
  });

  static Future<void> show(
    BuildContext context, {
    required AuthUser user,
    required VoidCallback onApproved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OfficeVerificationDetailsSheet(
        user: user,
        onApproved: onApproved,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final officeData = user.officeData;
    final identityData = user.identityData;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20.0,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44.0,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 14.0),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE67E22).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.badge_outlined,
                    color: Color(0xFFE67E22),
                    size: 22.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تفاصيل طلب توثيق مكتب النقل',
                        style: GoogleFonts.cairo(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'حالة الطلب: قيد المراجعة والتدقيق الإداري',
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Body list
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _buildSectionHeader('بيانات مكتب النقل', Icons.apartment_rounded, isDark),
                  _buildDataTile(
                    'اسم مكتب النقل',
                    officeData?.officeName ?? 'مكتب الأمانة لنقل البضائع والمهمات',
                    isDark,
                  ),
                  _buildDataTile(
                    'نوع النشاط',
                    officeData?.activityType ?? 'نقل ثقيل وبضائع بين المحافظات',
                    isDark,
                  ),
                  _buildDataTile(
                    'رقم السجل التجاري',
                    officeData?.crNumber ?? 'CR-7729104',
                    isDark,
                  ),
                  _buildDataTile(
                    'جهة إصدار السجل',
                    officeData?.crIssuer ?? 'وزارة الصناعة والتجارة - مكتب النقل',
                    isDark,
                  ),
                  _buildDataTile(
                    'تاريخ الإصدار / الانتهاء',
                    '${officeData?.crIssueDate ?? '2021-06-15'} إلى ${officeData?.crExpiryDate ?? '2027-06-14'}',
                    isDark,
                  ),
                  _buildDataTile(
                    'مقر وعنوان المكتب',
                    officeData?.address ?? 'صنعاء - شارع تعز - باب اليمن',
                    isDark,
                  ),
                  _buildDataTile(
                    'حجم الأسطول المقدر',
                    '${officeData?.fleetCount ?? 18} شاحنة وناقلة',
                    isDark,
                  ),
                  const SizedBox(height: 16.0),

                  _buildSectionHeader('بيانات المسؤول عن الحساب', Icons.person_outline_rounded, isDark),
                  _buildDataTile(
                    'الاسم الكامل للمسؤول',
                    identityData?.fullName ?? user.name,
                    isDark,
                  ),
                  _buildDataTile(
                    'رقم الهاتف المسجل',
                    user.phone,
                    isDark,
                  ),
                  _buildDataTile(
                    'نوع ورقم الهوية',
                    '${identityData?.idType ?? 'بطاقة شخصية'}: ${identityData?.idNumber ?? '1029384756'}',
                    isDark,
                  ),
                  const SizedBox(height: 16.0),

                  _buildSectionHeader('المستندات المرفوعة', Icons.folder_open_rounded, isDark),
                  _buildDocTile('صورة السجل التجاري الرسمي', Icons.check_circle_rounded, const Color(0xFF16A34A)),
                  _buildDocTile('صورة بطاقة هوية المسؤول (الوجهين)', Icons.check_circle_rounded, const Color(0xFF16A34A)),
                  _buildDocTile('صورة شخصية للتحقق من الهوية', Icons.check_circle_rounded, const Color(0xFF16A34A)),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
            const SizedBox(height: 14.0),

            // Simulation approve button
            SizedBox(
              height: 48.0,
              child: ElevatedButton.icon(
                onPressed: () {
                  AuthSimulationStore.instance.simulateApproveOfficeVerification(user.id);
                  Navigator.of(context).pop();
                  onApproved();
                },
                icon: const Icon(Icons.verified_rounded, color: Colors.white, size: 20.0),
                label: Text(
                  'اعتماد التوثيق تجريبياً',
                  style: GoogleFonts.cairo(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 17.0, color: const Color(0xFFE67E22)),
          const SizedBox(width: 8.0),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 14.0,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTile(String label, String value, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.cairo(
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocTile(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.0, color: color),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF065F46),
              ),
            ),
          ),
          const Text('مرفق ✓', style: TextStyle(color: Color(0xFF065F46), fontSize: 11.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
