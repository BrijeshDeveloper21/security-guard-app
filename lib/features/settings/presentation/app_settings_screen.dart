import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security_app/core/providers/app_providers.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AppSettingsScreen()));
  }

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  double? _fontScaleDraft;

  void _showSaveError(BuildContext context, Object error) {
    final message = ref
        .read(languageProvider.notifier)
        .translate('settings_save_error');
    debugPrint('Failed to save accessibility or language preference: $error');
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveLanguage(BuildContext context, String language) async {
    try {
      await ref.read(languageProvider.notifier).setLang(language);
    } catch (error) {
      if (context.mounted) _showSaveError(context, error);
    }
  }

  Future<void> _saveContrast(BuildContext context, bool enabled) async {
    try {
      await ref.read(accessibilityProvider.notifier).setHighContrast(enabled);
    } catch (error) {
      if (context.mounted) _showSaveError(context, error);
    }
  }

  Future<void> _saveFontScale(BuildContext context, double scale) async {
    try {
      await ref.read(accessibilityProvider.notifier).setFontScale(scale);
      if (mounted) setState(() => _fontScaleDraft = null);
    } catch (error) {
      if (mounted) setState(() => _fontScaleDraft = null);
      if (context.mounted) _showSaveError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final accessibility = ref.watch(accessibilityProvider);
    final translator = ref.watch(languageProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final fontScale = _fontScaleDraft ?? accessibility.fontScale;

    return Scaffold(
      appBar: AppBar(title: Text(translator.translate('settings_title'))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                translator.translate('settings_intro'),
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translator.translate('language_label'),
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Semantics(
                        label: translator.translate('language_picker'),
                        child: DropdownButtonFormField<String>(
                          initialValue: language,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'EN',
                              child: Text(
                                translator.translate('language_english'),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'HI',
                              child: Text(
                                translator.translate('language_hindi'),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'MR',
                              child: Text(
                                translator.translate('language_marathi'),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _saveLanguage(context, value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translator.translate('accessibility_label'),
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(translator.translate('high_contrast')),
                        subtitle: Text(
                          translator.translate('high_contrast_help'),
                        ),
                        value: accessibility.highContrast,
                        onChanged: (value) => _saveContrast(context, value),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(translator.translate('text_size')),
                        subtitle: Text(translator.translate('text_size_help')),
                        trailing: Text(
                          '${(fontScale * 100).round()}%',
                          semanticsLabel:
                              '${(fontScale * 100).round()} percent',
                        ),
                      ),
                      Semantics(
                        label: translator.translate('text_size'),
                        value: '${(fontScale * 100).round()} percent',
                        child: Slider(
                          min: 0.9,
                          max: 1.6,
                          divisions: 7,
                          value: fontScale,
                          onChanged: (value) {
                            setState(() => _fontScaleDraft = value);
                          },
                          onChangeEnd: (value) => _saveFontScale(
                            context,
                            (value * 10).roundToDouble() / 10,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(translator.translate('small')),
                          Text(translator.translate('large')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
