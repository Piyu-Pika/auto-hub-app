import 'package:auto_hub_app/features/browse/domain/models/product_part_item.dart';
import 'package:auto_hub_app/features/home/domain/entities/home_feed_entity.dart';

class HomeFeedModel extends HomeFeedEntity {
  const HomeFeedModel({
    super.hero,
    super.stats,
    super.categories,
    super.featured,
    super.recent,
    super.junkBanner,
    super.trustItems,
  });

  factory HomeFeedModel.fromJson(Map<String, dynamic> json) {
    HeroBannerEntity? hero;
    if (json['hero'] is Map<String, dynamic>) {
      final h = json['hero'] as Map<String, dynamic>;
      hero = HeroBannerEntity(
        id: h['id'] as String? ?? 'bnr_1',
        title: h['title'] as String? ?? 'Quality used auto parts',
        subtitle: h['subtitle'] as String? ?? 'Tested OEM parts from our yard',
        imageUrl: h['imageUrl'] as String?,
        ctaLabel: h['ctaLabel'] as String? ?? 'Shop now',
        ctaUrl: h['ctaUrl'] as String? ?? 'autohub://browse',
      );
    }

    final statsList = <HomeStatEntity>[];
    if (json['stats'] is List) {
      for (final item in json['stats'] as List) {
        if (item is Map<String, dynamic>) {
          statsList.add(
            HomeStatEntity(
              label: item['label'] as String? ?? '',
              value: item['value']?.toString() ?? '',
            ),
          );
        }
      }
    }

    final categoriesList = <HomeCategoryEntity>[];
    if (json['categories'] is List) {
      for (final item in json['categories'] as List) {
        if (item is Map<String, dynamic>) {
          categoriesList.add(
            HomeCategoryEntity(
              id: item['id'] as String? ?? '',
              name: item['name'] as String? ?? '',
              iconUrl: item['iconUrl'] as String?,
              partCount: item['partCount'] as int? ?? 0,
            ),
          );
        }
      }
    }

    final featuredList = <ProductPartItem>[];
    if (json['featured'] is List) {
      for (final item in json['featured'] as List) {
        if (item is Map<String, dynamic>) {
          featuredList.add(ProductPartItem.fromJson(item));
        }
      }
    }

    final recentList = <ProductPartItem>[];
    if (json['recent'] is List) {
      for (final item in json['recent'] as List) {
        if (item is Map<String, dynamic>) {
          recentList.add(ProductPartItem.fromJson(item));
        }
      }
    }

    JunkBannerEntity? junk;
    if (json['junkBanner'] is Map<String, dynamic>) {
      final j = json['junkBanner'] as Map<String, dynamic>;
      junk = JunkBannerEntity(
        title: j['title'] as String? ?? 'Junk your car',
        subtitle: j['subtitle'] as String? ?? 'Free towing + cash offer',
        imageUrl: j['imageUrl'] as String?,
        ctaUrl: j['ctaUrl'] as String? ?? 'autohub://new-junk-request',
      );
    }

    final trustList = <TrustStripItemEntity>[];
    if (json['trustStrip'] is Map<String, dynamic>) {
      final ts = json['trustStrip'] as Map<String, dynamic>;
      final items = ts['items'] as List?;
      if (items != null) {
        for (final item in items) {
          if (item is Map<String, dynamic>) {
            trustList.add(
              TrustStripItemEntity(
                icon: item['icon'] as String? ?? '',
                label: item['label'] as String? ?? '',
              ),
            );
          }
        }
      }
    }

    return HomeFeedModel(
      hero: hero,
      stats: statsList,
      categories: categoriesList,
      featured: featuredList,
      recent: recentList,
      junkBanner: junk,
      trustItems: trustList,
    );
  }
}
