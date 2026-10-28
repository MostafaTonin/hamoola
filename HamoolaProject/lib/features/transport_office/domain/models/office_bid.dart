/// Domain model representing a binding price bid submitted by a transport office
class OfficeBid {
  final String id;
  final String orderId;
  final String officeUserId;
  final String officeName;
  final double offeredPrice;
  final String deliveryDuration;
  final String notes;
  final DateTime createdAt;
  final bool isAccepted;

  const OfficeBid({
    required this.id,
    required this.orderId,
    required this.officeUserId,
    required this.officeName,
    required this.offeredPrice,
    required this.deliveryDuration,
    required this.notes,
    required this.createdAt,
    this.isAccepted = false,
  });

  OfficeBid copyWith({
    String? id,
    String? orderId,
    String? officeUserId,
    String? officeName,
    double? offeredPrice,
    String? deliveryDuration,
    String? notes,
    DateTime? createdAt,
    bool? isAccepted,
  }) {
    return OfficeBid(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      officeUserId: officeUserId ?? this.officeUserId,
      officeName: officeName ?? this.officeName,
      offeredPrice: offeredPrice ?? this.offeredPrice,
      deliveryDuration: deliveryDuration ?? this.deliveryDuration,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      isAccepted: isAccepted ?? this.isAccepted,
    );
  }
}
