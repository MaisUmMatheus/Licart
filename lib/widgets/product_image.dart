import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Renderiza a foto de um produto: imagem enviada (base64), URL externa
/// ou, na ausência de ambas, a foto padrão da LICÀRT.
class ProductImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;

  const ProductImage({super.key, required this.imageUrl, this.fit = BoxFit.contain});

  static const String defaultAsset = 'assets/images/default-product.jpg';

  // Reaproveita os bytes já decodificados para a mesma imagem em builds
  // seguintes, evitando que o Flutter redecodifique (e pisque) a cada
  // rebuild do widget pai (hover, troca de página da galeria, etc).
  static final Map<String, Uint8List> _decodedCache = {};

  static Uint8List _decodeCached(String dataUri) {
    return _decodedCache.putIfAbsent(dataUri, () {
      final base64Data = dataUri.substring(dataUri.indexOf(',') + 1);
      return base64Decode(base64Data);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Image.asset(defaultAsset, fit: fit, gaplessPlayback: true);
    }

    if (imageUrl.startsWith('data:image')) {
      try {
        final bytes = _decodeCached(imageUrl);
        return Image.memory(
          bytes,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => Image.asset(defaultAsset, fit: fit, gaplessPlayback: true),
        );
      } catch (_) {
        return Image.asset(defaultAsset, fit: fit, gaplessPlayback: true);
      }
    }

    return Image.network(
      imageUrl,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => Image.asset(defaultAsset, fit: fit, gaplessPlayback: true),
    );
  }
}
