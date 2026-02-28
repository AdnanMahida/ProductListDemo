import 'package:product_list_demo/features/products/data/datasource/product_remote_datasource.dart';
import 'package:product_list_demo/features/products/data/repository/product_repository.dart';

import '../../domain/entities/product.dart';


class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Product>> getProducts() async {
    return await remoteDataSource.fetchProducts();
  }
}