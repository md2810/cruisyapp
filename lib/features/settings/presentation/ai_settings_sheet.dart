import 'package:cruisyapp/core/providers/ai_provider.dart';
import 'package:cruisyapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class AiSettingsSheet extends ConsumerStatefulWidget {
  const AiSettingsSheet({super.key});

  @override
  ConsumerState<AiSettingsSheet> createState() => _AiSettingsSheetState();
}

class _AiSettingsSheetState extends ConsumerState<AiSettingsSheet> {
  final TextEditingController _apiKeyController = TextEditingController();

  AiProviderType? _lastProvider;
  bool _obscureApiKey = true;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiSettingsControllerProvider);
    final controller = ref.read(aiSettingsControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final selectedProvider = state.selectedProvider;
    final models = state.modelsFor(selectedProvider);
    final selectedModel = state.selectedModelFor(selectedProvider);
    final busy = state.busyProvider == selectedProvider;

    if (_lastProvider != selectedProvider) {
      _lastProvider = selectedProvider;
      final savedApiKey = state.apiKeyFor(selectedProvider) ?? '';
      if (_apiKeyController.text != savedApiKey) {
        _apiKeyController.text = savedApiKey;
      }
    }

    final dropdownValue =
        models.any((model) => model.id == selectedModel) ? selectedModel : null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.aiImportSettings,
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.configureAiImport,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.recommend_rounded, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.googleRecommendedDescription,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.aiProvider,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  AiProviderType.values.map((provider) {
                    final isSelected = provider == selectedProvider;
                    final label =
                        provider.isRecommended
                            ? '${provider.displayName} • ${l10n.googleRecommended}'
                            : provider.displayName;

                    return ChoiceChip(
                      selected: isSelected,
                      label: Text(label),
                      onSelected: (_) => controller.selectProvider(provider),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.apiKey,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyController,
              autocorrect: false,
              enableSuggestions: false,
              obscureText: _obscureApiKey,
              decoration: InputDecoration(
                hintText: l10n.enterApiKey,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                prefixIcon: const Icon(Icons.key_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureApiKey = !_obscureApiKey;
                    });
                  },
                  icon: Icon(
                    _obscureApiKey
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.savedOnThisDevice,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed:
                      busy
                          ? null
                          : () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(
                              context,
                            );

                            try {
                              await controller.saveApiKey(
                                selectedProvider,
                                _apiKeyController.text,
                              );
                              if (!mounted) {
                                return;
                              }
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(l10n.aiKeySaved),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } catch (error) {
                              if (!mounted) {
                                return;
                              }
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    error.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: colorScheme.error,
                                ),
                              );
                            }
                          },
                  icon:
                      busy
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                          : const Icon(Icons.save_rounded),
                  label: Text(l10n.saveKey),
                ),
                OutlinedButton.icon(
                  onPressed:
                      busy || !state.hasApiKeyFor(selectedProvider)
                          ? null
                          : () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(
                              context,
                            );

                            try {
                              await controller.refreshModels(selectedProvider);
                              if (!mounted) {
                                return;
                              }
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(l10n.aiModelsUpdated),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } catch (error) {
                              if (!mounted) {
                                return;
                              }
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    error.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: colorScheme.error,
                                ),
                              );
                            }
                          },
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.refreshModels),
                ),
                TextButton.icon(
                  onPressed:
                      busy || !state.hasApiKeyFor(selectedProvider)
                          ? null
                          : () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(
                              context,
                            );
                            await controller.clearApiKey(selectedProvider);
                            if (!mounted) {
                              return;
                            }
                            _apiKeyController.clear();
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(l10n.aiKeyRemoved),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.clearKey),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              l10n.aiModel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 12),
            if (state.isLoading && models.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (!state.hasApiKeyFor(selectedProvider))
              _InfoCard(message: l10n.modelsLoadAfterKey)
            else if (busy && models.isEmpty)
              _InfoCard(
                message: l10n.fetchingModels,
                trailing: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (models.isEmpty)
              _InfoCard(message: l10n.noModelsAvailable)
            else
              DropdownButtonFormField<String>(
                initialValue: dropdownValue,
                items:
                    models
                        .map(
                          (model) => DropdownMenuItem<String>(
                            value: model.id,
                            child: Text(
                              model.displayName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    busy
                        ? null
                        : (value) {
                          if (value == null) {
                            return;
                          }
                          controller.selectModel(selectedProvider, value);
                        },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  prefixIcon: const Icon(Icons.smart_toy_rounded),
                ),
              ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 16),
              _InfoCard(
                message: state.errorMessage!.replaceFirst('Exception: ', ''),
                tone: _InfoTone.error,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.message,
    this.tone = _InfoTone.neutral,
    this.trailing,
  });

  final String message;
  final _InfoTone tone;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color backgroundColor;
    final Color borderColor;
    final Color textColor;

    switch (tone) {
      case _InfoTone.error:
        backgroundColor = colorScheme.errorContainer.withValues(alpha: 0.35);
        borderColor = colorScheme.error.withValues(alpha: 0.2);
        textColor = colorScheme.error;
      case _InfoTone.neutral:
        backgroundColor = colorScheme.surfaceContainerHighest;
        borderColor = colorScheme.outlineVariant.withValues(alpha: 0.5);
        textColor = colorScheme.onSurfaceVariant;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(child: Text(message, style: TextStyle(color: textColor))),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

enum _InfoTone { neutral, error }
