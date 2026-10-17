import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Quantity selector stepper widget with decrement [-], input field, and increment [+] buttons.
/// Designed specifically to guarantee non-negative values (minimum 0, no negative numbers).
class ApplianceQuantitySelector extends StatefulWidget {
  final int count;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const ApplianceQuantitySelector({
    super.key,
    required this.count,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
  });

  @override
  State<ApplianceQuantitySelector> createState() => _ApplianceQuantitySelectorState();
}

class _ApplianceQuantitySelectorState extends State<ApplianceQuantitySelector> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.count}');
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      if (_controller.text.isEmpty) {
        _controller.text = '${widget.min}';
        widget.onChanged(widget.min);
      } else {
        final parsed = int.tryParse(_controller.text) ?? widget.min;
        final clamped = parsed.clamp(widget.min, widget.max);
        if (_controller.text != '$clamped') {
          _controller.text = '$clamped';
        }
        if (parsed != clamped) {
          widget.onChanged(clamped);
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant ApplianceQuantitySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      final currentInField = int.tryParse(_controller.text);
      if (currentInField != widget.count) {
        _controller.text = '${widget.count}';
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _decrement() {
    if (widget.count > widget.min) {
      final newVal = (widget.count - 1).clamp(widget.min, widget.max);
      _controller.text = '$newVal';
      widget.onChanged(newVal);
    }
  }

  void _increment() {
    if (widget.count < widget.max) {
      final newVal = (widget.count + 1).clamp(widget.min, widget.max);
      _controller.text = '$newVal';
      widget.onChanged(newVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canDecrement = widget.count > widget.min;
    final canIncrement = widget.count < widget.max;
    final isActive = widget.count > widget.min;

    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive ? const Color(0xFF0E3B6C).withValues(alpha: 0.3) : const Color(0xFFCBD5E1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Decrement Button [-]
            Material(
              color: canDecrement ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
              child: InkWell(
                onTap: canDecrement ? _decrement : null,
                child: SizedBox(
                  width: 24,
                  child: Center(
                    child: Icon(
                      Icons.remove_rounded,
                      size: 13,
                      color: canDecrement ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              ),
            ),

            // Left divider
            Container(
              width: 1,
              color: const Color(0xFFE2E8F0),
            ),

            // Middle Value / Input Field
            SizedBox(
              width: 32,
              child: Center(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  cursorHeight: 14,
                  cursorWidth: 1.5,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  strutStyle: const StrutStyle(
                    fontSize: 12,
                    height: 1.1,
                    forceStrutHeight: true,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    leadingDistribution: TextLeadingDistribution.even,
                    color: isActive ? const Color(0xFF0E3B6C) : const Color(0xFF64748B),
                  ),
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onTap: () {
                    _controller.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _controller.text.length,
                    );
                  },
                  onChanged: (text) {
                    if (text.isEmpty) {
                      widget.onChanged(widget.min);
                      return;
                    }
                    final parsed = int.tryParse(text) ?? widget.min;
                    final clamped = parsed.clamp(widget.min, widget.max);
                    widget.onChanged(clamped);
                  },
                ),
              ),
            ),

            // Right divider
            Container(
              width: 1,
              color: const Color(0xFFE2E8F0),
            ),

            // Increment Button [+]
            Material(
              color: canIncrement ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
              child: InkWell(
                onTap: canIncrement ? _increment : null,
                child: SizedBox(
                  width: 24,
                  child: Center(
                    child: Icon(
                      Icons.add_rounded,
                      size: 13,
                      color: canIncrement ? const Color(0xFFF36A21) : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
