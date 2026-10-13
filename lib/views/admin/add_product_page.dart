import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_image.dart';

class AddProductPage extends StatefulWidget {
  final Product? editingProduct;

  const AddProductPage({super.key, this.editingProduct});

  bool get isEditing => editingProduct != null;

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController(text: widget.editingProduct?.name ?? '');
  late final _priceController = TextEditingController(
    text: widget.editingProduct != null
        ? widget.editingProduct!.price.toStringAsFixed(2).replaceAll('.', ',')
        : '139,00',
  );
  late final _stockController = TextEditingController(
    text: widget.editingProduct?.stock.toString() ?? '15',
  );
  late final _descriptionController = TextEditingController(
    text: widget.editingProduct?.description ?? '',
  );

  static const int _maxImages = 2;

  late String _selectedCategory = widget.editingProduct?.tag ??
      widget.editingProduct?.category ??
      'Drop 07';

  // Imagens já salvas no produto (ao editar) que o usuário pode remover.
  late final List<String> _existingImages = List.of(widget.editingProduct?.images ?? []);
  // Imagens novas escolhidas nesta sessão.
  final List<Uint8List> _newImageBytesList = [];

  int get _totalImageCount => _existingImages.length + _newImageBytesList.length;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_totalImageCount >= _maxImages) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    final bytes = result?.files.single.bytes;
    if (bytes != null) {
      setState(() => _newImageBytesList.add(bytes));
    }
  }

  void _removeExistingImage(int index) {
    setState(() => _existingImages.removeAt(index));
  }

  void _removeNewImage(int index) {
    setState(() => _newImageBytesList.removeAt(index));
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 139.0;
    final stock = int.tryParse(_stockController.text) ?? 15;

    final images = [
      ..._existingImages,
      ..._newImageBytesList.map((bytes) => 'data:image/png;base64,${base64Encode(bytes)}'),
    ];

    final productProvider = context.read<ProductProvider>();

    if (widget.isEditing) {
      final updatedProduct = widget.editingProduct!.copyWith(
        name: _nameController.text.trim().toUpperCase(),
        description: _descriptionController.text.trim(),
        price: price,
        images: images,
        category: _selectedCategory,
        tag: _selectedCategory,
        stock: stock,
      );
      await productProvider.updateProduct(updatedProduct);
    } else {
      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim().toUpperCase(),
        description: _descriptionController.text.trim(),
        price: price,
        images: images,
        category: _selectedCategory,
        tag: _selectedCategory,
        stock: stock,
        isFeatured: true,
        rating: 5.0,
      );
      await productProvider.addProduct(newProduct);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditing
              ? 'Estampa "${_nameController.text.trim().toUpperCase()}" atualizada com sucesso!'
              : 'Estampa "${_nameController.text.trim().toUpperCase()}" cadastrada com sucesso!',
          style: GoogleFonts.archivo(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppTheme.tinta,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.papel,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'EDITAR ESTAMPA' : 'CADASTRAR NOVA ESTAMPA',
          style: GoogleFonts.permanentMarker(fontSize: 20, color: AppTheme.tinta),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.tinta),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isEditing ? 'Editar Estampa' : 'Nova Estampa',
                    style: GoogleFonts.permanentMarker(fontSize: 26, color: AppTheme.tinta),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.isEditing
                        ? 'Atualize os detalhes desta peça do catálogo.'
                        : 'Insira os detalhes da nova peça do catálogo ou drop.',
                    style: GoogleFonts.archivo(fontSize: 14, color: AppTheme.tintaSuave),
                  ),
                  const SizedBox(height: 32),

                  // Foto do Produto
                  _buildLabel('FOTO DA ESTAMPA (OPCIONAL · ATÉ $_maxImages IMAGENS)'),
                  const SizedBox(height: 6),
                  Text(
                    _totalImageCount == 0
                        ? 'Nenhuma imagem selecionada. A foto padrão da LICÀRT será usada até você enviar uma.'
                        : 'Você pode enviar uma ou duas fotos — a primeira aparece na vitrine.',
                    style: GoogleFonts.archivo(fontSize: 13, color: AppTheme.tintaSuave),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (int i = 0; i < _existingImages.length; i++) _buildExistingImageTile(i),
                      for (int i = 0; i < _newImageBytesList.length; i++) _buildNewImageTile(i),
                      if (_totalImageCount < _maxImages) _buildAddImageTile(),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Divider(color: AppTheme.linha),
                  const SizedBox(height: 32),

                  // Nome da Estampa
                  _buildLabel('NOME DA ESTAMPA'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Ex: METAMORFOSE, AURORA, RAIZ...',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Informe o nome da estampa';
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Categoria / Coleção
                  _buildLabel('COLEÇÃO / TAG'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    dropdownColor: AppTheme.papel,
                    decoration: const InputDecoration(),
                    items: const [
                      DropdownMenuItem(value: 'Drop 07', child: Text('Drop 07 (Atual)')),
                      DropdownMenuItem(value: 'Clássicos', child: Text('Clássicos do Ateliê')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Preço e Estoque
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('PREÇO (R\$)'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '139.00',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Informe o valor';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('QUANTIDADE EM ESTOQUE (TIRAGEM)'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '15',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Informe o estoque';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Descrição Poética da Estampa
                  _buildLabel('DESCRIÇÃO DA ESTAMPA'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Ex: Traço contínuo executado em nanquim puro sobre papel 300g.',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Informe a descrição da peça';
                      return null;
                    },
                  ),

                  const SizedBox(height: 36),

                  // Botão Salvar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.tinta,
                        foregroundColor: AppTheme.papel,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: Text(
                        widget.isEditing ? 'SALVAR ALTERAÇÕES' : 'SALVAR E PUBLICAR ESTAMPA',
                        style: GoogleFonts.archivo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.archivo(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: AppTheme.tinta,
      ),
    );
  }

  Widget _buildExistingImageTile(int index) {
    return _buildImageTileFrame(
      child: ProductImage(imageUrl: _existingImages[index]),
      onRemove: () => _removeExistingImage(index),
    );
  }

  Widget _buildNewImageTile(int index) {
    return _buildImageTileFrame(
      child: Image.memory(_newImageBytesList[index], fit: BoxFit.contain),
      onRemove: () => _removeNewImage(index),
    );
  }

  Widget _buildImageTileFrame({required Widget child, required VoidCallback onRemove}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.papel2,
            border: Border.all(color: AppTheme.linha),
          ),
          child: child,
        ),
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(color: AppTheme.tinta, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: AppTheme.papel),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageTile() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.papel2,
          border: Border.all(color: AppTheme.linha, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_outlined, color: AppTheme.tintaSuave, size: 28),
            const SizedBox(height: 8),
            Text(
              'ADICIONAR',
              style: GoogleFonts.archivo(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppTheme.tintaSuave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
