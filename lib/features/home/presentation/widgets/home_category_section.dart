import 'package:auto_hub_app/core/theme/app_colors.dart';
import 'package:auto_hub_app/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeCategorySection extends StatelessWidget {
  const HomeCategorySection({super.key, this.categories});

  final List<HomeCategoryEntity>? categories;

  @override
  Widget build(BuildContext context) {
    final items = categories ?? const <HomeCategoryEntity>[];
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Browse by Category',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFF0F6FC),
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Semantics(
                button: true,
                label: 'See all categories',
                child:GestureDetector(
                  onTap: () => context.push('/browse'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'See all',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0DA0CE),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      SvgPicture.asset(
                        'assets/icons/ic_chevron_right.svg',
                        width: 12.w,
                        height: 12.h,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF0DA0CE),
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        // Horizontal scrollable categories
        SizedBox(
          height: 126.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 20.w),
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              return _CategoryCard(category: items[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final HomeCategoryEntity category;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${category.name}, ${category.partCount} parts',
      child:GestureDetector(
        onTap: () => context.push('/browse'),
        child: Container(
          width: 76.w,
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
              _CategoryIcon(iconUrl: category.iconUrl),
              SizedBox(height: 8.h),
              Text(
                category.name,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF0F6FC),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 1.h),
              Text(
                category.partCount.toString(),
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.iconUrl});

  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final url = iconUrl ?? '';
    if (url.isEmpty) {
      return Icon(
        Icons.category,
        size: 24.sp,
        color: AppColors.onboardingCyan,
      );
    }
    if (url.startsWith('http')) {
      return SvgPicture.network(url, width: 24.w, height: 24.h);
    }
    return SvgPicture.asset(url, width: 24.w, height: 24.h);
  }
}
