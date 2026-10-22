import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'types.dart';

/// Controller to programmatically manipulate a multi-level cascading picker,
/// supporting both synchronous trees and asynchronous dynamic data loaders.
class WheelCascadeController<T> extends ChangeNotifier {
  /// Creates a controller for cascading options.
  WheelCascadeController({
    List<WheelCascadeItem<T>>? items,
    WheelCascadeOptionsLoader<T>? optionsLoader,
    int? depth,
    List<T>? initialValue,
    ValueChanged<List<T>>? onChanged,
    bool? loop,
  })  : _items = items ?? const [],
        _optionsLoader = optionsLoader,
        _onChanged = onChanged,
        _loop = loop ?? false,
        _depth = depth ??
            (items != null && items.isNotEmpty ? _calculateDepth(items) : 0),
        _valueNotifier = ValueNotifier<List<T>>([]) {
    _init(initialValue);
  }

  final List<WheelCascadeItem<T>> _items;
  final WheelCascadeOptionsLoader<T>? _optionsLoader;
  final bool _loop;
  final int _depth;
  final ValueNotifier<List<T>> _valueNotifier;
  ValueChanged<List<T>>? _onChanged;

  final List<WheelController<T>> _controllers = [];
  final List<List<WheelCascadeItem<T>>> _levelItems = [];
  final List<bool> _loadingLevels = [];
  final List<Object?> _errorLevels = [];
  final List<int> _versions = [];
  final List<int> _requestTokens = [];
  final List<T> _currentValues = [];

  bool _disposed = false;

  /// Number of levels (depth) in this cascading tree.
  int get depth => _depth;

  /// Controllers for each level in the cascade.
  List<WheelController<T>> get controllers => List.unmodifiable(_controllers);

  /// Currently selected values across all levels (e.g. `[country, state, city]`).
  List<T> get value => _valueNotifier.value;

  /// Read-only listenable for the selected values.
  ValueListenable<List<T>> get valueListenable => _valueNotifier;

  /// Returns whether the specified level is currently fetching options asynchronously.
  bool isLoading(int level) =>
      level < _loadingLevels.length && _loadingLevels[level];

  /// Returns whether the specified level encountered an error fetching options.
  bool hasError(int level) =>
      level < _errorLevels.length && _errorLevels[level] != null;

  /// Returns the error object for the specified level, if any.
  Object? error(int level) =>
      level < _errorLevels.length ? _errorLevels[level] : null;

  /// Returns the version number for options at [level], incremented on changes.
  int versionAt(int level) =>
      level < _versions.length ? _versions[level] : 0;

  /// Returns the items available at [level].
  List<WheelCascadeItem<T>> itemsAt(int level) =>
      level < _levelItems.length ? List.unmodifiable(_levelItems[level]) : const [];

  /// Returns the cascade item corresponding to [val] at [level].
  WheelCascadeItem<T>? itemFor(int level, T val) {
    if (level >= _levelItems.length) return null;
    return _levelItems[level].where((e) => e.value == val).firstOrNull;
  }

  /// Returns the label for [val] at [level], defaulting to `val.toString()`.
  String labelFor(int level, T val) {
    return itemFor(level, val)?.label ?? val.toString();
  }

  static int _calculateDepth<T>(List<WheelCascadeItem<T>> items) {
    if (items.isEmpty) return 0;
    var maxChildDepth = 0;
    for (final it in items) {
      if (it.hasChildren && it.children.isNotEmpty) {
        final d = _calculateDepth(it.children);
        if (d > maxChildDepth) maxChildDepth = d;
      }
    }
    return 1 + maxChildDepth;
  }

  FutureOr<List<WheelCascadeItem<T>>> _loadOptionsForLevel(
    int level,
    List<T> selectedValues,
  ) {
    final loader = _optionsLoader;
    if (loader != null) {
      return loader(level, selectedValues);
    }
    return _defaultTreeLoader(level, selectedValues);
  }

  FutureOr<List<WheelCascadeItem<T>>> _defaultTreeLoader(
    int level,
    List<T> selectedValues,
  ) {
    if (level == 0) return _items;

    List<WheelCascadeItem<T>> currentList = _items;
    for (var i = 0; i < level; i++) {
      final parentVal = i < selectedValues.length ? selectedValues[i] : null;
      final parentNode =
          currentList.where((e) => e.value == parentVal).firstOrNull;
      if (parentNode == null) return const [];
      if (parentNode.loadChildren != null && i == level - 1) {
        return parentNode.loadChildren!();
      }
      currentList = parentNode.children;
    }
    return currentList;
  }

