import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../../merchant/domain/models/merchant_order.dart';

/// Modal bottom sheet for submitting a binding price bid on an available order.
/// Rule: "تقديم عرض السعر ملزم وغير قابل للتعديل بعد تقديمه."
class TransportOfficeBidDialog extends StatefulWidget {
  final MerchantOrder order;
  final AuthUser officeUser;
  final void Function(double price, String duration, String notes) onSubmitBid;

  const TransportOfficeBidDialog({
    super.key,
    required this.order,
    required this.officeUser,
    required this.onSubmitBid,
  });

  static Future<void> show({
    required BuildContext context,
    required MerchantOrder order,
    required AuthUser officeUser,
    required void Function(double price, String duration, String notes) onSubmitBid,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TransportOfficeBidDialog(
        order: order,
        officeUser: officeUser,
        onSubmitBid: onSubmitBid,
      ),
    );
  }

  @override
  State<TransportOfficeBidDialog> createState() => _TransportOfficeBidDialogState();
}

class _TransportOfficeBidDialogState extends State<TransportOfficeBidDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late final TextEditingController _notesController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate with reasonable estimate based on budget or distance
    final initialPrice = (widget.order.budget != null && widget.order.budget! > 0)
        ? widget.order.budget!.toStringAsFixed(0)
        : '280000';
    _priceController = TextEditingController(text: initialPrice);
    _durationController = TextEditingController(text: 'يومين (48 ساعة)');
    _notesController = TextEditingController(
      text: 'شامل التحميل والتفريغ، قاطرة مغلقة مجهزة مع تغطية تأمينية كاملة.',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final duration = _durationController.text.trim();
    final notes = _notesController.text.trim();

    widget.onSubmitBid(price, duration, notes);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final officeName = widget.officeUser.officeData?.officeName ?? 'مكتب النقل';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
          top: 20.0,
          left: 20.0,
          right: 20.0,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20.0,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top handle
                Center(
                  child: Container(
                    width: 48.0,
                    height: 5.0,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Dialog Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE67E22).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: Color(0xFFE67E22),
                        size: 24.0,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تقديم عرض سعر للنقل',
                            style: GoogleFonts.cairo(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'باسم: $officeName',
                            style: GoogleFonts.cairo(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE67E22),
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

                // Order summary card
                Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 18.0, color: const Color(0xFF64748B)),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              widget.order.cargoTitle,
                              style: GoogleFonts.cairo(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E7FF),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              '${widget.order.weightTons} طن',
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF3730A3),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Icon(Icons.route_rounded, size: 16.0, color: Color(0xFFE67E22)),
                          const SizedBox(width: 6.0),
                          Text(
                            '${widget.order.originCity} ➔ ${widget.order.destinationCity}',
                            style: GoogleFonts.cairo(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18.0),

                // Binding Rule Alert Box
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.gavel_rounded,
                        color: Color(0xFFD97706),
                        size: 20.0,
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          'تنبيه نظام حمولة: تقديم عرض السعر ملزم وغير قابل للتعديل بعد إرساله. في حال قبول التاجر للعرض، يُسند الطلب لمكتبك للتنفيذ.',
                          style: GoogleFonts.cairo(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF92400E),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18.0),

                // Price Field
                Text(
                  'سعر العرض الإجمالي (ريال يمني)',
                  style: GoogleFonts.cairo(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6.0),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.cairo(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE67E22),
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.payments_outlined, color: Color(0xFFE67E22)),
                    suffixText: 'ر.ي',
                    suffixStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white12 : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'يرجى إدخال سعر العرض';
                    final num = double.tryParse(val);
                    if (num == null || num <= 0) return 'يرجى إدخال مبلغ صحيح أكبر من الصفر';
                    return null;
                  },
                ),
                const SizedBox(height: 14.0),

                // Estimated Duration Field
                Text(
                  'المدة المتوقعة لتنفيذ النقل والتوصيل',
                  style: GoogleFonts.cairo(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6.0),
                TextFormField(
                  controller: _durationController,
                  style: GoogleFonts.cairo(fontSize: 14.0, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.timer_outlined, color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white12 : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'يرجى تحديد مدة التوصيل';
                    return null;
                  },
                ),
                const SizedBox(height: 14.0),

                // Notes Field
                Text(
                  'ملاحظات وتفاصيل العرض (اختياري)',
                  style: GoogleFonts.cairo(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6.0),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  style: GoogleFonts.cairo(fontSize: 13.5),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white12 : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22.0),

                // Action Buttons
                SizedBox(
                  height: 48.0,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE67E22),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22.0,
                            height: 22.0,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            'تأكيد وإرسال العرض الملزم',
                            style: GoogleFonts.cairo(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'إلغاء التراجع',
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
