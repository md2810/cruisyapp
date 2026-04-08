enum AiProviderType { google, anthropic, openai, mistral }

AiProviderType aiProviderFromKey(String? value) {
  return AiProviderType.values
          .where((provider) => provider.storageKey == value)
          .firstOrNull ??
      AiProviderType.google;
}

extension AiProviderTypeX on AiProviderType {
  String get storageKey => name;

  String get displayName => switch (this) {
    AiProviderType.google => 'Google',
    AiProviderType.anthropic => 'Anthropic',
    AiProviderType.openai => 'OpenAI',
    AiProviderType.mistral => 'Mistral',
  };

  bool get isRecommended => this == AiProviderType.google;
}

class AiModelInfo {
  const AiModelInfo({
    required this.id,
    required this.displayName,
    this.description,
    this.supportsChat = true,
    this.supportsVision = false,
    this.isDeprecated = false,
  });

  final String id;
  final String displayName;
  final String? description;
  final bool supportsChat;
  final bool supportsVision;
  final bool isDeprecated;
}

class ActiveAiConfiguration {
  const ActiveAiConfiguration({
    required this.provider,
    required this.apiKey,
    required this.model,
    this.modelInfo,
  });

  final AiProviderType provider;
  final String apiKey;
  final String model;
  final AiModelInfo? modelInfo;

  String get modelLabel => modelInfo?.displayName ?? model;
}

class AiSettingsState {
  const AiSettingsState({
    required this.isLoading,
    required this.selectedProvider,
    required this.apiKeys,
    required this.selectedModels,
    required this.availableModels,
    this.busyProvider,
    this.errorMessage,
  });

  factory AiSettingsState.initial() => const AiSettingsState(
    isLoading: true,
    selectedProvider: AiProviderType.google,
    apiKeys: {},
    selectedModels: {},
    availableModels: {},
  );

  final bool isLoading;
  final AiProviderType selectedProvider;
  final Map<AiProviderType, String> apiKeys;
  final Map<AiProviderType, String?> selectedModels;
  final Map<AiProviderType, List<AiModelInfo>> availableModels;
  final AiProviderType? busyProvider;
  final String? errorMessage;

  bool get isBusy => busyProvider != null;

  String? apiKeyFor(AiProviderType provider) => apiKeys[provider];

  String? selectedModelFor(AiProviderType provider) => selectedModels[provider];

  List<AiModelInfo> modelsFor(AiProviderType provider) =>
      availableModels[provider] ?? const <AiModelInfo>[];

  bool hasApiKeyFor(AiProviderType provider) {
    final apiKey = apiKeyFor(provider);
    return apiKey != null && apiKey.isNotEmpty;
  }

  ActiveAiConfiguration? get activeConfiguration {
    final apiKey = apiKeyFor(selectedProvider);
    final model = selectedModelFor(selectedProvider);
    if (apiKey == null || apiKey.isEmpty || model == null || model.isEmpty) {
      return null;
    }

    AiModelInfo? selectedModelInfo;
    for (final modelInfo in modelsFor(selectedProvider)) {
      if (modelInfo.id == model) {
        selectedModelInfo = modelInfo;
        break;
      }
    }

    return ActiveAiConfiguration(
      provider: selectedProvider,
      apiKey: apiKey,
      model: model,
      modelInfo: selectedModelInfo,
    );
  }

  AiSettingsState copyWith({
    bool? isLoading,
    AiProviderType? selectedProvider,
    Map<AiProviderType, String>? apiKeys,
    Map<AiProviderType, String?>? selectedModels,
    Map<AiProviderType, List<AiModelInfo>>? availableModels,
    Object? busyProvider = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return AiSettingsState(
      isLoading: isLoading ?? this.isLoading,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      apiKeys: apiKeys ?? this.apiKeys,
      selectedModels: selectedModels ?? this.selectedModels,
      availableModels: availableModels ?? this.availableModels,
      busyProvider:
          busyProvider == _sentinel
              ? this.busyProvider
              : busyProvider as AiProviderType?,
      errorMessage:
          errorMessage == _sentinel
              ? this.errorMessage
              : errorMessage as String?,
    );
  }

  static const Object _sentinel = Object();
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) {
      return null;
    }
    return first;
  }
}
