import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testapp/core/error/failures.dart';
import 'package:flutter_testapp/core/theme/app_theme.dart';
import 'package:flutter_testapp/core/theme/theme_cubit.dart';
import 'package:flutter_testapp/features/catalog/domain/entities/product.dart';
import 'package:flutter_testapp/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:flutter_testapp/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:flutter_testapp/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:flutter_testapp/features/catalog/presentation/pages/catalog_page.dart';
import 'package:flutter_testapp/features/catalog/presentation/pages/product_details_page.dart';
import 'package:flutter_testapp/features/catalog/presentation/widgets/product_shimmer_grid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

const List<int> _kTransparentPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {}

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_kTransparentPng).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

Widget _buildTestHarness({
  required CatalogRepository repository,
  double textScale = 1.0,
}) {
  return MultiBlocProvider(
    providers: <BlocProvider<StateStreamableSource<Object?>>>[
      BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
      BlocProvider<CatalogBloc>(
        create: (_) =>
            CatalogBloc(repository: repository)..add(const CatalogLoadRequested()),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const CatalogPage(),
    ),
  );
}

void main() {
  late _MockCatalogRepository mockRepository;

  const List<Product> sampleProducts = <Product>[
    Product(
      id: 1,
      title: 'Ultra Precision Ergonomic Studio Monitor Stand Pro Edition',
      description:
          'Heavy-duty anodized aluminum monitor riser engineered for modern workspaces.',
      category: 'home-decoration',
      price: 1299.99,
      discountPercentage: 15.0,
      rating: 4.8,
      stock: 18,
      brand: 'NordicCraft Studio',
      thumbnail: 'https://cdn.example.com/stand-thumb.webp',
      images: <String>['https://cdn.example.com/stand.webp'],
      tags: <String>['workspace', 'aluminum'],
      shippingInformation: 'Ships in 1-2 business days',
      warrantyInformation: '2 year limited warranty',
      availabilityStatus: 'In Stock',
      returnPolicy: '30 days return policy',
    ),
    Product(
      id: 2,
      title: 'Velvet Lash Mascara',
      description: 'Long-lasting volumizing beauty formula.',
      category: 'beauty',
      price: 19.99,
      discountPercentage: 10.0,
      rating: 4.5,
      stock: 35,
      brand: 'Lumiere',
      thumbnail: 'https://cdn.example.com/mascara-thumb.webp',
      images: <String>['https://cdn.example.com/mascara.webp'],
      tags: <String>['beauty'],
      shippingInformation: 'Ships tomorrow',
      warrantyInformation: 'No warranty',
      availabilityStatus: 'In Stock',
      returnPolicy: '14 days return policy',
    ),
    Product(
      id: 3,
      title: 'Cedar Noir Eau de Parfum',
      description: 'Warm cedarwood and amber signature fragrance.',
      category: 'fragrances',
      price: 89.50,
      discountPercentage: 12.0,
      rating: 4.7,
      stock: 9,
      brand: 'Lumiere',
      thumbnail: 'https://cdn.example.com/perfume-thumb.webp',
      images: <String>['https://cdn.example.com/perfume.webp'],
      tags: <String>['fragrances'],
      shippingInformation: 'Ships in 3 days',
      warrantyInformation: 'No warranty',
      availabilityStatus: 'In Stock',
      returnPolicy: '30 days return policy',
    ),
  ];

  HttpOverrides? previousHttpOverrides;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    previousHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = _FakeHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = previousHttpOverrides;
  });

  setUp(() {
    mockRepository = _MockCatalogRepository();
  });

  group('Senior Audit Widget Verification', () {
    testWidgets(
      'renders Loading, Success, Empty, and Details with zero RenderFlex overflow at 1.3x font scale',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final Completer<CatalogResult<List<Product>>> completer =
            Completer<CatalogResult<List<Product>>>();
        when(() => mockRepository.getProducts())
            .thenAnswer((_) => completer.future);

        await tester.pumpWidget(
          _buildTestHarness(repository: mockRepository, textScale: 1.3),
        );
        await tester.pump();

        expect(find.byType(ProductShimmerGrid), findsOneWidget);
        expect(tester.takeException(), isNull);

        completer.complete(const CatalogSuccess<List<Product>>(sampleProducts));
        await tester.pumpAndSettle();

        expect(find.text('3 items available'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.enterText(find.byType(TextField), 'no-match-query');
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pumpAndSettle();

        expect(find.text('No matching products'), findsOneWidget);
        expect(find.text('Reset Filters'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Reset Filters'));
        await tester.pumpAndSettle();
        expect(find.text('3 items available'), findsOneWidget);

        await tester.tap(
          find.text('Ultra Precision Ergonomic Studio Monitor Stand Pro Edition'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ProductDetailsPage), findsOneWidget);
        expect(find.text('Product Specifications'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'renders Error state when offline and recovers cleanly on Try Again tap',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        int calls = 0;
        when(() => mockRepository.getProducts()).thenAnswer((_) async {
          calls += 1;
          if (calls == 1) {
            return const CatalogFailure<List<Product>>(NetworkFailure());
          }
          return const CatalogSuccess<List<Product>>(sampleProducts);
        });

        await tester.pumpWidget(
          _buildTestHarness(repository: mockRepository, textScale: 1.3),
        );
        await tester.pumpAndSettle();

        expect(find.text('Unable to load catalog'), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Try Again'));
        await tester.pumpAndSettle();

        expect(find.text('3 items available'), findsOneWidget);
        expect(find.text('Velvet Lash Mascara'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'handles rapid search typing combined with category switching without race conditions',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        when(() => mockRepository.getProducts()).thenAnswer(
          (_) async => const CatalogSuccess<List<Product>>(sampleProducts),
        );

        await tester.pumpWidget(
          _buildTestHarness(repository: mockRepository),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'mascara');
        await tester.pump(const Duration(milliseconds: 50));
        await tester.enterText(find.byType(TextField), 'Lumiere');
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('Fragrances'));
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pumpAndSettle();

        expect(find.text('1 item available'), findsOneWidget);
        expect(find.text('Cedar Noir Eau de Parfum'), findsOneWidget);
        expect(find.text('Velvet Lash Mascara'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
