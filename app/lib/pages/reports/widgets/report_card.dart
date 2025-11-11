// lib/pages/reports/widgets/report_card.dart
import 'package:app/core/models/report_models.dart';
import 'package:app/widgets/avatar_cicle.dart';
import 'package:flutter/material.dart';
import 'image_carousel.dart';
import 'comment_tile.dart';

class ReportCard extends StatelessWidget {
  final ReportItem item;

  const ReportCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final showCity = [
      item.city,
      item.state,
    ].where((s) => s.isNotEmpty).join(' • ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      clipBehavior: Clip.antiAlias,
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                // >>> mudou: agora passa InlineImage
                AvatarCircle(avatar: item.authorAvatar, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.authorName.isEmpty ? 'Anônimo' : item.authorName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (showCity.isNotEmpty)
                        Text(
                          showCity,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
          ),

          // Texto
          if (item.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(item.description),
            ),

          // Imagens
          if (item.images.isNotEmpty) ReportImageCarousel(images: item.images),

          // Barra de ações (mock)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.mode_comment_outlined),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_border),
                ),
              ],
            ),
          ),

          // Comentários (preview)
          if (item.comments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Comentários',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...item.comments
                      .take(3)
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: CommentTile(c: c),
                        ),
                      ),
                  if (item.comments.length > 3)
                    TextButton(
                      onPressed: () {
                        // TODO: navegar para tela de comentários
                      },
                      child: Text('Ver todos (${item.comments.length})'),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
