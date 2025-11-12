import 'package:app/core/models/report_models.dart';
import 'package:app/core/repositories/reports_repository.dart';
import 'package:app/widgets/avatar_cicle.dart';
import 'package:flutter/material.dart';
import 'image_carousel.dart';
import 'comment_tile.dart';
import 'comment_composer.dart'; // <-- precisa desse import

class ReportCard extends StatefulWidget {
  final ReportItem item;

  const ReportCard({super.key, required this.item});

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  bool _showComposer = false; // controla visibilidade

  void _toggleComposer() {
    setState(() => _showComposer = !_showComposer);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
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
          // Cabeçalho
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
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

          // Descrição
          if (item.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(item.description),
            ),

          // Imagens
          if (item.images.isNotEmpty) ReportImageCarousel(images: item.images),

          // Barra de ações
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border),
                ),
                IconButton(
                  onPressed:
                      _toggleComposer, // agora abre o campo de comentário
                  icon: Icon(
                    _showComposer
                        ? Icons.mode_comment
                        : Icons.mode_comment_outlined,
                  ),
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

          // Comentários (pré-visualização)
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
                        // TODO: abrir tela de todos os comentários
                      },
                      child: Text('Ver todos (${item.comments.length})'),
                    ),
                ],
              ),
            ),

          // Composer (visível só quando clicar)
          if (_showComposer) ...[
            Divider(height: 1, color: cs.outlineVariant),
            CommentComposer(
              reportId: item.id,
              onCommentSent: (_) async {
                final repo = context.reportsRepo();
                final updated = await repo.getFeed(); // implemente este método
                setState(() {
                  _showComposer = false;
                });
              },
            ),
          ],
        ],
      ),
    );
  }
}
