import 'package:app/pages/reports/widgets/report_map_widget.dart';
import 'package:latlong2/latlong.dart';
import '../core/models/report_models.dart';

double _parseCoord(String s, {double fallback = 0}) {
  if (s.isEmpty) return fallback;
  final d1 = double.tryParse(s);
  if (d1 != null) return d1;
  final d2 = double.tryParse(s.replaceAll(',', '.'));
  return d2 ?? fallback;
}

BasicReport toBasic(ReportItem x) {
  final lat = _parseCoord(x.latitude);
  final lng = _parseCoord(x.longitude);

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
