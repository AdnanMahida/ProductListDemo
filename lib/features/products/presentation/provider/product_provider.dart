import 'package:product_list_demo/core/network/api_client.dart';
import 'package:product_list_demo/features/products/data/datasource/product_remote_datasource.dart';
import 'package:product_list_demo/features/products/data/repository/product_repository.dart';
import 'package:product_list_demo/features/products/domain/entities/product.dart';
import 'package:product_list_demo/features/products/domain/repository/product_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final apiClientProvider = Provider<ApiClient>( (ref) => ApiClient(),);

final productRemoteDataSourceProvider =
    Provider<ProductRemoteDataSource>(
  (ref) => ProductRemoteDataSource(
    ref.read(apiClientProvider),
  ),
);

final productRepositoryProvider =
    Provider<ProductRepository>(
  (ref) => ProductRepositoryImpl(
    ref.read(productRemoteDataSourceProvider),
  ),
);


class ProductState {
  final List<Product> products;
  final bool isLoading;
  final bool hasError;
  final String searchQuery;
  final bool hasMore;

  const ProductState({
    required this.products,
    required this.isLoading,
    required this.hasError,
    required this.searchQuery,
    required this.hasMore,
  });

  factory ProductState.initial() => const ProductState(
        products: [],
        isLoading: false,
        hasError: false,
        searchQuery: '',
        hasMore: true,
      );

  ProductState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? hasError,
    String? searchQuery,
    bool? hasMore,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      searchQuery: searchQuery ?? this.searchQuery,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductRepository repository;
  static const int pageSize = 6;

  List<Product> _allProducts = [];
  int _currentPage = 0;

  ProductNotifier(this.repository) : super(ProductState.initial()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, hasError: false);

    try {
      _allProducts = await repository.getProducts();
      _currentPage = 1;

      state = state.copyWith(
        products: _getPaginated(),
        isLoading: false,
        hasMore: _hasMore(),
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }

  List<Product> _filtered() {
    if (state.searchQuery.isEmpty) return _allProducts;

    return _allProducts.where((p) {
      return p.title
          .toLowerCase()
          .contains(state.searchQuery.toLowerCase());
    }).toList();
  }

  // NOTE: Pagitation not supported in this api
  List<Product> _getPaginated() {
    final filtered = _filtered();
    final end = _currentPage * pageSize;
    return filtered.take(end).toList();
  }

  bool _hasMore() {
    return _getPaginated().length < _filtered().length;
  }

  void loadMore() {
    if (!state.hasMore) return;

    _currentPage++;
    state = state.copyWith(
      products: _getPaginated(),
      hasMore: _hasMore(),
    );
  }

  void search(String query) {
    _currentPage = 1;
    state = state.copyWith(
      searchQuery: query,
      products: _getPaginated(),
      hasMore: _hasMore(),
    );
  }

  Future<void> refresh() async {
    await loadProducts();
  }
}

final productProvider =
    StateNotifierProvider<ProductNotifier, ProductState>(
        (ref) =>
            ProductNotifier(ref.read(productRepositoryProvider)));