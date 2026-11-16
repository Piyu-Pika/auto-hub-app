import '../../domain/models/product_part_item.dart';
import '../../domain/repositories/browse_repository.dart';

class MockBrowseRepository implements BrowseRepository {
  List<ProductPartItem> _mockParts = const [
    ProductPartItem(
      id: '1',
      title: 'Front Strut Assembly — Pair',
      price: 190,
      condition: 'Good',
      rating: 4.5,
      make: 'Kia',
      model: 'Sorento',
      yearRange: '2017–2020',
      category: 'Suspension',
      warranty: '30 Days',
      location: 'Miami, FL',
      imagePath: 'assets/images/home_part_bumper.png',
    ),
    ProductPartItem(
      id: '2',
      title: '2.5L 4-Cylinder Engine',
      price: 1650,
      condition: 'Excellent',
      rating: 4.8,
      make: 'Subaru',
      model: 'Outback',
      yearRange: '2015–2019',
      category: 'Engine',
      warranty: '6 Months',
      location: 'Seattle, WA',
      imagePath: 'assets/images/home_part_engine.png',
      tag: 'Featured',
    ),
    ProductPartItem(
      id: '3',
      title: 'Driver Door Panel',
      price: 135,
      condition: 'Good',
      rating: 4.4,
      make: 'Nissan',
      model: 'Altima',
      yearRange: '2019–2023',
      category: 'Interior',
      warranty: '30 Days',
      location: 'Dallas, TX',
      imagePath: 'assets/images/home_part_bumper.png',
    ),
    ProductPartItem(
      id: '4',
      title: 'Radiator Assembly',
      price: 210,
      condition: 'Good',
      rating: 4.6,
      make: 'BMW',
      model: '3 Series',
      yearRange: '2011–2016',
      category: 'Cooling',
      warranty: '45 Days',
      location: 'Atlanta, GA',
      imagePath: 'assets/images/home_part_alternator.png',
      tag: 'New',
    ),
    ProductPartItem(
      id: '5',
      title: 'LED Headlight Assembly — Left',
      price: 275,
      condition: 'Excellent',
      rating: 4.7,
      make: 'Toyota',
      model: 'Camry',
      yearRange: '2018–2022',
      category: 'Electrical',
      warranty: '90 Days',
      location: 'Los Angeles, CA',
      imagePath: 'assets/images/home_part_headlight.png',
    ),
    ProductPartItem(
      id: '6',
      title: '6-Speed Automatic Transmission',
      price: 750,
      condition: 'Excellent',
      rating: 4.9,
      make: 'Chevrolet',
      model: 'Malibu',
      yearRange: '2016–2019',
      category: 'Transmission',
      warranty: '6 Months',
      location: 'Chicago, IL',
      imagePath: 'assets/images/home_part_transmission.png',
      tag: 'Certified',
    ),
    ProductPartItem(
      id: '7',
      title: 'Front Bumper Assembly',
      price: 320,
      condition: 'Good',
      rating: 4.0,
      make: 'Ford',
      model: 'F-150',
      yearRange: '2018–2021',
      category: 'Body',
      warranty: '30 Days',
      location: 'Phoenix, AZ',
      imagePath: 'assets/images/home_part_bumper.png',
      tag: '🔥 Hot Deal',
    ),
    ProductPartItem(
      id: '8',
      title: 'OEM Alternator',
      price: 185,
      condition: 'Excellent',
      rating: 4.8,
      make: 'Honda',
      model: 'Civic',
      yearRange: '2016–2021',
      category: 'Electrical',
      warranty: '90 Days',
      location: 'Houston, TX',
      imagePath: 'assets/images/home_part_alternator.png',
      tag: 'Featured',
    ),
  ];

  @override
  Future<List<ProductPartItem>> getParts() async {
    return List.unmodifiable(_mockParts);
  }

