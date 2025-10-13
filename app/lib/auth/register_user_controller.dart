import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../services/service_locator.dart';

/// TerraON — RegisterUserController
///
/// Controla o estado e a lógica da tela de cadastro:
/// - Carrega UFs e cidades (IBGE)
/// - Usa geolocalização para detectar cidade/UF
/// - Gerencia avatar (câmera/galeria ou upload web)
/// - Envia cadastro para o AuthService
///
/// Uso na UI:
///   final c = RegisterUserController()..init();
///   c.addListener(() => setState(() {}));
///   ...
///   await c.submit(name: ..., email: ..., password: ...);

class RegisterUserController extends ChangeNotifier {
  // --- IBGE / localização ---
  final ImagePicker _picker = ImagePicker();

  List<String> states = [];
  List<String> cities = [];
  String? stateName; // "Rio Grande do Sul"
  String? uf;        // "RS"
  String? city;

  bool loadingStates = false;
  bool loadingCities = false;
  bool loadingSubmit = false;

  // --- Termos ---
  bool acceptedTerms = false;

  // --- Avatar (preview cross-platform) ---
  Uint8List? avatarBytes;

  // Mapa fixo estado → UF (para inferência rápida)
  static const Map<String, String> _ufs = {
    'Acre': 'AC','Alagoas':'AL','Amapá':'AP','Amazonas':'AM','Bahia':'BA',
    'Ceará':'CE','Distrito Federal':'DF','Espírito Santo':'ES','Goiás':'GO',
    'Maranhão':'MA','Mato Grosso':'MT','Mato Grosso do Sul':'MS','Minas Gerais':'MG',
    'Pará':'PA','Paraíba':'PB','Paraná':'PR','Pernambuco':'PE','Piauí':'PI',
    'Rio de Janeiro':'RJ','Rio Grande do Norte':'RN','Rio Grande do Sul':'RS',
    'Rondônia':'RO','Roraima':'RR','Santa Catarina':'SC','São Paulo':'SP',
    'Sergipe':'SE','Tocantins':'TO',
  };

  // === Ciclo de vida ===
  Future<void> init() async {
    await _loadStates();

    // Prefill com dados do usuário logado (se houver) — acesso seguro
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
      // tenta inferir o nome do estado para exibir no dropdown
      stateName = _ufs.keys.firstWhere(
        (name) => _ufs[name] == uf,
        orElse: () => '',
      );
      if (stateName!.isEmpty) stateName = null;
      await loadCitiesForUF(uf!);
      // garante que a cidade atual exista na lista (senão, mantém null)
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
      throw Exception('Falha ao obter sigla da UF');
    }
  }

  Future<void> loadCitiesForUF(String ufSigla) async {
    final data = await ibgeService.getCities(ufSigla);
    data.sort();
    cities = data;
    loadingCities = false;
    notifyListeners();
  }

  // === Localização atual ===
  Future<String?> useMyLocation() async {
    final geo = await geoService.getCurrentCityAndState();
    if (geo.permissionDenied) return 'Permissão de localização negada';
    if (geo.uf == null || geo.city == null) return 'Não foi possível detectar sua cidade';

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

    return city != null ? 'Localização aplicada: ${geo.city} - ${geo.uf}' : null;
  }

  // === Avatar ===
  Future<void> pickAvatar([ImageSource? source]) async {
    final src = source ?? await _chooseSource();
    if (src == null) return;

    final xfile = await _picker.pickImage(source: src, maxWidth: 1024);
    if (xfile == null) return;

    avatarBytes = await xfile.readAsBytes(); // Android + Web
    notifyListeners();
  }

  Future<ImageSource?> _chooseSource() async {
    // UI dessa escolha é responsabilidade da página/Widget.
   
    if (kIsWeb) return ImageSource.gallery;
    return ImageSource.gallery; // a Página pode passar a fonte desejada
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
  Future<bool> submit({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (!acceptedTerms) {
      throw Exception('É necessário aceitar os Termos e a Política.');
    }
    if (uf == null || city == null) {
      throw Exception('Selecione sua UF e Cidade.');
    }

    loadingSubmit = true;
    notifyListeners();

    final ok = await authService.registerUser(
      fullName: fullName.trim(),
      email: email.trim(),
      password: password,
      city: city!,
      uf: uf!,
      avatarPath: null, // upload real virá com backend
      acceptedTerms: acceptedTerms,
    );

    loadingSubmit = false;
    notifyListeners();
    return ok;
  }
}
