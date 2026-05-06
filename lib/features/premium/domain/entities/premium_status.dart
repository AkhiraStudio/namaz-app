import 'package:equatable/equatable.dart';

enum PremiumProduct { monthly, yearly, lifetime }

class PremiumStatus extends Equatable {
  final bool isActive;
  final PremiumProduct? activeProduct;
  final DateTime? expirationDate;
  final bool isInGracePeriod;

  const PremiumStatus({
    required this.isActive,
    this.activeProduct,
    this.expirationDate,
    this.isInGracePeriod = false,
  });

  static const free = PremiumStatus(isActive: false);

  @override
  List<Object?> get props =>
      [isActive, activeProduct, expirationDate, isInGracePeriod];
}
