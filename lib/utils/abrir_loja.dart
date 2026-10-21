import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';

const lojaYouDraw = 'https://youdraw.store/licart';

/// Abre a página do produto na YouDraw (ou a loja, se o produto não tiver link).
Future<void> abrirNaLoja(BuildContext context, Product product) async {
  final link = (product.youdrawUrl?.isNotEmpty ?? false)
      ? product.youdrawUrl!
      : lojaYouDraw;
  // '_blank' abre em nova aba e mantém o site aberto. Use '_self' para abrir na mesma aba.
  final abriu = await launchUrl(Uri.parse(link), webOnlyWindowName: '_blank');
  if (!abriu && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não foi possível abrir a loja. Tente de novo.'),
      ),
    );
  }
}
