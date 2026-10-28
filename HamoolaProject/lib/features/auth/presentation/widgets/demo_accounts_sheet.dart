import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/auth_simulation_store.dart';
import '../../domain/models/auth_user.dart';

/// Modal bottom sheet providing quick access to demo simulation accounts
/// Allows 1-tap autofill for testing all 4 user roles seamlessly
class DemoAccountsSheet extends StatelessWidget {
  final ValueChanged<AuthUser> onSelectAccount;

  const DemoAccountsSheet({
    super.key,
    required this.onSelectAccount,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<AuthUser> onSelectAccount,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DemoAccountsSheet(
        onSelectAccount: (user) {
          Navigator.of(ctx).pop();
          onSelectAccount(user);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final users = [
      AuthSimulationStore.initialDemoUsers.firstWhere((u) => u.id == 'USR-CLIENT-01'),
      AuthSimulationStore.initialDemoUsers.firstWhere((u) => u.id == 'USR-DRIVER-01'),
      AuthSimulationStore.initialDemoUsers.firstWhere((u) => u.id == 'USR-MERCHANT-01'),
      AuthSimulationStore.initialDemoUsers.firstWhere((u) => u.id == 'USR-OFFICE-01'),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12.0),
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14.0),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(
                      Icons.key_rounded,
                      color: AppColors.primaryGold,
                      size: 22.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حسابات التجربة والمحاكاة',
                          style: GoogleFonts.cairo(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'اختر حساباً للتعبئة التلقائية وتجربة دور المستخدم',
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14.0),
            const Divider(height: 1),

            // Accounts List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                itemCount: users.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10.0),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42.0,
                          height: 42.0,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Icon(
                            user.role.icon,
                            color: AppColors.primaryGold,
                            size: 22.0,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user.name,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0, vertical: 2.0),
                                    decoration: BoxDecoration(
                                      color: user.verificationStatus.color
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: Text(
                                      user.verificationStatus.label,
                                      style: GoogleFonts.cairo(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: user.verificationStatus.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                'الهاتف: ${user.phone} • كلمة المرور: ${user.password}',
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 11.0,
                                  color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () => onSelectAccount(user),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 6.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            'استخدام',
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
