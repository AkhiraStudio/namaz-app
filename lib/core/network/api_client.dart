import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Client HTTP Dio configuré pour l'API Aladhan.
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.aladhanBaseUrl,
        connectTimeout:const Duration(seconds: AppConstants.apiTimeoutSeconds),
        receiveTimeout:const Duration(seconds: AppConstants.apiTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        error: true,
      ),
      _RetryInterceptor(_dio),
    ]);
  }

  Dio get dio => _dio;
}

/// Interceptor de retry automatique (1 tentative) sur erreur réseau.
class _RetryInterceptor extends Interceptor {
  final Dio dio;
  _RetryInterceptor(this.dio);

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.receiveTimeout) {
      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (_) {
        // La deuxième tentative a aussi échoué — on laisse l'erreur remonter
      }
    }
    handler.next(err);
  }
}
