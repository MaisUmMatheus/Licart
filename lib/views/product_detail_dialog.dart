import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ink_splatter_painter.dart';

class ProductDetailDialog extends StatefulWidget {
  final Product product;

  const ProductDetailDialog({super.key, required this.product});

  @override
  State<ProductDetailDialog> createState() => _ProductDetailDialogState();
}

class _ProductDetailDialogState extends State<ProductDetailDialog> {
  int _quantity = 1;
  String _selectedSize = 'M';
  final List<String> _sizes = const ['P', 'M', 'G', 'GG'];

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: AppTheme.papel,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780, maxHeight: 620),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Arte da Estampa
                        Expanded(
                          flex: 5,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: _buildArtworkVisual(),
                          ),
                        ),
                        // Conteúdo
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: _buildDetails(context, currencyFormatter),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AspectRatio(
                          aspectRatio: 1.2,
                          child: _buildArtworkVisual(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: _buildDetails(context, currencyFormatter),
                        ),
                      ],
                    ),
            ),

            // Botão Fechar
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppTheme.tinta),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtworkVisual() {
    return Container(
      color: AppTheme.papel2,
      child: widget.product.imageUrl.isNotEmpty
          ? Image.network(
              widget.product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => CustomPaint(
                painter: InkSplatterPainter(
                  seed: widget.product.seed ?? widget.product.name.hashCode,
                  sizeRatio: 0.35,
                  drawDrip: true,
                ),
              ),
            )
          : CustomPaint(
              painter: InkSplatterPainter(
                seed: widget.product.seed ?? widget.product.name.hashCode,
                sizeRatio: 0.35,
                drawDrip: true,
              ),
            ),
    );
  }

  Widget _buildDetails(BuildContext context, NumberFormat currencyFormatter) {
    final cart = context.read<CartProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tag Categoria / Drop
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: AppTheme.tinta,
          child: Text(
            (widget.product.tag ?? widget.product.category).toUpperCase(),
            style: GoogleFonts.archivo(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: AppTheme.papel,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Nome
        Text(
          widget.product.name,
          style: GoogleFonts.permanentMarker(
            fontSize: 32,
            color: AppTheme.tinta,
          ),
        ),
        const SizedBox(height: 8),

        // Preço
        Text(
          currencyFormatter.format(widget.product.price),
          style: GoogleFonts.archivo(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.tinta,
          ),
        ),
        const SizedBox(height: 16),

        // Descrição
        Text(
          widget.product.description,
          style: GoogleFonts.archivo(
            fontSize: 14,
            height: 1.5,
            color: AppTheme.tintaSuave,
          ),
        ),
        const SizedBox(height: 20),

        // Seleção de Tamanho
        Text(
          'TAMANHO',
          style: GoogleFonts.archivo(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: AppTheme.tinta,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: _sizes.map((s) {
            final isSelected = _selectedSize == s;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                width: 44,
                height: 40,
                child: OutlinedButton(
                  onPressed: () => setState(() => _selectedSize = s),
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
                    s,
                    style: GoogleFonts.archivo(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // Quantidade
        Row(
          children: [
            Text(
              'QUANTIDADE',
              style: GoogleFonts.archivo(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: AppTheme.tinta,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 32,
              height: 32,
              child: OutlinedButton(
                onPressed: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: const BorderSide(color: AppTheme.linha),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: const Icon(Icons.remove, size: 14, color: AppTheme.tinta),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                '$_quantity',
                style: GoogleFonts.archivo(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: OutlinedButton(
                onPressed: () => setState(() => _quantity++),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: const BorderSide(color: AppTheme.linha),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: const Icon(Icons.add, size: 14, color: AppTheme.tinta),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Botão Adicionar à Sacola
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              for (int i = 0; i < _quantity; i++) {
                cart.addItem(widget.product, size: _selectedSize);
              }
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${widget.product.name} ($_selectedSize) adicionado à sacola!',
                    style: GoogleFonts.archivo(fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: AppTheme.tinta,
                  behavior: SnackBarBehavior.floating,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.tinta,
              foregroundColor: AppTheme.papel,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text(
              'ADICIONAR À SACOLA',
              style: GoogleFonts.archivo(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
