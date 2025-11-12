import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
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

  Future<void> _loadStates() async {
    loadingStates = true;
    notifyListeners();
    try {
      final data = await ibgeService.getStates();
      data.sort();
      states = data;
    } catch (e) {
      // log opcional
      debugPrint('[_loadStates] erro: $e');
    } finally {
      loadingStates = false;
      notifyListeners();
    }
  }

  Future<void> onSelectState(String? newStateName) async {
    if (newStateName == null) return;
    stateName = newStateName;
    cities = [];
    city = null;
    loadingCities = true;
    notifyListeners();

    try {
      final sigla = await ibgeService.getUfSigla(newStateName);
      if (sigla != null) {
        uf = sigla;
        await loadCitiesForUF(sigla);
      } else {
        debugPrint('[onSelectState] UF não encontrada para "$newStateName"');
      }
    } catch (e) {
      debugPrint('[onSelectState] erro: $e');
    } finally {
      loadingCities = false;
      notifyListeners();
    }
  }

  Future<void> loadCitiesForUF(String ufSigla) async {
    loadingCities = true;
    notifyListeners();
    try {
      final data = await ibgeService.getCities(ufSigla);
      data.sort();
      cities = data;
    } catch (e) {
      debugPrint('[loadCitiesForUF] erro: $e');
    } finally {
      loadingCities = false;
      notifyListeners();
    }
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

  Future<bool> submit({
    required String fullName,
    required String email,
    required String password,
    String? phoneId, // token/ID do dispositivo (FCM)
    String? phoneNumber, // se tiver um campo no form; pode ser null
  }) async {
    if (!acceptedTerms) {
      throw Exception('É necessário aceitar os Termos e a Política.');
    }

    // city/state vêm das escolhas IBGE
    final selectedCity = city?.trim();
    final selectedState = (uf ?? stateName)?.trim(); // prioriza sigla (ex.: RS)

    // avatar em Base64 (sem prefixo data:)
    final profileImageBase64 = (avatarBytes != null && avatarBytes!.isNotEmpty)
        ? base64Encode(avatarBytes!)
        : null;

    loadingSubmit = true;
    notifyListeners();
    try {
      final ok = await _auth.registerUser(
        name: fullName.trim(),
        email: email.trim(),
        password: password,
        phoneNumber: phoneNumber, // pode ser null
        phoneId: phoneId, // pode ser null
        city: selectedCity, // pode ser null
        state: selectedState, // pode ser null (ex.: "RS")
        profileImageBase64: profileImageBase64, // pode ser null
      );
      return ok;
    } finally {
      loadingSubmit = false;
      notifyListeners();
    }
  }
}
