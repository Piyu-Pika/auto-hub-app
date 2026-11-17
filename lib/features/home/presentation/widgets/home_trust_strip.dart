import 'package:auto_hub_app/core/theme/app_colors.dart';
import 'package:auto_hub_app/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeTrustStrip extends StatelessWidget {
  const HomeTrustStrip({super.key, this.trustItems});

  final List<TrustStripItemEntity>? trustItems;

  @override
  Widget build(BuildContext context) {
    final items = trustItems ?? const <TrustStripItemEntity>[];
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: 'Trust badges',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final item in items)
            _TrustItem(icon: item.icon, label: item.label),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            icon,
            width: 16.w,
            height: 16.h,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
