import 'package:auto_hub_app/core/theme/app_colors.dart';
import 'package:auto_hub_app/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeStatsRow extends StatelessWidget {
  const HomeStatsRow({super.key, this.stats});

  final List<HomeStatEntity>? stats;

  static const _colors = [
    Color(0xFF0DA0CE),
    Color(0xFF34D399),
    Color(0xFFA78BFA),
  ];

  @override
  Widget build(BuildContext context) {
    if (stats != null && stats!.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: [
            for (var i = 0; i < stats!.length; i++) ...[
              if (i > 0) SizedBox(width: 11.w),
              _StatCard(
                value: stats![i].value,
                label: stats![i].label,
                color: _colors[i % _colors.length],
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          const _StatCard(
            value: '18K+',
            label: 'Parts Listed',
            color: Color(0xFF0DA0CE),
          ),
          SizedBox(width: 11.w),
          const _StatCard(
            value: '320+',
            label: 'Yards',
            color: Color(0xFF34D399),
          ),
          SizedBox(width: 11.w),
          const _StatCard(
            value: '94K+',
            label: 'Buyers',
            color: Color(0xFFA78BFA),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 72.h,
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0x12FFFFFF),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
