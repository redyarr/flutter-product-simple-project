import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testapp/core/error/exceptions.dart';
import 'package:flutter_testapp/features/catalog/data/models/product_model.dart';

void main() {
  group('ProductModel.fromJson', () {
    test('parses a complete valid JSON payload accurately', () {
      final Map<String, Object?> json = <String, Object?>{
        'id': 1,
        'title': 'Essence Mascara Lash Princess',
        'description': 'Volumizing and lengthening mascara.',
        'category': 'beauty',
        'price': 9.99,
        'discountPercentage': 10.48,
        'rating': 4.56,
        'stock': 99,
        'brand': 'Essence',
        'thumbnail': 'https://cdn.dummyjson.com/products/1/thumbnail.webp',
        'images': <Object?>[
          'https://cdn.dummyjson.com/products/1/1.webp',
        ],
        'tags': <Object?>['beauty', 'mascara'],
        'shippingInformation': 'Ships in 3-5 business days',
        'warrantyInformation': '1 week warranty',
        'availabilityStatus': 'In Stock',
        'returnPolicy': 'No return policy',
      };

      final ProductModel model = ProductModel.fromJson(json);

      expect(model.id, 1);
      expect(model.title, 'Essence Mascara Lash Princess');
      expect(model.description, 'Volumizing and lengthening mascara.');
      expect(model.category, 'beauty');
      expect(model.price, 9.99);
      expect(model.discountPercentage, 10.48);
      expect(model.rating, 4.56);
      expect(model.stock, 99);
      expect(model.brand, 'Essence');
      expect(
        model.thumbnail,
        'https://cdn.dummyjson.com/products/1/thumbnail.webp',
      );
      expect(
        model.images,
        <String>['https://cdn.dummyjson.com/products/1/1.webp'],
      );
      expect(model.tags, <String>['beauty', 'mascara']);
      expect(model.shippingInformation, 'Ships in 3-5 business days');
      expect(model.warrantyInformation, '1 week warranty');
      expect(model.availabilityStatus, 'In Stock');
      expect(model.returnPolicy, 'No return policy');
    });

    test('handles integer numeric fields and missing optional fields safely', () {
      final Map<String, Object?> json = <String, Object?>{
        'id': 42,
        'title': 'Minimalist Desk Lamp',
        'price': 50,
        'rating': 7.5,
        'discountPercentage': 120,
        'stock': 0,
        'brand': null,
        'images': <Object?>['https://cdn.example.com/lamp.png', 123, null, ''],
      };

      final ProductModel model = ProductModel.fromJson(json);

      expect(model.id, 42);
      expect(model.title, 'Minimalist Desk Lamp');
      expect(model.price, 50.0);
      expect(model.rating, 5.0);
      expect(model.discountPercentage, 99.9);
      expect(model.brand, 'Catalog');
      expect(model.category, 'general');
      expect(model.availabilityStatus, 'Out of Stock');
      expect(model.images, <String>['https://cdn.example.com/lamp.png']);
      expect(model.tags, isEmpty);
    });

    test('throws DataParsingException when id is missing or non-positive', () {
      expect(
        () => ProductModel.fromJson(const <String, Object?>{
          'title': 'Valid Title',
          'price': 10.0,
        }),
        throwsA(isA<DataParsingException>()),
      );

      expect(
        () => ProductModel.fromJson(const <String, Object?>{
          'id': 0,
          'title': 'Valid Title',
          'price': 10.0,
        }),
        throwsA(isA<DataParsingException>()),
      );

      expect(
        () => ProductModel.fromJson(const <String, Object?>{
          'id': '1',
          'title': 'Valid Title',
          'price': 10.0,
        }),
        throwsA(isA<DataParsingException>()),
      );
    });

    test('throws DataParsingException when title is blank or mistyped', () {
      expect(
        () => ProductModel.fromJson(const <String, Object?>{
          'id': 1,
          'title': '   ',
          'price': 10.0,
        }),
        throwsA(isA<DataParsingException>()),
      );

      expect(
        () => ProductModel.fromJson(const <String, Object?>{
          'id': 1,
          'title': 999,
          'price': 10.0,
        }),
        throwsA(isA<DataParsingException>()),
      );
    });

    test('throws DataParsingException when price is missing, negative, or string', () {
      expect(
        () => ProductModel.fromJson(const <String, Object?>{
          'id': 1,
          'title': 'Valid Title',
        }),
        throwsA(isA<DataParsingException>()),
      );

      expect(
        () => ProductModel.fromJson(const <String, Object?>{
          'id': 1,
          'title': 'Valid Title',
          'price': -5.0,
        }),
        throwsA(isA<DataParsingException>()),
      );

      expect(
        () => ProductModel.fromJson(const <String, Object?>{
          'id': 1,
          'title': 'Valid Title',
          'price': '19.99',
        }),
        throwsA(isA<DataParsingException>()),
      );
    });
  });
}
