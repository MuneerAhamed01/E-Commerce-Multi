import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../tokens/app_radii.dart';
import '../../tokens/app_spacing.dart';

/// A segmented one-time-passcode entry field, per
/// docs/08_COMPONENT_LIBRARY.md §5 (`OtpInputRow`). Renders [length] boxes,
/// auto-advances focus as digits are typed, and calls [onCompleted] once
/// every box is filled.
///
/// Set [hasError] to `true` to render the error (shake) state after a
/// failed verification attempt; the caller is responsible for clearing it
/// once the user starts editing again.
///
/// ```dart
/// AppOtpInputRow(
///   length: 6,
///   hasError: state is OtpVerificationFailure,
///   onCompleted: (code) => bloc.add(OtpSubmitted(code)),
/// );
/// ```
class AppOtpInputRow extends StatefulWidget {
  const AppOtpInputRow({
    required this.onCompleted,
    this.length = 6,
    this.hasError = false,
    super.key,
  });

  final int length;
  final bool hasError;
  final ValueChanged<String> onCompleted;

  @override
  State<AppOtpInputRow> createState() => _AppOtpInputRowState();
}

class _AppOtpInputRowState extends State<AppOtpInputRow>
    with SingleTickerProviderStateMixin {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(covariant AppOtpInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    final code = _controllers.map((c) => c.text).join();
    if (code.length == widget.length) {
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final offset = _shakeOffset(_shakeController.value);
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.length, (index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < widget.length - 1 ? AppSpacing.sm : 0,
            ),
            child: SizedBox(
              width: 44,
              height: 52,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: Theme.of(context).textTheme.titleLarge,
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadii.borderRadiusSm,
                    borderSide: BorderSide(
                      color: widget.hasError
                          ? colorScheme.error
                          : colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadii.borderRadiusSm,
                    borderSide: BorderSide(
                      color: widget.hasError
                          ? colorScheme.error
                          : colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) => _onChanged(index, value),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// A decaying sine sweep (4 full cycles) for a natural-feeling shake that
  /// starts and ends at rest.
  double _shakeOffset(double t) {
    const amplitude = 8.0;
    return amplitude * (1 - t) * math.sin(t * 4 * math.pi);
  }
}
