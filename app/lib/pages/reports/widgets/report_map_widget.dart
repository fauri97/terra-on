import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

class BasicReport {
  final String id;
  final double lat;
  final double lng;
  final String title;
  final String? subtitle; // e.g., status/category/address
  final String? description;
  final String? imageUrl;

  const BasicReport({
    required this.id,
    required this.lat,
    required this.lng,
    required this.title,
    this.subtitle,
    this.description,
    this.imageUrl,
  });
}

typedef ReportTap = void Function(BasicReport report);

class ReportsMapWidget extends StatefulWidget {
  const ReportsMapWidget({
    super.key,
    required this.reports,
    this.initialCenter,
    this.initialZoom = 13,
    this.onTapMarker,
    this.useCluster = true,
    this.tileUrlTemplate = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    this.tileSubdomains = const ['a', 'b', 'c'],
    this.userAgentPackageName = 'com.seu.app',
    this.markerBuilder,
    this.fitPadding = const EdgeInsets.all(24),
    this.emptyFallbackCenter = const LatLng(-14.235004, -51.92528), // BR
  });

  /// Reports to plot on the map. Provide BasicReport or map your model.
  final List<BasicReport> reports;

  /// Optional center for the very first camera position.
  final LatLng? initialCenter;
  final double initialZoom;

  /// Called when a marker is tapped. If null, a default bottom sheet is shown.
  final ReportTap? onTapMarker;

  /// Whether to use cluster for markers.
  final bool useCluster;

  /// Tile layer config (consider a paid provider for heavy usage).
  final String tileUrlTemplate;
  final List<String> tileSubdomains;
  final String userAgentPackageName;

  /// Optional custom marker builder. If null, uses default pin icon.
  final Widget Function(BasicReport report)? markerBuilder;

  /// Padding used when fitting all points in view.
  final EdgeInsets fitPadding;

  /// If [reports] is empty, we center on this.
  final LatLng emptyFallbackCenter;

  @override
  State<ReportsMapWidget> createState() => _ReportsMapWidgetState();
}

class _ReportsMapWidgetState extends State<ReportsMapWidget> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final reports = widget.reports;
    final center =
        widget.initialCenter ??
        (reports.isNotEmpty
            ? LatLng(reports.first.lat, reports.first.lng)
            : widget.emptyFallbackCenter);

    final markers = reports
        .map(
          (r) => Marker(
            point: LatLng(r.lat, r.lng),
            width: 44,
            height: 44,
            alignment: Alignment.topCenter,
            child: _MarkerButton(
              child:
                  widget.markerBuilder?.call(r) ??
                  const Icon(Icons.location_on, size: 40),
              onPressed: () => _onTapMarker(r),
            ),
          ),
        )
        .toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: widget.initialZoom,
          ),
          children: [
            TileLayer(
              urlTemplate: widget.tileUrlTemplate,
              subdomains: widget.tileSubdomains,
              userAgentPackageName: widget.userAgentPackageName,
            ),
            if (!widget.useCluster) MarkerLayer(markers: markers),
            if (widget.useCluster)
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 48,
                  size: const Size(40, 40),
                  disableClusteringAtZoom: 18,
                  padding: widget.fitPadding,
                  markers: markers,
                  builder: (context, clusterMarkers) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      clusterMarkers.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        // UI actions
        Positioned(
          right: 12,
          bottom: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RoundBtn(
                icon: Icons.fit_screen,
                tooltip: 'Enquadrar pontos',
                onTap: () => _fitAll(reports),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onTapMarker(BasicReport r) {
    if (widget.onTapMarker != null) {
      widget.onTapMarker!(r);
      return;
    }
    _showDefaultBottomSheet(r);
  }

  void _showDefaultBottomSheet(BasicReport r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).padding.bottom + 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.report, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.title,
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (r.subtitle != null)
                          Text(
                            r.subtitle!,
                            style: Theme.of(ctx).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (r.description != null)
                Text(r.description!, style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Fechar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _fitAll(List<BasicReport> reports) {
    if (reports.isEmpty) return;

    double minLat = reports.first.lat;
    double maxLat = reports.first.lat;
    double minLng = reports.first.lng;
    double maxLng = reports.first.lng;

    for (final r in reports) {
      if (r.lat < minLat) minLat = r.lat;
      if (r.lat > maxLat) maxLat = r.lat;
      if (r.lng < minLng) minLng = r.lng;
      if (r.lng > maxLng) maxLng = r.lng;
    }

    final bounds = LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: widget.fitPadding),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap, this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg.withOpacity(0.95),
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Tooltip(message: tooltip ?? '', child: Icon(icon, size: 22)),
          ),
        ),
      ),
    );
  }
}

