import 'package:auto_hub_app/features/home/presentation/bloc/home_cubit.dart';
import 'package:auto_hub_app/features/home/presentation/bloc/home_state.dart';
import 'package:auto_hub_app/features/home/presentation/widgets/hitech_insurance_widget.dart';
import 'package:auto_hub_app/features/home/presentation/widgets/home_app_bar.dart';
import 'package:auto_hub_app/features/home/presentation/widgets/home_category_section.dart';
import 'package:auto_hub_app/features/home/presentation/widgets/home_featured_parts.dart';
import 'package:auto_hub_app/features/home/presentation/widgets/home_hero_banner.dart';
import 'package:auto_hub_app/features/home/presentation/widgets/home_junk_car_banner.dart';
import 'package:auto_hub_app/features/home/presentation/widgets/home_recent_listings.dart';
import 'package:auto_hub_app/features/home/presentation/widgets/home_search_bar.dart';
import 'package:auto_hub_app/features/home/presentation/widgets/home_stats_row.dart';
import 'package:auto_hub_app/features/home/presentation/widgets/home_trust_strip.dart';
import 'package:auto_hub_app/features/home/presentation/widgets/home_vin_lookup.dart';
import 'package:auto_hub_app/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>()..loadFeed(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: const Color(0xFF0D1117),
          body: SafeArea(
            bottom: false,
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                final feed = state is HomeLoaded ? state.feed : null;

                return Column(
                  children: [
                    const HomeAppBar(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () =>
                            context.read<HomeCubit>().loadFeed(isRefresh: true),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16.h),

                              // Search bar
                              const HomeSearchBar(),

                              SizedBox(height: 16.h),

                              // Hero banner
                              HomeHeroBanner(imageUrl: feed?.hero?.imageUrl),

                              SizedBox(height: 16.h),

                              // HiTech Insurance Banner
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: const HiTechInsuranceWidget(),
                              ),

                              SizedBox(height: 20.h),

                              // Dynamic Stats row
                              HomeStatsRow(stats: feed?.stats),

                              SizedBox(height: 20.h),

                              // Browse by Category
                              const HomeCategorySection(),

                              SizedBox(height: 15.h),

                              // VIN Parts Lookup
                              const HomeVinLookup(),

                              SizedBox(height: 28.h),

                              // Dynamic Featured Parts
                              HomeFeaturedParts(parts: feed?.featured),

                              SizedBox(height: 24.h),

                              // Dynamic Recent Listings
                              HomeRecentListings(parts: feed?.recent),

                              SizedBox(height: 20.h),

                              // Junk Your Car CTA
                              const HomeJunkCarBanner(),

                              SizedBox(height: 24.h),

                              // Trust strip
                              const HomeTrustStrip(),

                              SizedBox(height: 40.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
