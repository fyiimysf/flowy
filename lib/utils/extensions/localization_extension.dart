import 'package:flutter/material.dart';
import '../../services/localization/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  String tr(String key) {
    return AppLocalizations.of(this)?.translate(key) ?? key;
  }

  String trArgs(String key, Map<String, dynamic> args) {
    return AppLocalizations.of(this)?.translateWithArgs(key, args) ?? key;
  }
}
