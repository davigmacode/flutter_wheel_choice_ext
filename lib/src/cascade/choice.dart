import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'controller.dart';
import 'types.dart';

/// Builder callback for custom loading indicator per column.
typedef WheelCascadeLoadingBuilder = Widget Function(
  BuildContext context,
  int level,
);

/// Builder callback for custom error display per column.
typedef WheelCascadeErrorBuilder = Widget Function(
  BuildContext context,
  int level,
  Object? error,
  VoidCallback retry,
);

/// A multi-column cascading wheel selector where downstream options
/// depend on upstream selections (e.g. Country -> State -> City).
///
/// Supports both synchronous static trees and asynchronous dynamic data loaders.
class WheelCascadeChoice<T> extends StatefulWidget {
  /// Creates a cascading picker with a hierarchical item tree.
  const WheelCascadeChoice({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.header,
    this.flex,
    this.itemExtent,
    this.itemVisible,
    this.itemLabel,
    this.loadingBuilder,
    this.errorBuilder,
    this.overlay,
    this.effect,
    this.spacing,
    this.physics,
    this.clipBehavior,
    this.keyboard,
    this.focusNode,
    this.haptics,
  })  : optionsLoader = null,
        depth = null,
        controller = null;

  /// Creates a cascading picker using an on-demand/async options loader.
  const WheelCascadeChoice.builder({
    super.key,
    required this.depth,
    required this.optionsLoader,
    this.value,
    this.onChanged,
    this.header,
    this.flex,
    this.itemExtent,
    this.itemVisible,
    this.itemLabel,
    this.loadingBuilder,
    this.errorBuilder,
    this.overlay,
    this.effect,
    this.spacing,
    this.physics,
    this.clipBehavior,
    this.keyboard,
    this.focusNode,
    this.haptics,
  })  : items = const [],
        controller = null;

  /// Creates a cascading picker using an external [controller].
  const WheelCascadeChoice.raw({
    super.key,
    required WheelCascadeController<T> this.controller,
    this.header,
    this.flex,
    this.itemExtent,
    this.itemVisible,
    this.itemLabel,
    this.loadingBuilder,
    this.errorBuilder,
    this.overlay,
    this.effect,
    this.spacing,
    this.physics,
    this.clipBehavior,
    this.keyboard,
    this.focusNode,
    this.haptics,
  })  : items = const [],
        optionsLoader = null,
        depth = null,
        value = null,
        onChanged = null;

  /// The root hierarchical options (for static or lazy tree).
  final List<WheelCascadeItem<T>> items;

  /// Level-by-level options loader callback (sync or async).
  final WheelCascadeOptionsLoader<T>? optionsLoader;

  /// Explicit depth (number of columns), required for `.builder`.
  final int? depth;

  /// Initial selected values for each level.
  final List<T>? value;

  /// Callback when the full selected path changes.
  final ValueChanged<List<T>>? onChanged;

  /// Optional header widgets rendered above each column from left to right.
  final List<Widget?>? header;

  /// Flex distribution factors for each column.
  final List<int>? flex;

  /// Height of each item row.
  final double? itemExtent;

  /// Number of visible rows.
  final int? itemVisible;

  /// Custom label formatting callback. If null, uses [WheelCascadeItem.label].
  final WheelItemLabel<T>? itemLabel;

  /// Custom widget builder when a column is loading options asynchronously.
  final WheelCascadeLoadingBuilder? loadingBuilder;

  /// Custom widget builder when a column encounters an error loading options.
  final WheelCascadeErrorBuilder? errorBuilder;

  /// Overlay highlighting selected row across all columns.
  final WidgetBuilder? overlay;

  /// 3D and magnification effect.
  final WheelEffect? effect;

  /// Horizontal spacing between columns.
  final double? spacing;

  /// Scroll physics.
  final ScrollPhysics? physics;

  /// Viewport clipping behavior.
  final Clip? clipBehavior;

  /// Whether keyboard navigation is enabled.
  final bool? keyboard;

  /// Optional focus node.
  final FocusNode? focusNode;

  /// Whether haptic feedback is played.
  final bool? haptics;

  /// External cascade controller.
  final WheelCascadeController<T>? controller;

  @override
  State<WheelCascadeChoice<T>> createState() => _WheelCascadeChoiceState<T>();
}

class _WheelCascadeChoiceState<T> extends State<WheelCascadeChoice<T>> {
  WheelCascadeController<T>? _defaultCtrl;
  WheelCascadeController<T> get _ctrl => widget.controller ?? _ensureCtrl();

