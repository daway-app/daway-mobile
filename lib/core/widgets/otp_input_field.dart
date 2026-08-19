import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../helpers/digits_only_formatter.dart';
import '../theming/app_colors.dart';

/// Renders as [length] boxes but is backed by a single hidden [TextField],
/// so the OS/IME owns cursor and backspace behavior natively — earlier
/// versions used one TextField+FocusNode per box and inferred backspace
/// from onChanged("") or raw key events, which some Android keyboards
/// report unreliably (phantom empty onChanged, missing/garbled key events),
/// causing focus to jump to the wrong box or throw on out-of-range access.
class OtpInputField extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;

  const OtpInputField({
    super.key,
    this.length = 6,
    required this.onChanged,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(_handleChanged);
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChanged() {
    widget.onChanged(_controller.text);
    setState(() {});
  }

  Widget _buildBox(int index, String text, bool isFocused) {
    return Container(
      width: 42.w,
      height: 50.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isFocused ? AppColors.primaryTeal : AppColors.borderGrey,
          width: isFocused ? 1.5 : 1,
        ),
      ),
      child: Text(
        index < text.length ? text[index] : '',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text;
    final activeIndex = text.length.clamp(0, widget.length - 1);

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
       child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(widget.length, (index) {
                final isFocused = _focusNode.hasFocus && index == activeIndex;
                return _buildBox(index, text, isFocused);
              }),
            ),
            Opacity(
              opacity: 0,
              child: SizedBox(
                width: double.infinity,
                height: 60.h,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: widget.length,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  inputFormatters: [DigitsOnlyFormatter()],
                  decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
