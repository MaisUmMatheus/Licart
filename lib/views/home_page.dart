import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ink_splatter_painter.dart';
import '../widgets/product_card.dart';
import '../widgets/store_header.dart';
import 'cart_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _storeKey = GlobalKey();
  final GlobalKey _processKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();

  int _heroSeed = 20261005;

  final TextEditingController _newsletterController = TextEditingController();
  String _newsletterMessage = '';

  @override
  void dispose() {
    _scrollController.dispose();
    _newsletterController.dispose();
    super.dispose();
  }

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _openCart() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _redrawHeroSplatter() {
    setState(() {
      _heroSeed = Random().nextInt(100000000);
    });
  }

  void _subscribeNewsletter() {
    final email = _newsletterController.text.trim();
    if (RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() {
        _newsletterMessage =
            'Anotado. Você receberá o próximo drop antes de todo mundo.';
      });
      _newsletterController.clear();
    } else {
      setState(() {
        _newsletterMessage =
            'Esse e-mail parece incompleto. Confira o @ e o domínio.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.filteredProducts;
    final isDesktop = MediaQuery.of(context).size.width > 880;

    return Scaffold(
      key: _scaffoldKey,
      appBar: StoreHeader(
        onOpenCart: _openCart,
        onScrollToStore: () => _scrollToKey(_storeKey),
        onScrollToProcess: () => _scrollToKey(_processKey),
        onScrollToAbout: () => _scrollToKey(_aboutKey),
      ),
      endDrawer: const Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: CartSheet(),
      ),
      body: productProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.tinta,
                strokeWidth: 2,
              ),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. HERO SECTION
                  _buildHeroSection(isDesktop),

                  // 2. TICKER STRIP (FITA INFINITA DE NANQUIM)
                  _buildTickerStrip(),

                  // 3. SEÇÃO AS ESTAMPAS (CATÁLOGO / LOJA)
                  Container(
                    key: _storeKey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 48,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cabeçalho da Seção e Filtros
                            _buildCatalogHeader(productProvider),

                            const SizedBox(height: 32),

                            // Grid de Produtos
                            if (products.isEmpty)
                              _buildEmptyCatalog(productProvider)
                            else
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  int crossAxisCount = 3;
                                  if (constraints.maxWidth < 640) {
                                    crossAxisCount = 1;
                                  } else if (constraints.maxWidth < 980) {
                                    crossAxisCount = 2;
                                  }

                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: products.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          crossAxisSpacing: 24,
                                          mainAxisSpacing: 36,
                                          childAspectRatio: 0.62,
                                        ),
                                    itemBuilder: (context, index) {
                                      return ProductCard(
                                        product: products[index],
                                      );
                                    },
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 4. SEÇÃO PROCESSO (COMO A ARTE NASCE)
                  Container(
                    key: _processKey,
                    color: AppTheme.papel2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 64,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: _buildProcessSection(isDesktop),
                      ),
                    ),
                  ),

                  // 5. SEÇÃO MANIFESTO / SOBRE
                  Container(
                    key: _aboutKey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 64,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: _buildManifestoSection(isDesktop),
                      ),
                    ),
                  ),

                  // 6. SEÇÃO NEWSLETTER
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppTheme.linha, width: 1),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 64,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: _buildNewsletterSection(),
                      ),
                    ),
                  ),

                  // 7. FOOTER
                  _buildFooter(),
                ],
              ),
            ),
    );
  }

  // 1. HERO SECTION
  Widget _buildHeroSection(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 11, child: _buildHeroText()),
                    const SizedBox(width: 48),
                    Expanded(flex: 10, child: _buildHeroArtCanvas()),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroText(),
                    const SizedBox(height: 36),
                    _buildHeroArtCanvas(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DROP 07 · OUTUBRO 2026',
          style: GoogleFonts.archivo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppTheme.tintaSuave,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Desenhado\nà mão.\nImpresso\nem você.',
          style: GoogleFonts.permanentMarker(
            fontSize: 56,
            height: 0.98,
            color: AppTheme.tinta,
          ),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'Cada estampa começa com um pincel, nanquim e uma folha em branco. '
            'Nada de banco de imagens, nada de vetor pronto. O traço que você veste '
            'é o mesmo que saiu da mão.',
            style: GoogleFonts.archivo(
              fontSize: 18,
              height: 1.5,
              color: AppTheme.tintaSuave,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () => _scrollToKey(_storeKey),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.tinta,
                foregroundColor: AppTheme.papel,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                'VER A COLEÇÃO',
                style: GoogleFonts.archivo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () => _scrollToKey(_processKey),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.tinta,
                side: const BorderSide(color: AppTheme.tinta, width: 1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                'VER A ARTE NASCER',
                style: GoogleFonts.archivo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroArtCanvas() {
    return AspectRatio(
      aspectRatio: 4 / 4.8,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.papel2,
          border: Border.all(color: AppTheme.linha, width: 1),
        ),
        child: Stack(
          children: [
            // Pintura de Nanquim Dinâmica
            Positioned.fill(
              child: CustomPaint(
                painter: InkSplatterPainter(
                  seed: _heroSeed,
                  sizeRatio: 0.28,
                  customCenterY: 0.48,
                  drawStroke: true,
                  drawDrip: true,
                ),
              ),
            ),

            // Carimbo "Novo Drop" em vermelho com rotação -12 graus
            Positioned(
              top: 24,
              right: 24,
              child: Transform.rotate(
                angle: -12 * (pi / 180),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: AppTheme.respingo,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'NOVO',
                          style: GoogleFonts.archivo(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppTheme.sobreRespingo,
                          ),
                        ),
                        Text(
                          'Drop',
                          style: GoogleFonts.permanentMarker(
                            fontSize: 26,
                            color: AppTheme.sobreRespingo,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Rodapé do Canvas com botão "Respingar de novo"
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Original · nanquim sobre papel 300g',
                    style: GoogleFonts.archivo(
                      fontSize: 12,
                      color: AppTheme.tintaSuave,
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _redrawHeroSplatter,
                      child: Text(
                        'Respingar de novo',
                        style: GoogleFonts.archivo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.tinta,
                          decoration: TextDecoration.underline,
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

  // 2. TICKER STRIP
  Widget _buildTickerStrip() {
    return Container(
      color: AppTheme.tinta,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(children: [..._buildTickerItems(), ..._buildTickerItems()]),
      ),
    );
  }

  List<Widget> _buildTickerItems() {
    final words = [
      'Feito à mão',
      'Nanquim',
      'Algodão 100%',
      'Serigrafia',
      'Tiragem limitada',
      'Arte que nasce do nada',
    ];

    return words.map((w) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          w,
          style: GoogleFonts.permanentMarker(
            color: AppTheme.papel,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
      );
    }).toList();
  }

  // 3. CATALOG HEADER
  Widget _buildCatalogHeader(ProductProvider provider) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 16,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'As estampas',
              style: GoogleFonts.archivo(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppTheme.tinta,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Peças exclusivas com tiragem reduzida e serigrafia artesanal.',
              style: GoogleFonts.archivo(
                fontSize: 14,
                color: AppTheme.tintaSuave,
              ),
            ),
          ],
        ),

        // Filtro em Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: provider.categories.map((cat) {
            final isSelected = provider.selectedCategory == cat;
            return OutlinedButton(
              onPressed: () => provider.setCategory(cat),
              style: OutlinedButton.styleFrom(
                backgroundColor: isSelected
                    ? AppTheme.tinta
                    : Colors.transparent,
                foregroundColor: isSelected ? AppTheme.papel : AppTheme.tinta,
                side: BorderSide(
                  color: isSelected ? AppTheme.tinta : AppTheme.linha,
                  width: 1,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                cat.toUpperCase(),
                style: GoogleFonts.archivo(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyCatalog(ProductProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            const Icon(
              Icons.brush_outlined,
              size: 48,
              color: AppTheme.tintaSuave,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma estampa encontrada para esta seleção.',
              style: GoogleFonts.archivo(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.tinta,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                provider.setCategory('Todas');
                provider.setSearchQuery('');
              },
              child: const Text('VER TODAS AS ESTAMPAS'),
            ),
          ],
        ),
      ),
    );
  }

  // 4. PROCESSO (COMO A ARTE NASCE)
  Widget _buildProcessSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Como a arte nasce',
          style: GoogleFonts.permanentMarker(
            fontSize: 38,
            color: AppTheme.tinta,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Text(
            'Toda camisa passa pelas mesmas três etapas. A ordem não muda, e nenhuma delas é feita por máquina sozinha.',
            style: GoogleFonts.archivo(
              fontSize: 16,
              color: AppTheme.tintaSuave,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 48),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildProcessStep(
                  number: '1',
                  title: 'Rascunho',
                  desc:
                      'Um traço solto num caderno A4. Muitos não passam daqui. Os que ficam viram arte em tamanho real.',
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: _buildProcessStep(
                  number: '2',
                  title: 'Nanquim',
                  desc:
                      'Pincel seco, nanquim e papel 300g. O respingo acontece uma vez só. Se não ficou bom, a folha vai para o lixo.',
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: _buildProcessStep(
                  number: '3',
                  title: 'Serigrafia',
                  desc:
                      'A arte é escaneada em alta e gravada em tela. Cada camisa é puxada à mão, uma por uma, em algodão 100%.',
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildProcessStep(
                number: '1',
                title: 'Rascunho',
                desc:
                    'Um traço solto num caderno A4. Muitos não passam daqui. Os que ficam viram arte em tamanho real.',
              ),
              const SizedBox(height: 32),
              _buildProcessStep(
                number: '2',
                title: 'Nanquim',
                desc:
                    'Pincel seco, nanquim e papel 300g. O respingo acontece uma vez só. Se não ficou bom, a folha vai para o lixo.',
              ),
              const SizedBox(height: 32),
              _buildProcessStep(
                number: '3',
                title: 'Serigrafia',
                desc:
                    'A arte é escaneada em alta e gravada em tela. Cada camisa é puxada à mão, uma por uma, em algodão 100%.',
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildProcessStep({
    required String number,
    required String title,
    required String desc,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.tinta, width: 2)),
      ),
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: GoogleFonts.permanentMarker(
              fontSize: 38,
              color: AppTheme.tinta,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.archivo(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.tinta,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: GoogleFonts.archivo(
              fontSize: 14,
              color: AppTheme.tintaSuave,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 5. MANIFESTO
  Widget _buildManifestoSection(bool isDesktop) {
    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  '“Arte que surge do nada. Uma folha em branco, um pincel e uma madrugada.”',
                  style: GoogleFonts.permanentMarker(
                    fontSize: 40,
                    height: 1.1,
                    color: AppTheme.tinta,
                  ),
                ),
              ),
              const SizedBox(width: 48),
              Expanded(flex: 1, child: _buildManifestoFacts()),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '“Arte que surge do nada. Uma folha em branco, um pincel e uma madrugada.”',
                style: GoogleFonts.permanentMarker(
                  fontSize: 32,
                  height: 1.15,
                  color: AppTheme.tinta,
                ),
              ),
              const SizedBox(height: 32),
              _buildManifestoFacts(),
            ],
          );
  }

  Widget _buildManifestoFacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A LICÀRT nasceu numa mesa de desenho. Cada estampa é um original que existe no papel antes de existir no tecido. Por isso as tiragens são curtas: quando acaba, a folha volta para a gaveta.',
          style: GoogleFonts.archivo(
            fontSize: 16,
            height: 1.6,
            color: AppTheme.tintaSuave,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _buildFactItem(value: '100%', label: 'algodão penteado'),
            ),
            Expanded(
              child: _buildFactItem(value: '150', label: 'peças por estampa'),
            ),
            Expanded(
              child: _buildFactItem(value: '1', label: 'original no papel'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFactItem({required String value, required String label}) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppTheme.linha, width: 1)),
      ),
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.permanentMarker(
              fontSize: 34,
              color: AppTheme.tinta,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.archivo(
              fontSize: 12,
              color: AppTheme.tintaSuave,
            ),
          ),
        ],
      ),
    );
  }

  // 6. NEWSLETTER
  Widget _buildNewsletterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fique sabendo do próximo drop',
          style: GoogleFonts.archivo(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.tinta,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Um e-mail por drop, com a arte original antes de virar camisa. Sem spam.',
          style: GoogleFonts.archivo(fontSize: 15, color: AppTheme.tintaSuave),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _newsletterController,
                    decoration: const InputDecoration(
                      hintText: 'seu@email.com',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _subscribeNewsletter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.tinta,
                    foregroundColor: AppTheme.papel,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'AVISAR',
                    style: GoogleFonts.archivo(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_newsletterMessage.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            _newsletterMessage,
            style: GoogleFonts.archivo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _newsletterMessage.contains('incompleto')
                  ? AppTheme.respingo
                  : AppTheme.tinta,
            ),
          ),
        ],
      ],
    );
  }

  // 7. FOOTER
  Widget _buildFooter() {
    return Container(
      color: AppTheme.tinta,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 32,
            spacing: 32,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LICÀRT',
                    style: GoogleFonts.permanentMarker(
                      fontSize: 36,
                      color: AppTheme.papel,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Desenhado à mão no Brasil.',
                    style: GoogleFonts.archivo(
                      fontSize: 14,
                      color: AppTheme.papel.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 48,
                runSpacing: 24,
                children: [
                  _buildFooterCol(
                    label: 'CONTATO',
                    value: 'contato@licart.com.br',
                  ),
                  _buildFooterCol(label: 'INSTAGRAM', value: '@licart'),
                  _buildFooterCol(label: 'TROCAS', value: 'Até 30 dias'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterCol({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.archivo(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: AppTheme.papel.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 6),
        SelectableText(
          value,
          style: GoogleFonts.archivo(fontSize: 14, color: AppTheme.papel),
        ),
      ],
    );
  }
}
