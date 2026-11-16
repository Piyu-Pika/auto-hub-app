import 'dart:async';

import 'package:auto_hub_app/core/constants/app_icons.dart';
import 'package:auto_hub_app/core/theme/app_colors.dart';
import 'package:auto_hub_app/core/theme/app_text_styles.dart';
import 'package:auto_hub_app/core/widgets/app_image.dart';
import 'package:auto_hub_app/features/browse/domain/models/product_part_item.dart';
import 'package:auto_hub_app/features/browse/domain/repositories/browse_repository.dart';
import 'package:auto_hub_app/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class PartDetailsPage extends StatefulWidget {
  const PartDetailsPage({required this.partId, super.key});

  final String partId;

  @override
  State<PartDetailsPage> createState() => _PartDetailsPageState();
}

class _PartDetailsPageState extends State<PartDetailsPage> {
  int _currentTabIndex = 0;
  late final BrowseRepository _repository;

  Map<String, dynamic>? _detail;
  List<ProductPartItem> _similarParts = const [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _repository = getIt<BrowseRepository>();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final detail = await _repository.getPartDetail(widget.partId);
      final similar = await _repository.getSimilarParts(widget.partId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _similarParts = similar;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Map<String, dynamic> get _specs =>
      (_detail?['specifications'] as Map<String, dynamic>?) ?? {};

  Map<String, dynamic> get _yard =>
      (_detail?['yard'] as Map<String, dynamic>?) ?? {};

  double get _rating {
    final raw = _detail?['rating'];
    return (raw is num) ? raw.toDouble() : 0.0;
  }

  int get _ratingCount {
    final raw = _detail?['ratingCount'];
    return (raw is num) ? raw.toInt() : 0;
  }

  double get _price {
    final raw = _detail?['price'];
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0;
    return 0;
  }

  String get _title => _detail?['title'] as String? ?? '';
  String get _location => _detail?['location'] as String? ?? '';
  String get _partNumber => _detail?['partNumber'] as String? ?? '';
  String get _condition => _detail?['condition'] as String? ?? 'Good';
  String get _warranty => _detail?['warranty'] as String? ?? '30 Days';
  String get _category => _specs['category'] as String? ?? '';
  String get _yearRange => _specs['yearRange'] as String? ?? '';
  String get _tag => _detail?['tag'] as String? ?? '';
  String get _imageUrl => _detail?['imageUrl'] as String? ?? '';

  void _switchTab(int index) {
    if (_currentTabIndex == index) {
      return;
    }
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.onboardingBackground,
        body: SafeArea(
          bottom: false,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _hasError || _detail == null
                  ? _buildErrorState(context)
                  : _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              AppIcons.warningAmber,
              size: 48,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Could not load part details',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onboardingTextPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'This part may no longer be available. Please try again.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onboardingTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            _HeroActionButton(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              child: const Icon(AppIcons.arrowLeft, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(context),
          Transform.translate(
            offset: Offset(0, -32.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleBlock(),
                  SizedBox(height: 19.h),
                  _buildQuickFactsCard(),
                  SizedBox(height: 21.h),
                  _buildFitsCard(),
                  SizedBox(height: 19.h),
                  _DetailsToggleTab(
                    currentIndex: _currentTabIndex,
                    onSpecificationsTap: () => _switchTab(0),
                    onYardInfoTap: () => _switchTab(1),
                  ),
                  SizedBox(height: 16.h),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: _currentTabIndex == 0
                          ? _DetailsCard(
                              key: const ValueKey<String>('specifications'),
                              rows: _buildSpecRows(),
                            )
                          : _DetailsCard(
                              key: const ValueKey<String>('yard-info'),
                              rows: _buildYardRows(),
                            ),
                    ),
                  ),
                  SizedBox(height: 19.h),
                  _buildDescriptionCard(),
                  SizedBox(height: 20.h),
                  _buildSimilarPartsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_DetailsRowData> _buildSpecRows() {
    final rows = <_DetailsRowData>[
      _DetailsRowData(
        icon: AppIcons.confirmationNumber,
        label: 'Part Number',
        value: _partNumber,
      ),
      _DetailsRowData(
        icon: AppIcons.category,
        label: 'Category',
        value: _category,
      ),
      _DetailsRowData(
        icon: AppIcons.directionsCar,
        label: 'Compatible Make',
        value: _specs['compatibleMake'] as String? ?? '',
      ),
      _DetailsRowData(
        icon: AppIcons.precisionManufacturing,
        label: 'Compatible Model',
        value: _specs['compatibleModel'] as String? ?? '',
      ),
      _DetailsRowData(
        icon: AppIcons.calendarMonth,
        label: 'Year Range',
        value: _yearRange,
      ),
    ];

    final mileage = _specs['donorMileage'];
    if (mileage is String && mileage.isNotEmpty) {
      rows.add(
        _DetailsRowData(
          icon: AppIcons.speed,
          label: 'Donor Mileage',
          value: mileage,
        ),
      );
    }

    final weight = _specs['weight'];
    if (weight is String && weight.isNotEmpty) {
      rows.add(
        _DetailsRowData(
          icon: AppIcons.scale,
          label: 'Weight',
          value: weight,
        ),
      );
    }

    rows.add(
      _DetailsRowData(
        icon: AppIcons.verifiedUser,
        label: 'Warranty',
        value: _warranty,
      ),
    );

    return rows;
  }

  List<_DetailsRowData> _buildYardRows() {
    final rating = _yard['rating'];
    final ratingCount = _yard['ratingCount'];
    final ratingValue = (rating is num) ? rating.toDouble() : 0.0;
    final ratingCountValue = (ratingCount is num) ? ratingCount.toInt() : 0;
    final ratingDisplay = ratingValue > 0
        ? '${ratingValue.toStringAsFixed(1)}'
            '${ratingCountValue > 0 ? ' ($ratingCountValue)' : ''}'
        : 'Not rated';

    final pickupAvailable = _yard['pickupAvailable'] as bool? ?? true;
    final deliveryNationwide = _yard['deliveryNationwide'] as bool? ?? false;
    final isVerified = _yard['isVerified'] as bool? ?? false;

    return [
      _DetailsRowData(
        icon: AppIcons.warehouse,
        label: 'Yard Name',
        value: _yard['name'] as String? ?? '',
      ),
      _DetailsRowData(
        icon: AppIcons.starBorder,
        label: 'Yard Rating',
        value: ratingDisplay,
      ),
      _DetailsRowData(
        icon: AppIcons.locationOn,
        label: 'Address',
        value: _yard['address'] as String? ?? _location,
      ),
      _DetailsRowData(
        icon: AppIcons.call,
        label: 'Contact',
        value: _yard['phone'] as String? ?? '-',
      ),
      _DetailsRowData(
        icon: AppIcons.schedule,
        label: 'Business Hours',
        value: _yard['businessHours'] as String? ?? '-',
      ),
      _DetailsRowData(
        icon: AppIcons.localShipping,
        label: 'Pickup',
        value: pickupAvailable ? 'Available' : 'Unavailable',
      ),
      _DetailsRowData(
        icon: AppIcons.deliveryDining,
        label: 'Delivery',
        value: deliveryNationwide ? 'Nationwide' : 'Local',
      ),
      _DetailsRowData(
        icon: AppIcons.verified,
        label: 'Verified Seller',
        value: isVerified ? 'Yes' : 'No',
      ),
    ];
  }

  Widget _buildHeroSection(BuildContext context) {
    return SizedBox(
      height: 300.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppImage(
            imagePath: _imageUrl,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x59000000),
                  Color(0x00000000),
                  AppColors.onboardingBackground,
                ],
                stops: [0, 0.4, 1],
              ),
            ),
          ),
          Positioned(
            left: 16.w,
            right: 16.w,
            top: 12.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _HeroActionButton(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  child: const Icon(AppIcons.arrowLeft),
                ),
                Row(
                  children: [
                    _HeroActionButton(
                      onTap: () {},
                      child: Icon(
                        AppIcons.share,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _HeroActionButton(
                      onTap: () {},
                      child: const Icon(AppIcons.heart),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_tag.isNotEmpty)
            Positioned(
              left: 16.w,
              top: 220.h,
              child: Container(
                width: 72.w,
                height: 38.h,
                decoration: BoxDecoration(
                  color: AppColors.onboardingCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.onboardingCyan.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _tag,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onboardingCyan,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.onboardingTextPrimary,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  _MetaLine(
                    iconPath: AppIcons.mapPin,
                    text: _location,
                    textStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onboardingTextSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                  if (_partNumber.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    _MetaLine(
                      iconPath: AppIcons.tag,
                      text: _partNumber,
                      textStyle: GoogleFonts.cousine(
                        color: AppColors.textTertiary,
                        fontSize: 11.sp,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 70.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: AppColors.onboardingGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppColors.onboardingGreen.withValues(alpha: 0.14),
                  width: 0.8,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _condition,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onboardingGreen,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${_price.toStringAsFixed(0)}',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.onboardingTextPrimary,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      height: 1,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Warranty: $_warranty',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 11.sp,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            if (_rating > 0 || _ratingCount > 0)
              Container(
                width: 110.w,
                height: 42.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                    width: 0.8,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Row(
                  children: [
                    const Icon(AppIcons.star),
                    SizedBox(width: 8.w),
                    Text(
                      _rating.toStringAsFixed(1),
                      style: AppTextStyles.titleLarge.copyWith(
                        color: const Color(0xFFFBBF24),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '($_ratingCount)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickFactsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.onboardingSurfaceLight,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.8.w, vertical: 16.8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _QuickFactItem(
            icon: AppIcons.electricalServices,
            value: _category,
            label: 'Category',
          ),
          _QuickFactItem(
            icon: AppIcons.calendarToday,
            value: _yearRange,
            label: 'Years',
          ),
          _QuickFactItem(
            icon: AppIcons.shield,
            value: _warranty,
            label: 'Warranty',
          ),
        ],
      ),
    );
  }

  Widget _buildFitsCard() {
    final fitment = (_detail?['fitment'] as Map<String, dynamic>?) ?? {};
    final label = fitment['label'] as String? ?? 'Fits: $_title';
    final detail = fitment['detail'] as String? ?? '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.onboardingCyan.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.onboardingCyan.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.8.w, 13.h, 12.w, 13.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            AppIcons.directionsCar,
            size: 16.sp,
            color: AppColors.onboardingCyan,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.onboardingTextPrimary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (detail.isNotEmpty) ...[
                  SizedBox(height: 1.h),
                  Text(
                    detail,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onboardingTextSecondary,
                      fontSize: 11.sp,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    final description = _detail?['description'] as String? ?? '';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.onboardingSurfaceLight,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.onboardingTextPrimary,
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 9.h),
          Text(
            description.isEmpty ? 'No description available.' : description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onboardingTextSecondary,
              fontSize: 13.sp,
              height: 1.8,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Read more',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.onboardingCyan,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 2.w),
              const Icon(AppIcons.chevronRight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarPartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Similar Parts',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.onboardingTextPrimary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'See all',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.onboardingCyan,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (_similarParts.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.onboardingSurfaceLight,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.07),
                width: 0.8,
              ),
            ),
            child: Text(
              'No similar parts available.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onboardingTextSecondary,
              ),
            ),
          )
        else
          SizedBox(
            height: 220.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _similarParts.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final part = _similarParts[index];
                return GestureDetector(
                  onTap: () =>
                      context.push('/part-details/${part.id}'),
                  child: _SimilarPartCard(part: part),
                );
              },
            ),
          ),
        SizedBox(height: 40.h),
      ],
    );
  }
}

class _SimilarPartCard extends StatelessWidget {
  const _SimilarPartCard({required this.part});

  final ProductPartItem part;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 174.w,
      decoration: BoxDecoration(
        color: AppColors.onboardingSurfaceLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 172.w,
            height: 100.h,
            child: AppImage(
              imagePath: part.imagePath,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  part.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.onboardingTextPrimary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${part.make} ${part.model}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10.sp,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  r'$${part.price.toStringAsFixed(0)}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.onboardingCyan,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  const _HeroActionButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: AppColors.onboardingBackground.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.iconPath,
    required this.text,
    required this.textStyle,
  });

  final IconData iconPath;
  final String text;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(iconPath),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(text, style: textStyle),
        ),
      ],
    );
  }
}

class _QuickFactItem extends StatelessWidget {
  const _QuickFactItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88.w,
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.onboardingCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 16.sp,
              color: AppColors.onboardingCyan,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.onboardingTextPrimary,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsToggleTab extends StatelessWidget {
  const _DetailsToggleTab({
    required this.currentIndex,
    required this.onSpecificationsTap,
    required this.onYardInfoTap,
  });

  final int currentIndex;
  final VoidCallback onSpecificationsTap;
  final VoidCallback onYardInfoTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.onboardingSurface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(4.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 2;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: currentIndex == 0 ? 0 : tabWidth,
                width: tabWidth,
                height: constraints.maxHeight,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.onboardingCyan,
                        AppColors.onboardingCyanDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.onboardingCyan.withValues(alpha: 0.35),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onSpecificationsTap,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        alignment: Alignment.center,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: AppTextStyles.labelLarge.copyWith(
                            color: currentIndex == 0
                                ? Colors.white
                                : AppColors.textTertiary,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          child: const Text('Specifications'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: onYardInfoTap,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        alignment: Alignment.center,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: AppTextStyles.labelLarge.copyWith(
                            color: currentIndex == 1
                                ? Colors.white
                                : AppColors.textTertiary,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          child: const Text('Yard Info'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.rows, super.key});

  final List<_DetailsRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.onboardingSurfaceLight,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++)
            _DetailsInfoRow(
              row: rows[index],
              showDivider: index != rows.length - 1,
            ),
        ],
      ),
    );
  }
}

class _DetailsInfoRow extends StatelessWidget {
  const _DetailsInfoRow({required this.row, required this.showDivider});

  final _DetailsRowData row;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 0.8,
                ),
              )
            : null,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: AppColors.onboardingSurface,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  row.icon,
                  size: 13.sp,
                  color: const Color(0xFF2B3445),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                row.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onboardingTextSecondary,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
          Flexible(
            child: Text(
              row.value,
              textAlign: TextAlign.right,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.onboardingTextPrimary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsRowData {
  const _DetailsRowData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
