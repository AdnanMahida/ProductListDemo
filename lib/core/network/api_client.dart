import 'package:dio/dio.dart';
import 'package:product_list_demo/core/config/api_const.dart';
import '../error/error_mapper.dart';


class ApiClient {
  final Dio _dio;

  ApiClient._(this._dio);

  factory ApiClient() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstant.baseUrl,
        connectTimeout: const Duration(seconds: ApiConstant.connectionTimeout),
        receiveTimeout: const Duration(seconds: ApiConstant.receiveTimeout),
      ),
    );

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    return ApiClient._(dio);
  }

  Future<dynamic> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return _safeRequest(() => _dio.get(path,
        queryParameters: queryParameters));
  }

  Future<dynamic> post(String path,
      {dynamic data}) async {
    return _safeRequest(() => _dio.post(path, data: data));
  }

  Future<dynamic> put(String path,
      {dynamic data}) async {
    return _safeRequest(() => _dio.put(path, data: data));
  }

  Future<dynamic> delete(String path) async {
    return _safeRequest(() => _dio.delete(path));
  }

  Future<dynamic> _safeRequest(
      Future<Response> Function() request) async {
    try {
      final response = await request();
      return response.data;
    } on DioException catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}