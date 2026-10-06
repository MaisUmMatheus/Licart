import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ink_splatter_painter.dart';

class CartSheet extends StatelessWidget {
  const CartSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final cartEntries = cart.items.entries.toList();

    return Container(
      width: 440,
      color: AppTheme.papel,
      child: SafeArea(
        child: Column(
          children: [
            // Cabeçalho da Sacola
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.linha, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'SACOLA',
                        style: GoogleFonts.permanentMarker(
                          fontSize: 22,
                          color: AppTheme.tinta,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.tinta,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: GoogleFonts.archivo(
                            color: AppTheme.papel,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.tinta),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Barra de Frete
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: AppTheme.papel2,
              child: Row(
                children: [
                  Icon(
                    cart.hasFreeShipping ? Icons.check_circle : Icons.local_shipping_outlined,
                    size: 16,
                    color: cart.hasFreeShipping ? AppTheme.successColor : AppTheme.tinta,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cart.hasFreeShipping
                          ? 'Frete grátis liberado para o seu pedido!'
                          : 'Adicione mais ${currencyFormatter.format(cart.amountUntilFreeShipping)} para frete grátis.',
                      style: GoogleFonts.archivo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cart.hasFreeShipping ? AppTheme.successColor : AppTheme.tintaSuave,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de Itens
            Expanded(
              child: cart.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            size: 56,
                            color: AppTheme.tintaSuave,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sua sacola está vazia.',
                            style: GoogleFonts.permanentMarker(
                              fontSize: 24,
                              color: AppTheme.tinta,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Explore as estampas do Drop 07 e clássicos.',
                            style: GoogleFonts.archivo(
                              fontSize: 14,
                              color: AppTheme.tintaSuave,
                            ),
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.tinta,
                              side: const BorderSide(color: AppTheme.tinta, width: 1),
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            child: const Text('VER COLEÇÃO'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: cartEntries.length,
                      separatorBuilder: (_, _) => const Divider(color: AppTheme.linha, height: 28),
                      itemBuilder: (context, index) {
                        final entry = cartEntries[index];
                        final itemKey = entry.key;
                        final item = entry.value;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Miniatura com estampa
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppTheme.papel2,
                                border: Border.all(color: AppTheme.linha),
                              ),
                              child: item.product.imageUrl.isNotEmpty
                                  ? Image.network(
                                      item.product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => CustomPaint(
                                        painter: InkSplatterPainter(
                                          seed: item.product.seed ?? item.product.name.hashCode,
                                          sizeRatio: 0.35,
                                          drawDrip: false,
                                        ),
                                      ),
                                    )
                                  : CustomPaint(
                                      painter: InkSplatterPainter(
                                        seed: item.product.seed ?? item.product.name.hashCode,
                                        sizeRatio: 0.35,
                                        drawDrip: false,
                                      ),
                                    ),
                            ),

                            const SizedBox(width: 14),

                            // Informações do Item
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: GoogleFonts.permanentMarker(
                                      fontSize: 18,
                                      color: AppTheme.tinta,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        color: AppTheme.papel2,
                                        child: Text(
                                          'TAMANHO ${item.size}',
                                          style: GoogleFonts.archivo(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.8,
                                            color: AppTheme.tintaSuave,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        currencyFormatter.format(item.product.price),
                                        style: GoogleFonts.archivo(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.tinta,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Controles de Quantidade
                                  Row(
                                    children: [
                                      _buildQuantityButton(
                                        icon: Icons.remove,
                                        onPressed: () => cart.decrementItem(itemKey),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          '${item.quantity}',
                                          style: GoogleFonts.archivo(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      _buildQuantityButton(
                                        icon: Icons.add,
                                        onPressed: () => cart.addItem(item.product, size: item.size),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.tintaSuave),
                                        onPressed: () => cart.removeItem(itemKey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            // Rodapé com Totais e Finalização
            if (!cart.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppTheme.papel,
                  border: Border(top: BorderSide(color: AppTheme.linha, width: 1)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL',
                          style: GoogleFonts.archivo(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppTheme.tinta,
                          ),
                        ),
                        Text(
                          currencyFormatter.format(cart.totalAmount),
                          style: GoogleFonts.archivo(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.tinta,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showCheckoutSuccessDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.tinta,
                          foregroundColor: AppTheme.papel,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        child: Text(
                          'FINALIZAR PEDIDO',
                          style: GoogleFonts.archivo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: 28,
      height: 28,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: AppTheme.linha, width: 1),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Icon(icon, size: 14, color: AppTheme.tinta),
      ),
    );
  }

  void _showCheckoutSuccessDialog(BuildContext context) {
    final cart = context.read<CartProvider>();
    final total = cart.totalAmount;
    cart.clearCart();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          'PEDIDO RECEBIDO',
          style: GoogleFonts.permanentMarker(fontSize: 24, color: AppTheme.tinta),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Obrigado pelo seu pedido!',
              style: GoogleFonts.archivo(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Cada estampa será serigrafada à mão em tiragem limitada especialmente para você.',
              style: GoogleFonts.archivo(fontSize: 14, color: AppTheme.tintaSuave, height: 1.4),
            ),
            const SizedBox(height: 12),
            Text(
              'Total: ${NumberFormat.currency(locale: "pt_BR", symbol: "R\$").format(total)}',
              style: GoogleFonts.archivo(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.tinta,
              foregroundColor: AppTheme.papel,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
