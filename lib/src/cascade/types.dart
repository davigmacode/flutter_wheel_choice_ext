import 'dart:async';

/// Callback for dynamically loading child items for a specific node.
typedef WheelCascadeLoader<T> = FutureOr<List<WheelCascadeItem<T>>> Function();

/// Callback for loading options level by level based on current selections.
typedef WheelCascadeOptionsLoader<T> = FutureOr<List<WheelCascadeItem<T>>> Function(
  int level,
  List<T> selectedValues,
);

/// Represents a node in a cascading hierarchical tree of options.
class WheelCascadeItem<T> {
  /// Creates a cascade item.
  const WheelCascadeItem({
    required this.value,
    this.label,
    this.children = const [],
    this.loadChildren,
  });

  /// The underlying value represented by this item.
  final T value;

  /// Optional display label. Defaults to `value.toString()`.
  final String? label;

  /// Child items shown when this item is selected (synchronous).
  final List<WheelCascadeItem<T>> children;

  /// Optional callback to load child items dynamically or asynchronously.
  final WheelCascadeLoader<T>? loadChildren;

  /// Whether this node has child options.
  bool get hasChildren => children.isNotEmpty || loadChildren != null;

  @override
  String toString() => label ?? value.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WheelCascadeItem<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
