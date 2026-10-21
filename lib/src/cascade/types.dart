/// Represents a node in a cascading hierarchical tree of options.
class WheelCascadeItem<T> {
  /// Creates a cascade item.
  const WheelCascadeItem({
    required this.value,
    this.label,
    this.children = const [],
  });

  /// The underlying value represented by this item.
  final T value;

  /// Optional display label. Defaults to `value.toString()`.
  final String? label;

  /// Child items shown when this item is selected.
  final List<WheelCascadeItem<T>> children;

  @override
  String toString() => label ?? value.toString();
}
