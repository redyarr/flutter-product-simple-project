import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.thumbnail,
    required this.images,
    required this.tags,
    required this.shippingInformation,
    required this.warrantyInformation,
    required this.availabilityStatus,
    required this.returnPolicy,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String thumbnail;
  final List<String> images;
  final List<String> tags;
  final String shippingInformation;
  final String warrantyInformation;
  final String availabilityStatus;
  final String returnPolicy;

  String get primaryImageUrl {
    if (thumbnail.isNotEmpty) {
      return thumbnail;
    }
    if (images.isNotEmpty) {
      return images.first;
    }
    return '';
  }

  String get heroImageUrl {
    if (images.isNotEmpty) {
      return images.first;
    }
    return thumbnail;
  }

  double? get originalPrice {
    if (discountPercentage <= 0 || discountPercentage >= 100) {
      return null;
    }
    return price / (1 - (discountPercentage / 100));
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        description,
        category,
        price,
        discountPercentage,
        rating,
        stock,
        brand,
        thumbnail,
        images,
        tags,
        shippingInformation,
        warrantyInformation,
        availabilityStatus,
        returnPolicy,
      ];
}
