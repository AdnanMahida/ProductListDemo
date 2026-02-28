import 'package:product_list_demo/core/config/api_const.dart';

import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSource(this.apiClient);

  Future<List<ProductModel>> fetchProducts() async {
    final data = await apiClient.get(ApiConstant.getProduct);

    return (data as List)
        .map((e) => ProductModel.fromJson(e))
        .toList();
  }
}