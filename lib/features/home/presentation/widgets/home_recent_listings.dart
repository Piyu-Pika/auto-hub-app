import 'package:auto_hub_app/features/browse/domain/models/product_part_item.dart';
import 'package:auto_hub_app/features/home/presentation/widgets/home_part_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeRecentListings extends StatelessWidget {
  const HomeRecentListings({super.key, this.parts});

  final List<ProductPartItem>? parts;

  List<PartItemData> get _items {
    if (parts != null && parts!.isNotEmpty) {
      return parts!.map((p) {
        return PartItemData(
          id: p.id,
          imagePath: p.imagePath,
          title: p.title,
          subtitle: '${p.make} ${p.model} (${p.yearRange})',
          price: '\$${p.price.toStringAsFixed(0)}',
          category: p.category,
          warranty: p.warranty,
          location: p.location,
          rating: p.rating,
          badge: p.tag == 'Featured'
              ? PartBadgeType.featured
              : PartBadgeType.none,
          condition: p.condition.toLowerCase().contains('excellent')
              ? PartCondition.excellent
              : PartCondition.good,
        );
      }).toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
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
                child: Row(
                  children: [
                    Container(
                      width: 28.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0DA0CE).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/icons/ic_sparkles.svg',
                        width: 14.w,
                        height: 14.h,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF0DA0CE),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Listings',
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF0F6FC),
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Fresh parts added today',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF8B929A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => context.push('/browse'),
                child: Row(
                  children: [
                    Text(
                      'View all',
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
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Vertical list of cards
        Column(
          children: items.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: HomePartCardVertical(
                item: item,
                onTap: () => context.push('/part-details/${item.id}'),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
