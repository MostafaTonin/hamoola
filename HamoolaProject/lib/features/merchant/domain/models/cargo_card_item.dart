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
  });

  /// Default demo cargos from Hamoola prototype
  static List<CargoCardItem> get demoCargos => [
        const CargoCardItem(
          id: 'CRG-001',
          name: 'حديد تسليح',
          category: AppStrings.buildingMaterials,
          weight: '10 طن',
          quantity: '200 وحدة',
          handlingRequirement: AppStrings.coveringRequired,
          imageAsset: 'assets/images/hamula_port_cargo.jpg',
          isSpecialHandling: true,
          categoryIcon: Icons.view_in_ar_rounded,
          handlingIcon: Icons.security_rounded,
        ),
        const CargoCardItem(
          id: 'CRG-002',
          name: 'إسمنت',
          category: AppStrings.buildingMaterials,
          weight: '5 طن',
          quantity: '100 كيس',
          handlingRequirement: AppStrings.normalHandling,
          imageAsset: null,
          isSpecialHandling: false,
          categoryIcon: Icons.view_in_ar_rounded,
          handlingIcon: null,
        ),
        const CargoCardItem(
          id: 'CRG-003',
          name: 'مواد تموينية وزيوت',
          category: AppStrings.foodSupplies,
          weight: '8 طن',
          quantity: '350 كرتون',
          handlingRequirement: AppStrings.perishableVentilation,
          imageAsset: 'assets/images/hamula_intercity_cargo.jpg',
          isSpecialHandling: true,
          categoryIcon: Icons.shopping_basket_outlined,
          handlingIcon: Icons.ac_unit_rounded,
        ),
      ];
}
