import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/cargo_card_item.dart';

/// Uniform, high-fidelity card component representing a merchant's registered cargo.
/// Accurately reflects Hamoula branding and reference layout: thumbnail, title,
/// category, status pill, specs (weight, quantity, handling tag), and details arrow.
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

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE2E8F0);

    // Determine status badge colors and label
    Color statusColor;
    Color statusBg;
    String statusLabel = cargo.status;

    if (cargo.status == 'مرتبطة بطلب نشط' ||
        cargo.hasActiveOrder ||
        cargo.status == 'قيد النقل') {
      statusColor = const Color(0xFF3B82F6);
      statusBg = const Color(0x1A3B82F6);
      statusLabel = 'مرتبطة بطلب نشط';
    } else if (cargo.status == 'مكتملة' ||
        cargo.status == 'مكتملة الاستخدام') {
      statusColor = const Color(0xFF64748B);
      statusBg = const Color(0x1A64748B);
      statusLabel = 'مكتملة';
    } else if (cargo.status == 'معلقة') {
      statusColor = const Color(0xFFF59E0B);
      statusBg = const Color(0x1AF59E0B);
      statusLabel = 'معلقة';
    } else {
      statusColor = const Color(0xFF10B981);
      statusBg = const Color(0x1A10B981);
      statusLabel = 'جاهزة للنقل';
    }

    final imagePath = cargo.imageAsset ??
        (cargo.photos.isNotEmpty ? cargo.photos.first : null);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Thumbnail + Title & Category + Status Badge & Chevron
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Right: Cargo Thumbnail Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        width: 66.0,
                        height: 66.0,
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF1F5F9),
                        child: imagePath != null
                            ? Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Center(
                                  child: Icon(
                                    cargo.categoryIcon,
                                    size: 26.0,
                                    color: AppColors.primaryGold,
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  cargo.categoryIcon,
                                  size: 26.0,
                                  color: AppColors.primaryGold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12.0),

                    // Middle: Title & Category & SubCategory
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cargo.name,
                            style: GoogleFonts.cairo(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textMainLight,
                              height: 1.25,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3.0),
                          Row(
                            children: [
                              Icon(
                                cargo.categoryIcon,
                                size: 13.0,
                                color: isDark
                                    ? AppColors.textSubtle
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 4.0),
                              Expanded(
                                child: Text(
                                  cargo.subCategory != null
                                      ? '${cargo.category} • ${cargo.subCategory}'
                                      : cargo.category,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textSubtle
                                        : const Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          // Handling tag
                          Text(
                            cargo.handlingRequirement,
                            style: GoogleFonts.cairo(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),

                    // Left: Status Badge Pill & Detail Arrow
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Status Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.35),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.0,
                                height: 6.0,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5.0),
                              Text(
                                statusLabel,
                                style: GoogleFonts.cairo(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        // Chevron Indicator
                        Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 13.0,
                          color: isDark
                              ? AppColors.textSubtle
                              : const Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10.0),
                Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF1F5F9),
                ),
                const SizedBox(height: 8.0),

                // Bottom Row: Weight & Quantity Specs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Weight
                    Row(
                      children: [
                        const Icon(
                          Icons.scale_rounded,
                          size: 15.0,
                          color: AppColors.primaryGold,
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          cargo.weight,
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.textMainLight,
                          ),
                        ),
                      ],
                    ),

                    // Quantity
                    Row(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 14.0,
                          color: Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          cargo.quantity,
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.textMainLight,
                          ),
                        ),
                      ],
                    ),

                    // Packaging or Perishable indicator
                    Row(
                      children: [
                        Icon(
                          cargo.isPerishable
                              ? Icons.ac_unit_rounded
                              : Icons.layers_outlined,
                          size: 14.0,
                          color: cargo.isPerishable
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          cargo.packagingType,
                          style: GoogleFonts.cairo(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSubtle
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
