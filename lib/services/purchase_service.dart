import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_character.dart';
import '../config/monetization_config.dart';
import 'character_service.dart';

class PurchaseService {
  InAppPurchase? _iap;
  final CharacterService _characterService;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final Map<String, ProductDetails> _products = {};
  bool _available = false;
  bool _adFree = false;

  PurchaseService(this._characterService);

  /// Reklamsız paket satın alınmış mı
  bool get isAdFree => _adFree;

  /// Ürün bilgisi (fiyat dahil) — Google Play'den dinamik gelir
  String getPrice(String productId) {
    final product = _products[productId];
    if (product != null) return product.price;
    return '...';
  }

  String getSingleCharacterPrice(CharacterId id) {
    return getPrice('${MonetizationConfig.productIdPrefix}${id.name}');
  }

  String getBundlePrice() {
    return getPrice(MonetizationConfig.productIdBundle);
  }

  String getAdFreePrice() {
    return getPrice(MonetizationConfig.productIdAdFree);
  }

  bool get isAvailable => _available;

  Future<void> init() async {
    // Reklamsız durumu yükle
    final prefs = await SharedPreferences.getInstance();
    _adFree = prefs.getBool('ad_free') ?? false;

    // Web'de IAP desteklenmiyor
    if (kIsWeb) return;

    _iap = InAppPurchase.instance;
    _available = await _iap!.isAvailable();
    if (!_available) return;

    _subscription = _iap!.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) {},
    );

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (_iap == null) return;

    final productIds = <String>{
      MonetizationConfig.productIdBundle,
      MonetizationConfig.productIdAdFree,
    };

    for (final character in GameCharacter.all) {
      if (!character.isFree) {
        productIds.add(character.productId);
      }
    }

    final response = await _iap!.queryProductDetails(productIds);
    for (final product in response.productDetails) {
      _products[product.id] = product;
    }
  }

  Future<void> buyCharacter(CharacterId id) async {
    final character = GameCharacter.getById(id);
    final product = _products[character.productId];
    if (product == null || _iap == null) return;

    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap!.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> buyBundle() async {
    final product = _products[MonetizationConfig.productIdBundle];
    if (product == null || _iap == null) return;

    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap!.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> buyAdFree() async {
    final product = _products[MonetizationConfig.productIdAdFree];
    if (product == null || _iap == null) return;

    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap!.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _handleSuccessfulPurchase(purchase);
      }

      if (purchase.pendingCompletePurchase) {
        _iap!.completePurchase(purchase);
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    if (purchase.productID == MonetizationConfig.productIdAdFree) {
      _adFree = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ad_free', true);
    } else if (purchase.productID == MonetizationConfig.productIdBundle) {
      _characterService.setAllOwned();
    } else if (purchase.productID.startsWith(MonetizationConfig.productIdPrefix)) {
      final charName = purchase.productID.replaceFirst(
        '${MonetizationConfig.productIdPrefix}_',
        '',
      );
      try {
        final id = CharacterId.values.firstWhere((e) => e.name == charName);
        _characterService.setOwned(id);
      } catch (_) {}
    }
  }

  Future<void> restorePurchases() async {
    if (_iap == null) return;
    await _iap!.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
