import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testapp/core/error/failures.dart';
import 'package:flutter_testapp/features/catalog/domain/entities/product.dart';
import 'package:flutter_testapp/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:flutter_testapp/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:flutter_testapp/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:flutter_testapp/features/catalog/presentation/bloc/catalog_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late _MockCatalogRepository mockRepository;

  const Product laptop = Product(
    id: 1,
    title: 'Pro Studio Laptop',
    description: 'High performance developer workstation.',
    category: 'laptops',
    price: 1499.0,
    discountPercentage: 10.0,
    rating: 4.9,
    stock: 12,
    brand: 'ApexTech',
    thumbnail: 'https://cdn.example.com/laptop-thumb.webp',
    images: <String>['https://cdn.example.com/laptop.webp'],
    tags: <String>['laptop', 'workstation'],
    shippingInformation: 'Ships tomorrow',
    warrantyInformation: '2 year warranty',
    availabilityStatus: 'In Stock',
    returnPolicy: '30 days return policy',
  );

  const Product mascara = Product(
    id: 2,
    title: 'Velvet Lash Mascara',
    description: 'Long-lasting volumizing beauty formula.',
    category: 'beauty',
    price: 14.5,
    discountPercentage: 5.0,
    rating: 4.4,
    stock: 40,
    brand: 'Lumiere',
    thumbnail: 'https://cdn.example.com/mascara-thumb.webp',
    images: <String>['https://cdn.example.com/mascara.webp'],
    tags: <String>['beauty'],
    shippingInformation: 'Ships in 2 days',
    warrantyInformation: 'No warranty',
    availabilityStatus: 'In Stock',
    returnPolicy: '14 days return policy',
  );

  const Product perfume = Product(
    id: 3,
    title: 'Cedar Noir Eau de Parfum',
    description: 'Woody aromatic fragrance.',
    category: 'fragrances',
    price: 89.0,
    discountPercentage: 0.0,
    rating: 4.7,
    stock: 8,
    brand: 'Lumiere',
    thumbnail: 'https://cdn.example.com/perfume-thumb.webp',
    images: <String>['https://cdn.example.com/perfume.webp'],
    tags: <String>['fragrances'],
    shippingInformation: 'Ships in 3 days',
    warrantyInformation: 'No warranty',
    availabilityStatus: 'In Stock',
    returnPolicy: '30 days return policy',
  );

  final List<Product> sampleProducts = <Product>[laptop, mascara, perfume];
  final List<String> sortedCategories = <String>[
    'beauty',
    'fragrances',
    'laptops',
  ];

  setUp(() {
    mockRepository = _MockCatalogRepository();
  });

  group('CatalogBloc', () {
    test('initial state is CatalogStatus.initial', () {
      final CatalogBloc bloc = CatalogBloc(repository: mockRepository);
      expect(bloc.state, const CatalogState());
      addTearDown(bloc.close);
    });

    blocTest<CatalogBloc, CatalogState>(
      'emits [loading, success] with sorted categories when load succeeds',
      build: () {
        when(() => mockRepository.getProducts()).thenAnswer(
          (_) async => CatalogSuccess<List<Product>>(sampleProducts),
        );
        return CatalogBloc(repository: mockRepository);
      },
      act: (CatalogBloc bloc) => bloc.add(const CatalogLoadRequested()),
      expect: () => <CatalogState>[
        const CatalogState(status: CatalogStatus.loading),
        CatalogState(
          status: CatalogStatus.success,
          allProducts: sampleProducts,
          filteredProducts: sampleProducts,
          categories: sortedCategories,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.getProducts()).called(1);
      },
    );

    blocTest<CatalogBloc, CatalogState>(
      'emits [loading, failure] with domain Failure when load fails',
      build: () {
        when(() => mockRepository.getProducts()).thenAnswer(
          (_) async => const CatalogFailure<List<Product>>(NetworkFailure()),
        );
        return CatalogBloc(repository: mockRepository);
      },
      act: (CatalogBloc bloc) => bloc.add(const CatalogLoadRequested()),
      expect: () => const <CatalogState>[
        CatalogState(status: CatalogStatus.loading),
        CatalogState(
          status: CatalogStatus.failure,
          failure: NetworkFailure(),
        ),
      ],
    );

    blocTest<CatalogBloc, CatalogState>(
      'debounces, sanitizes, and filters products on search query changes',
      build: () {
        when(() => mockRepository.getProducts()).thenAnswer(
          (_) async => CatalogSuccess<List<Product>>(sampleProducts),
        );
        return CatalogBloc(repository: mockRepository);
      },
      seed: () => CatalogState(
        status: CatalogStatus.success,
        allProducts: sampleProducts,
        filteredProducts: sampleProducts,
        categories: sortedCategories,
      ),
      act: (CatalogBloc bloc) {
        bloc
          ..add(const CatalogSearchQueryChanged('mascara'))
          ..add(const CatalogSearchQueryChanged('  Pro   Laptop  '))
          ..add(const CatalogSearchQueryChanged('  Lumiere   '));
      },
      wait: const Duration(milliseconds: 380),
      expect: () => <CatalogState>[
        CatalogState(
          status: CatalogStatus.success,
          allProducts: sampleProducts,
          filteredProducts: const <Product>[mascara, perfume],
          categories: sortedCategories,
          searchQuery: 'Lumiere',
        ),
      ],
    );

    blocTest<CatalogBloc, CatalogState>(
      'caps search queries to 100 characters during sanitization',
      build: () => CatalogBloc(
        repository: mockRepository,
        searchDebounce: Duration.zero,
      ),
      seed: () => CatalogState(
        status: CatalogStatus.success,
        allProducts: sampleProducts,
        filteredProducts: sampleProducts,
        categories: sortedCategories,
      ),
      act: (CatalogBloc bloc) {
        final String oversizedQuery = 'a' * 140;
        bloc.add(CatalogSearchQueryChanged(oversizedQuery));
      },
      expect: () => <CatalogState>[
        CatalogState(
          status: CatalogStatus.success,
          allProducts: sampleProducts,
          filteredProducts: const <Product>[],
          categories: sortedCategories,
          searchQuery: 'a' * 100,
        ),
      ],
    );

    blocTest<CatalogBloc, CatalogState>(
      'filters by category, combines with search, and resets filters cleanly',
      build: () => CatalogBloc(
        repository: mockRepository,
        searchDebounce: Duration.zero,
      ),
      seed: () => CatalogState(
        status: CatalogStatus.success,
        allProducts: sampleProducts,
        filteredProducts: sampleProducts,
        categories: sortedCategories,
      ),
      act: (CatalogBloc bloc) async {
        bloc.add(const CatalogCategorySelected('beauty'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const CatalogSearchQueryChanged('Lumiere'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const CatalogFiltersReset());
      },
      expect: () => <CatalogState>[
        CatalogState(
          status: CatalogStatus.success,
          allProducts: sampleProducts,
          filteredProducts: const <Product>[mascara],
          categories: sortedCategories,
          selectedCategory: 'beauty',
        ),
        CatalogState(
          status: CatalogStatus.success,
          allProducts: sampleProducts,
          filteredProducts: const <Product>[mascara],
          categories: sortedCategories,
          selectedCategory: 'beauty',
          searchQuery: 'Lumiere',
        ),
        CatalogState(
          status: CatalogStatus.success,
          allProducts: sampleProducts,
          filteredProducts: sampleProducts,
          categories: sortedCategories,
        ),
      ],
    );

    blocTest<CatalogBloc, CatalogState>(
      'prevents race conditions when rapid search overlaps category switch or reset',
      build: () => CatalogBloc(repository: mockRepository),
      seed: () => CatalogState(
        status: CatalogStatus.success,
        allProducts: sampleProducts,
        filteredProducts: sampleProducts,
        categories: sortedCategories,
      ),
      act: (CatalogBloc bloc) async {
        bloc
          ..add(const CatalogSearchQueryChanged('mascara'))
          ..add(const CatalogSearchQueryChanged('Lumiere'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const CatalogCategorySelected('fragrances'));
        await Future<void>.delayed(const Duration(milliseconds: 350));
        bloc
          ..add(const CatalogSearchQueryChanged('stale-query'))
          ..add(const CatalogFiltersReset());
        await Future<void>.delayed(const Duration(milliseconds: 350));
      },
      expect: () => <CatalogState>[
        CatalogState(
          status: CatalogStatus.success,
          allProducts: sampleProducts,
          filteredProducts: const <Product>[perfume],
          categories: sortedCategories,
          selectedCategory: 'fragrances',
        ),
        CatalogState(
          status: CatalogStatus.success,
          allProducts: sampleProducts,
          filteredProducts: const <Product>[perfume],
          categories: sortedCategories,
          selectedCategory: 'fragrances',
          searchQuery: 'Lumiere',
        ),
        CatalogState(
          status: CatalogStatus.success,
          allProducts: sampleProducts,
          filteredProducts: sampleProducts,
          categories: sortedCategories,
        ),
      ],
    );
  });
}
