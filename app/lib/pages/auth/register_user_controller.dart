import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:app/core/repositories/auth_repository.dart';
import '../../services/service_locator.dart'; // se ainda usa ibgeService/geoService

class RegisterUserController extends ChangeNotifier {
  RegisterUserController(this._auth);
  final AuthRepository _auth;

  // --- IBGE / localização (opcionais para UI) ---
  final ImagePicker _picker = ImagePicker();

  List<String> states = [];
  List<String> cities = [];
  String? stateName; // "Rio Grande do Sul"
  String? uf; // "RS"
  String? city;

  bool loadingStates = false;
  bool loadingCities = false;
  bool loadingSubmit = false;

  // --- Termos ---
  bool acceptedTerms = false;

  // --- Avatar (preview) ---
  Uint8List? avatarBytes;

  static const Map<String, String> _ufs = {
    'Acre': 'AC',
    'Alagoas': 'AL',
    'Amapá': 'AP',
    'Amazonas': 'AM',
    'Bahia': 'BA',
    'Ceará': 'CE',
    'Distrito Federal': 'DF',
    'Espírito Santo': 'ES',
    'Goiás': 'GO',
    'Maranhão': 'MA',
    'Mato Grosso': 'MT',
    'Mato Grosso do Sul': 'MS',
    'Minas Gerais': 'MG',
    'Pará': 'PA',
    'Paraíba': 'PB',
    'Paraná': 'PR',
    'Pernambuco': 'PE',
    'Piauí': 'PI',
    'Rio de Janeiro': 'RJ',
    'Rio Grande do Norte': 'RN',
    'Rio Grande do Sul': 'RS',
    'Rondônia': 'RO',
    'Roraima': 'RR',
    'Santa Catarina': 'SC',
    'São Paulo': 'SP',
    'Sergipe': 'SE',
    'Tocantins': 'TO',
  };

  // === Ciclo de vida ===
  Future<void> init() async {
    await _loadStates();

    // Prefill opcional
    try {
      final dynamic a = authService;
      final String? userUf = a.userUF as String?;
      final String? userCity = a.userCity as String?;
      uf = userUf;
      city = userCity;
    } catch (_) {
      uf = null;
      city = null;
    }

    if (uf != null && uf!.isNotEmpty) {
      stateName = _ufs.keys.firstWhere(
        (name) => _ufs[name] == uf,
        orElse: () => '',
      );
      if (stateName!.isEmpty) stateName = null;
      await loadCitiesForUF(uf!);
      if (city != null && city!.isNotEmpty) {
        final found = cities.firstWhere(
          (c) => c.toLowerCase() == city!.toLowerCase(),
          orElse: () => '',
        );
        if (found.isEmpty) city = null;
      }
    }
  }

  // === IBGE ===
  Future<void> _loadStates() async {
    loadingStates = true;
    notifyListeners();
    final data = await ibgeService.getStates();
    data.sort();
    states = data;
    loadingStates = false;
    notifyListeners();
  }

  Future<void> onSelectState(String? newStateName) async {
    if (newStateName == null) return;
    stateName = newStateName;
    cities = [];
    city = null;
    loadingCities = true;
    notifyListeners();

    final sigla = await ibgeService.getUfSigla(newStateName);
    if (sigla != null) {
      uf = sigla;
      await loadCitiesForUF(sigla);
    } else {
      loadingCities = false;
      notifyListeners();
      // mantém a UI responsável por exibir o erro se quiser
    }
  }

  Future<void> loadCitiesForUF(String ufSigla) async {
    final data = await ibgeService.getCities(ufSigla);
    data.sort();
    cities = data;
    loadingCities = false;
    notifyListeners();
  }

  // === Localização atual (opcional) ===
  Future<String?> useMyLocation() async {
    final geo = await geoService.getCurrentCityAndState();
    if (geo.permissionDenied) return 'Permissão de localização negada';
    if (geo.uf == null || geo.city == null)
      return 'Não foi possível detectar sua cidade';

    uf = geo.uf;
    stateName = _ufs.keys.firstWhere(
      (name) => _ufs[name] == uf,
      orElse: () => '',
    );
    if (stateName!.isEmpty) stateName = null;

    loadingCities = true;
    notifyListeners();
    await loadCitiesForUF(uf!);

    final detected = cities.firstWhere(
      (c) => c.toLowerCase() == geo.city!.toLowerCase(),
      orElse: () => '',
    );
    city = detected.isEmpty ? null : detected;
    notifyListeners();

    return city != null
        ? 'Localização aplicada: ${geo.city} - ${geo.uf}'
        : null;
  }

  // === Avatar ===
  Future<void> pickAvatar([ImageSource? source]) async {
    final src = source ?? await _chooseSource();
    if (src == null) return;

    final xfile = await _picker.pickImage(source: src, maxWidth: 1024);
    if (xfile == null) return;

    avatarBytes = await xfile.readAsBytes();
    notifyListeners();
  }

  Future<ImageSource?> _chooseSource() async {
    if (kIsWeb) return ImageSource.gallery;
    return ImageSource.gallery;
  }

  void removeAvatar() {
    avatarBytes = null;
    notifyListeners();
  }

  // === Termos ===
  void setAcceptedTerms(bool v) {
    acceptedTerms = v;
    notifyListeners();
  }

  // === Envio ===
  /// Envia somente os campos necessários pela sua API:
  /// - name, email, password e opcionalmente phoneId (para notificações).
  Future<bool> submit({
    required String fullName,
    required String email,
    required String password,
    String? phoneId, // passe o token do FCM/deviceId aqui quando tiver
  }) async {
    if (!acceptedTerms) {
      throw Exception('É necessário aceitar os Termos e a Política.');
    }

    loadingSubmit = true;
    notifyListeners();
    try {
      final ok = await _auth.registerUser(
        name: fullName.trim(),
        email: email.trim(),
        password: password,
        // phoneNumber: null      // não enviar
      );
      return ok;
    } finally {
      loadingSubmit = false;
      notifyListeners();
    }
  }
}
