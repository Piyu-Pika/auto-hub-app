import 'package:auto_hub_app/features/browse/domain/models/product_part_item.dart';
import 'package:auto_hub_app/features/home/presentation/widgets/home_part_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeFeaturedParts extends StatelessWidget {
  const HomeFeaturedParts({super.key, this.parts});

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Featured Parts',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFF0F6FC),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Hand-picked quality parts from verified yards',
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
        // Horizontal list
        SizedBox(
          height: 256.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => SizedBox(width: 14.w),
            itemBuilder: (context, index) {
              final item = items[index];
              return HomePartCardHorizontal(
                item: item,
                onTap: () => context.push('/part-details/${item.id}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
