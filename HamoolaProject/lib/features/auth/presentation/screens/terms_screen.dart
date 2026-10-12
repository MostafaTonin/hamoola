import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/buttons/hamula_button.dart';

/// Screen 11 in Prototype: "الشروط والأحكام وسياسة الخصوصية" (Terms & Conditions).
/// Faithfully reproduces `#screenTerms` with the 10 official regulatory articles
/// governing shippers, drivers, and transport offices on the Hamoola platform.
class TermsScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onAccept;

  const TermsScreen({
    super.key,
    this.onBack,
    this.onAccept,
  });

  static const List<({int number, String title, String content})> _articles = [
    (
      number: 1,
      title: 'مقدمة',
      content:
          'يُعد استخدام منصة حمولة وإنشاء الحساب فيها إقراراً صريحاً وموافقة كاملة من المستخدم على كافة الشروط والضوابط المنظمة لاستخدام خدمات المنصة ولوائحها التشغيلية.',
    ),
    (
      number: 2,
      title: 'إنشاء الحساب',
      content:
          'يلتزم المستخدم بتقديم بيانات شخصية وتجارية صحيحة ودقيقة ومحدثة، ويتحمل المسؤولية القانونية والأمنية الكاملة عن المحافظة على سرية بيانات تسجيل الدخول الخاصة بحسابه.',
    ),
    (
      number: 3,
      title: 'استخدام منصة حمولة',
      content:
          'توفر المنصة بنية وخدمات رقمية لتنظيم وتسهيل عمليات طلب ونقل الحمولات وربط طالبي الخدمة بمزودي النقل المعتمدين وفق المعايير المحددة.',
    ),
    (
      number: 4,
      title: 'مسؤوليات المستخدم',
      content:
          'يتعهد المستخدم باستخدام خدمات المنصة بطريقة نظامية، وتقديم معلومات شحن دقيقة، والامتناع التام عن استخدام حسابه أو المنصة في نقل بضائع محظورة أو أي نشاط مخالف للقوانين.',
    ),
    (
      number: 5,
      title: 'الطلبات والعروض والاتفاقات',
      content:
          'تخضع جميع طلبات النقل وعروض الأسعار والاتفاقات المبرمة عبر المنصة للبيانات والموافقات والتأكيدات الإلكترونية التي يقرها أطراف الرحلة داخل النظام الرقمي.',
    ),
    (
      number: 6,
      title: 'المدفوعات والتسويات',
      content:
          'تتم كافة التعاملات المالية وتسوية الأجور ومستحقات النقل وفق قنوات الدفع وآلية الرصيد والضمانات المالية المعتمدة رسمياً في منصة حمولة.',
    ),
    (
      number: 7,
      title: 'الإلغاء والحالات الاستثنائية',
      content:
          'تُنظم حالات إلغاء الرحلات أو تأخر الاستلام والتسليم وفق سياسة الإلغاء والتعويضات المعتمدة في المنصة لحفظ حقوق الشاحن والناقل على حد سواء.',
    ),
    (
      number: 8,
      title: 'الملكية الفكرية',
      content:
          'جميع العلامات التجارية، والبرمجيات، والتصاميم، والشعارات، والمحتويات المتاحة عبر المنصة هي ملكية حصرية لمنصة حمولة ومحمية بالأنظمة المرعية.',
    ),
    (
      number: 9,
      title: 'إخلاء المسؤولية وحدودها',
      content:
          'تعمل المنصة كوسيط تقني تنظيمي، ولا تتحمل المسؤولية المباشرة عن الأضرار الناجمة عن القوة القاهرة، أو الحوادث المرورية الخارجية الخارجة عن السيطرة.',
    ),
    (
      number: 10,
      title: 'القانون الواجب التطبيق وتسوية النزاعات',
      content:
          'تخضع هذه الشروط والأحكام للأنظمة والقوانين المعمول بها في الجمهورية اليمنية، وتُسوى أي نزاعات تنشأ عنها وفق الآليات الودية ثم الجهات القضائية المختصة.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18.0),
          onPressed: onBack,
          tooltip: AppStrings.back,
        ),
        title: Text(
          'الشروط والأحكام',
          style: GoogleFonts.cairo(
            fontSize: 18.0,
            fontWeight: FontWeight.w700,
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
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceLg,
                      vertical: AppDimensions.spaceMd,
                    ),
                    children: [
                      // Intro Banner
                      _buildIntroBanner(isDark),
                      const SizedBox(height: 18.0),
                      // 10 Articles
                      ..._articles.map((art) => _buildArticleCard(art, isDark)),
                      const SizedBox(height: 12.0),
                    ],
                  ),
                ),
                // Bottom Fixed Acceptance Bar
                _buildBottomBar(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFFDE68A),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.navyDark : Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.primaryGold,
              size: 24.0,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الشروط والأحكام وسياسة الخصوصية',
                  style: GoogleFonts.cairo(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'يرجى قراءة البنود التنظيمية التالية بعناية قبل استخدام منصة حمولة أو إتمام إنشاء الحساب.',
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    height: 1.5,
                    color: isDark ? AppColors.textSubtle : const Color(0xFF78350F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(
    ({int number, String title, String content}) article,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMd),
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26.0,
                height: 26.0,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGold, width: 1.0),
                ),
                child: Center(
                  child: Text(
                    '${article.number}',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSm),
              Text(
                article.title,
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            article.content,
            style: GoogleFonts.cairo(
              fontSize: 13.0,
              height: 1.6,
              color: isDark ? AppColors.textSubtle : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.0,
          ),
        ),
      ),
      child: HamulaButton(
        label: 'أوافق على الشروط والمتابعة',
        onPressed: onAccept ?? onBack,
        variant: HamulaButtonVariant.primary,
        size: HamulaButtonSize.lg,
      ),
    );
  }
}
