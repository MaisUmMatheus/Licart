import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('products');

  List<Product> _products = [];
  String _selectedCategory = 'Todas';
  String _searchQuery = '';
  bool _isLoading = true;

  List<Product> get products => _products;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<String> get categories {
    final set = <String>{'Todas', 'Drop 07', 'Clássicos'};
    for (final p in _products) {
      if (p.category.isNotEmpty) set.add(p.category);
      if (p.tag != null && p.tag!.isNotEmpty) set.add(p.tag!);
    }
    return set.toList();
  }

  ProductProvider() {
    _listenToCatalog();
  }

  List<Product> get filteredProducts {
    return _products.where((prod) {
      final matchesCategory = _selectedCategory == 'Todas' ||
          prod.category.toLowerCase() == _selectedCategory.toLowerCase() ||
          (prod.tag != null && prod.tag!.toLowerCase() == _selectedCategory.toLowerCase());

      final matchesSearch = _searchQuery.isEmpty ||
          prod.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prod.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prod.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (prod.tag != null && prod.tag!.toLowerCase().contains(_searchQuery.toLowerCase()));

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void _listenToCatalog() {
    _collection.snapshots().listen(
      (snapshot) {
        _products = snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Erro ao ouvir catálogo no Firestore: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addProduct(Product product) async {
    await _collection.doc(product.id).set(product.toMap());
  }

  Future<void> updateProduct(Product updatedProduct) async {
    await _collection.doc(updatedProduct.id).set(updatedProduct.toMap());
  }

  Future<void> removeProduct(String productId) async {
    await _collection.doc(productId).delete();
  }
}
