import 'package:auto_hub_app/core/theme/app_colors.dart';
import 'package:auto_hub_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    required this.hintText,
    required this.prefixIcon,
    super.key,
    this.isPassword = false,
    this.suffixIconPath, // icon when password is hidden
    this.suffixIconPathActive, // icon when password is visible
    this.controller,
    this.onChanged,
    this.focusNode,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled = true,
  });

  final String hintText;
  final Widget prefixIcon;
  final bool isPassword;
  final IconData? suffixIconPath;
  final IconData? suffixIconPathActive;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  bool _focused = false;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() => _focused = _focusNode.hasFocus);

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final accent = hasError ? Colors.redAccent : AppColors.onboardingCyan;
    final borderColor = hasError
        ? Colors.redAccent
        : _focused
            ? AppColors.onboardingCyan
            : Colors.white.withValues(alpha: 0.06);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: AppColors.onboardingSurface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              if (_focused || hasError)
                BoxShadow(
                  color: accent.withValues(alpha: 0.18),
                  blurRadius: 14.r,
                  spreadRadius: 1.r,
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 4.r,
                  offset: Offset(0, 1.h),
                ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: _focused ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
  child: IconTheme(
    data: IconThemeData(
      size: 16.w,
      color: accent,
    ),
    child: SizedBox(
      width: 16.w,
      height: 16.w,
      child: FittedBox(child: widget.prefixIcon),
    ),
  ),
),),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  obscureText: widget.isPassword && _obscured,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  inputFormatters: widget.inputFormatters,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onboardingTextPrimary,
                    fontSize: 14.sp,
                  ),
                  cursorColor: accent,
                  cursorWidth: 1.6,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onboardingTextPrimary
                          .withValues(alpha: 0.4),
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    isDense: true,
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              if (widget.isPassword)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _obscured = !_obscured),
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        _obscured
                            ? (widget.suffixIconPath ??
                                Icons.visibility_off_outlined)
                            : (widget.suffixIconPathActive ??
                                Icons.visibility_outlined),
                        key: ValueKey(_obscured),
                        size: 20.w,
                        color: _focused
                            ? AppColors.onboardingCyan
                            : AppColors.onboardingTextPrimary
                                .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topLeft,
          child: hasError
              ? Padding(
                  padding: EdgeInsets.only(top: 6.h, left: 6.w),
                  child: Text(
                    widget.errorText!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.redAccent,
                      fontSize: 12.sp,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}