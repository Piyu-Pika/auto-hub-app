import 'dart:async';

import 'package:auto_hub_app/core/theme/app_colors.dart';
import 'package:auto_hub_app/core/theme/app_text_styles.dart';
import 'package:auto_hub_app/features/request_junk/domain/repositories/junk_repository.dart';
import 'package:auto_hub_app/features/request_junk/widgets/junk_request_stepper.dart';
import 'package:auto_hub_app/features/request_junk/widgets/step_indigator.dart';
import 'package:auto_hub_app/features/request_junk/widgets/step_pickup_schedule.dart';
import 'package:auto_hub_app/features/request_junk/widgets/step_vehicle_condition.dart';
import 'package:auto_hub_app/features/request_junk/widgets/step_vehicle_info.dart';
import 'package:auto_hub_app/features/request_junk/widgets/top_toast.dart';
import 'package:auto_hub_app/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Screen for creating a new junk car request.
class NewJunkRequest extends StatefulWidget {
  /// Creates the [NewJunkRequest] page.
  const NewJunkRequest({super.key});

  @override
  State<NewJunkRequest> createState() => _NewJunkRequestState();
}

class _NewJunkRequestState extends State<NewJunkRequest> {
  int _currentStep = 1;
  final int _totalSteps = 3;
  bool _isSubmitting = false;

  // Step 1 controllers
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _vinController = TextEditingController();

  // Step 2 values
  String _selectedCondition = 'Running – Good condition';
  bool _hasTitle = false;
  bool _hasKeys = true;

  // Step 3 controllers & values
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final List<String> _selectedImages = [];
  int? _estimatedOffer;

