/// Mobin X Hero & Promotional Banner Model
class BannerModel {
  final String id;
  final String title;
  final String image;
  final String actionUrl;
  final String badge;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.title,
    required this.image,
    this.actionUrl = '',
    this.badge = 'HOT',
    this.isActive = true,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? json['imageUrl']?.toString() ?? 'assets/images/banner_hero1.jpg',
      actionUrl: json['actionUrl']?.toString() ?? '',
      badge: json['badge']?.toString() ?? 'HOT',
      isActive: json['isActive'] != false && json['status'] != 'inactive',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'actionUrl': actionUrl,
      'badge': badge,
      'isActive': isActive,
    };
  }
}

/// Mobin X Flash Diamond Deal Model
class FlashDealModel {
  final String id;
  final String diamondAmount;
  final String price;
  final String badge;
  final String bonus;
  final bool inStock;

  FlashDealModel({
    required this.id,
    required this.diamondAmount,
    required this.price,
    this.badge = 'DEAL',
    this.bonus = '',
    this.inStock = true,
  });

  factory FlashDealModel.fromJson(Map<String, dynamic> json) {
    return FlashDealModel(
      id: json['id']?.toString() ?? '',
      diamondAmount: json['diamondAmount']?.toString() ?? '100 DIAMONDS',
      price: json['price']?.toString() ?? '৳ 80',
      badge: json['badge']?.toString() ?? 'DEAL',
      bonus: json['bonus']?.toString() ?? '',
      inStock: json['inStock'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diamondAmount': diamondAmount,
      'price': price,
      'badge': badge,
      'bonus': bonus,
      'inStock': inStock,
    };
  }
}
