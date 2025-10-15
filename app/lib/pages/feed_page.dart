import 'dart:convert';
import 'dart:typed_data';

import 'package:app/core/tokens/token_store.dart';
import 'package:app/widgets/app_navbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/models/report_models.dart';
import '../core/repositories/reports_repository.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late final ReportsRepository _repo;
  late Future<List<ReportItem>> _future;

  @override
  void initState() {
    super.initState();
    final apiClient = context.read<ApiClient>();
    final tokenStore = context.read<TokenStore>();
    _repo = ReportsRepository(apiClient, tokenStore);
    _future = _repo.getFeed();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppNavbar(),
      body: FutureBuilder<List<ReportItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erro ao carregar feed:\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const Center(
              child: Text('Nenhuma publicação por aqui ainda.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => ReportCard(item: items[i]),
          );
        },
      ),
      backgroundColor: cs.surface,
    );
  }
}

class ReportCard extends StatefulWidget {
  const ReportCard({super.key, required this.item});
  final ReportItem item;

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  late final PageController _pageCtrl;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final item = widget.item;
    final images = item.imagesBase64;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho: avatar + nome
            Row(
              children: [
                _AvatarPlaceholder(name: item.authorName),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.authorName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Descrição
            if (item.description.isNotEmpty)
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.9),
                ),
              ),

            // Carrossel de fotos (quando houver)
            if (images.isNotEmpty) ...[
              const SizedBox(height: 10),
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                      controller: _pageCtrl,
                      onPageChanged: (v) => setState(() => _page = v),
                      itemCount: images.length,
                      itemBuilder: (_, idx) {
                        final bytes = _decodeBase64(images[idx]);
                        if (bytes == null) {
                          return _BrokenImagePlaceholder(color: cs.error);
                        }
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            bytes,
                            gaplessPlayback: true,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                            errorBuilder: (_, __, ___) =>
                                _BrokenImagePlaceholder(color: cs.error),
                          ),
                        );
                      },
                    ),
                    // Dots
                    Positioned(
                      bottom: 8,
                      child: _DotsIndicator(
                        length: images.length,
                        index: _page,
                        activeColor: cs.primary,
                        inactiveColor: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Aceita base64 puro ou data URI (ex: data:image/jpeg;base64,xxxx)
  Uint8List? _decodeBase64(String data) {
    try {
      final comma = data.indexOf(',');
      final payload = comma >= 0 ? data.substring(comma + 1) : data;
      return base64Decode(payload);
    } catch (_) {
      return null;
    }
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final initials = _initials(name);

    return CircleAvatar(
      radius: 20,
      backgroundColor: cs.primaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          color: cs.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _initials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.length,
    required this.index,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int length;
  final int index;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: List.generate(length, (i) {
            final active = i == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: active ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _BrokenImagePlaceholder extends StatelessWidget {
  const _BrokenImagePlaceholder({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      alignment: Alignment.center,
      child: Icon(Icons.broken_image_outlined, size: 36, color: color),
    );
  }
}
