import 'package:app/core/models/report_models.dart';
import 'package:app/core/repositories/reports_repository.dart';
import 'package:app/widgets/app_navbar.dart';
import 'package:flutter/material.dart';

import 'widgets/report_card.dart';

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
    _repo = context.reportsRepo();
    _future = _repo.getFeed();
  }

  Future<void> _refresh() async {
    setState(() => _future = _repo.getFeed());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppNavbar(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<ReportItem>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const _FeedSkeleton();
            }
            if (snap.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 100),
                  Icon(Icons.wifi_off, size: 48, color: cs.error),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Falha ao carregar o feed',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: cs.error),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: FilledButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ),
                ],
              );
            }

            final items = snap.data ?? const <ReportItem>[];
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text('Sem publicações por aqui…')),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: items.length,
              itemBuilder: (context, i) => ReportCard(item: items[i]),
            );
          },
        ),
      ),
    );
  }
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar() => Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Row(
        children: [
          const _Box(w: 40, h: 40, r: 20),
          const SizedBox(width: 10),
          const Expanded(child: _Box(h: 14, r: 6)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
        ],
      ),
    );

    Widget block() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        _Box(h: 16, m: EdgeInsets.symmetric(horizontal: 12, vertical: 8), r: 6),
        AspectRatio(aspectRatio: 1, child: _Box()),
        SizedBox(height: 12),
      ],
    );

    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, i) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(children: [bar(), block()]),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final double? w;
  final double? h;
  final double r;
  final EdgeInsetsGeometry? m;

  const _Box({super.key, this.w, this.h, this.r = 12, this.m});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: h,
      margin: m,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}
