import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
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
    _initCatalog();
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

  Future<void> _initCatalog() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedProductsJson = prefs.getStringList('licart_products_v2');

      if (savedProductsJson != null && savedProductsJson.isNotEmpty) {
        _products = savedProductsJson
            .map((item) => Product.fromJson(item))
            .toList();
      } else {
        _products = _getInitialCatalog();
        await _saveToStorage();
      }
    } catch (e) {
      debugPrint('Erro ao carregar catálogo: $e');
      _products = _getInitialCatalog();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = _products.map((p) => p.toJson()).toList();
      await prefs.setStringList('licart_products_v2', stringList);
    } catch (e) {
      debugPrint('Erro ao salvar produtos: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    _products.insert(0, product);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> updateProduct(Product updatedProduct) async {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
      await _saveToStorage();
    }
  }

  Future<void> removeProduct(String productId) async {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
    await _saveToStorage();
  }

  List<Product> _getInitialCatalog() {
    return [
      const Product(
        id: 'corvo',
        name: 'CORVO',
        description: 'Asas abertas em três pinceladas. Nanquim, madrugada de outubro.',
        price: 139.00,
        imageUrl: '',
        category: 'Drop 07',
        tag: 'Drop 07',
        stock: 15,
        rating: 5.0,
        isFeatured: true,
        seed: 11,
      ),
      const Product(
        id: 'madrugada',
        name: 'MADRUGADA',
        description: 'Um traço só, sem tirar o pincel do papel.',
        price: 129.00,
        imageUrl: '',
        category: 'Drop 07',
        tag: 'Drop 07',
        stock: 22,
        rating: 4.9,
        isFeatured: true,
        seed: 42,
      ),
      const Product(
        id: 'gota-zero',
        name: 'GOTA ZERO',
        description: 'O primeiro respingo da marca. A folha original ainda está na parede.',
        price: 119.00,
        imageUrl: '',
        category: 'Clássicos',
        tag: 'Clássicos',
        stock: 18,
        rating: 4.8,
        isFeatured: false,
        seed: 7,
      ),
      const Product(
        id: 'risco',
        name: 'RISCO',
        description: 'Pincel seco arrastado em diagonal. Textura que só a mão faz.',
        price: 129.00,
        imageUrl: '',
        category: 'Clássicos',
        tag: 'Clássicos',
        stock: 12,
        rating: 4.9,
        isFeatured: false,
        seed: 93,
      ),
      const Product(
        id: 'nanquim',
        name: 'NANQUIM',
        description: 'Tinta derramada e soprada até virar raiz.',
        price: 139.00,
        imageUrl: '',
        category: 'Drop 07',
        tag: 'Drop 07',
        stock: 10,
        rating: 5.0,
        isFeatured: true,
        seed: 305,
      ),
      const Product(
        id: 'voo-cego',
        name: 'VOO CEGO',
        description: 'Desenhado de olhos fechados, em quarenta segundos.',
        price: 129.00,
        imageUrl: '',
        category: 'Clássicos',
        tag: 'Clássicos',
        stock: 14,
        rating: 4.8,
        isFeatured: false,
        seed: 1888,
      ),
    ];
  }
}
