import 'package:flutter/material.dart';

class CrestImage extends StatelessWidget {
  static const String fallbackAsset = 'assets/default_crest.png';

  final String? crestUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const CrestImage({
    Key? key,
    required this.crestUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final url = (crestUrl ?? '').trim();
    if (url.isEmpty) return _fallback();

    if (url.toLowerCase().contains('.svg')) return _fallback();

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() {
    return Image.asset(
      fallbackAsset,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