  void _init(List<T>? initialValue) {
    for (var i = 0; i < _depth; i++) {
      _loadingLevels.add(false);
      _errorLevels.add(null);
      _versions.add(0);
      _requestTokens.add(0);
      _levelItems.add([]);

      final levelIndex = i;
      final ctrl = WheelController<T>(
        options: const [],
        loop: _loop,
        onChanged: (val) => _handleLevelChanged(levelIndex, val),
      );
      _controllers.add(ctrl);
    }

    _loadLevel(0, initialValues: initialValue);
  }

  FutureOr<void> _loadLevel(int level, {List<T>? initialValues}) {
    if (_disposed || level >= _depth) return null;

    final selectedUpstream = _currentValues.take(level).toList();
    final res = _loadOptionsForLevel(level, selectedUpstream);

    final preferred = (initialValues != null && level < initialValues.length)
        ? initialValues[level]
        : null;

    if (res is Future<List<WheelCascadeItem<T>>>) {
      _loadingLevels[level] = true;
      _errorLevels[level] = null;
      notifyListeners();

      final token = ++_requestTokens[level];
      return res.then<void>((items) {
        if (_disposed || _requestTokens[level] != token) return;
        _loadingLevels[level] = false;
        _applyLevelItems(level, items, preferred);
        notifyListeners();

        if (level + 1 < _depth) {
          _loadLevel(level + 1, initialValues: initialValues);
        }
      }).catchError((err) {
        if (_disposed || _requestTokens[level] != token) return;
        _loadingLevels[level] = false;
        _errorLevels[level] = err;
        notifyListeners();
      });
    } else {
      _loadingLevels[level] = false;
      _errorLevels[level] = null;
      _applyLevelItems(level, res, preferred);

      if (level + 1 < _depth) {
        return _loadLevel(level + 1, initialValues: initialValues);
      } else {
        notifyListeners();
      }
    }
  }

  void _applyLevelItems(
    int level,
    List<WheelCascadeItem<T>> items,
    T? preferred,
  ) {
    _levelItems[level] = items;
    _versions[level]++;
    final opts = items.map((e) => e.value).toList();

    T? targetVal;
    if (preferred != null && opts.contains(preferred)) {
      targetVal = preferred;
    } else if (opts.isNotEmpty) {
      targetVal = opts.first;
    } else {
      targetVal = null;
    }

    final ctrl = _controllers[level];
    ctrl.setOptions(opts, alignToValue: false);
    if (targetVal != null) {
      ctrl.jumpToValue(targetVal, notify: false);
    }

    if (level < _currentValues.length) {
      if (targetVal != null) {
        _currentValues[level] = targetVal;
      } else {
        _currentValues.removeRange(level, _currentValues.length);
      }
    } else if (targetVal != null) {
      _currentValues.add(targetVal);
    }

    _valueNotifier.value = List.unmodifiable(_currentValues);
  }

  void _handleLevelChanged(int level, T newValue) {
    if (_disposed) return;
    if (level < _currentValues.length && _currentValues[level] == newValue) {
      return;
    }

    if (level < _currentValues.length) {
      _currentValues[level] = newValue;
      if (_currentValues.length > level + 1) {
        _currentValues.removeRange(level + 1, _currentValues.length);
      }
    } else {
      _currentValues.add(newValue);
    }

    // Invalidate in-flight tokens for downstream levels to prevent race conditions
    for (var d = level + 1; d < _depth; d++) {
      _requestTokens[d]++;
    }

    _valueNotifier.value = List.unmodifiable(_currentValues);
    _onChanged?.call(_valueNotifier.value);
    notifyListeners();

    // Cascading reload downstream
    if (level + 1 < _depth) {
      _loadLevel(level + 1);
    }
  }

  /// Retries fetching options for the given [level] if an error occurred.
  void retry(int level) {
    if (level < _depth) {
      _loadLevel(level);
    }
  }

  /// Updates the onChanged callback.
  void setOnChanged(ValueChanged<List<T>>? f) => _onChanged = f;

  /// Jumps the cascade controllers to the provided [values].
  FutureOr<void> jumpToValues(List<T> values) {
    if (values.isEmpty) return null;
    return _loadLevel(0, initialValues: values);
  }

  /// Disposes all controllers and listeners.
  @override
  void dispose() {
    _disposed = true;
    _valueNotifier.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }
}
