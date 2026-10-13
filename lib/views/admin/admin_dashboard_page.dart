import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_image.dart';
import 'add_product_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final auth = context.watch<AuthProvider>();
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final totalStockValue = productProvider.products.fold<double>(
      0.0,
      (sum, p) => sum + (p.price * p.stock),
    );
    final totalUnits = productProvider.products.fold<int>(
      0,
      (sum, p) => sum + p.stock,
    );

    return Scaffold(
      backgroundColor: AppTheme.papel,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: AppTheme.tinta,
              child: Text(
                'ATELIÊ',
                style: GoogleFonts.archivo(
                  color: AppTheme.papel,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'PAINEL ADMINISTRATIVO',
              style: GoogleFonts.permanentMarker(fontSize: 20, color: AppTheme.tinta),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.storefront_outlined, size: 16),
            label: Text(
              'VER VITRINE',
              style: GoogleFonts.archivo(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            style: TextButton.styleFrom(foregroundColor: AppTheme.tinta),
          ),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.tinta,
        foregroundColor: AppTheme.papel,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
        },
        icon: const Icon(Icons.add, size: 18),
        label: Text(
          'NOVA ESTAMPA / PRODUTO',
          style: GoogleFonts.archivo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Boas-vindas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, ${auth.user?.name ?? "Administrador"} 👋',
                          style: GoogleFonts.permanentMarker(
                            fontSize: 28,
                            color: AppTheme.tinta,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gerencie o catálogo de estampas, tiragens de drops e estoque.',
                          style: GoogleFonts.archivo(
                            fontSize: 14,
                            color: AppTheme.tintaSuave,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Cards de Métricas
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 650;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isSmall ? 1 : 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isSmall ? 2.5 : 1.7,
                      children: [
                        _buildMetricCard(
                          title: 'TOTAL DE ESTAMPAS',
                          value: '${productProvider.products.length}',
                          icon: Icons.palette_outlined,
                        ),
                        _buildMetricCard(
                          title: 'PEÇAS EM ESTOQUE',
                          value: '$totalUnits un.',
                          icon: Icons.inventory_2_outlined,
                        ),
                        _buildMetricCard(
                          title: 'VALOR DO ESTOQUE',
                          value: currencyFormatter.format(totalStockValue),
                          icon: Icons.monetization_on_outlined,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Título da Tabela
                Text(
                  'Catálogo de Estampas',
                  style: GoogleFonts.archivo(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.tinta,
                  ),
                ),
                const SizedBox(height: 16),

                // Lista de Itens do Catálogo
                if (productProvider.products.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.linha),
                    ),
                    child: Center(
                      child: Text(
                        'Nenhuma estampa cadastrada.',
                        style: GoogleFonts.archivo(color: AppTheme.tintaSuave),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: productProvider.products.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = productProvider.products[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.papel,
                          border: Border.all(color: AppTheme.linha),
                        ),
                        child: Row(
                          children: [
                            // Miniatura com Nanquim / Imagem
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppTheme.papel2,
                                border: Border.all(color: AppTheme.linha),
                              ),
                              child: ProductImage(imageUrl: product.imageUrl),
                            ),

                            const SizedBox(width: 16),

                            // Informações do Produto
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        product.name,
                                        style: GoogleFonts.permanentMarker(
                                          fontSize: 18,
                                          color: AppTheme.tinta,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        color: AppTheme.papel2,
                                        child: Text(
                                          (product.tag ?? product.category).toUpperCase(),
                                          style: GoogleFonts.archivo(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.tintaSuave,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.archivo(
                                      fontSize: 13,
                                      color: AppTheme.tintaSuave,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${currencyFormatter.format(product.price)} • Estoque: ${product.stock} peças',
                                    style: GoogleFonts.archivo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.tinta,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Botão Editar
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppTheme.tinta),
                              tooltip: 'Editar estampa',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddProductPage(editingProduct: product),
                                  ),
                                );
                              },
                            ),

                            // Botão Excluir
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.respingo),
                              tooltip: 'Remover estampa',
                              onPressed: () {
                                _confirmDeleteProduct(context, productProvider, product.id, product.name);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.papel2,
        border: Border.all(color: AppTheme.linha),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.archivo(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppTheme.tintaSuave,
                ),
              ),
              Icon(icon, size: 20, color: AppTheme.tinta),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.permanentMarker(
              fontSize: 26,
              color: AppTheme.tinta,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProduct(
    BuildContext context,
    ProductProvider provider,
    String id,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          'REMOVER ESTAMPA',
          style: GoogleFonts.permanentMarker(fontSize: 20, color: AppTheme.tinta),
        ),
        content: Text(
          'Deseja realmente remover "$name" do catálogo?',
          style: GoogleFonts.archivo(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCELAR',
              style: GoogleFonts.archivo(fontWeight: FontWeight.w700, color: AppTheme.tintaSuave),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              provider.removeProduct(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.respingo,
              foregroundColor: AppTheme.papel,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('REMOVER'),
          ),
        ],
      ),
    );
  }
}
