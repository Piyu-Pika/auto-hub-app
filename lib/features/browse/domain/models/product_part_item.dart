class ProductPartItem {

  const ProductPartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.condition,
    required this.rating,
    required this.make,
    required this.model,
    required this.yearRange,
    required this.category,
    required this.warranty,
    required this.location,
    required this.imagePath,
    this.tag,
    this.isFavorite = false,
  });
  final String id;
  final String title;
  final double price;
  final String condition;
  final double rating;
  final String make;
  final String model;
  final String yearRange;
  final String category;
  final String warranty;
  final String location;
  final String imagePath;
  final String? tag;
  final bool isFavorite;

  ProductPartItem copyWith({
    bool? isFavorite,
  }) {
    return ProductPartItem(
      id: id,
      title: title,
      price: price,
      condition: condition,
      rating: rating,
      make: make,
      model: model,
      yearRange: yearRange,
      category: category,
      warranty: warranty,
      location: location,
      imagePath: imagePath,
      tag: tag,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory ProductPartItem.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    final price = (rawPrice is num) ? rawPrice.toDouble() : 0.0;

    final rawRating = json['rating'];
    final rating = (rawRating is num) ? rawRating.toDouble() : 0.0;

    String? rawImage =
        json['imagePath'] as String? ?? json['imageUrl'] as String?;
    if ((rawImage == null || rawImage.trim().isEmpty) &&
        json['images'] is List &&
        (json['images'] as List).isNotEmpty) {
      rawImage = (json['images'] as List).first?.toString();
    }
    final image = (rawImage != null && rawImage.trim().isNotEmpty)
        ? rawImage.trim()
        : 'assets/images/home_part_bumper.png';

    return ProductPartItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: price,
      condition: json['condition'] as String? ?? 'Good',
      rating: rating,
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      yearRange: json['yearRange'] as String? ?? '',
      category: json['category'] as String? ?? '',
      warranty: json['warranty'] as String? ?? '30 Days',
      location: json['location'] as String? ?? 'AutoHub Express',
      imagePath: image,
      tag: json['tag'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'condition': condition,
      'rating': rating,
      'make': make,
      'model': model,
      'yearRange': yearRange,
      'category': category,
      'warranty': warranty,
      'location': location,
      'imagePath': imagePath,
      if (tag != null) 'tag': tag,
      'isFavorite': isFavorite,
    };
  }
}
