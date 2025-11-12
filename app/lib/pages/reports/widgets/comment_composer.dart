import 'package:app/core/tokens/token_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/service_locator.dart';
import '../../../core/repositories/reports_repository.dart';

class CommentComposer extends StatefulWidget {
  final int reportId;
  final void Function(String content)? onCommentSent; // callback opcional

  const CommentComposer({
    super.key,
    required this.reportId,
    this.onCommentSent,
  });

  @override
  State<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<CommentComposer> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    // Lê o estado atual da sessão via MobX TokenStore
    final tokenStore = context.read<TokenStore>();
    final id = tokenStore.userId;

    if (id == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para comentar.')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      // Use o seu service locator (igual no restante do app)
      final repo = context.reportsRepo();

      // Se o backend inferir o autor pelo token, remova o authorId do body e do método
      await repo.createCommentRaw(
        reportId: widget.reportId,
        authorId: id,
        content: text,
      );

      widget.onCommentSent?.call(text);
      _controller.clear();
      _focusNode.unfocus();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Comentário enviado!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao comentar: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Reage a login/logout automaticamente
    final tokenStore = context.watch<TokenStore>();
    final isLogged = tokenStore.isLoggedIn;

    return Material(
      color: cs.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: IgnorePointer(
          ignoring: !isLogged,
          child: Opacity(
            opacity: isLogged ? 1 : 0.6,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    minLines: 1,
                    maxLines: 5,
                    maxLength: 500, // opcional
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: isLogged
                          ? 'Escreva um comentário...'
                          : 'Entre para comentar',
                      prefixIcon: const Icon(Icons.mode_comment_outlined),
                      counterText: '', // esconde contador do maxLength
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withOpacity(0.12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide(color: cs.outlineVariant),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: (!isLogged || _sending) ? null : _send,
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  tooltip: isLogged ? 'Enviar' : 'Entre para comentar',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
