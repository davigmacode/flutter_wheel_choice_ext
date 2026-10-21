[![Pub Version](https://img.shields.io/pub/v/wheel_choice_ext)](https://pub.dev/packages/wheel_choice_ext) [![Pub Points](https://img.shields.io/pub/points/wheel_choice_ext)](https://pub.dev/packages/wheel_choice_ext/score) [![Tests](https://img.shields.io/badge/tests-47%20passed-success.svg)](https://github.com/davigmacode/flutter_wheel_choice_ext) ![GitHub](https://img.shields.io/github/license/davigmacode/flutter_wheel_choice_ext) [![GitHub](https://badgen.net/badge/icon/buymeacoffee?icon=buymeacoffee&color=yellow&label)](https://www.buymeacoffee.com/davigmacode) [![GitHub](https://badgen.net/badge/icon/ko-fi?icon=kofi&color=red&label)](https://ko-fi.com/davigmacode)

Composite wheel-shaped picker widget suite for Flutter built on top of [wheel_choice](https://pub.dev/packages/wheel_choice). Features Date, Time, Combined DateTime, Duration/Timer, Number/Weight, Date Range, Cascading Tree pickers, and ready-to-use Modal Bottom Sheet helpers.

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

- **Date Picker (`WheelDateChoice`)**: Composite picker for Day, Month, and Year with locale-aware column ordering (`WheelDateOrder`).
- **Time Picker (`WheelTimeChoice`)**: 24-hour (0..23) and 12-hour (1..12 + AM/PM) modes with configurable minute interval steps.
- **Combined Date & Time (`WheelDateTimeChoice`)**: Unified picker combining calendar date and clock time in a single synchronized widget.
- **Duration & Timer (`WheelDurationChoice`)**: Hours, Minutes, and Seconds picker for cooking timers, workouts, and stopwatches.
- **Number & Measurement (`WheelNumberChoice`)**: Pick integer, decimal fraction, and unit (`kg`, `lbs`, `cm`, etc.) for fitness and measurement inputs.
- **Date Range (`WheelDateRangeChoice`)**: Synchronized Start Date and End Date picker for hotel, travel, and appointment bookings.
- **Cascading Tree Picker (`WheelCascadeChoice<T>`)**: Multi-level dependent picker (e.g. Country → Province/State → City).
- **Modal Dialog & Sheet Helpers**: Instant modal bottom sheets (`showWheelDatePicker`, `showWheelTimePicker`, `showWheelDateTimePicker`, `showWheelDurationPicker`).
- **Subtree Theming (`WheelChoiceTheme`)**: Inherit styling (`itemExtent`, `itemVisible`, `effect`, `overlay`, `physics`, `clipBehavior`, `keyboard`, and `haptics`) from an ancestor theme.
- **Form Integration**: Ready-to-use `FormField` widgets for all pickers (`WheelDateChoiceFormField`, `WheelTimeChoiceFormField`, `WheelDateTimeChoiceFormField`, `WheelDurationChoiceFormField`, `WheelNumberChoiceFormField`, `WheelDateRangeChoiceFormField`, `WheelCascadeChoiceFormField`).
- **All-in-One Exports**: Re-exports all core utilities from `wheel_choice` (`WheelChoice`, `WheelController`, `WheelOverlay`, `WheelEffect`, `WheelHeader`, `WheelChoiceTheme`, etc.).

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
  order: WheelDateOrder.of(context),
  overlay: WheelOverlay.outlined(),
)
```

### 2. Time Picker (12h or 24h)

```dart
WheelTimeChoice(
  value: const TimeOfDay(hour: 14, minute: 30),
  use24hFormat: false, // 12-hour mode with AM/PM
  minuteStep: 5,
  onChanged: (TimeOfDay time) => debugPrint('Selected time: ${time.format(context)}'),
  overlay: WheelOverlay.outlined(),
)
```

### 3. Combined Date & Time

```dart
WheelDateTimeChoice(
  value: DateTime.now(),
  use24hFormat: false,
  minuteStep: 15,
  onChanged: (DateTime dt) => debugPrint('Selected DateTime: $dt'),
  overlay: WheelOverlay.outlined(),
)
```

### 4. Duration / Timer

```dart
WheelDurationChoice(
  value: const Duration(hours: 1, minutes: 30),
  showSeconds: true,
  onChanged: (Duration d) => debugPrint('Selected Duration: $d'),
  overlay: WheelOverlay.outlined(),
)
```

### 5. Number & Weight / Height

```dart
WheelNumberChoice(
  value: 68.5,
  min: 30,
  max: 200,
  precision: 1,
  units: const ['kg', 'lbs'],
  onChanged: (num val) => debugPrint('Value: $val'),
  overlay: WheelOverlay.outlined(),
)
```

### 6. Date Range (Booking)

```dart
WheelDateRangeChoice(
  value: DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(days: 7)),
  ),
  onChanged: (DateTimeRange range) => debugPrint('Booking: $range'),
  overlay: WheelOverlay.outlined(),
)
```

### 7. Cascading Multi-Level Tree

```dart
WheelCascadeChoice<String>(
  items: const [
    WheelCascadeItem(
      value: 'USA',
      label: 'United States',
      children: [
        WheelCascadeItem(value: 'CA', label: 'California', children: [
          WheelCascadeItem(value: 'LA', label: 'Los Angeles'),
          WheelCascadeItem(value: 'SF', label: 'San Francisco'),
        ]),
      ],
    ),
  ],
  onChanged: (List<String> values) => debugPrint('Selected: $values'),
)
```

### 8. Instant Modal Bottom Sheet

```dart
final DateTime? picked = await showWheelDatePicker(
  context: context,
  initialDate: DateTime.now(),
);

final TimeOfDay? time = await showWheelTimePicker(
  context: context,
  use24hFormat: false,
);
```

## API Overview

| Class | Type | Description |
| :--- | :--- | :--- |
| `WheelDateChoice` | Widget | Composite calendar date picker |
| `WheelTimeChoice` | Widget | 12h / 24h clock time picker |
| `WheelDateTimeChoice` | Widget | Combined Date + Time synchronized picker |
| `WheelDurationChoice` | Widget | Hours, Minutes, Seconds duration/timer picker |
| `WheelNumberChoice` | Widget | Numeric stepper with decimal precision & unit wheel |
| `WheelDateRangeChoice` | Widget | Start Date & End Date range picker |
| `WheelCascadeChoice<T>` | Widget | Multi-level dependent cascading picker |
| `showWheelDatePicker` | Function | Instant modal bottom sheet for Date |
| `showWheelTimePicker` | Function | Instant modal bottom sheet for Time |
| `showWheelDateTimePicker` | Function | Instant modal bottom sheet for Date & Time |
| `showWheelDurationPicker` | Function | Instant modal bottom sheet for Duration |
| `showWheelModalSheet` | Function | Generic bottom sheet with Cancel / Done header |
| `Wheel*ChoiceFormField` | FormField | Form integration widgets for Flutter `Form` validation |

## License

BSD-3-Clause License. See [LICENSE](LICENSE) for details.
