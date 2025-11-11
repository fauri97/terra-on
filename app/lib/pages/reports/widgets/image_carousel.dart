// lib/pages/reports/widgets/image_carousel.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:app/core/models/report_models.dart';

class ReportImageCarousel extends StatefulWidget {
  final List<ReportImage> images;

  const ReportImageCarousel({super.key, required this.images});

  @override
  State<ReportImageCarousel> createState() => _ReportImageCarouselState();
}

class _ReportImageCarouselState extends State<ReportImageCarousel> {
  int index = 0;

  Uint8List? _decode(ReportImage img) {
    try {
      final b64 = img.base64 ?? '';
      if (b64.isEmpty) {
        debugPrint('[Carousel] base64 vazio para imageId=${img.id}');
        return null;
      }
      // base64 puro (sem data URL)
      final bytes = base64Decode(b64);
      if (bytes.isEmpty) {
        debugPrint('[Carousel] bytes vazios para imageId=${img.id}');
        return null;
      }
      return bytes;
    } catch (e) {
      debugPrint('[Carousel] Falha ao decodificar imageId=${img.id}: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imgs = widget.images;
    if (imgs.isEmpty) return const SizedBox.shrink();

    debugPrint('[Carousel] recebidas ${imgs.length} imagens');

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: imgs.length,
            onPageChanged: (i) => setState(() => index = i),
            itemBuilder: (context, i) {
              final bytes = _decode(imgs[i]);
              if (bytes == null) {
                return const ColoredBox(
                  color: Colors.black12,
                  child: Center(child: Icon(Icons.broken_image_outlined)),
                );
              }
              return Image.memory(bytes, fit: BoxFit.cover);
            },
          ),
          if (imgs.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  imgs.length,
                  (i) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (i == index) ? Colors.white : Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
