import 'package:product_list_demo/core/config/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/product_provider.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductListScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 100) {
        ref.read(productProvider.notifier).loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppString.appName)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(productProvider.notifier).refresh(),
        child: Column(
          children: [
            _searchField(),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppString.searchProduct,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (value) => ref.read(productProvider.notifier).search(value),
      ),
    );
  }

  Widget _buildBody(ProductState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return const Center(child: Text(AppString.somethingWentWrong));
    }

    if (state.products.isEmpty) {
      return const Center(child: Text(AppString.noProductFound));
    }

    return ListView.builder(
      controller: _controller,
      itemCount: state.products.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.products.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final product = state.products[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: Image.network(
              product.image,
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
            title: Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text("\$${product.price}"),
          ),
        );
      },
    );
  }
}
