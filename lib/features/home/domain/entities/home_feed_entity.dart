import 'package:auto_hub_app/features/browse/domain/models/product_part_item.dart';
import 'package:equatable/equatable.dart';

class HeroBannerEntity extends Equatable {
  const HeroBannerEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.ctaLabel,
    this.ctaUrl,
  });

  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? ctaLabel;
  final String? ctaUrl;

  @override
  List<Object?> get props => [id, title, subtitle, imageUrl, ctaLabel, ctaUrl];
}

class HomeStatEntity extends Equatable {
  const HomeStatEntity({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  List<Object?> get props => [label, value];
}

class HomeCategoryEntity extends Equatable {
  const HomeCategoryEntity({
    required this.id,
    required this.name,
    this.iconUrl,
    this.partCount = 0,
  });

  final String id;
  final String name;
  final String? iconUrl;
  final int partCount;

  @override
  List<Object?> get props => [id, name, iconUrl, partCount];
}

class JunkBannerEntity extends Equatable {
  const JunkBannerEntity({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.ctaUrl,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? ctaUrl;

  @override
  List<Object?> get props => [title, subtitle, imageUrl, ctaUrl];
}

class TrustStripItemEntity extends Equatable {
  const TrustStripItemEntity({
    required this.icon,
    required this.label,
  });

  final String icon;
  final String label;

  @override
  List<Object?> get props => [icon, label];
}

class HomeFeedEntity extends Equatable {
  const HomeFeedEntity({
    this.hero,
    this.stats = const [],
    this.categories = const [],
    this.featured = const [],
    this.recent = const [],
    this.junkBanner,
    this.trustItems = const [],
  });

  final HeroBannerEntity? hero;
  final List<HomeStatEntity> stats;
  final List<HomeCategoryEntity> categories;
  final List<ProductPartItem> featured;
  final List<ProductPartItem> recent;
  final JunkBannerEntity? junkBanner;
  final List<TrustStripItemEntity> trustItems;

  @override
  List<Object?> get props => [
        hero,
        stats,
        categories,
        featured,
        recent,
        junkBanner,
        trustItems,
      ];
}