class _MarkerButton extends StatelessWidget {
  const _MarkerButton({required this.child, required this.onPressed});
  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onPressed, child: child);
  }
}

// =======================
// Example usage:
// =======================
//
// class ReportsMapPage extends StatelessWidget {
//   const ReportsMapPage({super.key});
//
//   List<BasicReport> get demoReports => const [
//     BasicReport(
//       id: '1',
//       lat: -29.7945,
//       lng: -51.8650,
//       title: 'Buraco na rua',
//       subtitle: 'Aberto · Bairro Centro',
//       description: 'Cratera próxima à esquina. Risco de acidentes.',
//     ),
//     BasicReport(
//       id: '2',
//       lat: -29.7990,
//       lng: -51.8600,
//       title: 'Lâmpada queimada',
//       subtitle: 'Em análise · Rua B',
//     ),
//     BasicReport(
//       id: '3',
//       lat: -29.8005,
//       lng: -51.8705,
//       title: 'Entulho',
//       subtitle: 'Resolvido · Praça C',
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Denúncias no mapa')),
//       body: ReportsMapWidget(
//         reports: demoReports,
//         useCluster: true,
//         onTapMarker: (r) {
//           // Navegar para a página de detalhes, se preferir:
//           // context.push('/reports/${r.id}');
//         },
//       ),
//     );
//   }
// }

// =======================
// Adapting to your existing ReportItem model:
// =======================
// If you already have `ReportItem` with different field names, 
// create a mapper:
//
// BasicReport toBasic(ReportItem x) => BasicReport(
//   id: x.id.toString(),
//   lat: x.latitude,
//   lng: x.longitude,
//   title: x.title ?? 'Sem título',
//   subtitle: '${x.statusName} · ${x.districtName}',
//   description: x.description,
// );
//
// final list = await _repo.getFeed();
// final mapped = list.map(toBasic).toList();
// ReportsMapWidget(reports: mapped);

/*
=======================
Adapter & Example (place in your own files)
=======================

// Put the following snippets in your own files (NOT inside this widget file),
// so imports stay at the top of each file and you can add the proper imports
// for ReportItem/ApiClient/ReportsRepository.

// 1) Safe parser for String -> double (accepts comma or dot)
double _parseCoord(String s, {double fallback = 0}) {
  if (s.isEmpty) return fallback;
  final d1 = double.tryParse(s);
  if (d1 != null) return d1;
  final d2 = double.tryParse(s.replaceAll(',', '.'));
  return d2 ?? fallback;
}

// 2) Mapper from ReportItem -> BasicReport
BasicReport toBasic(ReportItem x) {
  final lat = _parseCoord(x.latitude, fallback: 0);
  final lng = _parseCoord(x.longitude, fallback: 0);
  final subtitleParts = [
    if (x.bairro.isNotEmpty) x.bairro,
    if (x.city.isNotEmpty) x.city,
    if (x.state.isNotEmpty) x.state,
  ];
  final addr = x.address.isNotEmpty ? x.address : subtitleParts.join(' · ');
  return BasicReport(
    id: x.id.toString(),
    lat: lat,
    lng: lng,
    title: addr.isNotEmpty ? addr : 'Ocorrência #${x.id}',
    subtitle: subtitleParts.join(' · '),
    description: x.description,
  );
}

// 3) Example page using FutureBuilder + ReportsMapWidget
class ReportsMapPage extends StatefulWidget {
  const ReportsMapPage({super.key});
  @override
  State<ReportsMapPage> createState() => _ReportsMapPageState();
}

class _ReportsMapPageState extends State<ReportsMapPage> {
  late final ReportsRepository _repo;
  late Future<List<ReportItem>> _future;

  @override
  void initState() {
    super.initState();
    final apiClient = context.read<ApiClient>();
    _repo = ReportsRepository(apiClient);
    _future = _repo.getFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ocorrências no mapa')),
      body: FutureBuilder<List<ReportItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Falha ao carregar: ${snapshot.error}'));
          }

          final items = snapshot.data ?? const <ReportItem>[];
          final mapped = items
              .map(toBasic)
              .where((b) => b.lat != 0 && b.lng != 0)
              .toList();

          if (mapped.isEmpty) {
            return const Center(
              child: Text('Nenhuma ocorrência com coordenadas válidas.'),
            );
          }

          return ReportsMapWidget(
            reports: mapped,
            useCluster: true,
            onTapMarker: (r) {
              // Navigate to details or open a bottom sheet
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(r.title),
                  content: Text(r.description ?? 'Sem descrição'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
*/