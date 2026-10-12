import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/buttons/hamula_button.dart';
import '../../domain/models/cargo_card_item.dart';

class MerchantCreateCargoScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<CargoCardItem>? onSubmitCargo;

  const MerchantCreateCargoScreen({
    super.key,
    this.onBack,
    this.onSubmitCargo,
  });

  @override
  State<MerchantCreateCargoScreen> createState() =>
      _MerchantCreateCargoScreenState();
}

class _MerchantCreateCargoScreenState extends State<MerchantCreateCargoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _weightController = TextEditingController();
  final _qtyController = TextEditingController();
  final _customUnitController = TextEditingController();
  final _volumeController = TextEditingController();

  String? _selectedCategory;
  String _selectedWeightUnit = 'طن';
  String? _selectedQtyUnit;

  final Set<String> _selectedHandling = {};
  final List<String> _photos = [];
  final List<String> _docs = [];

  static const List<String> _categories = [
    'بضائع عامة وسلع مستوردة',
    'مواد غذائية',
    'مستلزمات طبية ومعدات صحية',
    'مواد بناء',
    'إلكترونيات وأجهزة كهربائية',
    'ملابس ومنسوجات وأقمشة',
    'منتجات زراعية ومحاصيل',
    'قطع غيار ومعدات صناعية',
    'زيوت ومنتجات بترولية',
    'أخرى',
  ];

  static const List<String> _qtyUnits = [
    'كرتون',
    'كيس',
    'طرد',
    'وحدة',
    'أخرى',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _weightController.dispose();
    _qtyController.dispose();
    _customUnitController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final unitStr = _selectedQtyUnit == 'أخرى'
          ? _customUnitController.text.trim()
          : _selectedQtyUnit ?? 'وحدة';

      final handlingStr = _selectedHandling.isEmpty
          ? AppStrings.normalHandling
          : _selectedHandling.join(' • ');

      final newCargo = CargoCardItem(
        id: 'CRG-${100 + (_photos.length * 10) + (_docs.length + 1)}',
        name: _nameController.text.trim(),
        category: _selectedCategory ?? AppStrings.buildingMaterials,
        weight: '${_weightController.text.trim()} $_selectedWeightUnit',
        quantity: '${_qtyController.text.trim()} $unitStr',
        handlingRequirement: handlingStr,
        imageAsset: _photos.isNotEmpty ? _photos.first : null,
        isSpecialHandling: _selectedHandling.isNotEmpty,
        categoryIcon: _getCategoryIcon(_selectedCategory),
        handlingIcon: _selectedHandling.isNotEmpty ? Icons.security_rounded : null,
      );

      widget.onSubmitCargo?.call(newCargo);
    }
  }

  IconData _getCategoryIcon(String? category) {
    if (category == 'مواد غذائية') return Icons.shopping_basket_outlined;
    if (category == 'إلكترونيات وأجهزة كهربائية') return Icons.devices_rounded;
    if (category == 'مستلزمات طبية ومعدات صحية') return Icons.medical_services_outlined;
    return Icons.view_in_ar_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.navyDark : AppColors.backgroundLight,
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

                  // 2. Scrollable Form
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceMd,
                        vertical: AppDimensions.spaceSm,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Section Header
                            _buildSectionHeader(isDark),
                            const SizedBox(height: 14.0),

                            // Cargo Name Field
                            _buildCargoNameField(isDark),
                            const SizedBox(height: 12.0),

                            // Cargo Description Field
                            _buildCargoDescField(isDark),
                            const SizedBox(height: 12.0),

                            // Category Field
                            _buildCategoryField(isDark),
                            const SizedBox(height: 12.0),

                            // Weight Field (Compound with Unit)
                            _buildWeightField(isDark),
                            const SizedBox(height: 12.0),

                            // Quantity Field (Compound with Unit)
                            _buildQuantityField(isDark),
                            const SizedBox(height: 12.0),

                            // Volume Field (Optional with m³)
                            _buildVolumeField(isDark),
                            const SizedBox(height: 16.0),

                            // Handling Requirements Checkboxes
                            _buildHandlingSection(isDark),
                            const SizedBox(height: 16.0),

                            // Cargo Photos Upload Section
                            _buildPhotosSection(isDark),
                            const SizedBox(height: 16.0),

                            // Cargo Documents Section
                            _buildDocsSection(isDark),
                            const SizedBox(height: 24.0),

                            // Submit Button
                            HamulaButton(
                              label: AppStrings.saveCargoButton,
                              onPressed: _handleSubmit,
                              variant: HamulaButtonVariant.primary,
                              size: HamulaButtonSize.lg,
                            ),
                            const SizedBox(height: 32.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20.0),
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            onPressed: widget.onBack,
            tooltip: AppStrings.back,
          ),
          Text(
            AppStrings.createCargoTitle,
            style: GoogleFonts.cairo(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
          ),
          const SizedBox(width: 44.0), // Balance placeholder
        ],
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark) {
    return Row(
      children: [
        Container(
          width: 28.0,
          height: 28.0,
          decoration: BoxDecoration(
            color: const Color(0x2EF59E0B),
            borderRadius: BorderRadius.circular(7.0),
          ),
          child: const Icon(
            Icons.inventory_2_rounded,
            size: 16.0,
            color: AppColors.primaryGold,
          ),
        ),
        const SizedBox(width: 8.0),
        Text(
          AppStrings.cargoInfoSection,
          style: GoogleFonts.cairo(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
      ],
    );
  }

  Widget _buildCargoNameField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(AppStrings.cargoNameLabel, isRequired: true, isDark: isDark),
        const SizedBox(height: 5.0),
        TextFormField(
          controller: _nameController,
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppStrings.cargoNameRequiredError;
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: AppStrings.cargoNameHint,
            prefixIcon: const Icon(Icons.inventory_2_outlined, size: 20.0),
          ),
        ),
      ],
    );
  }

  Widget _buildCargoDescField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(AppStrings.cargoDescLabel, isOptional: true, isDark: isDark),
        const SizedBox(height: 5.0),
        TextFormField(
          controller: _descController,
          maxLines: 3,
          style: GoogleFonts.cairo(
            fontSize: 13.0,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
          decoration: InputDecoration(
            hintText: AppStrings.cargoDescHint,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(AppStrings.categoryLabel, isRequired: true, isDark: isDark),
        const SizedBox(height: 5.0),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
          items: _categories.map((cat) {
            return DropdownMenuItem<String>(
              value: cat,
              child: Text(cat),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
          validator: (val) {
            if (val == null || val.isEmpty) {
              return AppStrings.categoryRequiredError;
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: AppStrings.categoryHint,
            prefixIcon: const Icon(Icons.category_outlined, size: 20.0),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(AppStrings.weightLabel, isRequired: true, isDark: isDark),
        const SizedBox(height: 5.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textWhite : AppColors.textMainLight,
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
                  prefixIcon: Icon(Icons.scale_outlined, size: 20.0),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                initialValue: _selectedWeightUnit,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                ),
                items: const [
                  DropdownMenuItem(value: 'طن', child: Text('طن')),
                  DropdownMenuItem(value: 'كجم', child: Text('كجم')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedWeightUnit = val);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(AppStrings.quantityLabel, isRequired: true, isDark: isDark),
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
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textWhite : AppColors.textMainLight,
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
                  prefixIcon: Icon(Icons.format_list_numbered_rounded, size: 20.0),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                initialValue: _selectedQtyUnit,
                hint: Text(
                  AppStrings.unitHint,
                  style: GoogleFonts.cairo(fontSize: 12.0),
                ),
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                style: GoogleFonts.cairo(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                ),
                items: _qtyUnits.map((u) {
                  return DropdownMenuItem(value: u, child: Text(u));
                }).toList(),
                onChanged: (val) => setState(() => _selectedQtyUnit = val),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return AppStrings.qtyUnitRequiredError;
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        if (_selectedQtyUnit == 'أخرى') ...[
          const SizedBox(height: 8.0),
          TextFormField(
            controller: _customUnitController,
            style: GoogleFonts.cairo(
              fontSize: 13.0,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
            validator: (val) {
              if (_selectedQtyUnit == 'أخرى' && (val == null || val.trim().isEmpty)) {
                return AppStrings.customUnitRequiredError;
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: AppStrings.customUnitHint,
              prefixIcon: const Icon(Icons.edit_note_rounded, size: 20.0),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVolumeField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(AppStrings.volumeLabel, isOptional: true, isDark: isDark),
        const SizedBox(height: 5.0),
        TextFormField(
          controller: _volumeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 14.0,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
          validator: (val) {
            if (val != null && val.trim().isNotEmpty) {
              final numVal = double.tryParse(val.trim());
              if (numVal == null || numVal <= 0) {
                return AppStrings.volumeInvalidError;
              }
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: AppStrings.volumeHint,
            prefixIcon: const Icon(Icons.aspect_ratio_rounded, size: 20.0),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Center(
                widthFactor: 1.0,
                child: Text(
                  AppStrings.volumeUnit,
                  style: GoogleFonts.cairo(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHandlingSection(bool isDark) {
    const options = [
      AppStrings.handlingCooling,
      AppStrings.handlingFragile,
      AppStrings.handlingCovering,
      AppStrings.handlingHazardous,
      AppStrings.handlingTimeSensitive,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.handlingRequirementsTitle,
          style: GoogleFonts.cairo(
            fontSize: 13.0,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
        Text(
          AppStrings.handlingRequirementsSubtitle,
          style: GoogleFonts.cairo(
            fontSize: 11.0,
            color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: options.map((opt) {
            final isChecked = _selectedHandling.contains(opt);
            return FilterChip(
              label: Text(opt),
              selected: isChecked,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedHandling.add(opt);
                  } else {
                    _selectedHandling.remove(opt);
                  }
                });
              },
              selectedColor: const Color(0x33F59E0B),
              checkmarkColor: AppColors.primaryGold,
              labelStyle: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500,
                color: isChecked
                    ? AppColors.primaryGold
                    : (isDark ? AppColors.textWhite : AppColors.textMainLight),
              ),
              backgroundColor: isDark
                  ? const Color(0x661E293B)
                  : const Color(0xFFF1F5F9),
              side: BorderSide(
                color: isChecked
                    ? AppColors.primaryGold
                    : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.borderLight),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPhotosSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.cargoPhotosTitle,
          style: GoogleFonts.cairo(
            fontSize: 13.0,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
        Text(
          AppStrings.cargoPhotosSubtitle,
          style: GoogleFonts.cairo(
            fontSize: 11.0,
            color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
          ),
        ),
        const SizedBox(height: 8.0),
        // Upload trigger area
        InkWell(
          onTap: () {
            setState(() {
              _photos.add('assets/images/hamula_port_cargo.jpg');
            });
          },
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x661E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.borderLight,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 38.0,
                  height: 38.0,
                  decoration: BoxDecoration(
                    color: const Color(0x2EF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.primaryGold,
                    size: 20.0,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  AppStrings.cargoPhotosUploadMain,
                  style: GoogleFonts.cairo(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
                Text(
                  AppStrings.cargoPhotosUploadSub,
                  style: GoogleFonts.cairo(
                    fontSize: 10.0,
                    color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Photos Strip
        if (_photos.isNotEmpty) ...[
          const SizedBox(height: 8.0),
          SizedBox(
            height: 60.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8.0),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        _photos[index],
                        width: 60.0,
                        height: 60.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 2.0,
                      left: 2.0,
                      child: InkWell(
                        onTap: () => setState(() => _photos.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 14.0,
                            color: Colors.white,
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
        // Sample photo quick buttons
        const SizedBox(height: 6.0),
        Row(
          children: [
            Text(
              AppStrings.cargoSamplePhotoPrompt,
              style: GoogleFonts.cairo(
                fontSize: 10.5,
                color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(width: 6.0),
            ActionChip(
              label: Text(
                AppStrings.cargoSamplePort,
                style: GoogleFonts.cairo(fontSize: 10.5, color: AppColors.primaryGold),
              ),
              onPressed: () {
                setState(() => _photos.add('assets/images/hamula_port_cargo.jpg'));
              },
            ),
            const SizedBox(width: 4.0),
            ActionChip(
              label: Text(
                AppStrings.cargoSampleIntercity,
                style: GoogleFonts.cairo(fontSize: 10.5, color: AppColors.primaryGold),
              ),
              onPressed: () {
                setState(() => _photos.add('assets/images/hamula_intercity_cargo.jpg'));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.cargoDocsTitle,
          style: GoogleFonts.cairo(
            fontSize: 13.0,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
        Text(
          AppStrings.cargoDocsSubtitle,
          style: GoogleFonts.cairo(
            fontSize: 11.0,
            color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
          ),
        ),
        const SizedBox(height: 8.0),
        // Upload trigger area
        InkWell(
          onTap: () {
            setState(() {
              _docs.add(AppStrings.cargoSampleWaybill);
            });
          },
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x661E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.borderLight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 38.0,
                  height: 38.0,
                  decoration: BoxDecoration(
                    color: const Color(0x2EF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: AppColors.primaryGold,
                    size: 20.0,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  AppStrings.cargoDocsUploadMain,
                  style: GoogleFonts.cairo(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
                Text(
                  AppStrings.cargoDocsUploadSub,
                  style: GoogleFonts.cairo(
                    fontSize: 10.0,
                    color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Docs List
        if (_docs.isNotEmpty) ...[
          const SizedBox(height: 8.0),
          Column(
            children: _docs.asMap().entries.map((entry) {
              final idx = entry.key;
              final doc = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 6.0),
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x801E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf_outlined,
                        size: 18.0, color: AppColors.error),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        doc,
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16.0),
                      onPressed: () => setState(() => _docs.removeAt(idx)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        // Sample docs quick buttons
        const SizedBox(height: 6.0),
        Row(
          children: [
            Text(
              AppStrings.cargoSampleDocPrompt,
              style: GoogleFonts.cairo(
                fontSize: 10.5,
                color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(width: 6.0),
            ActionChip(
              label: Text(
                AppStrings.cargoSampleWaybill,
                style: GoogleFonts.cairo(fontSize: 10.5, color: AppColors.primaryGold),
              ),
              onPressed: () {
                setState(() => _docs.add(AppStrings.cargoSampleWaybill));
              },
            ),
            const SizedBox(width: 4.0),
            ActionChip(
              label: Text(
                AppStrings.cargoSamplePermit,
                style: GoogleFonts.cairo(fontSize: 10.5, color: AppColors.primaryGold),
              ),
              onPressed: () {
                setState(() => _docs.add(AppStrings.cargoSamplePermit));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label,
      {bool isRequired = false, bool isOptional = false, required bool isDark}) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4.0),
          Text(
            '*',
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppColors.error,
            ),
          ),
        ],
        if (isOptional) ...[
          const SizedBox(width: 4.0),
          Text(
            AppStrings.optionalTag,
            style: GoogleFonts.cairo(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
            ),
          ),
        ],
      ],
    );
  }
}
