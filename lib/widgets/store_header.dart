import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../views/login_page.dart';
import '../views/admin/admin_dashboard_page.dart';

class StoreHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onOpenCart;
  final VoidCallback? onScrollToStore;
  final VoidCallback? onScrollToProcess;
  final VoidCallback? onScrollToAbout;

  const StoreHeader({
    super.key,
    required this.onOpenCart,
    this.onScrollToStore,
    this.onScrollToProcess,
    this.onScrollToAbout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(112);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 720;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.papel,
        border: Border(bottom: BorderSide(color: AppTheme.linha, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 112,
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo Marca LICÀRT
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (onScrollToStore != null) {
                      onScrollToStore!();
                    }
                  },
                  child: Image.asset(
                    'assets/images/licart-logo-1024.png',
                    height: 96,
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Menu Central (Desktop)
              if (isDesktop)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavButton(label: 'LOJA', onTap: onScrollToStore),
                    const SizedBox(width: 24),
                    _NavButton(label: 'PROCESSO', onTap: onScrollToProcess),
                    const SizedBox(width: 24),
                    _NavButton(label: 'SOBRE', onTap: onScrollToAbout),
                  ],
                ),

              // Ações à Direita: Login / Admin + Sacola
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botão de Login / Acesso Admin
                  if (auth.isAuthenticated) ...[
                    if (auth.isAdmin)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminDashboardPage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 16,
                        ),
                        label: Text(
                          isDesktop ? 'ADMIN' : '',
                          style: GoogleFonts.archivo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.respingo,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.logout, size: 18),
                      tooltip: 'Sair (${auth.user?.name})',
                      color: AppTheme.tintaSuave,
                      onPressed: () => auth.logout(),
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.tinta,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'ENTRAR',
                        style: GoogleFonts.archivo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(width: 8),

                  // Botão Sacola de Compras com Badge
                  OutlinedButton(
                    onPressed: onOpenCart,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.tinta,
                      side: const BorderSide(color: AppTheme.tinta, width: 1),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SACOLA',
                          style: GoogleFonts.archivo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.tinta,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${cart.itemCount}',
                            style: GoogleFonts.archivo(
                              color: AppTheme.papel,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;

  const _NavButton({required this.label, this.onTap});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _isHovered ? AppTheme.tinta : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.archivo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: _isHovered ? AppTheme.tinta : AppTheme.tintaSuave,
            ),
          ),
        ),
      ),
    );
  }
}
