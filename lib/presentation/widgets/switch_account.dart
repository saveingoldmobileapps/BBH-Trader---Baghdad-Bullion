import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';

class SwitchAccountCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String iconString;
  final bool isSecondIcon;
  final bool initialSwitchValue;
  final bool isLoading; // Add this
  final ValueChanged<bool>? onToggleChanged;
  final VoidCallback onTap;

  const SwitchAccountCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconString,
    required this.isSecondIcon,
    required this.onTap,
    this.initialSwitchValue = false,
    this.isLoading = false, // Add this with default value
    this.onToggleChanged,
  });

  @override
  State<SwitchAccountCard> createState() => _SwitchAccountCardState();
}

class _SwitchAccountCardState extends State<SwitchAccountCard> {
  late bool _isRealAccount;

  @override
  void initState() {
    super.initState();
    _isRealAccount = widget.initialSwitchValue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onTap, // Disable tap when loading
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              widget.iconString,
              height: sizes!.responsiveHeight(phoneVal: 24, tabletVal: 32),
              width: sizes!.responsiveWidth(phoneVal: 24, tabletVal: 32),
            ),
            ConstPadding.sizeBoxWithWidth(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GetGenericText(
                  text: widget.title,
                  fontSize: sizes!.responsiveFont(phoneVal: 14, tabletVal: 16),
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey6Color,
                ),
                GetGenericText(
                  text: widget.subtitle,
                  fontSize: sizes!.responsiveFont(phoneVal: 11, tabletVal: 13),
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey3Color,
                ),
              ],
            ),
            const Spacer(),
            Visibility(
              visible: widget.isSecondIcon,
              child: widget.isLoading
                  ? SizedBox(
                      width: 48,
                      height: 24,
                      child: Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.goldColor,
                          ),
                        ),
                      ),
                    )
                  : Switch(
                      value: _isRealAccount,
                      activeColor: AppColors.goldColor,
                      onChanged: (value) {
                        widget.onToggleChanged?.call(value);
                        setState(() {
                          _isRealAccount = value;
                        });
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
