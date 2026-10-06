import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'admin/admin_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.isAdmin
                ? 'Bem-vindo, Administrador! Painel do ateliê liberado.'
                : 'Bem-vindo à LICÀRT, ${auth.user?.name}!',
            style: GoogleFonts.archivo(fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppTheme.tinta,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      );

      if (auth.isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
        );
      } else {
        Navigator.pop(context);
      }
    }
  }

  void _fillAdminDemo() {
    _emailController.text = 'admin@halina.com';
    _passwordController.text = 'admin123';
    _submitLogin();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.papel,
      appBar: AppBar(
        title: Text(
          'IDENTIFICAÇÃO',
          style: GoogleFonts.permanentMarker(fontSize: 20, color: AppTheme.tinta),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.tinta),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.papel,
                border: Border.all(color: AppTheme.linha, width: 1),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Marca / Cabeçalho
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.tinta,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                'L',
                                style: GoogleFonts.permanentMarker(
                                  color: AppTheme.papel,
                                  fontSize: 32,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'LICÀRT',
                            style: GoogleFonts.permanentMarker(
                              fontSize: 28,
                              color: AppTheme.tinta,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Acesse sua conta ou o painel de controle.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.archivo(
                              fontSize: 13,
                              color: AppTheme.tintaSuave,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Campo de E-mail
                    Text(
                      'E-MAIL',
                      style: GoogleFonts.archivo(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppTheme.tinta,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.archivo(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'exemplo@licart.com.br',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe seu e-mail';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Campo de Senha
                    Text(
                      'SENHA',
                      style: GoogleFonts.archivo(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppTheme.tinta,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.archivo(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppTheme.tintaSuave,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 4) {
                          return 'A senha deve ter pelo menos 4 caracteres';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Botão Entrar
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _submitLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.tinta,
                          foregroundColor: AppTheme.papel,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: AppTheme.papel, strokeWidth: 2),
                              )
                            : Text(
                                'ENTRAR',
                                style: GoogleFonts.archivo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Divider(color: AppTheme.linha),

                    const SizedBox(height: 20),

                    // Atalho Demo Administrador
                    OutlinedButton.icon(
                      onPressed: _fillAdminDemo,
                      icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                      label: const Text('ENTRAR COMO ADMINISTRADOR (DEMO)'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.tinta,
                        side: const BorderSide(color: AppTheme.linha),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Entrar como cliente demo
                    TextButton(
                      onPressed: () {
                        _emailController.text = 'cliente@licart.com.br';
                        _passwordController.text = '123456';
                        _submitLogin();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.tintaSuave,
                      ),
                      child: Text(
                        'Usar conta de cliente de teste',
                        style: GoogleFonts.archivo(
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