  @override
  Future<List<ProductPartItem>> searchParts({
    String? query,
    List<String>? makes,
    List<String>? categories,
    List<String>? conditions,
    double? maxPrice,
    int page = 1,
    int limit = 20,
  }) async {
    var filtered = _mockParts.where((part) {
      if (makes != null && makes.isNotEmpty && !makes.contains('All Makes')) {
        if (!makes.contains(part.make)) return false;
      }
      if (categories != null && categories.isNotEmpty && !categories.contains('All Categories')) {
        if (!categories.contains(part.category)) return false;
      }
      if (conditions != null && conditions.isNotEmpty && !conditions.contains('All')) {
        if (!conditions.contains(part.condition)) return false;
      }
      if (maxPrice != null && part.price > maxPrice) return false;

      return true;
    }).toList();

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered.where((part) {
        return part.title.toLowerCase().contains(q) ||
            part.make.toLowerCase().contains(q) ||
            part.model.toLowerCase().contains(q) ||
            part.category.toLowerCase().contains(q);
      }).toList();
    }

    final startIndex = (page - 1) * limit;
    if (startIndex >= filtered.length) {
      return [];
    }
    final endIndex = (startIndex + limit > filtered.length)
        ? filtered.length
        : startIndex + limit;
    return filtered.sublist(startIndex, endIndex);
  }

  @override
  Future<List<ProductPartItem>> searchByVin(
    String vin, {
    int page = 1,
    int limit = 20,
  }) async {
    if (vin.length < 17 || vin == '145454HASBJH7W27E') {
      return [];
    }
    final filtered = _mockParts
        .where((part) => part.make == 'Honda' || part.make == 'Ford')
        .toList();

    final startIndex = (page - 1) * limit;
    if (startIndex >= filtered.length) {
      return [];
    }
    final endIndex = (startIndex + limit > filtered.length)
        ? filtered.length
        : startIndex + limit;
    return filtered.sublist(startIndex, endIndex);
  }

  @override
  Future<Map<String, dynamic>> getPartDetail(String id) async {
    final part = _mockParts.where((p) => p.id == id).firstOrNull;
    if (part == null) {
      throw Exception('Part not found');
    }
    return {
      'id': part.id,
      'title': part.title,
      'subtitle': part.category,
      'description': '${part.title} pulled from a donor vehicle, tested and '
          'confirmed working. ${part.condition} condition with ${part.warranty} '
          'warranty.',
      'price': part.price,
      'condition': part.condition,
      'tag': part.tag,
      'imageUrl': part.imagePath,
      'rating': part.rating,
      'ratingCount': 94,
      'warranty': part.warranty,
      'isFavorite': part.isFavorite,
      'location': part.location,
      'partNumber': 'AUTO-${part.id}-HUB',
      'quantityAvailable': 1,
      'specifications': {
        'category': part.category,
        'compatibleMake': part.make,
        'compatibleModel': part.model,
        'yearRange': part.yearRange,
        'donorMileage': '48,000 mi',
        'weight': '4.2 kg',
      },
      'fitment': {
        'label': 'Fits: ${part.make} ${part.model}',
        'detail': 'Model years ${part.yearRange}',
      },
      'yard': {
        'yardId': 'yrd_${part.id}',
        'name': part.location,
        'address': part.location,
        'phone': '(832) 555-0142',
        'businessHours': 'Mon-Sat 8AM-6PM',
        'pickupAvailable': true,
        'deliveryNationwide': true,
        'isVerified': true,
        'rating': part.rating,
        'ratingCount': 94,
      },
    };
  }

  @override
  Future<List<ProductPartItem>> getSimilarParts(
    String id, {
    int limit = 10,
  }) async {
    final otherParts = _mockParts.where((p) => p.id != id).toList();
    return otherParts.take(limit).toList();
  }

  @override
  Future<void> toggleFavorite(String partId) async {
    _mockParts = _mockParts.map((part) {
      if (part.id == partId) {
        return part.copyWith(isFavorite: !part.isFavorite);
      }
      return part;
    }).toList();
  }
}
