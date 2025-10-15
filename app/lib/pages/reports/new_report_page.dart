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

  // Foto (preview cross-platform)
  final _picker = ImagePicker();
  Uint8List? _photoBytes;
  String? _photoPath;

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
    if (kIsWeb) {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
      );
      if (x == null) return;
      final bytes = await x.readAsBytes();
      setState(() {
        _photoBytes = bytes;
        _photoPath = x.path;
      });
      return;
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tirar foto (câmera)'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final x = await _picker.pickImage(source: source, maxWidth: 1600);
      if (x == null) return;
      final bytes = await x.readAsBytes();
      setState(() {
        _photoBytes = bytes;
        _photoPath = x.path;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao obter imagem: $e')));
    }
  }

  void _removePhoto() {
    setState(() {
      _photoBytes = null;
      _photoPath = null;
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
      final dynamic id = a.userId; // ajuste o nome do campo conforme seu Auth
      if (id is int) authorId = id;
      if (id is String) authorId = int.tryParse(id) ?? 0;
    } catch (_) {
      authorId = 0;
    }

    // lat/long placeholders por enquanto
    const String lat = '0';
    const String lon = '0';

    final imagesBase64 = <String>[];
    if (_photoBytes != null) {
      imagesBase64.add(_toBase64(_photoBytes!));
      // se sua API aceita com prefixo:
      // imagesBase64.add('data:image/jpeg;base64,${_toBase64(_photoBytes!)}');
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
        _photoBytes = null;
        _photoPath = null;
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

                  // CEP (obrigatório)
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

                  // Foto (preview + ações)
                  if (_photoBytes != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _photoBytes!,
                              fit: BoxFit.cover,
                              height: 180,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _removePhoto,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Remover foto'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('Adicionar foto'),
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
