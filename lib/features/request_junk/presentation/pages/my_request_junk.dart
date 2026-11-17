import 'package:auto_hub_app/core/constants/app_icons.dart';
import 'package:auto_hub_app/core/theme/app_colors.dart';
import 'package:auto_hub_app/core/theme/app_text_styles.dart';
import 'package:auto_hub_app/features/request_junk/domain/repositories/junk_repository.dart';
import 'package:auto_hub_app/features/request_junk/models/junk_models.dart';
import 'package:auto_hub_app/features/request_junk/widgets/empty_requests_state.dart';
import 'package:auto_hub_app/features/request_junk/widgets/filter_tabs.dart';
import 'package:auto_hub_app/features/request_junk/widgets/request_item_card.dart';
import 'package:auto_hub_app/features/request_junk/widgets/start_new_request_button.dart';
import 'package:auto_hub_app/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Page displaying the user's junk requests.
class MyRequestJunk extends StatefulWidget {
  /// Creates the MyRequestJunk page.
  const MyRequestJunk({super.key});

  @override
  State<MyRequestJunk> createState() => _MyRequestJunkState();
}

class _MyRequestJunkState extends State<MyRequestJunk> {
  String _selectedTab = 'All';
  List<JunkRequest> _allRequests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repo = getIt<JunkRepository>();
      final result = await repo.getJunkRequests();
      if (mounted) {
        result.fold(
          (failure) => setState(() {
            _allRequests = [];
            _isLoading = false;
            _errorMessage = 'Failed to load requests. Please try again.';
          }),
          (requests) => setState(() {
            _allRequests = requests;
            _isLoading = false;
          }),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load requests. Please try again.';
        });
      }
    }
  }
     

  List<JunkRequest> get _filteredRequests {
    if (_selectedTab == 'All') {
      return _allRequests;
    } else if (_selectedTab == 'Active') {
      return _allRequests
          .where(
            (r) =>
                r.status == JunkRequestStatus.pickupScheduled ||
                r.status == JunkRequestStatus.offerPending,
          )
          .toList();
    } else if (_selectedTab == 'Completed') {
      return _allRequests
          .where((r) => r.status == JunkRequestStatus.completed)
          .toList();
    } else if (_selectedTab == 'Cancelled') {
      return _allRequests
          .where((r) => r.status == JunkRequestStatus.cancelled)
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final requests = _filteredRequests;

    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(context),
            SizedBox(height: 16.h),
            FilterTabs(
              tabs: const ['All', 'Active', 'Completed', 'Cancelled'],
              selectedTab: _selectedTab,
              onTabSelected: (tab) {
                setState(() {
                  _selectedTab = tab;
                });
              },
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: Stack(
                children: [
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.onboardingCyan,
                        ),
                      ),
                    )
                  else if (_errorMessage != null)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80.w,
                            height: 80.h,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 32.sp,
                              color: AppColors.error,
                            ),
                          ),
                          SizedBox(height: 18.h),
                          Text(
                            'Something went wrong',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.onboardingTextPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _errorMessage ?? 'Failed to load requests. Please try again.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.onboardingTextSecondary,
                              fontSize: 13.sp,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          ElevatedButton(
                            onPressed: _loadRequests,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.onboardingCyan,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else if (requests.isEmpty)
                    const EmptyRequestsState()
                  else
                    _buildRequestsList(requests),
                  StartNewRequestButton(
                    onTap: () {
                      context.push('/new-junk-request');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: AppColors.onboardingSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1.0,
                ),
              ),
              child: const Icon(
                AppIcons.chevronLeft,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            'My Junk Requests',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.onboardingTextPrimary,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(List<JunkRequest> requests) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
            child: Text(
              '${requests.length} ${requests.length == 1 ? 'REQUEST' : 'REQUESTS'}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onboardingTextSecondary,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.onboardingSurface,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
                width: 1.0,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withValues(alpha: 0.06),
                height: 1.h,
              ),
              itemBuilder: (context, index) {
                final request = requests[index];
                return RequestItemCard(
                  request: request,
                  onTap: () {
                    context.push('/my-request-junk/junk?junk=${request.id}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}