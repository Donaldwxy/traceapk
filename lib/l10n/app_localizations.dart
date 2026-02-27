
import 'dart:async';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'Location History': 'Location History',
      'Search by date': 'Search by date',
      'Press the refresh button to get your location.': 'Press the refresh button to get your location.',
      'Getting your current location...': 'Getting your current location...',
      'Successfully recorded your location!': 'Successfully recorded your location!',
      'No records yet. Press the refresh button to start!': 'No records yet. Press the refresh button to start!',
      'Record Current Location': 'Record Current Location',
      'Language': 'Language',
      'English': 'English',
      'Chinese': 'Chinese',
      'Records for': 'Records for',
      'No records found for this date.': 'No records found for this date.',
      'Close': 'Close',
      'Could not open map application. Please ensure it is installed.': 'Could not open map application. Please ensure it is installed.',
      'Recorded Location': 'Recorded Location',
    },
    'zh': {
      'Location History': '位置记录',
      'Search by date': '按日期搜索',
      'Press the refresh button to get your location.': '请按刷新按钮获取您的位置。',
      'Getting your current location...': '正在获取您当前的位置...',
      'Successfully recorded your location!': '成功记录您的位置！',
      'No records yet. Press the refresh button to start!': '尚无记录。请按刷新按钮开始！',
      'Record Current Location': '记录当前位置',
      'Language': '语言',
      'English': '英语',
      'Chinese': '中文',
      'Records for': '的记录',
      'No records found for this date.': '未找到该日期的记录。',
      'Close': '关闭',
      'Could not open map application. Please ensure it is installed.': '无法打开地图应用，请确保已经安装。',
      'Recorded Location': '记录的位置',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]![key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) {
    return false;
  }
}
