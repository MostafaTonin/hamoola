import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/communication_launcher.dart';

/// Screen 12 in Prototype: "خدمة العملاء" (Customer Support).
/// Faithfully reproduces `#screenCustomerSupport` with direct phone call,
/// instant WhatsApp messaging, and expanding FAQs.
class CustomerSupportScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const CustomerSupportScreen({
    super.key,
    this.onBack,
  });

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  final List<({String question, String answer, bool isExpanded})> _faqs = [
    (
      question: 'كيف يتم تحديد تكلفة نقل الحمولة؟',
      answer:
          'تعتمد التكلفة على نوع الشاحنة المطلوبة، والمسافة الكلية بين نقاط التحميل والتفريغ، وطبيعة البضاعة ووزنها الإجمالي.',
      isExpanded: true,
    ),
    (
      question: 'ما هي وسائل الدفع المدعومة في حمولة؟',
      answer:
          'تدعم المنصة الدفع عبر المحافظ الإلكترونية اليمنية المعتمدة (جوالي، كاش، ون كاش، فلوسك)، والحوالات البنكية المباشرة، والدفع عند الاستلام والتسليم.',
      isExpanded: false,
    ),
    (
      question: 'كيف يتم توثيق حساب السائق والمركبة؟',
      answer:
          'من خلال رفع صورة رخصة القيادة سارية المفعول، وبطاقة الهوية الوطنية، واستمارة فحص المركبة، وصور الشاحنة من الجهات الأربع.',
      isExpanded: false,
    ),
    (
      question: 'ما هو دور مكتب النقليات في المنصة؟',
      answer:
          'يقوم مكتب النقليات بدور الوسيط والمنسق التجاري بين التجار ومزودي النقل لإدارة الصفقات الكبرى وضمان سير الرحلات، ولا يملك مركبات خاصة في النظام.',
      isExpanded: false,
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
          onPressed: widget.onBack,
          tooltip: AppStrings.back,
        ),
        title: Text(
          'خدمة العملاء',
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
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceLg,
                vertical: AppDimensions.spaceMd,
              ),
              children: [
                _buildHeroCard(isDark),
                const SizedBox(height: AppDimensions.spaceLg),
                Text(
                  'قنوات التواصل المباشرة',
                  style: GoogleFonts.cairo(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                _buildChannelButton(
                  title: 'اتصال هاتفي مباشر',
                  subtitle: 'الرقم المجاني: ${AppStrings.companyTollFreeDisplay}',
                  icon: Icons.phone_in_talk_rounded,
                  iconColor: AppColors.primaryGold,
                  iconBgColor: const Color(0xFFFEF3C7),
                  onTap: () {
                    CommunicationLauncher.makePhoneCall(
                      context,
                      phoneNumber: AppStrings.companyTollFreeNumber,
                    );
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                _buildChannelButton(
                  title: 'محادثة واتساب (WhatsApp)',
                  subtitle: 'الرقم المباشر: ${AppStrings.companyWhatsAppNumber} (+967)',
                  icon: Icons.chat_bubble_rounded,
                  iconColor: const Color(0xFF16A34A),
                  iconBgColor: const Color(0xFFDCFCE7),
                  onTap: () {
                    CommunicationLauncher.openWhatsApp(
                      context,
                      phoneNumber: AppStrings.companyWhatsAppNumber,
                    );
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 28.0),
                Text(
                  'الأسئلة الشائعة (FAQ)',
                  style: GoogleFonts.cairo(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                ...List.generate(_faqs.length, (i) => _buildFaqItem(i, isDark)),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64.0,
            height: 64.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFEF3C7),
              border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
            ),
            child: const Center(
              child: Icon(
                Icons.support_agent_rounded,
                color: AppColors.primaryGold,
                size: 36.0,
              ),
            ),
          ),
          const SizedBox(height: 14.0),
          Text(
            'فريق الدعم الفني جاهز لمساعدتك',
            style: GoogleFonts.cairo(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6.0),
          Text(
            'يمكنك التواصل مع فريق خدمة عملاء حمولة لأي استفسار أو متابعة لطلبات النقل.',
            style: GoogleFonts.cairo(
              fontSize: 13.0,
              color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              border: Border.all(color: AppColors.successBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6.5,
                  height: 6.5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 6.0),
                Text(
                  'متاحون على مدار الساعة لخدمتكم',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.center,
            children: [
              InkWell(
                onTap: () => CommunicationLauncher.makePhoneCall(
                  context,
                  phoneNumber: AppStrings.companyTollFreeNumber,
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_in_talk_rounded, size: 14.0, color: AppColors.primaryGold),
                      const SizedBox(width: 5.0),
                      Text(
                        'مجاني: ${AppStrings.companyTollFreeDisplay}',
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.primaryGold : const Color(0xFF92400E),
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () => CommunicationLauncher.openWhatsApp(
                  context,
                  phoneNumber: AppStrings.companyWhatsAppNumber,
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat_bubble_rounded, size: 14.0, color: Color(0xFF16A34A)),
                      const SizedBox(width: 5.0),
                      Text(
                        'واتساب: ${AppStrings.companyWhatsAppNumber}',
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF166534),
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChannelButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF1E293B) : iconBgColor,
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 22.0),
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12.0,
                      color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 15.0,
              color: isDark ? AppColors.textSubtle : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(int index, bool isDark) {
    final item = _faqs[index];

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.0,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: item.isExpanded,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
        title: Text(
          item.question,
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 14.0),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                item.answer,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  height: 1.6,
                  color: isDark ? AppColors.textSubtle : const Color(0xFF475569),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
