import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/cargo_card_item.dart';
import '../../domain/models/merchant_simulation_store.dart';
import 'merchant_create_order_screen.dart';

class MerchantCreateCargoScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<CargoCardItem>? onSubmitCargo;
  final ValueChanged<CargoCardItem>? onCreateOrderWithCargo;
  final CargoCardItem? initialCargo;

  const MerchantCreateCargoScreen({
    super.key,
    this.onBack,
    this.onSubmitCargo,
    this.onCreateOrderWithCargo,
    this.initialCargo,
  });

  @override
  State<MerchantCreateCargoScreen> createState() =>
      _MerchantCreateCargoScreenState();
}

class _MerchantCreateCargoScreenState extends State<MerchantCreateCargoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _handlingController = TextEditingController();
  final _weightController = TextEditingController();
  final _qtyController = TextEditingController();
  final _customUnitController = TextEditingController();
  final _volumeController = TextEditingController();

  String? _selectedCategory;
  String? _selectedSubCategory;
  String _selectedWeightUnit = 'طن';
  String? _selectedQtyUnit;
  String _selectedPackagingType = 'ربط معدني';
  bool? _isPerishable;

  final Set<String> _selectedHandling = {};
  final List<String> _photos = [];
  final List<String> _docs = [];

  static const List<String> _packagingTypes = [
    'ربط معدني',
    'طبالي خشبية',
    'كراتين مقواة',
    'أكياس ورقية / بلاستيك',
    'براميل',
    'تغليف فقاعي وكرتون',
    'صب / بدون تغليف',
    'تغليف خاص',
    'أخرى',
  ];

  static const List<String> _categories = [
    'مواد بناء',
    'مواد غذائية',
    'أثاث ومفروشات',
    'معدات وآلات',
    'بضائع عامة وسلع مستوردة',
    'مستلزمات طبية ومعدات صحية',
    'إلكترونيات وأجهزة كهربائية',
    'ملابس ومنسوجات وأقمشة',
    'منتجات زراعية ومحاصيل',
    'قطع غيار ومعدات صناعية',
    'زيوت ومنتجات بترولية',
    'أخرى',
  ];

  static const Map<String, List<String>> _subCategoriesMap = {
    'مواد بناء': [
      'حديد إنشائي',
      'حديد تسليح',
      'إسمنت',
      'طوب وبلك',
      'سيراميك وبلاط',
      'أخشاب بناء',
      'أخرى',
    ],
    'مواد غذائية': [
      'منتجات غذائية',
      'أغذية جافة ومجففة',
      'زيوت ومعلبات',
      'حبوب ودقيق',
      'ألبان ومشتقاتها',
      'لحوم ومجمدات',
      'خضار وفواكه',
      'أخرى',
    ],
    'أثاث ومفروشات': [
      'أثاث مكتبي',
      'أثاث منزلي',
      'مطابخ ودواليب',
      'مفروشات وسجاد',
      'أخرى',
    ],
    'معدات وآلات': [
      'معدات زراعية',
      'معدات صناعية',
      'مولدات كهربائية',
      'مضخات مياه',
      'أخرى',
    ],
    'إلكترونيات وأجهزة كهربائية': [
      'أجهزة منزلية',
      'شاشات وتلفزيونات',
      'أنظمة طاقة شمسية',
      'بطاريات ومحولات',
      'أخرى',
    ],
    'بضائع عامة وسلع مستوردة': [
      'سلع استهلاكية',
      'كراتين منوعة',
      'طرود تجارية',
      'أخرى',
    ],
    'مستلزمات طبية ومعدات صحية': [
      'أدوية ومحاليل',
      'معدات طبية',
      'مستلزمات وقاية',
      'أخرى',
    ],
    'ملابس ومنسوجات وأقمشة': [
      'ملابس جاهزة',
      'أقمشة وغزول',
      'أحذية وحقائب',
      'أخرى',
    ],
    'منتجات زراعية ومحاصيل': [
      'تمور ومحاصيل',
      'بن وقشر',
      'أعلاف وحبوب',
      'أخرى',
    ],
    'قطع غيار ومعدات صناعية': [
      'قطع غيار شاحنات',
      'إطارات وبطاريات صناعية',
      'أخرى',
    ],
    'زيوت ومنتجات بترولية': [
      'زيوت محركات',
      'مشتقات معبأة',
      'شحوم ومواد تشحيم',
      'أخرى',
    ],
    'أخرى': [
      'بضائع عامة',
      'أخرى',
    ],
  };

  static const List<String> _qtyUnits = [
    'شحنة',
    'قطعة',
    'صندوق',
    'طرد',
    'كرتون',
    'كيس',
    'منصة',
    'وحدة',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCargo != null) {
      final cargo = widget.initialCargo!;
      _nameController.text = cargo.name;
      _descController.text = cargo.description ?? '';
      _handlingController.text = cargo.handlingRequirement == AppStrings.normalHandling
          ? ''
          : cargo.handlingRequirement;

      // Weight parsing: e.g. "25 طن"
      final weightParts = cargo.weight.split(' ');
      if (weightParts.isNotEmpty) {
        _weightController.text = weightParts.first;
        if (weightParts.length > 1 && (weightParts.last == 'طن' || weightParts.last == 'كجم')) {
          _selectedWeightUnit = weightParts.last;
        }
      }

      // Quantity parsing: e.g. "1 شحنة"
      final qtyParts = cargo.quantity.split(' ');
      if (qtyParts.isNotEmpty) {
        _qtyController.text = qtyParts.first;
        if (qtyParts.length > 1) {
          final unit = qtyParts.sublist(1).join(' ');
          if (_qtyUnits.contains(unit)) {
            _selectedQtyUnit = unit;
          } else {
            _selectedQtyUnit = 'أخرى';
            _customUnitController.text = unit;
          }
        }
      }

      if (_categories.contains(cargo.category)) {
        _selectedCategory = cargo.category;
      } else {
        _selectedCategory = 'مواد بناء';
      }

      _selectedSubCategory = cargo.subCategory;

      if (_packagingTypes.contains(cargo.packagingType)) {
        _selectedPackagingType = cargo.packagingType;
      } else {
        _selectedPackagingType = 'أخرى';
      }

      _isPerishable = cargo.isPerishable;
      if (cargo.photos.isNotEmpty) {
        _photos.addAll(cargo.photos);
      } else if (cargo.imageAsset != null) {
        _photos.add(cargo.imageAsset!);
      }
      _docs.addAll(cargo.documents);
      if (cargo.volume != null) {
        _volumeController.text = cargo.volume!.replaceAll(' م³', '').trim();
      }

      if (cargo.handlingRequirement.isNotEmpty &&
          cargo.handlingRequirement != AppStrings.normalHandling) {
        final items = cargo.handlingRequirement.split(' • ');
        _selectedHandling.addAll(items);
      }
    } else {
      _selectedCategory = null;
      _selectedSubCategory = null;
      _selectedWeightUnit = 'طن';
      _selectedQtyUnit = null;
      _isPerishable = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _handlingController.dispose();
    _weightController.dispose();
    _qtyController.dispose();
    _customUnitController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  CargoCardItem _buildCargoObject() {
    final unitStr = _selectedQtyUnit == 'أخرى'
        ? _customUnitController.text.trim()
        : _selectedQtyUnit ?? 'وحدة';

    String handlingStr = _handlingController.text.trim();
    if (handlingStr.isEmpty) {
      handlingStr = _selectedHandling.isEmpty
          ? (widget.initialCargo?.handlingRequirement ?? AppStrings.normalHandling)
          : _selectedHandling.join(' • ');
    }

    return CargoCardItem(
      id: widget.initialCargo?.id ??
          'CRG-${100 + (_photos.length * 10) + (_docs.length + 1)}',
      name: _nameController.text.trim(),
      category: _selectedCategory ?? AppStrings.buildingMaterials,
      subCategory: _selectedSubCategory,
      weight: '${_weightController.text.trim()} $_selectedWeightUnit',
      quantity: '${_qtyController.text.trim()} $unitStr',
      handlingRequirement: handlingStr,
      imageAsset: _photos.isNotEmpty
          ? _photos.first
          : widget.initialCargo?.imageAsset ?? 'assets/images/cargo_ref_1.jpg',
      isSpecialHandling: _selectedHandling.isNotEmpty ||
          _isPerishable == true ||
          (widget.initialCargo?.isSpecialHandling ?? false),
      categoryIcon: _getCategoryIcon(_selectedCategory),
      handlingIcon: _selectedHandling.isNotEmpty || _isPerishable == true
          ? Icons.security_rounded
          : widget.initialCargo?.handlingIcon,
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : null,
      packagingType: _selectedPackagingType,
      isPerishable: _isPerishable ?? false,
      photos: List.from(_photos),
      documents: List.from(_docs),
      volume: _volumeController.text.trim().isNotEmpty
          ? '${_volumeController.text.trim()} م³'
          : widget.initialCargo?.volume,
      status: widget.initialCargo?.status ?? 'متاحة للاستخدام',
      linkedOrderIds: widget.initialCargo?.linkedOrderIds ?? const [],
      notes: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : widget.initialCargo?.notes,
      createdAtFormatted: widget.initialCargo?.createdAtFormatted ?? '2026/10/12',
      usageCount: widget.initialCargo?.usageCount ?? 0,
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final isEditing = widget.initialCargo != null;
      final cargo = _buildCargoObject();

      // Save to singleton simulation store so other screens reactively update
      if (isEditing) {
        MerchantSimulationStore.instance.updateCargo(cargo);
      } else {
        MerchantSimulationStore.instance.addCargo(cargo);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الحمولة بنجاح: ${cargo.name}'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );

      if (widget.onSubmitCargo != null) {
        widget.onSubmitCargo?.call(cargo);
      } else {
        Navigator.of(context).maybePop(cargo);
      }
    }
  }

  void _handleCreateOrderShortCut() {
    if (_formKey.currentState?.validate() ?? false) {
      final cargo = _buildCargoObject();

      // 1. Save cargo to simulation store first to preserve data
      if (widget.initialCargo != null) {
        MerchantSimulationStore.instance.updateCargo(cargo);
      } else {
        MerchantSimulationStore.instance.addCargo(cargo);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الحمولة "${cargo.name}" بنجاح، جاري فتح طلب النقل'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );

      // 2. If opened from an external order creation callback, invoke it
      if (widget.onCreateOrderWithCargo != null) {
        widget.onCreateOrderWithCargo?.call(cargo);
        return;
      }

      // If opened from order form modal context, pop back returning the cargo
      if (widget.onSubmitCargo != null && Navigator.of(context).canPop()) {
        widget.onSubmitCargo?.call(cargo);
        return;
      }

      // 3. Otherwise navigate directly to Create Order screen pre-selecting this cargo
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MerchantCreateOrderScreen(
            initialCargo: cargo,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
  }

  IconData _getCategoryIcon(String? category) {
    if (category == 'مواد غذائية') return Icons.shopping_basket_outlined;
    if (category == 'إلكترونيات وأجهزة كهربائية') return Icons.devices_rounded;
    if (category == 'مستلزمات طبية ومعدات صحية') {
      return Icons.medical_services_outlined;
    }
    if (category == 'أثاث ومفروشات') return Icons.chair_rounded;
    if (category == 'معدات وآلات') return Icons.agriculture_rounded;
    return Icons.view_in_ar_rounded;
  }

  void _openImagePickerModal() {
    final availableSampleImages = [
      {'name': 'حديد تسليح', 'path': 'assets/images/cargo_ref_1.jpg'},
      {'name': 'إسمنت بورتلاندي', 'path': 'assets/images/cargo_ref_2.jpg'},
      {'name': 'بلاط وسيراميك', 'path': 'assets/images/cargo_ref_3.jpg'},
      {'name': 'حديد إنشائي ثقيل', 'path': 'assets/images/cargo_ref_4.jpg'},
      {'name': 'بضائع ميناء', 'path': 'assets/images/hamula_port_cargo.jpg'},
      {'name': 'أثاث ومفروشات', 'path': 'assets/images/hamula_furniture_trucks.jpg'},
      {'name': 'بضائع تجارية مجففة', 'path': 'assets/images/hamula_intercity_cargo.jpg'},
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 14.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'اختر صور الحمولة (حد أقصى 5)',
                    style: GoogleFonts.cairo(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '${_photos.length}/5',
                    style: GoogleFonts.cairo(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                'اختر صورة لتضمينها في ملف الحمولة ومعاينتها للمشغلين والسائقين:',
                style: GoogleFonts.cairo(
                  fontSize: 12.0,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                height: 140.0,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableSampleImages.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 10.0),
                  itemBuilder: (context, index) {
                    final item = availableSampleImages[index];
                    final path = item['path']!;
                    final isAlreadyAdded = _photos.contains(path);

                    return InkWell(
                      onTap: () {
                        if (_photos.length >= 5 && !isAlreadyAdded) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('الحد الأقصى للصور هو 5 صور'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          if (isAlreadyAdded) {
                            _photos.remove(path);
                          } else {
                            _photos.add(path);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        width: 110.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: isAlreadyAdded
                                ? AppColors.primaryGold
                                : const Color(0xFFE2E8F0),
                            width: isAlreadyAdded ? 2.0 : 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(11.0),
                                ),
                                child: Image.asset(
                                  path,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFFF1F5F9),
                                    child: const Icon(Icons.image_outlined),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 6.0,
                              ),
                              color: isAlreadyAdded
                                  ? const Color(0xFFFEF3C7)
                                  : Colors.white,
                              child: Text(
                                item['name']!,
                                style: GoogleFonts.cairo(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isAlreadyAdded
                                      ? const Color(0xFF92400E)
                                      : const Color(0xFF334155),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18.0),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'تم وتطبيق الصور',
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.navyDark : const Color(0xFFF8FAFC),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.compactMax,
              ),
              child: Column(
                children: [
                  // 1. Screen Header
                  _buildHeader(isDark),

                  // 2. Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 12.0,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // CARD 1: بيانات الحمولة
                            _buildCargoDataCard(isDark),
                            const SizedBox(height: 14.0),

                            // CARD 2: تفاصيل إضافية
                            _buildAdditionalDetailsCard(isDark),
                            const SizedBox(height: 14.0),

                            // CARD 3: صور الحمولة (اختياري)
                            _buildCargoPhotosCard(isDark),
                            const SizedBox(height: 24.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. Bottom Sticky Action Buttons
                  _buildBottomActionButtons(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. HEADER
  // ===========================================================================
  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          Tooltip(
            message: AppStrings.back,
            child: InkWell(
              onTap: widget.onBack ?? () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.0,
                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12.0),

          // Titles Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.initialCargo != null
                      ? 'تعديل الحمولة'
                      : AppStrings.createCargoTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color:
                        isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'أدخل بيانات الحمولة لتتمكن من استخدامها في طلبات النقل لاحقاً',
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color:
                        isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Corner Orange Package Icon Badge
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: const Color(0xFFFFEDD5),
                width: 1.2,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.inventory_2_rounded,
                  size: 24.0,
                  color: Color(0xFFF97316),
                ),
                Positioned(
                  top: 2.0,
                  right: 2.0,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEA580C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 9.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CARD 1: بيانات الحمولة
  // ===========================================================================
  Widget _buildCargoDataCard(bool isDark) {
    final subCategories = _subCategoriesMap[_selectedCategory] ??
        ['حديد إنشائي', 'حديد تسليح', 'عام', 'أخرى'];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card 1 Header
          Row(
            children: [
              Container(
                width: 34.0,
                height: 34.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: const Icon(
                  Icons.view_in_ar_rounded,
                  size: 19.0,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.cargoInfoSection, // 'بيانات الحمولة'
                      style: GoogleFonts.cairo(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textWhite
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'المعلومات الأساسية عن البضاعة',
                      style: GoogleFonts.cairo(
                        fontSize: 11.0,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  size: 16.0,
                  color: Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),

          // 1. Cargo Name Field
          _buildFieldLabel(
            AppStrings.cargoNameLabel,
            isRequired: true,
            isDark: isDark,
          ),
          const SizedBox(height: 5.0),
          TextFormField(
            controller: _nameController,
            style: GoogleFonts.cairo(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return AppStrings.cargoNameRequiredError;
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: AppStrings.cargoNameHint, // 'مثال: حديد إنشائي'
              prefixIcon: const Icon(
                Icons.inventory_2_outlined,
                size: 20.0,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(height: 12.0),

          // 2. Row: Cargo Type & Sub-category
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cargo Category (نوع الحمولة *)
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      AppStrings.categoryLabel, // 'نوع الحمولة'
                      isRequired: true,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 5.0),
                    DropdownButtonFormField<String>(
                      key: ValueKey('category_field_$_selectedCategory'),
                      initialValue: _selectedCategory,
                      hint: Text(
                        AppStrings.categoryHint,
                        style: GoogleFonts.cairo(
                          fontSize: 12.0,
                          color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                        ),
                      ),
                      isExpanded: true,
                      dropdownColor:
                          isDark ? const Color(0xFF1E293B) : Colors.white,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textMainLight,
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val;
                          final availableSubs =
                              _subCategoriesMap[val] ?? ['عام'];
                          _selectedSubCategory = availableSubs.isNotEmpty ? availableSubs.first : null;
                        });
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return AppStrings.categoryRequiredError;
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.layers_outlined,
                          size: 19.0,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10.0),

              // Sub-category (التصنيف الفرعي)
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      'التصنيف الفرعي',
                      isRequired: false,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 5.0),
                    DropdownButtonFormField<String>(
                      key: ValueKey('subcat_$_selectedCategory'),
                      initialValue: subCategories.contains(_selectedSubCategory)
                          ? _selectedSubCategory
                          : null,
                      hint: Text(
                        _selectedCategory == null
                            ? 'اختر النوع أولاً'
                            : 'التصنيف الفرعي',
                        style: GoogleFonts.cairo(
                          fontSize: 12.0,
                          color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      isExpanded: true,
                      dropdownColor:
                          isDark ? const Color(0xFF1E293B) : Colors.white,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textMainLight,
                      ),
                      items: subCategories.map((sub) {
                        return DropdownMenuItem(
                          value: sub,
                          child: Text(sub, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedSubCategory = val),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.sell_outlined,
                          size: 18.0,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // 3. Row: Weight (الوزن الإجمالي) & Quantity (الكمية)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weight Compound
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      AppStrings.weightLabel, // 'الوزن الإجمالي'
                      isRequired: true,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 5.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textMainLight,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return AppStrings.weightRequiredError;
                              }
                              final numVal = double.tryParse(val.trim());
                              if (numVal == null || numVal <= 0) {
                                return AppStrings.weightRequiredError;
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: '0.0',
                              prefixIcon: Icon(
                                Icons.scale_rounded,
                                size: 18.0,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedWeightUnit,
                            isExpanded: true,
                            dropdownColor: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            style: GoogleFonts.cairo(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textMainLight,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'طن', child: Text('طن')),
                              DropdownMenuItem(value: 'كجم', child: Text('كجم')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedWeightUnit = val);
                              }
                            },
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10.0),

              // Quantity Compound
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      AppStrings.quantityLabel, // 'الكمية'
                      isRequired: true,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 5.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _qtyController,
                            keyboardType: TextInputType.number,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textMainLight,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return AppStrings.qtyRequiredError;
                              }
                              final intVal = int.tryParse(val.trim());
                              if (intVal == null || intVal <= 0) {
                                return AppStrings.qtyRequiredError;
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: '0',
                              prefixIcon: Icon(
                                Icons.all_inbox_rounded,
                                size: 18.0,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedQtyUnit,
                            hint: Text(
                              AppStrings.unitHint,
                              style: GoogleFonts.cairo(fontSize: 11.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                            isExpanded: true,
                            dropdownColor: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textMainLight,
                            ),
                            items: _qtyUnits.map((u) {
                              return DropdownMenuItem(
                                value: u,
                                child: Text(u, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedQtyUnit = val),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return AppStrings.qtyUnitRequiredError;
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Custom Unit if 'أخرى' is selected
          if (_selectedQtyUnit == 'أخرى') ...[
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _customUnitController,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                color: isDark ? AppColors.textWhite : AppColors.textMainLight,
              ),
              validator: (val) {
                if (_selectedQtyUnit == 'أخرى' &&
                    (val == null || val.trim().isEmpty)) {
                  return AppStrings.customUnitRequiredError;
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: AppStrings.customUnitHint,
                prefixIcon: const Icon(
                  Icons.edit_note_rounded,
                  size: 20.0,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // CARD 2: تفاصيل إضافية
  // ===========================================================================
  Widget _buildAdditionalDetailsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card 2 Header
          Row(
            children: [
              Container(
                width: 34.0,
                height: 34.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  size: 19.0,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تفاصيل إضافية',
                      style: GoogleFonts.cairo(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textWhite
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'معلومات تساعد على نقل آمن ومناسب',
                      style: GoogleFonts.cairo(
                        fontSize: 11.0,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  size: 16.0,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),

          // 1. طريقة التغليف *
          _buildFieldLabel(
            'طريقة التغليف',
            isRequired: true,
            isDark: isDark,
          ),
          const SizedBox(height: 5.0),
          DropdownButtonFormField<String>(
            initialValue: _selectedPackagingType,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            style: GoogleFonts.cairo(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
            items: _packagingTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedPackagingType = val);
            },
            decoration: const InputDecoration(
              hintText: 'اختر طريقة التغليف',
              prefixIcon: Icon(
                Icons.inventory_rounded,
                size: 20.0,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(height: 14.0),

          // 2. هل الحمولة قابلة للتلف؟ *
          Row(
            children: [
              const Icon(
                Icons.security_outlined,
                size: 16.0,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 5.0),
              _buildFieldLabel(
                'هل الحمولة قابلة للتلف؟',
                isRequired: true,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              // نعم Button (Selected State visually highlighted like reference)
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isPerishable = true),
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: _isPerishable == true
                          ? const Color(0xFFFFFBEB)
                          : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: _isPerishable == true
                            ? const Color(0xFFF59E0B)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE2E8F0)),
                        width: _isPerishable == true ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'نعم',
                          style: GoogleFonts.cairo(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: _isPerishable == true
                                ? const Color(0xFFB45309)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        if (_isPerishable == true) ...[
                          const SizedBox(width: 8.0),
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 18.0,
                            color: Color(0xFFF59E0B),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),

              // لا Button
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isPerishable = false),
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: _isPerishable == false
                          ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
                          : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: _isPerishable == false
                            ? const Color(0xFF475569)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE2E8F0)),
                        width: _isPerishable == false ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'لا',
                          style: GoogleFonts.cairo(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: _isPerishable == false
                                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                : const Color(0xFF64748B),
                          ),
                        ),
                        if (_isPerishable == false) ...[
                          const SizedBox(width: 8.0),
                          Icon(
                            Icons.check_circle_rounded,
                            size: 18.0,
                            color: isDark ? Colors.white : const Color(0xFF475569),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),

          // 3. تعليمات المناولة (اختياري)
          _buildFieldLabel(
            AppStrings.handlingRequirementsTitle, // 'تعليمات المناولة'
            isRequired: false,
            isDark: isDark,
          ),
          const SizedBox(height: 5.0),
          TextFormField(
            controller: _handlingController,
            maxLines: 2,
            minLines: 2,
            maxLength: 300,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
            decoration: const InputDecoration(
              hintText: 'مثال: يجب استخدام رافعة مناسبة عند التحميل ...',
              prefixIcon: Icon(
                Icons.assignment_outlined,
                size: 20.0,
                color: Color(0xFF64748B),
              ),
              counterText: '',
            ),
          ),
          // Suggestions Quick Chips
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: [
                AppStrings.handlingCovering,
                AppStrings.handlingCooling,
                AppStrings.handlingFragile,
                AppStrings.handlingHazardous,
              ].map((chip) {
                final isSelected = _selectedHandling.contains(chip);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedHandling.remove(chip);
                      } else {
                        _selectedHandling.add(chip);
                        if (!_handlingController.text.contains(chip)) {
                          final current = _handlingController.text.trim();
                          _handlingController.text = current.isEmpty
                              ? chip
                              : '$current • $chip';
                        }
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 3.0,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFEF3C7)
                          : (isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryGold
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      chip,
                      style: GoogleFonts.cairo(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF92400E)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12.0),

          // 4. ملاحظات إضافية (اختياري)
          _buildFieldLabel(
            AppStrings.cargoDescLabel, // 'ملاحظات إضافية'
            isRequired: false,
            isDark: isDark,
          ),
          const SizedBox(height: 5.0),
          TextFormField(
            controller: _descController,
            maxLines: 2,
            minLines: 2,
            maxLength: 300,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
            decoration: InputDecoration(
              hintText: AppStrings.cargoDescHint,
              prefixIcon: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20.0,
                color: Color(0xFF64748B),
              ),
              counterText: '',
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CARD 3: صور الحمولة (اختياري)
  // ===========================================================================
  Widget _buildCargoPhotosCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card 3 Header
          Row(
            children: [
              Container(
                width: 34.0,
                height: 34.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  size: 19.0,
                  color: Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'صور الحمولة (اختياري)',
                      style: GoogleFonts.cairo(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textWhite
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'يمكنك إضافة حتى 5 صور لتوضيح طبيعة البضاعة',
                      style: GoogleFonts.cairo(
                        fontSize: 11.0,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),

          // Upload Container with Dashed / Styled Border
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: const Color(0xFFCBD5E1),
                style: BorderStyle.solid,
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.image_rounded,
                  size: 40.0,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'إضافة صور للحمولة',
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'فضلاً اختر صور واضحة لمساعدة مقدم الخدمة على معرفة طبيعة البضاعة',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 11.0,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12.0),
                OutlinedButton.icon(
                  onPressed: _openImagePickerModal,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1D4ED8),
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 6.0,
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 16.0),
                  label: Text(
                    'اختيار الصور',
                    style: GoogleFonts.cairo(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quick Sample Attachment Chips (Satisfying testing & convenience)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      if (!_photos.contains('assets/images/hamula_port_cargo.jpg')) {
                        if (_photos.length < 5) {
                          _photos.add('assets/images/hamula_port_cargo.jpg');
                        }
                      }
                    });
                  },
                  child: Chip(
                    label: const Text(AppStrings.cargoSamplePort),
                    avatar: const Icon(Icons.photo_camera_back_outlined, size: 14.0),
                    backgroundColor: const Color(0xFFF1F5F9),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      if (!_photos.contains('assets/images/hamula_intercity_cargo.jpg')) {
                        if (_photos.length < 5) {
                          _photos.add('assets/images/hamula_intercity_cargo.jpg');
                        }
                      }
                    });
                  },
                  child: Chip(
                    label: const Text(AppStrings.cargoSampleIntercity),
                    avatar: const Icon(Icons.photo_library_outlined, size: 14.0),
                    backgroundColor: const Color(0xFFF1F5F9),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      if (!_docs.contains(AppStrings.cargoSampleWaybill)) {
                        _docs.add(AppStrings.cargoSampleWaybill);
                      }
                    });
                  },
                  child: Chip(
                    label: const Text(AppStrings.cargoSampleWaybill),
                    avatar: const Icon(Icons.description_outlined, size: 14.0),
                    backgroundColor: const Color(0xFFF1F5F9),
                  ),
                ),
              ],
            ),
          ),

          // Thumbnails Strip
          if (_photos.isNotEmpty) ...[
            const SizedBox(height: 14.0),
            SizedBox(
              height: 85.0,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length + (_photos.length < 5 ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(width: 10.0),
                itemBuilder: (context, index) {
                  // Button to add extra photo
                  if (index == _photos.length) {
                    return InkWell(
                      onTap: _openImagePickerModal,
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        width: 85.0,
                        height: 85.0,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              size: 22.0,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              'إضافة صورة',
                              style: GoogleFonts.cairo(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final photoPath = _photos[index];
                  return Stack(
                    children: [
                      Container(
                        width: 85.0,
                        height: 85.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11.0),
                          child: Image.asset(
                            photoPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Icon(Icons.image_outlined),
                            ),
                          ),
                        ),
                      ),
                      // Delete (X) Icon Button
                      Positioned(
                        top: 4.0,
                        right: 4.0,
                        child: InkWell(
                          onTap: () {
                            setState(() => _photos.removeAt(index));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(3.0),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 3.0,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 13.0,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. BOTTOM ACTION BUTTONS
  // ===========================================================================
  Widget _buildBottomActionButtons(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Primary Dark Button: حفظ الحمولة
          Expanded(
            flex: 3,
            child: ElevatedButton.icon(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 0,
              ),
              icon: const Icon(
                Icons.assignment_turned_in_outlined,
                size: 19.0,
              ),
              label: Text(
                widget.initialCargo != null
                    ? 'حفظ التعديلات'
                    : AppStrings.saveCargoButton,
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),

          // Secondary Blue Button: إنشاء طلب نقل
          Expanded(
            flex: 3,
            child: OutlinedButton(
              onPressed: _handleCreateOrderShortCut,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFEFF6FF),
                foregroundColor: const Color(0xFF1D4ED8),
                side: const BorderSide(color: Color(0xFFBFDBFE)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 7.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_shipping_rounded,
                    size: 19.0,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 6.0),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إنشاء طلب نقل',
                          style: GoogleFonts.cairo(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1D4ED8),
                            height: 1.15,
                          ),
                        ),
                        Text(
                          'استخدم هذه الحمولة في طلب نقل',
                          style: GoogleFonts.cairo(
                            fontSize: 9.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3B82F6),
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================
  Widget _buildFieldLabel(
    String label, {
    required bool isRequired,
    required bool isDark,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 3.0),
          const Text(
            '*',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
