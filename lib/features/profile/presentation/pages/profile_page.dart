import 'dart:async';

import 'package:auto_hub_app/core/constants/app_icons.dart';
import 'package:auto_hub_app/core/theme/app_colors.dart';
import 'package:auto_hub_app/core/theme/app_text_styles.dart';
import 'package:auto_hub_app/features/account_details/data/repositories/account_repository.dart';
import 'package:auto_hub_app/features/account_details/domain/models/user_profile.dart';
import 'package:auto_hub_app/features/profile/presentation/models/profile_menu_models.dart';
import 'package:auto_hub_app/features/profile/presentation/widgets/profile_menu_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_loadProfile());
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profile = await AccountRepository().getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<ProfileMenuSectionData> _buildSections(
    BuildContext context,
    VoidCallback onMenuTap,
  ) {
    return [
      ProfileMenuSectionData(
        title: 'MY ACTIVITY',
        items: [
          ProfileMenuItemData(
            title: 'My Orders',
            iconPath: AppIcons.profileActivity,
            iconBackgroundColor: const Color(0x1F0DA0CE),
            onTap: () => context.push('/my-orders'),
          ),
          ProfileMenuItemData(
            title: 'Saved Parts',
            iconPath: AppIcons.profileHeart,
            iconBackgroundColor: const Color(0x1FA78BFA),
            onTap: onMenuTap,
          ),
          ProfileMenuItemData(
            title: 'My Junk Requests',
            iconPath: AppIcons.profileCard,
            iconBackgroundColor: const Color(0x1F34D399),
            onTap: () => context.pushNamed('my-request-junk'),
          ),
          ProfileMenuItemData(
            title: 'Messages',
            iconPath: AppIcons.profileChat,
            iconBackgroundColor: const Color(0x1FFBBF24),
            onTap: () => context.push('/live-chats'),
          ),
        ],
      ),
      ProfileMenuSectionData(
        title: 'ACCOUNT INFO',
        items: [
          ProfileMenuItemData(
            title: 'Account Details',
            iconPath: AppIcons.profileActivity,
            iconBackgroundColor: const Color(0x1F0DA0CE),
            onTap: () => context.push('/account-details'),
          ),
          ProfileMenuItemData(
            title: 'Your Addresses',
            iconPath: AppIcons.profileHeart,
            iconBackgroundColor: const Color(0x1FA78BFA),
            onTap: () => context.push('/your-addresses'),
          ),
          ProfileMenuItemData(
            title: 'Payment Methods',
            iconPath: AppIcons.profileCard,
            iconBackgroundColor: const Color(0x1F34D399),
            onTap: () => context.pushNamed('payment-methods'),
          ),
          ProfileMenuItemData(
            title: 'Settings',
            iconPath: AppIcons.profileSettings,
            iconBackgroundColor: const Color(0x1A8B929A),
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
      ProfileMenuSectionData(
        title: 'SUPPORT',
        items: [
          ProfileMenuItemData(
            title: 'Help Center',
            iconPath: AppIcons.profileHelp,
            iconBackgroundColor: const Color(0x1F60A5FA),
            onTap: () => context.pushNamed('help-center'),
          ),
          ProfileMenuItemData(
            title: 'Contact Support',
            iconPath: AppIcons.profileChat,
            iconBackgroundColor: const Color(0x1FFBBF24),
            onTap: () => context.pushNamed('contact-support'),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections(context, () {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('This section is coming soon')),
        );
    });

    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              onBackTap: () {
                if (context.canPop()) {
                  context.pop();
                }
              },
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.onboardingCyan,
                      ),
                    )
                  : _error != null
                  ? _ErrorState(
                      message: _error!,
                      onRetry: _loadProfile,
                    )
                  : _userProfile == null
                  ? const _EmptyState()
                  : SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 24.h),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: [
                            SizedBox(height: 18.h),
                            _ProfileIdentityHeader(
                              name: _userProfile!.fullName,
                              initials: _userProfile!.initials,
                              isVerified: _userProfile!.isVerified,
                            ),
                            SizedBox(height: 27.h),
                            for (var index = 0;
                                index < sections.length;
                                index++)
                              Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: ProfileMenuSectionCard(
                                  section: sections[index],
                                ),
                              ),
                            _SignOutButton(
                              onTap: () {
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Sign out action coming soon',
                                      ),
                                    ),
                                  );
                              },
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'AutoHub Express v2.4.1 · Salvage & Parts',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF2D333B),
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Profile',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.onboardingTextPrimary,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: AppColors.onboardingSurface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                  width: 0.8,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                AppIcons.profileEdit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileIdentityHeader extends StatelessWidget {
  const _ProfileIdentityHeader({
    required this.name,
    required this.initials,
    required this.isVerified,
  });

  final String name;
  final String initials;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 72.w,
          height: 64.h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 64.w,
                  height: 64.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.onboardingCyan,
                        AppColors.onboardingCyanDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.onboardingSurface,
                      width: 2.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.onboardingCyan.withValues(alpha: 0.4),
                        blurRadius: 16.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 4.w,
                bottom: -4.h,
                child: Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: isVerified
                        ? AppColors.onboardingGreen
                        : AppColors.onboardingTextSecondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.onboardingSurface,
                      width: 1.6,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: const BoxDecoration(
                      color: AppColors.onboardingBackground,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          name,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.onboardingTextPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 20.h,
          padding: EdgeInsets.fromLTRB(10.w, 0.6.h, 10.w, 0.6.h),
          decoration: BoxDecoration(
            color: AppColors.onboardingGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.5.r),
            border: Border.all(
              color: AppColors.onboardingGreen.withValues(alpha: 0.2),
              width: 0.6,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.profileVerified,
                size: 10.sp,
                color: isVerified
                    ? AppColors.onboardingGreen
                    : AppColors.onboardingTextSecondary,
              ),
              SizedBox(width: 4.5.w),
              Text(
                isVerified ? 'VERIFIED' : 'UNVERIFIED',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isVerified
                      ? AppColors.onboardingGreen
                      : AppColors.onboardingTextSecondary,
                  fontSize: 7.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          width: double.infinity,
          height: 54.6.h,
          decoration: BoxDecoration(
            color: AppColors.onboardingCyan.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: AppColors.onboardingCyan.withValues(alpha: 0.14),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                AppIcons.profileLogout,
              ),
              SizedBox(width: 10.w),
              Text(
                'Sign Out',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.onboardingCyan,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.profileHelp,
              color: AppColors.error,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load profile',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.onboardingTextPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onboardingTextSecondary,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.onboardingCyan,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Retry',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.profileActivity,
              color: AppColors.onboardingTextSecondary,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'No profile data available',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.onboardingTextPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Please try again later or contact support.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onboardingTextSecondary,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
