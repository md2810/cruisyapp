import 'dart:convert';

import 'package:cruisyapp/core/models/ai_settings.dart';
import 'package:http/http.dart' as http;

class AiModelCatalogService {
  AiModelCatalogService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<AiModelInfo>> fetchModels(
    AiProviderType provider,
    String apiKey,
  ) {
    return switch (provider) {
      AiProviderType.google => _fetchGoogleModels(apiKey),
      AiProviderType.anthropic => _fetchAnthropicModels(apiKey),
      AiProviderType.openai => _fetchOpenAiModels(apiKey),
      AiProviderType.mistral => _fetchMistralModels(apiKey),
    };
  }

  Future<List<AiModelInfo>> _fetchGoogleModels(String apiKey) async {
    final response = await _client.get(
      Uri.https('generativelanguage.googleapis.com', '/v1beta/models'),
      headers: <String, String>{'x-goog-api-key': apiKey},
    );

    final json = _decodeResponse(
      provider: AiProviderType.google,
      response: response,
    );
    final models =
        (json['models'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .where((model) {
              final methods =
                  (model['supportedGenerationMethods'] as List<dynamic>? ??
                          const <dynamic>[])
                      .map((method) => method.toString())
                      .toSet();
              final name = model['name']?.toString() ?? '';
              return methods.contains('generateContent') &&
                  name.startsWith('models/gemini');
            })
            .map((model) {
              final fullName = model['name']?.toString() ?? '';
              final modelId =
                  fullName.startsWith('models/')
                      ? fullName.substring('models/'.length)
                      : fullName;
              return AiModelInfo(
                id: modelId,
                displayName: model['displayName']?.toString() ?? modelId,
                description: model['description']?.toString(),
                supportsVision: true,
              );
            })
            .toList();

    return _sortModels(models);
  }

  Future<List<AiModelInfo>> _fetchAnthropicModels(String apiKey) async {
    final response = await _client.get(
      Uri.https('api.anthropic.com', '/v1/models'),
      headers: <String, String>{
        'anthropic-version': '2023-06-01',
        'x-api-key': apiKey,
      },
    );

    final json = _decodeResponse(
      provider: AiProviderType.anthropic,
      response: response,
    );
    final models =
        (json['data'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .where(
              (model) => (model['id']?.toString() ?? '').startsWith('claude'),
            )
            .map((model) {
              final id = model['id']?.toString() ?? '';
              return AiModelInfo(
                id: id,
                displayName: model['display_name']?.toString() ?? id,
                description: model['description']?.toString(),
                supportsVision: true,
              );
            })
            .toList();

    return _sortModels(models);
  }

  Future<List<AiModelInfo>> _fetchOpenAiModels(String apiKey) async {
    final response = await _client.get(
      Uri.https('api.openai.com', '/v1/models'),
      headers: <String, String>{'Authorization': 'Bearer $apiKey'},
    );

    final json = _decodeResponse(
      provider: AiProviderType.openai,
      response: response,
    );
    final models =
        (json['data'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map((model) => model['id']?.toString() ?? '')
            .where(_isLikelyOpenAiChatModel)
            .map(
              (id) =>
                  AiModelInfo(id: id, displayName: id, supportsVision: true),
            )
            .toList();

    return _sortModels(models);
  }

  Future<List<AiModelInfo>> _fetchMistralModels(String apiKey) async {
    final response = await _client.get(
      Uri.https('api.mistral.ai', '/v1/models'),
      headers: <String, String>{'Authorization': 'Bearer $apiKey'},
    );

    final json = _decodeResponse(
      provider: AiProviderType.mistral,
      response: response,
    );

    final rawModels =
        (json['data'] as List<dynamic>?) ??
        (json['models'] as List<dynamic>?) ??
        const <dynamic>[];

    final models =
        rawModels
            .whereType<Map<String, dynamic>>()
            .where((model) {
              final capabilities =
                  model['capabilities'] as Map<String, dynamic>? ?? const {};
              final supportsChat = capabilities['completion_chat'] == true;
              final archived = model['archived'] == true;
              return supportsChat && !archived;
            })
            .map((model) {
              final capabilities =
                  model['capabilities'] as Map<String, dynamic>? ?? const {};
              final id = model['id']?.toString() ?? '';
              return AiModelInfo(
                id: id,
                displayName: model['name']?.toString() ?? id,
                description: model['description']?.toString(),
                supportsVision: capabilities['vision'] == true,
                isDeprecated: model['deprecation'] != null,
              );
            })
            .toList();

    return _sortModels(models);
  }

  Map<String, dynamic> _decodeResponse({
    required AiProviderType provider,
    required http.Response response,
  }) {
    dynamic decoded;
    if (response.body.isNotEmpty) {
      decoded = jsonDecode(response.body);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _extractErrorMessage(decoded);
      throw Exception(
        '${provider.displayName} model lookup failed (${response.statusCode})${message == null ? '' : ': $message'}',
      );
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is List<dynamic>) {
      return <String, dynamic>{'data': decoded};
    }

    return const <String, dynamic>{};
  }

  String? _extractErrorMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        return error['message']?.toString() ??
            error['detail']?.toString() ??
            error['type']?.toString();
      }

      return decoded['message']?.toString() ?? decoded['detail']?.toString();
    }

    if (decoded is String && decoded.isNotEmpty) {
      return decoded;
    }

    return null;
  }

  List<AiModelInfo> _sortModels(List<AiModelInfo> models) {
    final sorted = List<AiModelInfo>.from(models);
    sorted.sort((left, right) {
      if (left.isDeprecated != right.isDeprecated) {
        return left.isDeprecated ? 1 : -1;
      }
      return left.displayName.toLowerCase().compareTo(
        right.displayName.toLowerCase(),
      );
    });
    return sorted;
  }

  bool _isLikelyOpenAiChatModel(String modelId) {
    const blockedTokens = <String>[
      'audio',
      'babbage',
      'davinci',
      'embedding',
      'image',
      'moderation',
      'omni-moderation',
      'realtime',
      'search',
      'sora',
      'transcribe',
      'tts',
      'whisper',
    ];

    if (blockedTokens.any(modelId.contains)) {
      return false;
    }

    return modelId.startsWith('gpt-') ||
        modelId.startsWith('o') ||
        modelId.startsWith('chatgpt-') ||
        modelId.startsWith('gpt-oss-');
  }
}
