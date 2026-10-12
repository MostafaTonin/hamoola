import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/cargo_bid_opportunity.dart';

/// Interactive modal sheet allowing the driver to review a cargo requirement
/// and submit an instant competitive bid with pickup timing and notes.
class DriverBidModalSheet extends StatefulWidget {
  final CargoBidOpportunity cargo;
  final ValueChanged<int> onBidSubmitted;

  const DriverBidModalSheet({
    super.key,
    required this.cargo,
    required this.onBidSubmitted,
  });

  static Future<void> show(
    BuildContext context, {
    required CargoBidOpportunity cargo,
    required ValueChanged<int> onBidSubmitted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DriverBidModalSheet(
        cargo: cargo,
        onBidSubmitted: onBidSubmitted,
      ),
    );
  }

  @override
  State<DriverBidModalSheet> createState() => _DriverBidModalSheetState();
}

class _DriverBidModalSheetState extends State<DriverBidModalSheet> {
  late TextEditingController _priceController;
  late TextEditingController _noteController;
  late int _selectedPrice;
  String _selectedTiming = 'خلال ساعة (فوري)';
  bool _truckInspected = true;
  bool _isSubmitting = false;

  final List<String> _timingOptions = const [
    'خلال ساعة (فوري)',
    'اليوم عصراً',
    'غداً صباحاً',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPrice = widget.cargo.targetBudgetYmr;
    _priceController = TextEditingController(text: _selectedPrice.toString());
    _noteController = TextEditingController(
      text: widget.cargo.temperatureSpec != null
          ? 'المقطورة مبردة ومفحوصة وجاهزة للتحميل الفوري.'
          : 'شاحنة مرخصة وجاهزة بالرافعات وأحزمة التثبيت.',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _applyQuickPrice(int price) {
    setState(() {
      _selectedPrice = price;
      _priceController.text = price.toString();
    });
  }

  void _handleSubmit() {
    final parsed = int.tryParse(_priceController.text.replaceAll(',', ''));
    final finalPrice = parsed ?? _selectedPrice;

    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      widget.onBidSubmitted(finalPrice);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.successDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'تم إرسال عرضك بمبلغ ${_formatCurrency(finalPrice)} ر.ي إلى ${widget.cargo.merchantName}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          top: 16,
          left: 20,
          right: 20,
          bottom: 24 + bottomInset,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.borderLightInput,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Modal Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.gavel_rounded,
                    color: AppColors.goldDark,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تقديم عرض سعر (مزايدة)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navyDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'طلب: ${widget.cargo.id} • ${widget.cargo.merchantName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMutedLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMutedLight),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'إغلاق',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Cargo Brief Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.route_rounded, color: AppColors.primaryGold, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${widget.cargo.originCity} ➔ ${widget.cargo.destinationCity}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navyDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.navyDark.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${widget.cargo.distanceKm} كم',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'ميزانية التاجر المقترحة:',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMutedLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatCurrency(widget.cargo.targetBudgetYmr)} ر.ي',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Price Input & Quick adjustment
            const Text(
              'سعرك المقترح للشحنة (ريال يمني)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.navyDark,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navyDark,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.goldLight.withValues(alpha: 0.4),
                prefixIcon: const Icon(Icons.payments_outlined, color: AppColors.goldDark),
                suffixText: 'ر.ي',
                suffixStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldDark,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.goldBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.goldBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.goldDark, width: 2),
                ),
              ),
              onChanged: (val) {
                final num = int.tryParse(val.replaceAll(',', ''));
                if (num != null) {
                  _selectedPrice = num;
                }
              },
            ),
            const SizedBox(height: 8),

            // Quick adjustment chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildQuickChip(
                  label: 'نفس الميزانية',
                  price: widget.cargo.targetBudgetYmr,
                ),
                _buildQuickChip(
                  label: '+15,000 (أعلى)',
                  price: widget.cargo.targetBudgetYmr + 15000,
                ),
                _buildQuickChip(
                  label: '-15,000 (تنافسي)',
                  price: widget.cargo.targetBudgetYmr - 15000,
                  isDiscount: true,
                ),
                _buildQuickChip(
                  label: '-30,000 (فوري)',
                  price: widget.cargo.targetBudgetYmr - 30000,
                  isDiscount: true,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Timing selection
            const Text(
              'موعد جاهزيتك للتحميل',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.navyDark,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timingOptions.map((opt) {
                final isSelected = _selectedTiming == opt;
                return ChoiceChip(
                  label: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.navyDark : AppColors.textMutedLight,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.goldLight,
                  backgroundColor: AppColors.backgroundLight,
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryGold : AppColors.borderLight,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedTiming = opt);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Inspection confirmation checkbox
            Row(
              children: [
                Checkbox(
                  value: _truckInspected,
                  activeColor: AppColors.navyDark,
                  onChanged: (val) {
                    setState(() => _truckInspected = val ?? true);
                  },
                ),
                Expanded(
                  child: Text(
                    'أؤكد أن الشاحنة مطابقة للمواصفات ومفحوصة وجاهزة للتحميل.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMutedLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navyDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'إرسال العرض للتاجر',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildQuickChip({
    required String label,
    required int price,
    bool isDiscount = false,
  }) {
    final isSelected = _selectedPrice == price;
    return InkWell(
      onTap: () => _applyQuickPrice(price),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDiscount ? AppColors.successBg : AppColors.goldLight)
              : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (isDiscount ? AppColors.success : AppColors.primaryGold)
                : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDiscount ? AppColors.successDark : AppColors.goldDark)
                : AppColors.textMutedLight,
          ),
        ),
      ),
    );
  }
}
