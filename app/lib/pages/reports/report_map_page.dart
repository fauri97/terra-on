import 'package:app/pages/reports/widgets/report_map_widget.dart';
import 'package:app/services/report_mapper_service.dart';
import 'package:flutter/material.dart';
import 'package:app/core/models/report_models.dart';
import 'package:app/core/repositories/reports_repository.dart';
import 'package:app/widgets/app_navbar.dart';

class ReportMapPage extends StatefulWidget {
  const ReportMapPage({super.key});

  @override
  State<ReportMapPage> createState() => _ReportMapPageState();
}

class _ReportMapPageState extends State<ReportMapPage> {
  late final ReportsRepository _repo;
  late Future<List<ReportItem>> _future;

  @override
  void initState() {
    super.initState();
    _repo = context.reportsRepo();
    _future = _repo.getFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(),
      body: FutureBuilder<List<ReportItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erro ao carregar: ${snap.error}'));
          }

          final items = snap.data ?? const <ReportItem>[];
          final mapped = items
              .map(toBasic)
              .where((r) => r.lat != 0 && r.lng != 0)
              .toList();

          if (mapped.isEmpty) {
            return const Center(child: Text('Nenhuma ocorrência no mapa.'));
          }

          return ReportsMapWidget(reports: mapped);
        },
      ),
    );
  }
}
