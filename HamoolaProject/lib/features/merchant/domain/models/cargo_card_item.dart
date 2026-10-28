import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

/// Domain model representing a merchant's cargo profile/card
class CargoCardItem {
  final String id;
  final String name;
  final String category;
  final String weight;
  final String quantity;
  final String handlingRequirement;
  final String? imageAsset;
  final bool isSpecialHandling;
  final IconData categoryIcon;
  final IconData? handlingIcon;
  final String? description;
  final String packagingType;
  final bool isPerishable;
  final List<String> photos;
  final List<String> documents;
  final String? volume;
  final List<String> linkedOrderIds;
  final String status;
  final String? subCategory;
  final String? notes;
  final String? createdAtFormatted;
  final int usageCount;

  const CargoCardItem({
    required this.id,
    required this.name,
    required this.category,
    required this.weight,
    required this.quantity,
    required this.handlingRequirement,
    this.imageAsset,
    this.isSpecialHandling = true,
    this.categoryIcon = Icons.inventory_2_outlined,
    this.handlingIcon,
    this.description,
    this.packagingType = 'طبالي خشبية',
    this.isPerishable = false,
    this.photos = const [],
    this.documents = const [],
    this.volume,
    this.linkedOrderIds = const [],
    this.status = 'متاحة للاستخدام',
    this.subCategory,
    this.notes,
    this.createdAtFormatted,
    this.usageCount = 0,
  });

  /// Check if cargo has an active order linked
  bool get hasActiveOrder => linkedOrderIds.isNotEmpty;

  CargoCardItem copyWith({
    String? id,
    String? name,
    String? category,
    String? weight,
    String? quantity,
    String? handlingRequirement,
    String? imageAsset,
    bool? isSpecialHandling,
    IconData? categoryIcon,
    IconData? handlingIcon,
    String? description,
    String? packagingType,
    bool? isPerishable,
    List<String>? photos,
    List<String>? documents,
    String? volume,
    List<String>? linkedOrderIds,
    String? status,
    String? subCategory,
    String? notes,
    String? createdAtFormatted,
    int? usageCount,
  }) {
    return CargoCardItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      weight: weight ?? this.weight,
      quantity: quantity ?? this.quantity,
      handlingRequirement: handlingRequirement ?? this.handlingRequirement,
      imageAsset: imageAsset ?? this.imageAsset,
      isSpecialHandling: isSpecialHandling ?? this.isSpecialHandling,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      handlingIcon: handlingIcon ?? this.handlingIcon,
      description: description ?? this.description,
      packagingType: packagingType ?? this.packagingType,
      isPerishable: isPerishable ?? this.isPerishable,
      photos: photos ?? this.photos,
      documents: documents ?? this.documents,
      volume: volume ?? this.volume,
      linkedOrderIds: linkedOrderIds ?? this.linkedOrderIds,
      status: status ?? this.status,
      subCategory: subCategory ?? this.subCategory,
      notes: notes ?? this.notes,
      createdAtFormatted: createdAtFormatted ?? this.createdAtFormatted,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  /// Default demo cargos from Hamoola prototype matching reference visual direction
  static List<CargoCardItem> get demoCargos => [
        const CargoCardItem(
          id: 'CRG-001',
          name: 'حديد تسليح',
          category: AppStrings.buildingMaterials,
          subCategory: 'حديد إنشائي',
          weight: '10 طن',
          quantity: '200 وحدة',
          handlingRequirement: AppStrings.coveringRequired,
          imageAsset: 'assets/images/cargo_ref_1.jpg',
          isSpecialHandling: true,
          categoryIcon: Icons.view_in_ar_rounded,
          handlingIcon: Icons.security_rounded,
          description:
              'حديد تسليح بمواصفات قياسية عالي الجودة، مناسب للمشاريع الإنشائية والمقاولات الكبرى.',
          packagingType: 'ربطات حديدية',
          isPerishable: false,
          photos: [
            'assets/images/cargo_ref_1.jpg',
            'assets/images/cargo_ref_2.jpg',
            'assets/images/cargo_ref_3.jpg',
            'assets/images/cargo_ref_4.jpg',
          ],
          documents: ['بوليصة شحن رقم 90812.pdf', 'تصريح نقل مواد إنشائية.pdf'],
          volume: '8 م³',
          linkedOrderIds: ['REQ-1024'],
          status: 'مرتبطة بطلب نشط',
          createdAtFormatted: '2026/10/05',
          usageCount: 2,
          notes: 'يُفضل النقل في شاحنات مسطحة مع تأمين جيد وربط محكم للحمولة.',
        ),
        const CargoCardItem(
          id: 'CRG-002',
          name: 'إسمنت',
          category: AppStrings.buildingMaterials,
          subCategory: 'إسمنت بورتلاندي',
          weight: '5 طن',
          quantity: '100 كيس',
          handlingRequirement: AppStrings.normalHandling,
          imageAsset: 'assets/images/hamula_port_cargo.jpg',
          isSpecialHandling: false,
          categoryIcon: Icons.view_in_ar_rounded,
          handlingIcon: null,
          description:
              'إسمنت بورتلاندي عالي المقاومة معبأ بأكياس 50 كجم، تخزين داخلي وجاف مع منع الرطوبة.',
          packagingType: 'أكياس ورقية',
          isPerishable: false,
          photos: ['assets/images/hamula_port_cargo.jpg'],
          documents: ['فاتورة شراء معتمدة.pdf'],
          volume: '4 م³',
          linkedOrderIds: [],
          status: 'متاحة للاستخدام',
          createdAtFormatted: '2026/10/02',
          usageCount: 1,
          notes: 'حماية كاملة من الأمطار والبلل أثناء مسار النقل.',
        ),
        const CargoCardItem(
          id: 'CRG-003',
          name: 'مواد تموينية وزيوت',
          category: AppStrings.foodSupplies,
          subCategory: 'منتجات غذائية',
          weight: '8 طن',
          quantity: '350 كرتون',
          handlingRequirement: AppStrings.perishableVentilation,
          imageAsset: 'assets/images/hamula_intercity_cargo.jpg',
          isSpecialHandling: true,
          categoryIcon: Icons.shopping_basket_outlined,
          handlingIcon: Icons.ac_unit_rounded,
          description:
              'كراتين زيوت طعام وأغذية مجففة، تتطلب تهوية جيدة وصندوق مقفل بعيداً عن أشعة الشمس.',
          packagingType: 'كراتين مقواة',
          isPerishable: true,
          photos: ['assets/images/hamula_intercity_cargo.jpg'],
          documents: ['شهادة فحص صحي ورقابي.pdf', 'بيان جمركي رقم 4410.pdf'],
          volume: '16 م³',
          linkedOrderIds: ['REQ-1023'],
          status: 'مكتملة الاستخدام',
          createdAtFormatted: '2026/09/25',
          usageCount: 3,
          notes: 'تبريد خفيف وتهوية منتظمة مع عدم رص الكراتين لأكثر من 5 طبقات.',
        ),
      ];
}
