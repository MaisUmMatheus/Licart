import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ink_splatter_painter.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController(text: '139,00');
  final _stockController = TextEditingController(text: '15');
  final _imageController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Drop 07';
  int _seed = 12345;

  @override
  void initState() {
    super.initState();
    _seed = Random().nextInt(1000000);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _randomizeSeed() {
    setState(() {
      _seed = Random().nextInt(1000000);
    });
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 139.0;
    final stock = int.tryParse(_stockController.text) ?? 15;
    final newId = DateTime.now().millisecondsSinceEpoch.toString();

    final newProduct = Product(
      id: newId,
      name: _nameController.text.trim().toUpperCase(),
      description: _descriptionController.text.trim(),
      price: price,
      imageUrl: _imageController.text.trim(),
      category: _selectedCategory,
      tag: _selectedCategory,
      stock: stock,
      isFeatured: true,
      rating: 5.0,
      seed: _seed,
    );

    final productProvider = context.read<ProductProvider>();
    await productProvider.addProduct(newProduct);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Estampa "${newProduct.name}" cadastrada com sucesso!',
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
          'CADASTRAR NOVA ESTAMPA',
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
                    'Nova Estampa de Nanquim',
                    style: GoogleFonts.permanentMarker(fontSize: 26, color: AppTheme.tinta),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Insira os detalhes da nova peça do catálogo ou drop.',
                    style: GoogleFonts.archivo(fontSize: 14, color: AppTheme.tintaSuave),
                  ),
                  const SizedBox(height: 32),

                  // Área de Visualização e Configuração do Nanquim
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Prévia da Estampa
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppTheme.papel2,
                          border: Border.all(color: AppTheme.linha),
                        ),
                        child: CustomPaint(
                          painter: InkSplatterPainter(
                            seed: _seed,
                            sizeRatio: 0.35,
                            drawDrip: false,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GERADOR DE NANQUIM',
                              style: GoogleFonts.archivo(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: AppTheme.tinta,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Cada estampa da LICÀRT possui uma impressão única calculada por algoritmo de nanquim.',
                              style: GoogleFonts.archivo(fontSize: 13, color: AppTheme.tintaSuave),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _randomizeSeed,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('GERAR NOVO TRAÇO DE NANQUIM'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.tinta,
                                side: const BorderSide(color: AppTheme.tinta),
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                              ),
                            ),
                          ],
                        ),
                      ),
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

                  const SizedBox(height: 20),

                  // Imagem Customizada (Opcional)
                  _buildLabel('URL DE IMAGEM EXTERNA (OPCIONAL)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _imageController,
                    decoration: const InputDecoration(
                      hintText: 'Deixe em branco para usar o nanquim procedural acima',
                    ),
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
                        'SALVAR E PUBLICAR ESTAMPA',
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
}
