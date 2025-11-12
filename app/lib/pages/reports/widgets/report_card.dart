import 'package:app/core/models/report_models.dart';
import 'package:app/core/repositories/reports_repository.dart';
import 'package:app/widgets/avatar_cicle.dart';
import 'package:flutter/material.dart';
import 'image_carousel.dart';
import 'comment_tile.dart';
import 'comment_composer.dart';
import 'package:provider/provider.dart';
import 'package:app/core/tokens/token_store.dart';

class ReportCard extends StatefulWidget {
  final ReportItem item;

  const ReportCard({super.key, required this.item});

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  bool _showComposer = false; // controla visibilidade
  late bool _isLiked;
  late int _likeCount;

  bool _showAllComments = false;
  final _commentsKey = GlobalKey();

  void _toggleComposer() {
    setState(() => _showComposer = !_showComposer);
  }

  @override
  void initState() {
    super.initState();

    final tokenStore = context.read<TokenStore>();
    final currentUserId = tokenStore.userId;

    _isLiked =
        currentUserId != null &&
        widget.item.likes.any((l) => l.userId == currentUserId);

    _likeCount = widget.item.likeCount;
  }

  Future<void> _toggleLike() async {
    final repo = context.reportsRepo();
    setState(() {
      // feedback imediato (UI otimista)
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      await repo.toggleLike(widget.item.id);
    } catch (e) {
      // rollback em caso de erro
      setState(() {
        _isLiked = !_isLiked;
        _likeCount += _isLiked ? 1 : -1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao curtir. Tente novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final cs = Theme.of(context).colorScheme;

    final showCity = [
      item.city,
      item.state,
    ].where((s) => s.isNotEmpty).join(' • ');

    final visibleComments = _showAllComments
        ? item.comments
        : item.comments.take(3).toList();

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
                Row(
                  children: [
                    IconButton(
                      onPressed: _toggleLike,
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_likeCount > 0) // <<-- só mostra se tiver pelo menos 1
                      Text(
                        '$_likeCount',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),

                IconButton(
                  onPressed: _toggleComposer,
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
              key: _commentsKey, // <-- ancora para rolar
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Comentários (${item.comments.length})', // mostra total
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // anima a abertura/fechamento da lista
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        for (final c in visibleComments)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: CommentTile(c: c),
                          ),
                      ],
                    ),
                  ),

                  if (item.comments.length > 3)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          setState(() => _showAllComments = !_showAllComments);

                          if (_showAllComments) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final ctx = _commentsKey.currentContext;
                              if (ctx != null) {
                                Scrollable.ensureVisible(
                                  ctx,
                                  duration: const Duration(milliseconds: 200),
                                  alignment: 0.0,
                                );
                              }
                            });
                          }
                        },
                        child: Text(
                          _showAllComments
                              ? 'Ver menos'
                              : 'Ver todos (${item.comments.length})',
                        ),
                      ),
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
