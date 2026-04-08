import 'dart:async';

import 'package:cruisyapp/core/models/ai_settings.dart';
import 'package:cruisyapp/core/services/ai_model_catalog_service.dart';
import 'package:cruisyapp/core/services/ai_settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:cruisyapp/core/models/ai_settings.dart';

final aiSettingsRepositoryProvider = Provider<AiSettingsRepository>((ref) {
  return AiSettingsRepository();
});

final aiModelCatalogServiceProvider = Provider<AiModelCatalogService>((ref) {
  return AiModelCatalogService();
});

final aiSettingsControllerProvider =
    StateNotifierProvider<AiSettingsController, AiSettingsState>((ref) {
      final controller = AiSettingsController(
        repository: ref.read(aiSettingsRepositoryProvider),
        modelCatalogService: ref.read(aiModelCatalogServiceProvider),
      );
      unawaited(controller.load());
      return controller;
    });

final activeAiConfigurationProvider = Provider<ActiveAiConfiguration?>((ref) {
  return ref.watch(aiSettingsControllerProvider).activeConfiguration;
});

class AiSettingsController extends StateNotifier<AiSettingsState> {
  AiSettingsController({
    required AiSettingsRepository repository,
    required AiModelCatalogService modelCatalogService,
  }) : _repository = repository,
       _modelCatalogService = modelCatalogService,
       super(AiSettingsState.initial());

  final AiSettingsRepository _repository;
  final AiModelCatalogService _modelCatalogService;

  bool _hasLoaded = false;

  Future<void> load() async {
    if (_hasLoaded) {
      return;
    }
    _hasLoaded = true;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final selectedProvider = await _repository.loadSelectedProvider();
    final apiKeys = await _repository.loadApiKeys();
    final selectedModels = Map<AiProviderType, String?>.from(
      await _repository.loadSelectedModels(),
    );
    final availableModels = <AiProviderType, List<AiModelInfo>>{};
    String? firstError;

    for (final provider in AiProviderType.values) {
      final apiKey = apiKeys[provider];
      if (apiKey == null || apiKey.isEmpty) {
        continue;
      }

      try {
        final models = await _modelCatalogService.fetchModels(provider, apiKey);
        availableModels[provider] = models;

        final selectedModel = _pickPreferredModel(
          provider: provider,
          models: models,
          currentModel: selectedModels[provider],
        );
        selectedModels[provider] = selectedModel;
        await _repository.saveSelectedModel(provider, selectedModel);
      } catch (error) {
        firstError ??= error.toString();
      }
    }

    state = state.copyWith(
      isLoading: false,
      selectedProvider: selectedProvider,
      apiKeys: apiKeys,
      selectedModels: selectedModels,
      availableModels: availableModels,
      errorMessage: firstError,
      busyProvider: null,
    );
  }

  Future<void> selectProvider(AiProviderType provider) async {
    state = state.copyWith(selectedProvider: provider, errorMessage: null);
    await _repository.saveSelectedProvider(provider);
  }

  Future<void> saveApiKey(AiProviderType provider, String apiKey) async {
    final trimmedApiKey = apiKey.trim();
    if (trimmedApiKey.isEmpty) {
      await clearApiKey(provider);
      return;
    }

    state = state.copyWith(
      busyProvider: provider,
      errorMessage: null,
      apiKeys: <AiProviderType, String>{
        ...state.apiKeys,
        provider: trimmedApiKey,
      },
    );
    await _repository.saveApiKey(provider, trimmedApiKey);

    try {
      final models = await _modelCatalogService.fetchModels(
        provider,
        trimmedApiKey,
      );
      final selectedModel = _pickPreferredModel(
        provider: provider,
        models: models,
        currentModel: state.selectedModels[provider],
      );

      final selectedModels = <AiProviderType, String?>{
        ...state.selectedModels,
        provider: selectedModel,
      };
      final availableModels = <AiProviderType, List<AiModelInfo>>{
        ...state.availableModels,
        provider: models,
      };

      state = state.copyWith(
        availableModels: availableModels,
        selectedModels: selectedModels,
        busyProvider: null,
        errorMessage: null,
      );
      await _repository.saveSelectedModel(provider, selectedModel);
    } catch (error) {
      state = state.copyWith(
        busyProvider: null,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  Future<void> clearApiKey(AiProviderType provider) async {
    final apiKeys = <AiProviderType, String>{...state.apiKeys}
      ..remove(provider);
    final selectedModels = <AiProviderType, String?>{...state.selectedModels}
      ..remove(provider);
    final availableModels = <AiProviderType, List<AiModelInfo>>{
      ...state.availableModels,
    }..remove(provider);

    state = state.copyWith(
      apiKeys: apiKeys,
      selectedModels: selectedModels,
      availableModels: availableModels,
      busyProvider: null,
      errorMessage: null,
    );

    await _repository.deleteApiKey(provider);
    await _repository.saveSelectedModel(provider, null);
  }

  Future<void> refreshModels(AiProviderType provider) async {
    final apiKey = state.apiKeyFor(provider);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('No API key saved for ${provider.displayName}.');
    }

    state = state.copyWith(busyProvider: provider, errorMessage: null);

    try {
      final models = await _modelCatalogService.fetchModels(provider, apiKey);
      final selectedModel = _pickPreferredModel(
        provider: provider,
        models: models,
        currentModel: state.selectedModels[provider],
      );
      final selectedModels = <AiProviderType, String?>{
        ...state.selectedModels,
        provider: selectedModel,
      };
      final availableModels = <AiProviderType, List<AiModelInfo>>{
        ...state.availableModels,
        provider: models,
      };

      state = state.copyWith(
        availableModels: availableModels,
        selectedModels: selectedModels,
        busyProvider: null,
        errorMessage: null,
      );
      await _repository.saveSelectedModel(provider, selectedModel);
    } catch (error) {
      state = state.copyWith(
        busyProvider: null,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  Future<void> selectModel(AiProviderType provider, String modelId) async {
    final selectedModels = <AiProviderType, String?>{
      ...state.selectedModels,
      provider: modelId,
    };
    state = state.copyWith(selectedModels: selectedModels, errorMessage: null);
    await _repository.saveSelectedModel(provider, modelId);
  }

  String? _pickPreferredModel({
    required AiProviderType provider,
    required List<AiModelInfo> models,
    String? currentModel,
  }) {
    if (models.isEmpty) {
      return null;
    }

    if (currentModel != null) {
      for (final model in models) {
        if (model.id == currentModel) {
          return currentModel;
        }
      }
    }

    final preferredModelIds = switch (provider) {
      AiProviderType.google => <String>[
        'gemini-2.5-flash',
        'gemini-2.0-flash',
        'gemini-1.5-flash',
      ],
      AiProviderType.anthropic => <String>[
        'claude-sonnet-4-5',
        'claude-sonnet-4',
        'claude-3-7-sonnet',
      ],
      AiProviderType.openai => <String>[
        'gpt-5-mini',
        'gpt-5',
        'gpt-4.1-mini',
        'gpt-4o-mini',
        'gpt-4o',
      ],
      AiProviderType.mistral => <String>[
        'mistral-small-latest',
        'mistral-small',
        'mistral-medium-latest',
        'mistral-medium',
        'mistral-large-latest',
      ],
    };

    for (final preferredId in preferredModelIds) {
      for (final model in models) {
        if (model.id == preferredId || model.id.contains(preferredId)) {
          return model.id;
        }
      }
    }

    for (final model in models) {
      if (!model.isDeprecated) {
        return model.id;
      }
    }

    return models.first.id;
  }
}