  WheelCascadeController<T> _ensureCtrl() {
    return _defaultCtrl ??= WheelCascadeController<T>(
      items: widget.items.isNotEmpty ? widget.items : null,
      optionsLoader: widget.optionsLoader,
      depth: widget.depth,
      initialValue: widget.value,
      onChanged: widget.onChanged,
    );
  }

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_handleCtrlChanged);
  }

  void _handleCtrlChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant WheelCascadeChoice<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleCtrlChanged);
      if (oldWidget.controller == null) {
        _defaultCtrl?.dispose();
        _defaultCtrl = null;
      }
      widget.controller?.addListener(_handleCtrlChanged);
    }

    if (widget.controller == null) {
      if (widget.value != null && widget.value != oldWidget.value) {
        _defaultCtrl?.jumpToValues(widget.value!);
      }
      if (widget.onChanged != oldWidget.onChanged) {
        _ctrl.setOnChanged(widget.onChanged);
      }
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_handleCtrlChanged);
    _defaultCtrl?.dispose();
    _defaultCtrl = null;
    super.dispose();
  }

  String _resolveItemLabel(int level, T val) {
    if (widget.itemLabel != null) {
      return widget.itemLabel!(val);
    }
    return _ctrl.labelFor(level, val);
  }

  List<Widget> _withSpacing(List<Widget> items, double spacing) {
    if (spacing <= 0 || items.length <= 1) return items;
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(SizedBox(width: spacing));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = WheelChoiceTheme.of(context);
    final effectiveItemExtent = widget.itemExtent ?? theme?.itemExtent ?? 40.0;
    final effectiveItemVisible = widget.itemVisible ?? theme?.itemVisible ?? 5;
    final effectiveEffect = widget.effect ?? theme?.effect;
    final effectiveOverlay = widget.overlay ?? theme?.overlay;
    final effectivePhysics = widget.physics ?? theme?.physics;
    final effectiveClipBehavior = widget.clipBehavior ?? theme?.clipBehavior;
    final effectiveKeyboard = widget.keyboard ?? theme?.keyboard;
    final effectiveHaptics = widget.haptics ?? theme?.haptics;

    final depth = _ctrl.depth;
    final hasHeader = widget.header != null && widget.header!.isNotEmpty;
    final headers = <Widget>[];
    final wheels = <Widget>[];

    final totalHeight = effectiveItemExtent * effectiveItemVisible;

    for (var i = 0; i < depth; i++) {
      final ctrl = _ctrl.controllers[i];
      final colFlex = (widget.flex != null && i < widget.flex!.length)
          ? widget.flex![i]
          : 1;

      if (hasHeader) {
        final headerWidget = (i < widget.header!.length && widget.header![i] != null)
            ? widget.header![i]!
            : const SizedBox.shrink();
        headers.add(
          Expanded(
            flex: colFlex,
            child: headerWidget,
          ),
        );
      }

      Widget columnContent;
      if (_ctrl.isLoading(i)) {
        columnContent = widget.loadingBuilder?.call(context, i) ??
            Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
      } else if (_ctrl.hasError(i)) {
        columnContent = widget.errorBuilder?.call(
              context,
              i,
              _ctrl.error(i),
              () => _ctrl.retry(i),
            ) ??
            Center(
              child: IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Retry',
                onPressed: () => _ctrl.retry(i),
              ),
            );
      } else {
        columnContent = WheelChoice<T>.raw(
          key: ValueKey('cascade-col-$i-${_ctrl.versionAt(i)}'),
          controller: ctrl,
          itemExtent: effectiveItemExtent,
          itemVisible: effectiveItemVisible,
          itemLabel: (val) => _resolveItemLabel(i, val),
          overlay: (ctx) => const SizedBox.shrink(),
          effect: effectiveEffect,
          physics: effectivePhysics,
          clipBehavior: effectiveClipBehavior,
          keyboard: effectiveKeyboard,
          focusNode: widget.focusNode,
          haptics: effectiveHaptics,
        );
      }

      wheels.add(
        Expanded(
          flex: colFlex,
          child: SizedBox(
            height: totalHeight,
            child: columnContent,
          ),
        ),
      );
    }

    final body = WheelOverlay(
      builder: effectiveOverlay,
      extent: effectiveItemExtent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _withSpacing(wheels, widget.spacing ?? 0),
      ),
    );

    if (hasHeader) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _withSpacing(headers, widget.spacing ?? 0),
          ),
          const SizedBox(height: 8),
          body,
        ],
      );
    }

    return body;
  }
}
