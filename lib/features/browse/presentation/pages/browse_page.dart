import 'dart:async';

import 'package:auto_hub_app/core/theme/app_colors.dart';
import 'package:auto_hub_app/features/browse/domain/models/product_part_item.dart';
import 'package:auto_hub_app/features/browse/domain/repositories/browse_repository.dart';
import 'package:auto_hub_app/features/browse/presentation/widgets/browse_parts_header.dart';
import 'package:auto_hub_app/features/browse/presentation/widgets/empty_parts_view.dart';
import 'package:auto_hub_app/features/browse/presentation/widgets/filter_bottom_sheet.dart';
import 'package:auto_hub_app/features/browse/presentation/widgets/product_card.dart';
import 'package:auto_hub_app/features/browse/presentation/widgets/search_inputs.dart';
import 'package:auto_hub_app/features/browse/presentation/widgets/search_type_toggle.dart';
import 'package:auto_hub_app/features/browse/presentation/widgets/sort_chips_row.dart';
import 'package:auto_hub_app/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  // ── Constants ──────────────────────────────────────────────────────────
  static const int _pageSize = 20;
  static const double _defaultMaxPrice = 2000.0;
  static const double _scrollLoadThreshold = 250.0;
  static const Duration _debounceDuration = Duration(milliseconds: 350);

  // State variables
  SearchType _searchType = SearchType.part;
  SortType _sortType = SortType.newest;
  final TextEditingController _partController = TextEditingController();
  final TextEditingController _vinController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  // Filters State
  List<String> _selectedMakes = ['All Makes'];
  List<String> _selectedCategories = ['All Categories'];
  List<String> _selectedConditions = ['All'];
  double _maxPrice = _defaultMaxPrice;

  // Repository & State
  late final BrowseRepository _repository;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;

  List<ProductPartItem> _parts = [];
  int _totalCount = 0; // To keep track of listed count
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = getIt<BrowseRepository>();
    _scrollController.addListener(_onScroll);
    unawaited(_loadInitialCount());
    unawaited(_fetchParts());

    _partController.addListener(_onPartSearchChanged);
    _vinController.addListener(_onVinSearchChanged);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger load more when threshold before reaching the bottom
    if (currentScroll >= (maxScroll - _scrollLoadThreshold) &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMore) {
      unawaited(_loadMoreParts());
    }
  }

  Future<void> _loadInitialCount() async {
    try {
      final totalCount = await _repository.countParts();
      if (mounted) {
        setState(() {
          _totalCount = totalCount;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load catalog count.';
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounceTimer?.cancel();
    _partController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  void _onPartSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted) {
        unawaited(_fetchParts().catchError((e) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Search failed. Please try again.';
            });
          }
        }));
      }
    });
  }

  void _onVinSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted) {
        unawaited(_fetchParts().catchError((e) {
          if (mounted) {
            setState(() {
              _errorMessage = 'VIN lookup failed. Please try again.';
            });
          }
        }));
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedMakes = ['All Makes'];
      _selectedCategories = ['All Categories'];
      _selectedConditions = ['All'];
      _maxPrice = _defaultMaxPrice;
      _partController.clear();
      _vinController.clear();
      _errorMessage = null;
    });
    unawaited(_fetchParts().catchError((e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to clear filters.';
        });
      }
    }));
  }

  bool _areFiltersApplied() {
    final makesApplied =
        _selectedMakes.isNotEmpty && !_selectedMakes.contains('All Makes');
    final catsApplied =
        _selectedCategories.isNotEmpty &&
        !_selectedCategories.contains('All Categories');
    final condsApplied =
        _selectedConditions.isNotEmpty && !_selectedConditions.contains('All');
    final priceApplied = _maxPrice < _defaultMaxPrice;
    final queryApplied = _partController.text.isNotEmpty;
    return makesApplied ||
        catsApplied ||
        condsApplied ||
        priceApplied ||
        queryApplied;
  }

  Future<int> _calculateResultsCount(
    List<String> makes,
    List<String> categories,
    List<String> conditions,
    double maxPrice,
  ) async {
    return await _repository.countParts(
      query: _partController.text.trim(),
      makes: makes,
      categories: categories,
      conditions: conditions,
      maxPrice: maxPrice,
    );
  }

  List<ProductPartItem> _getSortedParts(List<ProductPartItem> list) {
    final sorted = List<ProductPartItem>.from(list);
    switch (_sortType) {
      case SortType.priceAsc:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case SortType.priceDesc:
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case SortType.topRated:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
      case SortType.newest:
        // Already sorted by newest first (repository default)
        break;
    }
    return sorted;
  }

  bool _isValidVIN(String vin) {
    return vin.length == 17 &&
        RegExp(r'^[A-HJ-NPR-Za-hj-npr-z0-9]{17}$').hasMatch(vin);
  }

  Future<void> _fetchParts({bool reset = true}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _hasMore = true;
        _errorMessage = null;
      });
    }

    var results = <ProductPartItem>[];
    try {
      if (_searchType == SearchType.vin) {
        final vinText = _vinController.text.trim();
        if (!_isValidVIN(vinText)) {
          if (mounted) {
            setState(() {
              _parts = [];
              _hasMore = false;
              _isLoading = false;
              _errorMessage = null;
            });
          }
          return;
        }
        results = await _repository.searchByVin(
          vinText,
          page: 1,
          limit: _pageSize,
        );
      } else {
        results = await _repository.searchParts(
          query: _partController.text.trim(),
          makes: _selectedMakes,
          categories: _selectedCategories,
          conditions: _selectedConditions,
          maxPrice: _maxPrice,
          page: 1,
          limit: _pageSize,
        );
      }

      final sortedResults = _getSortedParts(results);

      if (mounted) {
        setState(() {
          _parts = sortedResults;
          _currentPage = 1;
          _hasMore = results.length >= _pageSize;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load parts. Please try again.';
        });
      }
    }
  }

  Future<void> _loadMoreParts() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final nextPage = _currentPage + 1;
    var newItems = <ProductPartItem>[];

    try {
      if (_searchType == SearchType.vin) {
        final vinText = _vinController.text.trim();
        newItems = await _repository.searchByVin(
          vinText,
          page: nextPage,
          limit: _pageSize,
        );
      } else {
        newItems = await _repository.searchParts(
          query: _partController.text.trim(),
          makes: _selectedMakes,
          categories: _selectedCategories,
          conditions: _selectedConditions,
          maxPrice: _maxPrice,
          page: nextPage,
          limit: _pageSize,
        );
      }

      if (mounted) {
        if (newItems.isEmpty) {
          setState(() {
            _hasMore = false;
            _isLoadingMore = false;
          });
        } else {
          // Filter duplicates by id to ensure stable list
          final existingIds = _parts.map((p) => p.id).toSet();
          final uniqueNewItems =
              newItems.where((p) => !existingIds.contains(p.id)).toList();

          final updatedParts = List<ProductPartItem>.from(_parts)
            ..addAll(uniqueNewItems);
          final sortedParts = _getSortedParts(updatedParts);

          setState(() {
            _currentPage = nextPage;
            _parts = sortedParts;
            _hasMore = newItems.length >= _pageSize;
            _isLoadingMore = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _errorMessage = 'Failed to load more parts.';
        });
      }
    }
  }

  void _openFilterBottomSheet() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return FilterBottomSheet(
            initialMakes: _selectedMakes,
            initialCategories: _selectedCategories,
            initialConditions: _selectedConditions,
            initialMaxPrice: _maxPrice,
            calculateResultsCount: _calculateResultsCount,
            onApply: (makes, categories, conditions, maxPrice) {
              setState(() {
                _selectedMakes = makes;
                _selectedCategories = categories;
                _selectedConditions = conditions;
                _maxPrice = maxPrice;
              });
              unawaited(_fetchParts().catchError((e) {
                if (mounted) {
                  setState(() {
                    _errorMessage = 'Failed to apply filters.';
                  });
                }
              }));
            },
          );
        },
      ),
    );
  }

  Future<void> _toggleFavorite(String partId) async {
    try {
      await _repository.toggleFavorite(partId);
      if (mounted) {
        setState(() {
          _parts = _parts.map((p) {
            if (p.id == partId) {
              return p.copyWith(isFavorite: !p.isFavorite);
            }
            return p;
          }).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to update favorite.';
        });
      }
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            _errorMessage ?? 'An error occurred.',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              setState(() => _errorMessage = null);
              _fetchParts(reset: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null && _parts.isEmpty) {
      return _buildErrorState();
    }

    final showVinBanner =
        _searchType == SearchType.vin && _vinController.text.length == 17;

    return Scaffold(
      backgroundColor: const Color(0xFF12161A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header and Filters section
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Column(
                children: [
                  BrowsePartsHeader(listedCount: _totalCount),
                  SizedBox(height: 16.h),
                  SearchTypeToggle(
                    selectedType: _searchType,
                    onChanged: (type) {
                      setState(() {
                        _searchType = type;
                      });
                      unawaited(_fetchParts().catchError((e) {
                        if (mounted) {
                          setState(() {
                            _errorMessage = 'Failed to switch search type.';
                          });
                        }
                      }));
                    },
                  ),
                  SizedBox(height: 16.h),
                  SearchInputs(
                    searchType: _searchType,
                    partController: _partController,
                    vinController: _vinController,
                    onFilterTap: _openFilterBottomSheet,
                  ),
                  SizedBox(height: 16.h),
                  SortChipsRow(
                    selectedSort: _sortType,
                    onChanged: (sort) {
                      setState(() {
                        _sortType = sort;
                      });
                      // _getSortedParts() is applied lazily in build via _parts
                    },
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
            const Divider(color: Color(0x12FFFFFF), height: 1),

            // Scrollable content area with pull-to-refresh & infinite scroll
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchParts(reset: true),
                color: AppColors.info,
                backgroundColor: const Color(0xFF1C2330),
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  children: [
                    // VIN banner if valid VIN typed
                    if (showVinBanner) ...[
                      Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Showing parts compatible with VIN:\n'
                                '${_vinController.text}',
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // Results header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_parts.length} parts found',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (_searchType == SearchType.part &&
                            _areFiltersApplied())
                          IconButton(
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.close),
                            tooltip: 'Clear filters',
                            color: AppColors.info,
                            iconSize: 14.r,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            style: IconButton.styleFrom(
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(48),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.info,
                            ),
                          ),
                        ),
                      )
                    else if (_parts.isEmpty)
                      EmptyPartsView(onClearFilters: _clearFilters)
                    else ...[
                      ..._parts.map((part) {
                        return ProductCard(
                          part: part,
                          onFavoriteTap: () =>
                              unawaited(_toggleFavorite(part.id)),
                          onTap: () {
                            unawaited(context.push('/part-details/${part.id}'));
                          },
                        );
                      }),

                      // Loading more indicator at the bottom
                      if (_isLoadingMore)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.info,
                                ),
                              ),
                            ),
                          ),
                        )
                      else if (!_hasMore && _parts.length >= _pageSize)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: Center(
                            child: Text(
                              'You’ve reached the end of the parts catalog',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
