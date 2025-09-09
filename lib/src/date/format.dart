import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'package:intl/intl.dart';

abstract class WheelDateFormat {
  static WheelItemLabel<int> day({
    String? pattern,
    String? locale,
  }) {
    pattern ??= 'd';
    return (int d) => DateFormat(pattern, locale).format(DateTime(0, 1, d));
  }

  static WheelItemLabel<int> month({
    String? pattern,
    String? locale,
  }) {
    pattern ??= 'MMMM';
    return (int m) => DateFormat(pattern, locale).format(DateTime(0, m));
  }

  static WheelItemLabel<int> year({
    String? pattern,
    String? locale,
  }) {
    pattern ??= 'y';
    return (int y) => DateFormat(pattern, locale).format(DateTime(y));
  }

  static WheelItemLabel<int> dayOf(
    BuildContext context, [
    String? pattern,
  ]) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return day(locale: locale);
  }

  static WheelItemLabel<int> monthOf(
    BuildContext context, [
    String? pattern,
  ]) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return month(locale: locale);
  }

  static WheelItemLabel<int> yearOf(
    BuildContext context, [
    String? pattern,
  ]) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return year(locale: locale);
  }
}
