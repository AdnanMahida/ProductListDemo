import 'package:dio/dio.dart';
import 'package:product_list_demo/core/config/app_strings.dart';
import 'failures.dart';

class ErrorMapper {
  static Failure map(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure(AppString.connectionTimeOut);
    }

    if (e.response != null) {
      return ServerFailure(
          "${AppString.serverError} ${e.response?.statusCode}");
    }

    return const UnknownFailure(AppString.unexpectedError);
  }
}