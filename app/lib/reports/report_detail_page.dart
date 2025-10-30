import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_footer.dart';
import '../services/service_locator.dart';
import '../services/report_service.dart';

/// TerraON — ReportDetailPage
///
/// Exibe os detalhes de uma denúncia.
/// - Tenta carregar por ID via ReportService.getReportById.
/// - Se não vier ID ou o serviço retornar null, mostra estado neutro.
/// - Botões separados: Curtir e Comentar (integração real depois).
class ReportDetailPage extends StatefulWidget {
  const ReportDetailPage({super.key});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  String? _id;
  bool _loading = false;
  ReportDetail? _detail;

  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Tenta capturar o ID passado via Navigator.pushNamed(..., arguments: 'id')
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _id = ModalRoute.of(context)?.settings.arguments as String?;
      _load();
    });
  }

  Future<void> _load() async {
    if (_id == null) {
      setState(() {
        _loading = false;
        _detail = null;
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final d = await reportService.getReportById(_id!);
      setState(() => _detail = d);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleLike() async {
    if (_id == null) return;
    try {
      final ok = await (reportService as dynamic).likeReport(_id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok == true ? 'Curtir registrado.' : 'Não foi possível curtir.')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ação de curtir não está disponível nesta build.')),
      );
    }
  }

  Future<void> _handleComment() async {
    if (_id == null) return;

    _commentCtrl.clear();
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Novo comentário'),
        content: TextField(
          controller: _commentCtrl,
          decoration: const InputDecoration(
            hintText: 'Escreva seu comentário...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Enviar')),
        ],
      ),
    );

    if (sent != true) return;
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    try {
      final ok = await (reportService as dynamic).addComment(_id!, text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok == true ? 'Comentário enviado.' : 'Não foi possível comentar.')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ação de comentar não está disponível nesta build.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppNavbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : (_detail == null
                    ? _EmptyDetail(scheme: scheme, textTheme: textTheme, id: _id)
                    : _DetailContent(
                        detail: _detail!,
                        onLike: _handleLike,
                        onComment: _handleComment,
                      )),
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }
}

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail({required this.scheme, required this.textTheme, required this.id});
  final ColorScheme scheme;
  final TextTheme textTheme;
  final String? id;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detalhes da denúncia', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            id == null
                ? 'Nenhuma denúncia selecionada.'
                : 'Não foi possível carregar os dados desta denúncia.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Quando o backend estiver ligado, esta tela exibirá o conteúdo real.',
            style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.detail,
    required this.onLike,
    required this.onComment,
  });

  final ReportDetail detail;
  final VoidCallback onLike;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Corrige status e campos nulos
    final statusLabel = (detail.status?.name ?? '').isEmpty
        ? 'Sem status'
        : detail.status!.name;
    final isAnon = detail.isAnonymous ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detalhes da denúncia', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withOpacity(0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (detail.title.isNotEmpty)
                Text(detail.title, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Categoria: ${detail.category}',
                style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      detail.district == null || detail.district!.isEmpty
                          ? detail.city
                          : '${detail.city} / ${detail.district}',
                      style: textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (detail.description.isNotEmpty)
                Text(detail.description, style: textTheme.bodyMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(statusLabel),
                    avatar: const Icon(Icons.info_outline, size: 16),
                    backgroundColor: scheme.secondaryContainer,
                  ),
                  Chip(
                    label: Text(isAnon ? 'Denunciante: Anônimo' : 'Denunciante: identificado'),
                    backgroundColor: scheme.surfaceVariant,
                  ),
                  Chip(
                    label: Text(detail.photos.isEmpty ? 'Sem fotos' : '${detail.photos.length} foto(s)'),
                    backgroundColor: scheme.surfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            FilledButton.icon(
              onPressed: onLike,
              icon: const Icon(Icons.thumb_up_outlined),
              label: const Text('Curtir'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onComment,
              icon: const Icon(Icons.mode_comment_outlined),
              label: const Text('Comentar'),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mapa será adicionado futuramente.')),
                );
              },
              icon: const Icon(Icons.map_outlined),
              label: const Text('Ver no mapa'),
            ),
          ],
        ),
      ],
    );
  }
}
