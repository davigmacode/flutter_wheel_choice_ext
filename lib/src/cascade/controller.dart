import 'package:flutter/foundation.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'types.dart';

/// Controller to programmatically manipulate a multi-level cascading picker.
class WheelCascadeController<T> {
  /// Creates a controller for cascading options.
  WheelCascadeController({
    required List<WheelCascadeItem<T>> items,
    List<T>? initialValue,
    ValueChanged<List<T>>? onChanged,
  })  : _items = items,
        _onChanged = onChanged,
        _depth = _calculateDepth(items),
        _valueNotifier = ValueNotifier<List<T>>([]) {
    _initLevels(initialValue);
  }

  final List<WheelCascadeItem<T>> _items;
  final int _depth;
  final ValueNotifier<List<T>> _valueNotifier;
  ValueChanged<List<T>>? _onChanged;

  final List<WheelController<T>> _controllers = [];

  /// Number of levels (depth) in this cascading tree.
  int get depth => _depth;

  /// Controllers for each level in the cascade.
  List<WheelController<T>> get controllers => List.unmodifiable(_controllers);

  /// Currently selected values across all levels (e.g. `[country, state, city]`).
  List<T> get value => _valueNotifier.value;

  /// Read-only listenable for the selected values.
  ValueListenable<List<T>> get valueListenable => _valueNotifier;

  static int _calculateDepth<T>(List<WheelCascadeItem<T>> items) {
    if (items.isEmpty) return 0;
    var maxChildDepth = 0;
    for (final it in items) {
      if (it.children.isNotEmpty) {
        final d = _calculateDepth(it.children);
        if (d > maxChildDepth) maxChildDepth = d;
      }
    }
    return 1 + maxChildDepth;
  }

  void _initLevels(List<T>? initialValue) {
    final currentValues = <T>[];
    List<WheelCascadeItem<T>> currentOptions = _items;

    for (var level = 0; level < _depth; level++) {
      final opts = currentOptions.map((e) => e.value).toList();
      final T? targetVal = (initialValue != null && level < initialValue.length && opts.contains(initialValue[level]))
          ? initialValue[level]
          : (opts.isNotEmpty ? opts.first : null);

      if (targetVal != null) {
        currentValues.add(targetVal);
      }

      final capturedLevel = level;
      final ctrl = WheelController<T>(
        options: opts,
        value: targetVal,
        onChanged: (val) => _handleLevelChanged(capturedLevel, val),
      );
      _controllers.add(ctrl);

      final selectedNode = currentOptions.where((e) => e.value == targetVal).firstOrNull;
      currentOptions = selectedNode?.children ?? [];
    }

    _valueNotifier.value = currentValues;
  }

  void _handleLevelChanged(int level, T newValue) {
    // Recompute downstream levels from level + 1 downwards
    final newValues = <T>[..._valueNotifier.value.take(level), newValue];

    List<WheelCascadeItem<T>> currentOptions = _items;
    for (var i = 0; i <= level; i++) {
      final selectedNode = currentOptions.where((e) => e.value == newValues[i]).firstOrNull;
      currentOptions = selectedNode?.children ?? [];
    }

    for (var downstream = level + 1; downstream < _depth; downstream++) {
      final downstreamOpts = currentOptions.map((e) => e.value).toList();
      final ctrl = _controllers[downstream];
      final target = downstreamOpts.isNotEmpty ? downstreamOpts.first : null;

      ctrl.setOptions(downstreamOpts, alignToValue: false);
      if (target != null) {
        ctrl.jumpToValue(target, notify: false);
        newValues.add(target);
      }

      final nextNode = currentOptions.where((e) => e.value == target).firstOrNull;
      currentOptions = nextNode?.children ?? [];
    }

    _valueNotifier.value = newValues;
    _onChanged?.call(newValues);
  }

  /// Updates the onChanged callback.
  void setOnChanged(ValueChanged<List<T>>? f) => _onChanged = f;

  /// Jumps the cascade controllers to the provided [values].
  void jumpToValues(List<T> values) {
    if (values.isEmpty) return;
    _handleLevelChanged(0, values.first);
    for (var i = 1; i < values.length && i < _depth; i++) {
      if (_controllers[i].options.contains(values[i])) {
        _controllers[i].jumpToValue(values[i], notify: false);
      }
    }
  }

  /// Disposes all controllers.
  void dispose() {
    _valueNotifier.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
  }
}
