import 'package:auto_hub_app/core/theme/app_colors.dart';
import 'package:auto_hub_app/features/browse/data/datasources/browse_remote_datasource.dart';
import 'package:auto_hub_app/features/browse/domain/models/product_part_item.dart';
import 'package:auto_hub_app/features/browse/presentation/widgets/product_card.dart';
import 'package:auto_hub_app/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({required this.onBrowseTap, super.key});

  final VoidCallback onBrowseTap;

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  List<ProductPartItem> _savedParts = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSavedParts();
  }

  Future<void> _fetchSavedParts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final datasource = getIt<BrowseRemoteDatasource>();
      final items = await datasource.getSavedParts();
      if (mounted) {
        setState(() {
          _savedParts = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load saved parts. Please try again.';
        });
      }
    }
  }

  Future<void> _removeSaved(String id) async {
    try {
      final datasource = getIt<BrowseRemoteDatasource>();
      await datasource.removeSavedPart(id);
      setState(() {
        _savedParts.removeWhere((p) => p.id == id);
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0D1117),
                    Color(0xFF0B1016),
                    Color(0xFF070E17),
                  ],
                  stops: [0, 0.55, 1],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Container(
                  height: 76.h,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF161B22),
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0x0FFFFFFF),
                        width: 0.8,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0.8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My wishlist',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Text(
                            'Saved Parts',
                            style: GoogleFonts.inter(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF0F6FC),
                              height: 1.5,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      if (_savedParts.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.accentCyan.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.accentCyan.withValues(alpha: 0.2),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '${_savedParts.length} items',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentCyan,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accentCyan,
                          ),
                        )
                      : _savedParts.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _fetchSavedParts,
                              color: AppColors.accentCyan,
                              child: ListView.builder(
                                padding: EdgeInsets.all(16.w),
                                itemCount: _savedParts.length,
                                itemBuilder: (context, index) {
                                  final part = _savedParts[index];
                                  return ProductCard(
                                    part: part,
                                    onTap: () =>
                                        context.push('/part-details/${part.id}'),
                                    onFavoriteTap: () => _removeSaved(part.id),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: 480.h,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned(
              top: 70.h,
              left: 124.w,
              child: SizedBox(
                width: 112.w,
                height: 112.h,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 112.w,
                      height: 112.h,
                      decoration: BoxDecoration(
                        color: const Color(0x0F0DA0CE),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: const Color(0x1F0DA0CE),
                          width: 0.8,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x140DA0CE),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/icons/ic_saved_heart_empty.svg',
                        width: 50.w,
                        height: 50.h,
                      ),
                    ),
                    Positioned(
                      right: -8.w,
                      top: -8.h,
                      child: Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: const Color(0x0D0DA0CE),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0x1A0DA0CE),
                            width: 0.8,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -8.w,
                      bottom: -8.h,
                      child: Container(
                        width: 20.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: const Color(0x0A0DA0CE),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0x140DA0CE),
                            width: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 206.2.h,
              left: 0,
              right: 0,
              child: Text(
                'No saved parts yet',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFF0F6FC),
                  height: 1.5,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Positioned(
              top: 247.2.h,
              left: 62.w,
              right: 62.w,
              child: Text(
                'Tap the ♥ on any part listing to\nsave it to your wishlist',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8B929A),
                  height: 1.7,
                ),
              ),
            ),
            Positioned(
              top: 316.2.h,
              left: 83.w,
              child: GestureDetector(
                onTap: widget.onBrowseTap,
                child: Container(
                  width: 194.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    gradient: const LinearGradient(
                      begin: Alignment(-0.62, -1.0),
                      end: Alignment(0.62, 1.0),
                      colors: [
                        Color(0xFF0DA0CE),
                        Color(0xFF0B8FB5),
                      ],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x660DA0CE),
                        blurRadius: 24,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/ic_saved_wrench.svg',
                        width: 16.w,
                        height: 16.h,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Browse Parts',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      SvgPicture.asset(
                        'assets/icons/ic_saved_arrow_right.svg',
                        width: 16.w,
                        height: 16.h,
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
