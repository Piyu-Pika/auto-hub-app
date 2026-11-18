import 'dart:async';

import 'package:auto_hub_app/core/theme/app_colors.dart';
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
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<HomeCubit>();
        unawaited(cubit.loadFeed());
        return cubit;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: const Color(0xFF0D1117),
          body: SafeArea(
            bottom: false,
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.onboardingCyan,
                      strokeWidth: 3,
                    ),
                  );
                }

                if (state is HomeError) {
                  return _HomeErrorView(
                    message: state.message,
                    onRetry: () =>
                        unawaited(context.read<HomeCubit>().loadFeed()),
                  );
                }

                if (state is HomeEmpty) {
                  return _HomeEmptyView(
                    onRetry: () =>
                        unawaited(context.read<HomeCubit>().loadFeed()),
                  );
                }

                final feed = state is HomeLoaded ? state.feed : null;

                return Column(
                  children: [
                    const HomeAppBar(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => context
                            .read<HomeCubit>()
                            .loadFeed(isRefresh: true),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16.h),

                              // Search bar
                              HomeSearchBar(
                                onSubmitted: (query) {
                                  if (query.trim().isEmpty) return;
                                  unawaited(context.push('/browse'));
                                },
                              ),

                              SizedBox(height: 16.h),

                              // Hero banner
                              HomeHeroBanner(hero: feed?.hero),

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
                              HomeCategorySection(
                                categories: feed?.categories,
                              ),

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
                              HomeJunkCarBanner(
                                junkBanner: feed?.junkBanner,
                              ),

                              SizedBox(height: 24.h),

                              // Trust strip
                              HomeTrustStrip(
                                trustItems: feed?.trustItems,
                              ),

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

class _HomeErrorView extends StatelessWidget {
  const _HomeErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.onboardingCyan,
              size: 48,
            ),
            SizedBox(height: 16.h),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: AppColors.onboardingTextPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onboardingTextSecondary,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.onboardingCyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeEmptyView extends StatelessWidget {
  const _HomeEmptyView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: AppColors.onboardingCyan,
              size: 48,
            ),
            SizedBox(height: 16.h),
            Text(
              'No listings yet',
              style: TextStyle(
                color: AppColors.onboardingTextPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Check back soon for fresh parts and deals.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onboardingTextSecondary,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.onboardingCyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
