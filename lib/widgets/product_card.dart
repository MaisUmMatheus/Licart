import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/abrir_loja.dart';
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
  bool _isHovered = false;

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

          // Botão Comprar (Full width, sharp)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => abrirNaLoja(context, widget.product),
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
