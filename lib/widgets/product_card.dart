import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../views/product_detail_dialog.dart';
import 'product_image.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  String? _selectedSize;
  String _hintText = 'Escolha um tamanho.';
  bool _isHovered = false;

  final List<String> _availableSizes = const ['P', 'M', 'G', 'GG'];

  void _onSizeSelected(String size) {
    setState(() {
      _selectedSize = size;
      _hintText = 'Tamanho $size selecionado.';
    });
  }

  void _buyProduct(BuildContext context) {
    if (_selectedSize == null) {
      setState(() {
        _hintText = 'Escolha um tamanho antes de comprar.';
      });
      return;
    }

    final cart = context.read<CartProvider>();
    cart.addItem(widget.product, size: _selectedSize!);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.product.name} ($_selectedSize) na sacola.',
          style: GoogleFonts.archivo(
            color: AppTheme.papel,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        backgroundColor: AppTheme.tinta,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final tagLabel = widget.product.tag ?? (widget.product.category == 'Drop 07' ? 'Drop 07' : 'Clássico');

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Foto / Mockup da Camisa com Nanquim
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => ProductDetailDialog(product: widget.product),
              );
            },
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.papel2,
                  border: Border.all(
                    color: _isHovered ? AppTheme.tinta : AppTheme.linha,
                    width: 1.0,
                  ),
                ),
                child: Stack(
                  children: [
                    // Foto do Produto
                    Positioned.fill(
                      child: ProductImage(imageUrl: widget.product.imageUrl),
                    ),

                    // Tag Drop ou Clássico
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: AppTheme.papel.withValues(alpha: 0.9),
                        child: Text(
                          tagLabel.toUpperCase(),
                          style: GoogleFonts.archivo(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppTheme.tintaSuave,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Metadados do Produto: Nome e Preço
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  widget.product.name,
                  style: GoogleFonts.permanentMarker(
                    fontSize: 24,
                    color: AppTheme.tinta,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                currencyFormatter.format(widget.product.price),
                style: GoogleFonts.archivo(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.tinta,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Descrição do Produto
          Text(
            widget.product.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.archivo(
              fontSize: 13,
              color: AppTheme.tintaSuave,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 12),

          // Seletor de Tamanhos: P, M, G, GG
          Row(
            children: _availableSizes.map((size) {
              final isSelected = _selectedSize == size;
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: SizedBox(
                  width: 38,
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () => _onSizeSelected(size),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: isSelected ? AppTheme.tinta : Colors.transparent,
                      foregroundColor: isSelected ? AppTheme.papel : AppTheme.tinta,
                      side: BorderSide(
                        color: isSelected ? AppTheme.tinta : AppTheme.linha,
                        width: 1,
                      ),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: Text(
                      size,
                      style: GoogleFonts.archivo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 6),

          // Dica de Tamanho
          Text(
            _hintText,
            style: GoogleFonts.archivo(
              fontSize: 12,
              color: _selectedSize == null && _hintText.contains('antes')
                  ? AppTheme.respingo
                  : AppTheme.tintaSuave,
            ),
          ),

          const SizedBox(height: 10),

          // Botão Comprar (Full width, sharp)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => _buyProduct(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.tinta,
                foregroundColor: AppTheme.papel,
                elevation: 0,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: Text(
                'COMPRAR',
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
    );
  }
}
