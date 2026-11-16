import 'package:auto_hub_app/core/constants/app_icons.dart';
import 'package:auto_hub_app/core/theme/app_colors.dart';
import 'package:auto_hub_app/core/theme/app_text_styles.dart';
import 'package:auto_hub_app/features/request_junk/domain/repositories/junk_repository.dart';
import 'package:auto_hub_app/features/request_junk/models/junk_models.dart';
import 'package:auto_hub_app/features/request_junk/widgets/junk_overview_card.dart';
import 'package:auto_hub_app/features/request_junk/widgets/pickup_details_card.dart';
import 'package:auto_hub_app/features/request_junk/widgets/salvage_yard_card.dart';
import 'package:auto_hub_app/features/request_junk/widgets/vehicle_info_card.dart';
import 'package:auto_hub_app/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Screen displaying the details of a specific junk request.
class JunkDetailPage extends StatefulWidget {
  const JunkDetailPage({
    required this.junkId,
    super.key,
  });

  final String junkId;

  @override
  State<JunkDetailPage> createState() => _JunkDetailPageState();
}

class _JunkDetailPageState extends State<JunkDetailPage> {
  JunkRequest? _request;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  Future<void> _loadRequest() async {
    setState(() => _isLoading = true);
    final repo = getIt<JunkRepository>();
    final result = await repo.getJunkRequestById(widget.junkId);
    if (mounted) {
      result.fold(
        (failure) => setState(() => _isLoading = false),
        (req) => setState(() {
          _request = req;
          _isLoading = false;
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.onboardingBackground,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.onboardingCyan,
            ),
          ),
        ),
      );
    }

    final request = _request;
    if (request == null) {
      return Scaffold(
        backgroundColor: AppColors.onboardingBackground,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, null),
              const Expanded(
                child: Center(
                  child: Text(
                    'Junk request not found.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, request),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    JunkOverviewCard(request: request),
                    SizedBox(height: 16.h),
                    VehicleInfoCard(
                      condition: request.condition,
                      notes: request.notes,
                    ),
                    if (request.status == JunkRequestStatus.pickupScheduled &&
                        request.pickupDateTime != null) ...[
                      SizedBox(height: 16.h),
                      PickupDetailsCard(
                        pickupDateTime: request.pickupDateTime!,
                        towCompany: request.towCompany ?? '',
                      ),
                    ],
                    SizedBox(height: 16.h),
                    SalvageYardCard(
                      name: request.salvageYardName,
                      phone: request.salvageYardPhone,
                    ),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(context, request),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, JunkRequest? request) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: const BoxDecoration(
        color: AppColors.onboardingBackground,
        border: Border(
          bottom: BorderSide(
            color: Color(0x12FFFFFF),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: AppColors.onboardingSurface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                AppIcons.chevronLeft,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request?.id ?? 'Junk Request',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.onboardingTextPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (request != null)
                  Text(
                    'Submitted ${request.date}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onboardingTextSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, JunkRequest request) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      decoration: const BoxDecoration(
        color: AppColors.onboardingBackground,
        border: Border(
          top: BorderSide(
            color: Color(0x12FFFFFF),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                context.push('/contact-support-chat');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(0x33FFFFFF),
                  width: 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text(
                'Contact Yard',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onboardingTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (request.status == JunkRequestStatus.offerPending) ...[
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Accept offer action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.onboardingCyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Text(
                  'Accept Offer',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
