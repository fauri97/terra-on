// lib/pages/reports/new_report_page.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/app_navbar.dart';
import '../../widgets/app_footer.dart';
import '../../services/service_locator.dart';
import '../../core/repositories/reports_repository.dart'; // <-- usa o repo

class NewReportPage extends StatefulWidget {
  const NewReportPage({super.key});
  @override
  State<NewReportPage> createState() => _NewReportPageState();
}

class _NewReportPageState extends State<NewReportPage> {
  final _formKey = GlobalKey<FormState>();

  final _descController = TextEditingController();
  final _districtController = TextEditingController();
  final _addressController = TextEditingController();
  final _cepController = TextEditingController();

  bool _loading = false;

  // Localização
  bool _useLocation = true;
  bool _resolvingLocation = false;

  // UF / Cidade (IBGE)
  List<String> _states = [];
  List<String> _cities = [];
  String? _stateName; // ex.: "Rio Grande do Sul"
  String? _uf; // ex.: "RS"
  String? _city; // ex.: "Porto Alegre"
  bool _loadingStates = false;
  bool _loadingCities = false;

  // Fotos (múltiplas)
  final _picker = ImagePicker();
  final List<Uint8List> _photos = []; // <--- várias imagens
  final int _maxPhotos = 10; // limite (ajuste se quiser)

  @override
  void initState() {
    super.initState();
    _bootstrapIbge();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_useLocation) _applyLocation(quiet: true);
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    _districtController.dispose();
    _addressController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapIbge() async {
    setState(() => _loadingStates = true);
    final st = await ibgeService.getStates();
    st.sort();
    setState(() {
      _states = st;
      _loadingStates = false;
    });
  }

  Future<void> _applyLocation({bool quiet = false}) async {
    setState(() => _resolvingLocation = true);
    final geo = await geoService.getCurrentCityAndState();
    setState(() => _resolvingLocation = false);

    if (geo.permissionDenied) {
      if (!quiet && mounted) {
        await showDialog<void>(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Permissão negada'),
            content: Text(
              'Para usar a localização atual, conceda permissão de localização.\n'
              'Você ainda pode informar UF, cidade e bairro manualmente.',
            ),
          ),
        );
      }
      setState(() => _useLocation = false);
      return;
    }

