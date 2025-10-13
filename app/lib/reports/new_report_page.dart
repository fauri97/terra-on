import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/app_navbar.dart';
import '../widgets/app_footer.dart';
import '../services/service_locator.dart';
import '../services/report_service.dart';

/// TerraON — NewReportPage
///
/// Tela para criar nova denúncia.
/// Formulário: (sem título), categoria (enum), cidade, bairro, descrição,
/// opção de anonimato e upload de foto.
/// Pergunta sobre localização atual (chave) e trata permissões.

class NewReportPage extends StatefulWidget {
  const NewReportPage({super.key});

  @override
  State<NewReportPage> createState() => _NewReportPageState();
}

class _NewReportPageState extends State<NewReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _districtController = TextEditingController();

  ReportCategory? _category;
  bool _anonymous = false;
  bool _loading = false;

  // Localização
  bool _useLocation = true; // ligada por padrão (como combinamos)
  bool _resolvingLocation = false;

  // UF / Cidade (IBGE)
  List<String> _states = []; // nomes de estado ex.: "Rio Grande do Sul"
  List<String> _cities = []; // nomes de municípios
  String? _stateName;        // Nome do estado selecionado
  String? _uf;               // Sigla ex.: "RS"
  String? _city;             // Nome da cidade selecionada
  bool _loadingStates = false;
  bool _loadingCities = false;

  // Foto (preview cross-platform)
  final _picker = ImagePicker();
  Uint8List? _photoBytes;
  String? _photoPath; // para Android; no Web pode vir vazio

  // Labels amigáveis para o enum ReportCategory
  static const Map<ReportCategory, String> _categoryLabels = {
    ReportCategory.iluminacao: 'Iluminação pública',
    ReportCategory.lixo: 'Coleta de lixo',
    ReportCategory.poluicao: 'Meio ambiente',
    ReportCategory.buraco: 'Infraestrutura',
    ReportCategory.outro: 'Outros',
  };

  @override
  void initState() {
    super.initState();
    _bootstrapIbge();
    // Se a chave estiver ligada, tenta aplicar a localização atual.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_useLocation) _applyLocation(quiet: true);
    });
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

  // Aplica localização atual usando GeoService
  Future<void> _applyLocation({bool quiet = false}) async {
    setState(() => _resolvingLocation = true);
    final geo = await geoService.getCurrentCityAndState();
    setState(() => _resolvingLocation = false);

    if (geo.permissionDenied) {
      // Mostra alerta e permite edição manual
      if (!quiet && mounted) {
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Permissão negada'),
            content: const Text(
              'Para usar a localização atual, conceda permissão de localização.\n'
              'Você ainda pode informar UF, cidade e bairro manualmente.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
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
          builder: (_) => AlertDialog(
            title: const Text('Não foi possível obter sua cidade'),
            content: const Text(
              'Não conseguimos detectar sua cidade neste momento.\n'
              'Você pode preencher manualmente.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
          ),
        );
      }
      setState(() => _useLocation = false);
      return;
    }

    // Preenche UF e carrega cidades
    setState(() {
      _uf = geo.uf;                         // ex.: "RS"
      _stateName = _guessStateFromUF(_uf!); // ex.: "Rio Grande do Sul"
      _loadingCities = true;
    });
    await _loadCitiesForUF(_uf!);

    // Seleciona a cidade se existir na lista
    final detected = _cities.firstWhere(
      (c) => c.toLowerCase() == geo.city!.toLowerCase(),
      orElse: () => '',
    );
    setState(() => _city = detected.isEmpty ? null : detected);

    if (!quiet && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Localização aplicada: ${geo.city} - ${geo.uf}')),
      );
    }
  }

  String? _guessStateFromUF(String uf) {
    const map = {
      'AC': 'Acre','AL':'Alagoas','AP':'Amapá','AM':'Amazonas','BA':'Bahia',
      'CE':'Ceará','DF':'Distrito Federal','ES':'Espírito Santo','GO':'Goiás',
      'MA':'Maranhão','MT':'Mato Grosso','MS':'Mato Grosso do Sul','MG':'Minas Gerais',
      'PA':'Pará','PB':'Paraíba','PR':'Paraná','PE':'Pernambuco','PI':'Piauí',
      'RJ':'Rio de Janeiro','RN':'Rio Grande do Norte','RS':'Rio Grande do Sul',
      'RO':'Rondônia','RR':'Roraima','SC':'Santa Catarina','SP':'São Paulo',
      'SE':'Sergipe','TO':'Tocantins',
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

  // Seleção de foto (Android: câmera/galeria; Web: seletor nativo)
  Future<void> _pickPhoto() async {
    if (kIsWeb) {
      // No Web, abre seletor de arquivo diretamente
      final x = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1600);
      if (x == null) return;
      final bytes = await x.readAsBytes();
      setState(() {
        _photoBytes = bytes;
        _photoPath = x.path;
      });
      return;
    }

    // Android: mostra opções
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
        _photoPath = x.path; // pode ser vazio no Web; aqui é Android
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao obter imagem: $e')),
      );
    }
  }

  void _removePhoto() {
    setState(() {
      _photoBytes = null;
      _photoPath = null;
    });
  }

  Future<void> _submit() async {
    // validação: requer categoria, UF/cidade e descrição
    if (!_formKey.currentState!.validate()) return;

    // garante cidade válida
    if (_city == null || _city!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a cidade.')),
      );
      return;
    }

    setState(() => _loading = true);

    // Deriva o "título" interno pela categoria escolhida
    final derivedTitle = _category != null
        ? 'Denúncia: ${_categoryLabels[_category] ?? 'Categoria'}'
        : 'Denúncia';

    final input = CreateReportInput(
      title: derivedTitle,
      description: _descController.text.trim(),
      category: _category ?? ReportCategory.outro,
      city: _city!.trim(),
      district: _districtController.text.trim().isEmpty
          ? null
          : _districtController.text.trim(),
      isAnonymous: _anonymous,
      // UI apenas (sem upload real ainda). Se tiver path no Android, mandamos.
      photoPaths: _photoPath == null ? const [] : <String>[_photoPath!],
    );

    final id = await reportService.createReport(input);

    setState(() => _loading = false);
    if (!mounted) return;

    // Implementação local retorna null → estado neutro
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Denúncia enviada (modo local, sem backend).'),
        ),
      );
      _formKey.currentState?.reset();
      setState(() {
        _category = null;
        _anonymous = false;
        _photoBytes = null;
        _photoPath = null;
        // Mantém UF/cidade se a localização estiver ativa
        if (_useLocation && (_city == null || _city!.isEmpty)) {
          _applyLocation(quiet: true);
        }
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Denúncia registrada: $id')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Categoria (enum)
                  DropdownButtonFormField<ReportCategory>(
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _categoryLabels.entries
                        .map((e) => DropdownMenuItem<ReportCategory>(
                              value: e.key,
                              child: Text(e.value),
                            ))
                        .toList(),
                    value: _category,
                    onChanged: (v) => setState(() => _category = v),
                    validator: (v) => v == null ? 'Selecione uma categoria' : null,
                  ),
                  const SizedBox(height: 12),

                  // Localização automática (chave)
                  SwitchListTile(
                    value: _useLocation,
                    onChanged: (v) async {
                      setState(() => _useLocation = v);
                      if (v) {
                        await _applyLocation();
                      }
                    },
                    title: const Text('Usar minha localização atual'),
                    subtitle: _resolvingLocation
                        ? const Text('Obtendo localização...')
                        : const Text('Você pode editar manualmente se preferir'),
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
                      // Se ainda está carregando ou não há UF, não valida agora
                      if (_loadingCities || _uf == null) return null;
                      return (v == null || v.trim().isEmpty) ? 'Selecione a cidade' : null;
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
                            child: Image.memory(_photoBytes!, fit: BoxFit.cover, height: 180),
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

                  // Anonimato
                  CheckboxListTile(
                    title: const Text('Publicar como anônimo'),
                    value: _anonymous,
                    onChanged: (v) => setState(() => _anonymous = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 8),

                  // Botão de envio
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

  @override
  void dispose() {
    _descController.dispose();
    _districtController.dispose();
    super.dispose();
  }
}
