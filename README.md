[![Pub Version](https://img.shields.io/pub/v/wheel_choice_ext)](https://pub.dev/packages/wheel_choice_ext) [![Pub Points](https://img.shields.io/pub/points/wheel_choice_ext)](https://pub.dev/packages/wheel_choice_ext/score) [![Tests](https://img.shields.io/badge/tests-28%20passed-success.svg)](https://github.com/davigmacode/flutter_wheel_choice_ext) ![GitHub](https://img.shields.io/github/license/davigmacode/flutter_wheel_choice_ext) [![GitHub](https://badgen.net/badge/icon/buymeacoffee?icon=buymeacoffee&color=yellow&label)](https://www.buymeacoffee.com/davigmacode) [![GitHub](https://badgen.net/badge/icon/ko-fi?icon=kofi&color=red&label)](https://ko-fi.com/davigmacode)

Composite wheel-shaped date and time picker widgets for Flutter built on top of [wheel_choice](https://pub.dev/packages/wheel_choice). Features multi-column scrolling, locale-aware date ordering, 12h/24h time formats, subtree theming, reactive controllers, and FormField integration.

Demo: https://davigmacode.github.io/flutter_wheel_choice_ext

## Multi-Column Layout Architecture

```text
┌───────────────────────────────────────────────────────────┐
│               WheelDateHeader / WheelTimeHeader           │
├─────────────────┬───────────────────┬─────────────────────┤
│  Day / Hour     │   Month / Minute  │   Year / Period     │
│  ┌───────────┐  │   ┌───────────┐   │   ┌───────────┐     │
│  │  Overlay  │  │   │  Overlay  │   │   │  Overlay  │     │
│  └───────────┘  │   └───────────┘   │   └───────────┘     │
│                 │                   │                     │
└─────────────────┴───────────────────┴─────────────────────┘
```

## Features

- **Date Wheel Picker (`WheelDateChoice`)**: Composite picker for Day, Month, and Year columns.
- **Time Wheel Picker (`WheelTimeChoice`)**: Composite picker supporting both 24-hour (0..23) and 12-hour (1..12 + AM/PM) modes with customizable minute step intervals.
- **Locale-Aware Date Ordering (`WheelDateOrder`)**: Automatically rearranges Day, Month, and Year columns according to the current locale (e.g. DMY, MDY, YMD, YDM).
- **Subtree Theming (`WheelChoiceTheme`)**: Seamlessly inherits `itemExtent`, `itemVisible`, `effect`, `overlay`, `physics`, `clipBehavior`, `keyboard`, and `haptics` from an ancestor theme.
- **Form Integration**: Ready-to-use form fields (`WheelDateChoiceFormField` & `WheelTimeChoiceFormField`) with automatic validation, `InputDecoration` error rendering, `onSaved`, and `reset` support.
- **Reactive Controllers**: `WheelDateController` and `WheelTimeController` expose `valueListenable` for zero-rebuild reactive UI patterns, stepping helpers (`nextDay()`, `previousDay()`, `nextHour()`, etc.), and automatic day clamping for shorter months.
- **All-in-One Exports**: Re-exports all core utilities from `wheel_choice` (`WheelChoice`, `WheelController`, `WheelOverlay`, `WheelEffect`, `WheelHeader`, `WheelChoiceTheme`, etc.) so you only need one import.

## Installation

```sh
flutter pub add wheel_choice_ext
```

Import:

```dart
import 'package:wheel_choice_ext/wheel_choice_ext.dart';
```

## Quick Start

### 1. Date Picker

```dart
WheelDateChoice(
  value: DateTime.now(),
  onChanged: (DateTime date) => debugPrint('Selected date: $date'),
  itemExtent: 44,
  itemVisible: 5,
  spacing: 8,
  // Automatically detects locale date ordering (e.g., MDY for en_US, DMY for id_ID)
  order: WheelDateOrder.of(context),
  overlay: WheelOverlay.outlined(),
)
```

### 2. Time Picker (12-Hour or 24-Hour)

```dart
WheelTimeChoice(
  value: const TimeOfDay(hour: 14, minute: 30),
  use24hFormat: false, // 12-hour mode with AM/PM column
  minuteStep: 5,       // Multiples of 5 minutes
  onChanged: (TimeOfDay time) => debugPrint('Selected time: ${time.format(context)}'),
  itemExtent: 44,
  itemVisible: 5,
  spacing: 8,
  overlay: WheelOverlay.outlined(),
)
```

### 3. Subtree Theming with `WheelChoiceTheme`

Style all nested wheel choice pickers uniformly without repeating styling props:

```dart
WheelChoiceTheme(
  data: WheelChoiceThemeData(
    itemExtent: 48,
    itemVisible: 5,
    effect: const WheelEffect(useMagnifier: true, magnification: 1.15),
    overlay: WheelOverlay.filled(color: Colors.blue.withAlpha(30)),
  ),
  child: Column(
    children: [
      WheelDateChoice(value: DateTime.now()),
      const SizedBox(height: 16),
      WheelTimeChoice(value: TimeOfDay.now()),
    ],
  ),
)
```

### 4. Form Field Integration

```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      WheelDateChoiceFormField(
        initialValue: DateTime.now(),
        decoration: const InputDecoration(
          labelText: 'Appointment Date',
          border: OutlineInputBorder(),
        ),
        validator: (d) => d != null && d.weekday > 5 ? 'Weekdays only' : null,
        onSaved: (d) => _selectedDate = d,
      ),
      const SizedBox(height: 16),
      WheelTimeChoiceFormField(
        initialValue: const TimeOfDay(hour: 10, minute: 0),
        use24hFormat: false,
        minuteStep: 15,
        decoration: const InputDecoration(
          labelText: 'Appointment Time',
          border: OutlineInputBorder(),
        ),
        validator: (t) => t != null && t.hour < 9 ? 'Opens at 9 AM' : null,
        onSaved: (t) => _selectedTime = t,
      ),
    ],
  ),
)
```

### 5. Reactive Controller & Stepping Helpers

```dart
final controller = WheelDateController(value: DateTime(2025, 1, 31));

// Reactive listener without parent widget rebuilds:
ValueListenableBuilder<DateTime>(
  valueListenable: controller.valueListenable,
  builder: (context, date, _) => Text('Date: $date'),
);

// Programmatic stepping:
await controller.nextDay();      // Day 31 -> Clamped or next
await controller.previousDay();
await controller.nextMonth();    // Automatically clamps 31 Jan -> 28 Feb!
await controller.nextYear();
```

## API Overview

| Class | Description |
| :--- | :--- |
| `WheelDateChoice` | Composite date wheel widget for Day, Month, and Year |
| `WheelDateController` | Programmatic controller with `valueListenable`, stepping, and constraints |
| `WheelDateChoiceFormField` | Flutter `FormField<DateTime>` with validation, reset, and `InputDecoration` |
| `WheelDateOrder` | Reordering callback (DMY, MDY, YMD, YDM, or locale-derived via `.of(context)`) |
| `WheelDateLabel` | Localized label formatter for day, month, and year |
| `WheelDateFlex` | Column flex ratios (defaults to 3:4:4) |
| `WheelDateHeader` | Column headers configuration |
| `WheelDateBuilder` | Custom widget builder for each date column |
| `WheelTimeChoice` | Composite time wheel widget (hour, minute, optional AM/PM) |
| `WheelTimeController` | Programmatic controller for 12h/24h time with `minuteStep` and stepping |
| `WheelTimeChoiceFormField` | Flutter `FormField<TimeOfDay>` with validation, reset, and `InputDecoration` |
| `WheelTimeLabel` | Localized label formatter for hour, minute, and period |
| `WheelTimeFlex` | Column flex ratios (defaults to 4:4:3) |
| `WheelTimeHeader` | Column headers configuration |
| `WheelTimePeriod` | AM/PM enum (`WheelTimePeriod.am`, `WheelTimePeriod.pm`) |
| `WheelChoiceTheme` | Inherited widget cascading theme configuration across subtrees |

## License

BSD-3-Clause License. See [LICENSE](LICENSE) for details.
