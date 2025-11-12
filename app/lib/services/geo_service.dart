import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GeoResult {
  final bool permissionDenied;
  final double? latitude;
  final double? longitude;
  final String? uf; // Ex.: "RS"
  final String? city; // Ex.: "Porto Alegre"
  final String? district; // Bairro
  final String? address; // Rua + número (quando disponível)
  final String? cep; // CEP (quando disponível)

  const GeoResult({
    required this.permissionDenied,
    this.latitude,
    this.longitude,
    this.uf,
    this.city,
    this.district,
    this.address,
    this.cep,
  });
}

class GeoService {
  /// Retorna UF, cidade, bairro, endereço, CEP e lat/lon.
  Future<GeoResult> getCurrentCityAndState() async {
    // 1) Checa/solicita permissão
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever ||
        perm == LocationPermission.denied) {
      return const GeoResult(permissionDenied: true);
    }

    // 2) Pega posição atual
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    // 3) Reverse geocoding → Placemark
    final placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );
    if (placemarks.isEmpty) {
      return GeoResult(
        permissionDenied: false,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
    }
    final p = placemarks.first;

    final ufCandidate = (p.administrativeArea ?? '').trim();
    final city = (p.locality ?? p.subAdministrativeArea ?? '').trim();
    final district = (p.subLocality ?? '').trim();
    final street = (p.thoroughfare ?? '').trim();
    final number = (p.subThoroughfare ?? '').trim();
    final address = [street, number].where((s) => s.isNotEmpty).join(', ');
    final cep = (p.postalCode ?? '').replaceAll(RegExp(r'\s+'), '');

    return GeoResult(
      permissionDenied: false,
      latitude: pos.latitude,
      longitude: pos.longitude,
      uf: ufCandidate.isEmpty ? null : ufCandidate,
      city: city.isEmpty ? null : city,
      district: district.isEmpty ? null : district,
      address: address.isEmpty ? null : address,
      cep: cep.isEmpty ? null : cep,
    );
  }
}
