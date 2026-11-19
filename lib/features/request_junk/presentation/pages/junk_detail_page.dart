import 'package:auto_hub_app/core/constants/app_icons.dart';
import 'package:auto_hub_app/core/theme/app_colors.dart';
import 'package:auto_hub_app/core/theme/app_text_styles.dart';
import 'package:auto_hub_app/features/request_junk/domain/repositories/junk_repository.dart';
import 'package:auto_hub_app/features/request_junk/models/junk_models.dart';
import 'package:auto_hub_app/features/request_junk/widgets/junk_overview_card.dart';
import 'package:auto_hub_app/features/request_junk/widgets/pickup_details_card.dart';
import 'package:auto_hub_app/features/request_junk/widgets/salvage_yard_card.dart';
import 'package:auto_hub_app/features/request_junk/widgets/top_toast.dart';
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
  bool _isActionLoading = false;

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

  Future<void> _handleAcceptOffer(JunkRequest request) async {
    final offer = request.offerAmount;
    if (offer == null || _isActionLoading) return;

    setState(() => _isActionLoading = true);
    final repo = getIt<JunkRepository>();
    final result = await repo.acceptOffer(request.id, offerAmount: offer);

    if (!mounted) return;
    setState(() => _isActionLoading = false);

    result.fold(
      (failure) {
        TopToast.show(
          context,
          failure.message.isNotEmpty
              ? failure.message
              : 'Failed to accept offer. Please try again.',
        );
      },
      (updatedRequest) {
        setState(() {
          _request = updatedRequest;
        });
        TopToast.show(
          context,
          'Offer accepted! You can now arrange pickup.',
        );
      },
    );
  }

  Future<void> _handleCancelRequest(JunkRequest request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.onboardingSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Cancel Junk Request',
          style: AppTextStyles.headlineSmall.copyWith(
            color: Colors.white,
            fontSize: 18.sp,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this junk car request?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onboardingTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'No, Keep It',
              style: TextStyle(color: Colors.white70, fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isActionLoading = true);
    final repo = getIt<JunkRepository>();
    final result = await repo.cancelJunkRequest(
      request.id,
      reason: 'Cancelled by customer',
    );

    if (!mounted) return;
    setState(() => _isActionLoading = false);

    result.fold(
      (failure) {
        TopToast.show(
          context,
          failure.message.isNotEmpty
              ? failure.message
              : 'Failed to cancel request.',
        );
      },
      (updatedRequest) {
        setState(() {
          _request = updatedRequest;
        });
        TopToast.show(context, 'Junk request cancelled.');
      },
    );
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
                    SizedBox(height: 32.h),
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
    final canCancel = request != null &&
        (request.status == JunkRequestStatus.offerPending ||
            request.status == JunkRequestStatus.pickupScheduled);

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
          if (canCancel)
            IconButton(
              icon: Icon(
                Icons.cancel_outlined,
                color: Colors.white60,
                size: 22.r,
              ),
              tooltip: 'Cancel Request',
              onPressed: _isActionLoading
                  ? null
                  : () => _handleCancelRequest(request),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, JunkRequest request) {
    final hasPendingOffer = request.status == JunkRequestStatus.offerPending &&
        request.offerAmount != null;

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
          if (hasPendingOffer) ...[
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _isActionLoading
                    ? null
                    : () => _handleAcceptOffer(request),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.onboardingCyan,
                  disabledBackgroundColor:
                      AppColors.onboardingCyan.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: _isActionLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
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
