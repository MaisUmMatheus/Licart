import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/abrir_loja.dart';
import '../widgets/product_image.dart';

class ProductDetailDialog extends StatefulWidget {
  final Product product;

  const ProductDetailDialog({super.key, required this.product});

  @override
  State<ProductDetailDialog> createState() => _ProductDetailDialogState();
}

class _ProductDetailDialogState extends State<ProductDetailDialog> {
  int _galleryIndex = 0;
  final PageController _galleryController = PageController();

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  void _goToGalleryPage(int index) {
    _galleryController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

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
    final images = widget.product.images;

    if (images.length <= 1) {
      return Container(
        color: AppTheme.papel2,
        child: ProductImage(imageUrl: images.isNotEmpty ? images.first : ''),
      );
    }

    return Container(
      color: AppTheme.papel2,
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _galleryController,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _galleryIndex = i),
              itemBuilder: (_, i) => ProductImage(imageUrl: images[i]),
            ),
          ),

          // Seta Anterior
          if (_galleryIndex > 0)
            Positioned(
              left: 4,
              top: 0,
              bottom: 0,
              child: Center(child: _buildGalleryArrow(Icons.chevron_left, () => _goToGalleryPage(_galleryIndex - 1))),
            ),

          // Seta Próxima
          if (_galleryIndex < images.length - 1)
            Positioned(
              right: 4,
              top: 0,
              bottom: 0,
              child: Center(child: _buildGalleryArrow(Icons.chevron_right, () => _goToGalleryPage(_galleryIndex + 1))),
            ),

          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final isActive = i == _galleryIndex;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.tinta : AppTheme.tinta.withValues(alpha: 0.3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryArrow(IconData icon, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.papel.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.linha),
          ),
          child: Icon(icon, color: AppTheme.tinta, size: 20),
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, NumberFormat currencyFormatter) {
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

        Text(
          'Cor e tamanho você escolhe na próxima página.',
          style: GoogleFonts.archivo(fontSize: 12, color: AppTheme.tintaSuave),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => abrirNaLoja(context, widget.product),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.tinta,
              foregroundColor: AppTheme.papel,
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
    );
  }
}