  @override
  void dispose() {
    _yearController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _vinController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isStep1Valid {
    return _yearController.text.trim().isNotEmpty &&
        _makeController.text.trim().isNotEmpty &&
        _modelController.text.trim().isNotEmpty;
  }

  bool get _isStep3Valid {
    return _addressController.text.trim().isNotEmpty;
  }

  bool get _isCurrentStepValid {
    switch (_currentStep) {
      case 1:
        return _isStep1Valid;
      case 2:
        return true; // Condition selecting step is always valid
      case 3:
        return _isStep3Valid;
      default:
        return false;
    }
  }

  void _onStepChanged() {
    setState(() {});
  }

  void _handleNext() {
    if (!_isCurrentStepValid) return;

    if (_currentStep < _totalSteps) {
      if (_currentStep == 2) {
        unawaited(_fetchInstantQuote());
      }
      setState(() {
        _currentStep++;
      });
    } else {
      unawaited(_handleSubmit());
    }
  }

  Future<void> _fetchInstantQuote() async {
    try {
      final repo = getIt<JunkRepository>();
      final result = await repo.getInstantQuote(
        year: _yearController.text.trim(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        condition: _selectedCondition,
        hasTitle: _hasTitle,
        hasKeys: _hasKeys,
        vin: _vinController.text.trim().isEmpty
            ? null
            : _vinController.text.trim(),
      );

      if (mounted) {
        result.fold(
          (_) => null,
          (data) {
            final offer = data['estimatedOffer'];
            if (offer is int) {
              setState(() => _estimatedOffer = offer);
            } else if (offer is num) {
              setState(() => _estimatedOffer = offer.toInt());
            }
          },
        );
      }
    } catch (_) {
      // Ignore quote fetch errors so user can still proceed with submission
    }
  }

  void _handleBack() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting || !_isStep3Valid) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repo = getIt<JunkRepository>();

      List<String>? imageUrls;
      if (_selectedImages.isNotEmpty) {
        final uploadResult = await repo.uploadVehicleImages(_selectedImages);
        uploadResult.fold(
          (_) => null,
          (urls) {
            imageUrls = urls;
          },
        );
      }

      final result = await repo.createJunkRequest(
        year: _yearController.text.trim(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        condition: _selectedCondition,
        hasTitle: _hasTitle,
        hasKeys: _hasKeys,
        pickupAddress: _addressController.text.trim(),
        vin: _vinController.text.trim().isEmpty
            ? null
            : _vinController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        imageUrls: imageUrls,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _isSubmitting = false;
          });
          TopToast.show(
            context,
            failure.message.isNotEmpty
                ? failure.message
                : 'Failed to submit junk request. Please try again.',
          );
        },
        (createdRequest) {
          setState(() {
            _isSubmitting = false;
          });
          TopToast.show(
            context,
            "Junk request submitted! You'll receive an offer shortly.",
          );

          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/my-request-junk');
              }
            }
          });
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        TopToast.show(
          context,
          'An unexpected error occurred. Please try again.',
        );
      }
    }
  }

  String get _combinedVehicleTitle {
    final year = _yearController.text.trim();
    final make = _makeController.text.trim();
    final model = _modelController.text.trim();
    if (year.isEmpty && make.isEmpty && model.isEmpty) return '';
    return '$year $make $model'.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      body: SafeArea(
        child: Column(
          children: [
            JunkRequestStepper(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              onBack: () {
                if (_currentStep > 1) {
                  setState(() {
                    _currentStep--;
                  });
                } else {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/my-request-junk');
                  }
                }
              },
            ),
            StepIndicator(
              currentStep: _currentStep - 1,
              steps: const ['Vehicle', 'Condition', 'Pickup'],
              activeColor: AppColors.onboardingCyan,
              inactiveColor: Colors.white.withValues(alpha: 0.08),
              inactiveTextColor: AppColors.onboardingTextSecondary,
              activeTextColor: AppColors.onboardingCyan,
              surfaceColor: AppColors.onboardingSurface,
              completedColor: AppColors.onboardingGreen,
            ),
            Expanded(
              child: _buildCurrentStepWidget(),
            ),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case 1:
        return StepVehicleInfo(
          yearController: _yearController,
          makeController: _makeController,
          modelController: _modelController,
          vinController: _vinController,
          onChanged: _onStepChanged,
        );
      case 2:
        return StepVehicleCondition(
          selectedCondition: _selectedCondition,
          onConditionChanged: (condition) {
            setState(() {
              _selectedCondition = condition;
            });
          },
          hasTitle: _hasTitle,
          onHasTitleChanged: (val) {
            setState(() {
              _hasTitle = val;
            });
          },
          hasKeys: _hasKeys,
          onHasKeysChanged: (val) {
            setState(() {
              _hasKeys = val;
            });
          },
        );
      case 3:
        return StepPickupSchedule(
          addressController: _addressController,
          notesController: _notesController,
          onChanged: _onStepChanged,
          vehicleTitle: _combinedVehicleTitle,
          condition: _selectedCondition,
          selectedImages: _selectedImages,
          estimatedOffer: _estimatedOffer,
          onImagesChanged: (images) {
            setState(() {
              _selectedImages.clear();
              _selectedImages.addAll(images);
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomActionBar() {
    final isValid = _isCurrentStepValid && !_isSubmitting;
    final showBack = _currentStep > 1 && !_isSubmitting;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: const BoxDecoration(
        color: AppColors.onboardingBackground,
      ),
      child: Row(
        children: [
          if (showBack) ...[
            Expanded(
              child: _buildButton(
                label: 'Back',
                onTap: _handleBack,
                isPrimary: false,
              ),
            ),
            SizedBox(width: 16.w),
          ],
          Expanded(
            child: _buildButton(
              label: _currentStep == _totalSteps ? 'Submit Request' : 'Continue',
              onTap: isValid ? _handleNext : null,
              isPrimary: true,
              isLoading: _isSubmitting,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback? onTap,
    required bool isPrimary,
    bool isLoading = false,
  }) {
    final isEnabled = onTap != null && !isLoading;

    if (!isPrimary) {
      // Back button styling
      return Container(
        height: 54.h,
        decoration: BoxDecoration(
          color: AppColors.onboardingSurface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16.r),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.button.copyWith(
                  color: AppColors.onboardingTextPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Continue / Submit button styling
    return Container(
      height: 54.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: isEnabled
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.onboardingCyan,
                  AppColors.onboardingCyanDark,
                ],
              )
            : null,
        color: isEnabled ? null : Colors.white.withValues(alpha: 0.06),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: AppTextStyles.button.copyWith(
                      color: isEnabled
                          ? Colors.white
                          : AppColors.onboardingTextSecondary
                              .withValues(alpha: 0.5),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
