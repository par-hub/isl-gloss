import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';

class GlossApiException implements Exception {
  final String message;
  GlossApiException(this.message);

  @override
  String toString() => message;
}

abstract class GlossRepository {
  Future<List<String>> translateTextToGloss(String sentence);
}

final glossRepositoryProvider = Provider<GlossRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiGlossRepository(apiClient);
});

class ApiGlossRepository implements GlossRepository {
  final ApiClient apiClient;

  ApiGlossRepository(this.apiClient);

  @override
  Future<List<String>> translateTextToGloss(String sentence) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.translateEndpoint,
        data: {'sentence': sentence},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('gloss')) {
          final String glossText = data['gloss'].toString();
          return glossText
              .trim()
              .split(RegExp(r'\s+'))
              .where((token) => token.isNotEmpty)
              .toList();
        }
      }

      throw GlossApiException('Unexpected response structure from translation server.');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw GlossApiException('Connection timed out while reaching translation server.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw GlossApiException(
          'Could not reach translation server (${ApiConfig.baseUrl}) — check your server connection.',
        );
      } else if (e.response != null) {
        throw GlossApiException(
          'Translation server error (${e.response?.statusCode}): ${e.response?.statusMessage ?? "Unknown error"}',
        );
      } else {
        throw GlossApiException('Network error: ${e.message}');
      }
    } catch (e) {
      if (e is GlossApiException) rethrow;
      throw GlossApiException('An unexpected error occurred: $e');
    }
  }
}
