import 'package:cruisyapp/core/models/ai_settings.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiSettingsRepository {
  AiSettingsRepository({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _selectedProviderKey = 'ai.selected_provider';

  final FlutterSecureStorage _secureStorage;

  Future<AiProviderType> loadSelectedProvider() async {
    final prefs = await SharedPreferences.getInstance();
    return aiProviderFromKey(prefs.getString(_selectedProviderKey));
  }

  Future<void> saveSelectedProvider(AiProviderType provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedProviderKey, provider.storageKey);
  }

  Future<Map<AiProviderType, String>> loadApiKeys() async {
    final apiKeys = <AiProviderType, String>{};
    for (final provider in AiProviderType.values) {
      final key = await _secureStorage.read(key: _apiKeyStorageKey(provider));
      if (key != null && key.isNotEmpty) {
        apiKeys[provider] = key;
      }
    }
    return apiKeys;
  }

  Future<void> saveApiKey(AiProviderType provider, String apiKey) {
    return _secureStorage.write(
      key: _apiKeyStorageKey(provider),
      value: apiKey,
    );
  }

  Future<void> deleteApiKey(AiProviderType provider) {
    return _secureStorage.delete(key: _apiKeyStorageKey(provider));
  }

  Future<Map<AiProviderType, String?>> loadSelectedModels() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedModels = <AiProviderType, String?>{};
    for (final provider in AiProviderType.values) {
      selectedModels[provider] = prefs.getString(_selectedModelKey(provider));
    }
    return selectedModels;
  }

  Future<void> saveSelectedModel(
    AiProviderType provider,
    String? modelId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _selectedModelKey(provider);

    if (modelId == null || modelId.isEmpty) {
      await prefs.remove(key);
      return;
    }

    await prefs.setString(key, modelId);
  }

  String _apiKeyStorageKey(AiProviderType provider) =>
      'ai.api_key.${provider.storageKey}';

  String _selectedModelKey(AiProviderType provider) =>
      'ai.selected_model.${provider.storageKey}';
}
