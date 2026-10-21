import 'dart:convert';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images; // 0, 1 ou 2 imagens (upload ou URL)
  final String category;
  final int stock;
  final double rating;
  final bool isFeatured;
  final int? seed;
  final String? tag; // e.g. "Drop 07" ou "Clássicos"
  final String? youdrawUrl; // link do produto na loja da YouDraw

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.images = const [],
    required this.category,
    required this.stock,
    this.rating = 4.8,
    this.isFeatured = false,
    this.seed,
    this.tag,
    this.youdrawUrl,
  });

  /// Primeira imagem do produto, ou string vazia se nenhuma foi cadastrada.
  String get imageUrl => images.isNotEmpty ? images.first : '';

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    List<String>? images,
    String? category,
    int? stock,
    double? rating,
    bool? isFeatured,
    int? seed,
    String? tag,
    String? youdrawUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      images: images ?? this.images,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      isFeatured: isFeatured ?? this.isFeatured,
      seed: seed ?? this.seed,
      tag: tag ?? this.tag,
      youdrawUrl: youdrawUrl ?? this.youdrawUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      'category': category,
      'stock': stock,
      'rating': rating,
      'isFeatured': isFeatured,
      'seed': seed,
      'tag': tag,
      'youdrawUrl': youdrawUrl,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    List<String> parsedImages;
    final rawImages = map['images'];
    if (rawImages is List) {
      parsedImages = rawImages.map((e) => e.toString()).toList();
    } else {
      final legacyUrl = map['imageUrl'] as String?;
      parsedImages = (legacyUrl != null && legacyUrl.isNotEmpty) ? [legacyUrl] : [];
    }

    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      images: parsedImages,
      category: map['category'] ?? '',
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      isFeatured: map['isFeatured'] ?? false,
      seed: (map['seed'] as num?)?.toInt(),
      tag: map['tag'],
      youdrawUrl: map['youdrawUrl'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) => Product.fromMap(json.decode(source));
}