    if (geo.uf == null || geo.city == null) {
      if (!quiet && mounted) {
        await showDialog<void>(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Não foi possível obter sua cidade'),
            content: Text(
              'Não conseguimos detectar sua cidade neste momento.\n'
              'Você pode preencher manualmente.',
            ),
          ),
        );
      }
      setState(() => _useLocation = false);
      return;
    }

    setState(() {
      _uf = geo.uf; // "RS"
      _stateName = _guessStateFromUF(_uf!);
      _loadingCities = true;
    });
    await _loadCitiesForUF(_uf!);

    final detected = _cities.firstWhere(
      (c) => c.toLowerCase() == geo.city!.toLowerCase(),
      orElse: () => '',
    );
    setState(() => _city = detected.isEmpty ? null : detected);

    if (!quiet && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Localização aplicada: ${geo.city} - ${geo.uf}'),
        ),
      );
    }
  }

  String? _guessStateFromUF(String uf) {
    const map = {
      'AC': 'Acre',
      'AL': 'Alagoas',
      'AP': 'Amapá',
      'AM': 'Amazonas',
      'BA': 'Bahia',
      'CE': 'Ceará',
      'DF': 'Distrito Federal',
      'ES': 'Espírito Santo',
      'GO': 'Goiás',
      'MA': 'Maranhão',
      'MT': 'Mato Grosso',
      'MS': 'Mato Grosso do Sul',
      'MG': 'Minas Gerais',
      'PA': 'Pará',
      'PB': 'Paraíba',
      'PR': 'Paraná',
      'PE': 'Pernambuco',
      'PI': 'Piauí',
      'RJ': 'Rio de Janeiro',
      'RN': 'Rio Grande do Norte',
      'RS': 'Rio Grande do Sul',
      'RO': 'Rondônia',
      'RR': 'Roraima',
      'SC': 'Santa Catarina',
      'SP': 'São Paulo',
      'SE': 'Sergipe',
      'TO': 'Tocantins',
    };
    return map[uf];
  }

  Future<void> _onSelectState(String? stateName) async {
    if (stateName == null) return;
    setState(() {
      _stateName = stateName;
      _cities = [];
      _city = null;
      _loadingCities = true;
    });

    final sigla = await ibgeService.getUfSigla(stateName);
    if (sigla != null) {
      _uf = sigla;
      await _loadCitiesForUF(sigla);
    } else {
      setState(() => _loadingCities = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível obter a sigla da UF.')),
      );
    }
  }

  Future<void> _loadCitiesForUF(String uf) async {
    final cities = await ibgeService.getCities(uf);
    cities.sort();
    setState(() {
      _cities = cities;
      _loadingCities = false;
    });
  }

  Future<void> _pickPhoto() async {
    // Em todas as plataformas oferecemos: câmera (uma por vez) ou galeria (múltiplas)
    final source = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tirar foto (câmera)'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria (múltiplas)'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || source == null) return;

    if (source == 'camera') {
      await _addFromCamera();
    } else if (source == 'gallery') {
      await _addFromGalleryMulti();
    }
  }

  Future<void> _addFromCamera() async {
    try {
      if (_photos.length >= _maxPhotos) {
        _showLimitSnack();
        return;
      }
      final x = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (x == null) return;
      final bytes = await x.readAsBytes();
      setState(() => _photos.add(bytes));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao obter imagem: $e')));
    }
  }

  Future<void> _addFromGalleryMulti() async {
    try {
      // pickMultiImage funciona em Android/iOS/Web
      final remaining = _maxPhotos - _photos.length;
      if (remaining <= 0) {
        _showLimitSnack();
        return;
      }
      final xs = await _picker.pickMultiImage(
        maxWidth: 1600,
        imageQuality: 85,
        // Para Web o image_picker respeita seleção múltipla no diálogo
      );

      if (xs.isEmpty) return;

      // Respeita o limite
      final toAdd = xs.take(remaining);
      for (final x in toAdd) {
        final bytes = await x.readAsBytes();
        _photos.add(bytes);
      }
      if (mounted) setState(() {});
      if (xs.length > remaining && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Limite de $_maxPhotos imagens atingido.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao obter imagens: $e')));
    }
  }

  void _showLimitSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Você pode enviar no máximo $_maxPhotos fotos.')),
    );
  }

  void _removePhotoAt(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  String _toBase64(Uint8List bytes) => base64Encode(bytes);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_city == null || _city!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione a cidade.')));
      return;
    }

    setState(() => _loading = true);

    // authorId vindo do authService (se existir)
    int authorId = 0;
    try {
      final dynamic a = authService;
      final dynamic id = a.userId;
      if (id is int) authorId = id;
      if (id is String) authorId = int.tryParse(id) ?? 0;
    } catch (_) {
      authorId = 0;
    }

    // lat/long placeholders por enquanto
    const String lat = '0';
    const String lon = '0';

    final imagesBase64 = <String>[];
    if (_photos.isNotEmpty) {
      for (final bytes in _photos) {
        imagesBase64.add(_toBase64(bytes));
      }
    }

    try {
      final repo = context.reportsRepo();

      final resultId = await repo.createReportRaw(
        description: _descController.text.trim(),
        longitude: lon,
        latitude: lat,
        address: _addressController.text.trim(),
        city: _city!.trim(),
        state: _uf ?? (_stateName ?? ''),
        bairro: _districtController.text.trim(),
        cep: _cepController.text.trim(),
        imagesBase64: imagesBase64,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resultId == null
                ? 'Denúncia enviada.'
                : 'Denúncia registrada: $resultId',
          ),
        ),
      );

      // limpa o form (mantendo UF/cidade se quiser)
      _formKey.currentState?.reset();
      setState(() {
        _photos.clear();
        _districtController.clear();
        _addressController.clear();
        _cepController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao enviar: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppNavbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Nova denúncia',
                    style: text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Localização automática (chave)
                  SwitchListTile(
                    value: _useLocation,
                    onChanged: (v) async {
                      setState(() => _useLocation = v);
                      if (v) await _applyLocation();
                    },
                    title: const Text('Usar minha localização atual'),
                    subtitle: _resolvingLocation
                        ? const Text('Obtendo localização...')
                        : const Text(
                            'Você pode editar manualmente se preferir',
                          ),
                    secondary: const Icon(Icons.my_location),
                  ),
                  const SizedBox(height: 8),

                  // UF (IBGE)
                  DropdownButtonFormField<String>(
                    value: _stateName,
                    items: _states
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: _loadingStates ? null : (v) => _onSelectState(v),
                    decoration: const InputDecoration(
                      labelText: 'Estado (UF)',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cidade (IBGE)
                  DropdownButtonFormField<String>(
                    value: _city,
                    items: _cities
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: _loadingCities
                        ? null
                        : (v) => setState(() => _city = v),
                    validator: (v) {
                      if (_loadingCities || _uf == null) return null;
                      return (v == null || v.trim().isEmpty)
                          ? 'Selecione a cidade'
                          : null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Cidade',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bairro (opcional)
                  TextFormField(
                    controller: _districtController,
                    decoration: const InputDecoration(
                      labelText: 'Bairro (opcional)',
                      prefixIcon: Icon(Icons.map_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Endereço (obrigatório)
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Endereço',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Informe o endereço'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _cepController,
                    decoration: const InputDecoration(
                      labelText: 'CEP',
                      prefixIcon: Icon(Icons.local_post_office_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Informe o CEP' : null,
                  ),
                  const SizedBox(height: 12),

                  // Descrição
                  TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Descreva o problema observado'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Fotos (pré-visualização + ações)
                  if (_photos.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _photos.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemBuilder: (context, index) {
                          final bytes = _photos[index];
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(bytes, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Material(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => _removePhotoAt(index),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  OutlinedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: Text(
                      _photos.isEmpty
                          ? 'Adicionar foto'
                          : 'Adicionar mais fotos (${_photos.length}/$_maxPhotos)',
                    ),
                  ),

                  const SizedBox(height: 16),

                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.send_outlined),
                          label: const Text('Publicar'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}
