library newgenapps_client;

import 'package:newgenapps_client/types.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

part 'newgenapps_client.g.dart';

@RestApi(baseUrl: 'http://newgenapps.space:8081/comfy')
abstract class NewgenappsClient {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      printEmojis: true,
      colors: true,
    ),
  );
  factory NewgenappsClient({
    required String apiKey,
    required String appName,
    Dio? dio,
    String? baseUrl,
    bool enableLogging = false,
  }) {
    final clientDio = dio ?? Dio();
    clientDio.options.headers['x-authorization'] = 'Bearer $apiKey';
    clientDio.options.headers['app_name'] = appName;

    // Таймауты
    clientDio.options.connectTimeout = const Duration(seconds: 10);
    clientDio.options.receiveTimeout = const Duration(seconds: 30);
    clientDio.options.sendTimeout = const Duration(seconds: 30);

    // Автоматическое включение логов в debug режиме
    bool shouldLog = enableLogging || kDebugMode;

    if (shouldLog) {
      clientDio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          logPrint: (o) {
            _logger.d('🌐 NewgenappsClient: $o');
          },
        ),
      );
    }

    return _NewgenappsClient(clientDio, baseUrl: baseUrl);
  }

  @GET('/upload-url')
  Future<UploadUrlResult> getUploadUrl({
    @Query('type') String? type,
    @Query('file_size') int? fileSize,
  });

  @POST('/run')
  Future<RunResult> postRun({
    @Body() required RunData data,
  });

  @GET('/run/{runId}')
  Future<RunOutputResult> getRun({
    @Path('runId') required String runId,
  });

  @GET('/websocket/{deploymentId}')
  Future<WebsocketResult> getWebsocket({
    @Path() required String deploymentId,
  });
}
