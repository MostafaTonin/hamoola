import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/cargo_card_item.dart';

class MerchantCargoCardWidget extends StatelessWidget {
  final CargoCardItem cargo;
  final VoidCallback? onTap;

  const MerchantCargoCardWidget({
    super.key,
    required this.cargo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 16.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                // 1. Background (Image or Gradient)
                Positioned.fill(
                  child: cargo.imageAsset != null
                      ? Image.asset(
                          cargo.imageAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultBackground(isDark),
                        )
                      : _buildDefaultBackground(isDark),
                ),

                // 2. High-contrast Dark Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                const Color(0xBD0F172A),
                                const Color(0xF20F172A),
                              ]
                            : [
                                const Color(0xA60F172A),
                                const Color(0xE60F172A),
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // 3. Card Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 13.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Row: Title, Category & Arrow
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cargo.name,
                                  style: GoogleFonts.cairo(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 3.0),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      cargo.categoryIcon,
                                      size: 13.0,
                                      color: AppColors.primaryGold,
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      cargo.category,
                                      style: GoogleFonts.cairo(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryGold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 26.0,
                            height: 26.0,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_back_ios_rounded,
                                size: 12.0,
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),

                      // Specs Grid (Weight & Quantity)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 7.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x940F172A),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.07),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.weightLabel,
                                    style: GoogleFonts.cairo(
                                      fontSize: 10.5,
                                      color: const Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    cargo.weight,
                                    style: GoogleFonts.ibmPlexSansArabic(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFF8FAFC),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1.0,
                              height: 24.0,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.quantityLabel,
                                    style: GoogleFonts.cairo(
                                      fontSize: 10.5,
                                      color: const Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    cargo.quantity,
                                    style: GoogleFonts.ibmPlexSansArabic(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFF8FAFC),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      // Bottom Chip (Handling Requirement)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9.0,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: cargo.isSpecialHandling
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(6.0),
                            border: Border.all(
                              color: cargo.isSpecialHandling
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (cargo.handlingIcon != null) ...[
                                Icon(
                                  cargo.handlingIcon,
                                  size: 12.0,
                                  color: AppColors.primaryGold,
                                ),
                                const SizedBox(width: 4.0),
                              ],
                              Text(
                                cargo.handlingRequirement,
                                style: GoogleFonts.cairo(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: cargo.isSpecialHandling
                                      ? const Color(0xFFCBD5E1)
                                      : const Color(0xFF94A3B8),
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
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultBackground(bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
