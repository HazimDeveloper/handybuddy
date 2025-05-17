// lib/screens/common/language_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/utils/toast_util.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'en'; // Default language is English
  
  final List<Map<String, dynamic>> _languages = [
    {
      'code': 'en',
      'name': 'English',
      'flag': '🇬🇧',
      'description': 'English',
    },
    {
      'code': 'ms',
      'name': 'Malay',
      'flag': '🇲🇾',
      'description': 'Bahasa Melayu',
    },
    {
      'code': 'zh',
      'name': 'Chinese',
      'flag': '🇨🇳',
      'description': '中文',
    },
    {
      'code': 'ta',
      'name': 'Tamil',
      'flag': '🇮🇳',
      'description': 'தமிழ்',
    },
  ];

  void _changeLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
    
    // Here you would implement the actual language change
    // For example, with a language provider or shared preferences
    
    // Show confirmation toast
    ToastUtils.showSuccessToast('Language changed to ${_getLanguageName(languageCode)}');
  }
  
  String _getLanguageName(String code) {
    final language = _languages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'name': 'Unknown'},
    );
    return language['name'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppTexts.languageSettings),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppTexts.selectLanguage,
                  style: AppStyles.subheadingStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  AppTexts.languageSettingsSubtitle,
                  style: AppStyles.bodyTextStyle.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Language options
          Expanded(
            child: ListView.separated(
              itemCount: _languages.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final language = _languages[index];
                final isSelected = language['code'] == _selectedLanguage;
                
                return Material(
                  color: isSelected ? AppColors.primaryExtraLight : Colors.white,
                  child: InkWell(
                    onTap: () => _changeLanguage(language['code']),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      child: Row(
                        children: [
                          // Flag and language name
                          Text(
                            language['flag'],
                            style: const TextStyle(fontSize: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language['name'],
                                  style: AppStyles.bodyTextBoldStyle,
                                ),
                                Text(
                                  language['description'],
                                  style: AppStyles.bodySmallStyle.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Selected indicator
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Note about app restart
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.infoBackground,
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Some changes may require restarting the app to take full effect.',
                    style: AppStyles.bodySmallStyle.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}