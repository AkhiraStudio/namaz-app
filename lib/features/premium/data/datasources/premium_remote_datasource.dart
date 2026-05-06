import 'dart:async';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../domain/entities/premium_status.dart';

abstract class PremiumRemoteDataSource {
  Stream<PremiumStatus> get statusStream;
  Future<PremiumStatus> getCurrentStatus();
  Future<PremiumStatus> purchaseProduct(String productId);
  Future<PremiumStatus> restorePurchases();
}

class PremiumRemoteDataSourceImpl implements PremiumRemoteDataSource {
  static const _entitlement = 'premium';

  final _controller = StreamController<PremiumStatus>.broadcast();

  PremiumRemoteDataSourceImpl() {
    Purchases.addCustomerInfoUpdateListener((info) {
      _controller.add(_mapInfo(info));
    });
  }

  PremiumStatus _mapInfo(CustomerInfo info) {
    final entitlement = info.entitlements.active[_entitlement];
    if (entitlement == null) return PremiumStatus.free;

    final expiry = entitlement.expirationDate != null
        ? DateTime.tryParse(entitlement.expirationDate!)
        : null;

    return PremiumStatus(
      isActive: true,
      activeProduct: _productFromId(entitlement.productIdentifier),
      expirationDate: expiry,
      isInGracePeriod: entitlement.billingIssueDetectedAt != null,
    );
  }

  PremiumProduct _productFromId(String id) {
    if (id.contains('lifetime')) return PremiumProduct.lifetime;
    if (id.contains('yearly') || id.contains('annual')) {
      return PremiumProduct.yearly;
    }
    return PremiumProduct.monthly;
  }

  @override
  Stream<PremiumStatus> get statusStream => _controller.stream;

  @override
  Future<PremiumStatus> getCurrentStatus() async {
    final info = await Purchases.getCustomerInfo();
    return _mapInfo(info);
  }

  @override
  Future<PremiumStatus> purchaseProduct(String productId) async {
    final offerings = await Purchases.getOfferings();
    final packages = offerings.current?.availablePackages ?? [];
    final pkg = packages.firstWhere(
      (p) => p.storeProduct.identifier == productId,
      orElse: () => throw Exception('Produit introuvable : $productId'),
    );
    final info = await Purchases.purchasePackage(pkg);
    return _mapInfo(info);
  }

  @override
  Future<PremiumStatus> restorePurchases() async {
    final info = await Purchases.restorePurchases();
    return _mapInfo(info);
  }
}
