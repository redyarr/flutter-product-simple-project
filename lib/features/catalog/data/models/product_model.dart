import 'package:flutter_testapp/core/error/exceptions.dart';
import 'package:flutter_testapp/features/catalog/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.price,
    required super.discountPercentage,
    required super.rating,
    required super.stock,
    required super.brand,
    required super.thumbnail,
    required super.images,
    required super.tags,
    required super.shippingInformation,
    required super.warrantyInformation,
    required super.availabilityStatus,
    required super.returnPolicy,
  });

  factory ProductModel.fromJson(Map<String, Object?> json) {
    final int id = _requirePositiveInt(json['id'], 'id');
    final String title = _requireNonEmptyString(json['title'], 'title');
    final double price = _requireNonNegativeDouble(json['price'], 'price');

    final String description = _readString(json['description']);
    final String category = _readString(
      json['category'],
      fallback: 'general',
    );
    final double discountPercentage =
        _readDouble(json['discountPercentage']).clamp(0.0, 99.9);
    final double rating = _readDouble(json['rating']).clamp(0.0, 5.0);
    final int stock = _readNonNegativeInt(json['stock']);
    final String brand = _readString(json['brand'], fallback: 'Catalog');
    final String thumbnail = _readString(json['thumbnail']);
    final List<String> images = _readStringList(json['images']);
    final List<String> tags = _readStringList(json['tags']);
    final String shippingInformation = _readString(
      json['shippingInformation'],
      fallback: 'Standard shipping',
    );
    final String warrantyInformation = _readString(
      json['warrantyInformation'],
      fallback: 'Manufacturer warranty',
    );
    final String availabilityStatus = _readString(
      json['availabilityStatus'],
      fallback: stock > 0 ? 'In Stock' : 'Out of Stock',
    );
    final String returnPolicy = _readString(
      json['returnPolicy'],
      fallback: 'Standard return policy',
    );

    return ProductModel(
      id: id,
      title: title,
      description: description,
      category: category,
      price: price,
      discountPercentage: discountPercentage,
      rating: rating,
      stock: stock,
      brand: brand,
      thumbnail: thumbnail,
      images: images,
      tags: tags,
      shippingInformation: shippingInformation,
      warrantyInformation: warrantyInformation,
      availabilityStatus: availabilityStatus,
      returnPolicy: returnPolicy,
    );
  }

  static int _requirePositiveInt(Object? value, String fieldName) {
    if (value is int && value > 0) {
      return value;
    }
    throw DataParsingException('Invalid or missing positive int for "$fieldName".');
  }

  static String _requireNonEmptyString(Object? value, String fieldName) {
    if (value is String) {
      final String trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    throw DataParsingException('Invalid or missing non-empty string for "$fieldName".');
  }

  static double _requireNonNegativeDouble(Object? value, String fieldName) {
    if (value is num && value.isFinite && value >= 0) {
      return value.toDouble();
    }
    throw DataParsingException('Invalid or missing non-negative number for "$fieldName".');
  }

  static String _readString(Object? value, {String fallback = ''}) {
    if (value is String) {
      final String trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return fallback;
  }

  static double _readDouble(Object? value, {double fallback = 0.0}) {
    if (value is num && value.isFinite) {
      return value.toDouble();
    }
    return fallback;
  }

  static int _readNonNegativeInt(Object? value, {int fallback = 0}) {
    if (value is int && value >= 0) {
      return value;
    }
    if (value is num && value.isFinite && value >= 0) {
      return value.toInt();
    }
    return fallback;
  }

  static List<String> _readStringList(Object? value) {
    if (value is! List<Object?>) {
      return const <String>[];
    }
    final List<String> items = <String>[];
    for (final Object? element in value) {
      if (element is String) {
        final String trimmed = element.trim();
        if (trimmed.isNotEmpty) {
          items.add(trimmed);
        }
      }
    }
    return List<String>.unmodifiable(items);
  }
}
