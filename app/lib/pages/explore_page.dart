import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_footer.dart';
import '../services/service_locator.dart';
import '../services/report_service.dart';

/// TerraON — ExplorePage (filtros em painel + barra compacta)
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  // IBGE
  List<String> _states = [];
  List<String> _cities = [];
  String? _stateName; // "Rio Grande do Sul"
  String? _uf;        // "RS"
  String? _city;
  bool _loadingStates = false;
  bool _loadingCities = false;

  // Filtros adicionais
  final _districtCtrl = TextEditingController();

  // Categoria/Status (apenas UI por enquanto)
  String? _categoryFilterLabel;
  String? _statusFilterLabel;

  // Enums reais (deixamos null por enquanto)
  ReportCategory? _category;
  ReportStatus? _status;

  int? _periodDays; // 7 / 30 / 90
  bool _mineOnly = false;

  // Lista e loading
  bool _loadingList = false;
  List<ReportSummary> _items = [];

  // Opções visuais
  final _categories = const [
    'Meio ambiente',
    'Coleta de lixo',
    'Iluminação pública',
    'Infraestrutura',
    'Outros',
  ];
  final _statuses = const ['aberta', 'em andamento', 'resolvida'];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _loadingStates = true);
    final st = await ibgeService.getStates();
    st.sort();

    // Prefill a partir do perfil (se existir)
    try {
      // ignore: unnecessary_null_comparison
      _uf = (authService as dynamic).userUF;
      // ignore: unnecessary_null_comparison
      _city = (authService as dynamic).userCity;
      _stateName = _uf != null ? _guessStateFromUF(_uf!) : null;
    } catch (_) {
      _uf = null;
      _city = null;
      _stateName = null;
    }

    setState(() {
      _states = st;
      _loadingStates = false;
    });

    if (_uf != null) {
      await _loadCitiesForUF(_uf!);
    }

    await _refresh();
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

  Future<void> _useMyLocation() async {
    final msg = await geoService.getCurrentCityAndState();
    if (!mounted) return;
    if (msg.permissionDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão de localização negada.')),
      );
      return;
    }
    if (msg.uf == null || msg.city == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível detectar sua cidade.')),
      );
      return;
    }

    setState(() {
      _uf = msg.uf;
      _stateName = _guessStateFromUF(_uf!);
      _loadingCities = true;
    });
    await _loadCitiesForUF(_uf!);

    final detected = _cities.firstWhere(
      (c) => c.toLowerCase() == msg.city!.toLowerCase(),
      orElse: () => '',
    );
    setState(() => _city = detected.isEmpty ? null : detected);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Localização aplicada: ${msg.city} - ${msg.uf}')),
    );
  }

  ReportPeriod? _buildPeriod() {
    if (_periodDays == null) return null;
    final now = DateTime.now();
    return ReportPeriod(start: now.subtract(Duration(days: _periodDays!)), end: now);
  }

  Future<void> _refresh() async {
    setState(() {
      _loadingList = true;
      _items = [];
    });

    try {
      if (_mineOnly && authService.isLoggedIn) {
        final mine = await reportService.getMyReports();
        setState(() => _items = mine);
      } else {
        final data = await reportService.getPublicReports(
          city: _city,
          district: _districtCtrl.text.trim().isEmpty ? null : _districtCtrl.text.trim(),
          category: _category, // manter null por enquanto
          status: _status,     // manter null por enquanto
          period: _buildPeriod(),
        );
        setState(() => _items = data);
      }
    } catch (_) {
      setState(() => _items = []);
    } finally {
      if (mounted) setState(() => _loadingList = false);
    }
  }

  int get _activeFiltersCount {
    int n = 0;
    if (_uf != null && _uf!.isNotEmpty) n++;
    if (_city != null && _city!.isNotEmpty) n++;
    if (_districtCtrl.text.trim().isNotEmpty) n++;
    if (_categoryFilterLabel != null) n++;
    if (_statusFilterLabel != null) n++;
    if (_periodDays != null) n++;
    if (_mineOnly) n++;
    return n;
  }

  void _clearFilters() {
    setState(() {
      _stateName = null;
      _uf = null;
      _cities = [];
      _city = null;
      _districtCtrl.clear();
      _categoryFilterLabel = null;
      _statusFilterLabel = null;
      _category = null;
      _status = null;
      _periodDays = null;
      _mineOnly = false;
    });
  }

  Future<void> _openFiltersPanel() async {
    final isWide = MediaQuery.of(context).size.width >= 900;

    if (isWide) {
      // Diálogo lateral (web)
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          final scheme = Theme.of(ctx).colorScheme;
          return Dialog(
            insetPadding: const EdgeInsets.only(left: 80, right: 16, top: 24, bottom: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: _FiltersContent(
                states: _states,
                cities: _cities,
                loadingStates: _loadingStates,
                loadingCities: _loadingCities,
                stateName: _stateName,
                city: _city,
                categoryLabel: _categoryFilterLabel,
                statusLabel: _statusFilterLabel,
                periodDays: _periodDays,
                mineOnly: _mineOnly,
                onSelectState: _onSelectState,
                onSelectCity: (v) => setState(() => _city = v),
                onDistrictChanged: (v) => setState(() {}),
                districtController: _districtCtrl,
                categories: _categories,
                statuses: _statuses,
                onSelectCategory: (v) {
                  setState(() {
                    _categoryFilterLabel = v;
                    _category = null;
                  });
                },
                onSelectStatus: (v) {
                  setState(() {
                    _statusFilterLabel = v;
                    _status = null;
                  });
                },
                onSelectPeriod: (v) => setState(() => _periodDays = v),
                onToggleMineOnly: (v) => setState(() => _mineOnly = v),
                onUseMyLocation: _useMyLocation,
                onClear: () {
                  _clearFilters();
                  Navigator.pop(ctx);
                },
                onApply: () {
                  Navigator.pop(ctx);
                  _refresh();
                },
              ),
            ),
          );
        },
      );
    } else {
      // BottomSheet (mobile)
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
              top: 4,
            ),
            child: _FiltersContent(
              states: _states,
              cities: _cities,
              loadingStates: _loadingStates,
              loadingCities: _loadingCities,
              stateName: _stateName,
              city: _city,
              categoryLabel: _categoryFilterLabel,
              statusLabel: _statusFilterLabel,
              periodDays: _periodDays,
              mineOnly: _mineOnly,
              onSelectState: _onSelectState,
              onSelectCity: (v) => setState(() => _city = v),
              onDistrictChanged: (v) => setState(() {}),
              districtController: _districtCtrl,
              categories: _categories,
              statuses: _statuses,
              onSelectCategory: (v) {
                setState(() {
                  _categoryFilterLabel = v;
                  _category = null;
                });
              },
              onSelectStatus: (v) {
                setState(() {
                  _statusFilterLabel = v;
                  _status = null;
                });
              },
              onSelectPeriod: (v) => setState(() => _periodDays = v),
              onToggleMineOnly: (v) => setState(() => _mineOnly = v),
              onUseMyLocation: _useMyLocation,
              onClear: () {
                _clearFilters();
                Navigator.pop(ctx);
              },
              onApply: () {
                Navigator.pop(ctx);
                _refresh();
              },
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _districtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppNavbar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra compacta (sem campos)
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _openFiltersPanel,
                      icon: const Icon(Icons.tune),
                      label: Text(
                        _activeFiltersCount > 0
                            ? 'Filtros (${_activeFiltersCount})'
                            : 'Filtros',
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Aplicar'),
                    ),
                    const Spacer(),
                    // (Opcional) futuro: exportar CSV/PDF etc.
                  ],
                ),
                const SizedBox(height: 12),

                // Lista
                Expanded(
                  child: _loadingList
                      ? const Center(child: CircularProgressIndicator())
                      : _items.isEmpty
                          ? _EmptyState(text: text, scheme: scheme)
                          : ListView.separated(
                              itemCount: _items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (_, i) => _ReportTile(item: _items[i]),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}

/// Conteúdo do painel de filtros (usado no Dialog/BottomSheet)
class _FiltersContent extends StatelessWidget {
  const _FiltersContent({
    required this.states,
    required this.cities,
    required this.loadingStates,
    required this.loadingCities,
    required this.stateName,
    required this.city,
    required this.categoryLabel,
    required this.statusLabel,
    required this.periodDays,
    required this.mineOnly,
    required this.onSelectState,
    required this.onSelectCity,
    required this.onDistrictChanged,
    required this.districtController,
    required this.categories,
    required this.statuses,
    required this.onSelectCategory,
    required this.onSelectStatus,
    required this.onSelectPeriod,
    required this.onToggleMineOnly,
    required this.onUseMyLocation,
    required this.onClear,
    required this.onApply,
  });

  final List<String> states;
  final List<String> cities;
  final bool loadingStates;
  final bool loadingCities;

  final String? stateName;
  final String? city;

  final String? categoryLabel;
  final String? statusLabel;
  final int? periodDays;
  final bool mineOnly;

  final void Function(String?) onSelectState;
  final void Function(String?) onSelectCity;
  final void Function(String) onDistrictChanged;
  final TextEditingController districtController;

  final List<String> categories;
  final List<String> statuses;

  final void Function(String?) onSelectCategory;
  final void Function(String?) onSelectStatus;
  final void Function(int?) onSelectPeriod;
  final void Function(bool) onToggleMineOnly;
  final Future<void> Function() onUseMyLocation;

  final VoidCallback onClear;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.of(context).size.width;
    final compact = maxW < 560;

    InputDecoration deco(String label, IconData icon) => InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          isDense: compact,
          contentPadding: compact
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
              : null,
        );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Filtros', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),

            // Campos
            Wrap(
              spacing: compact ? 8 : 12,
              runSpacing: compact ? 8 : 12,
              children: [
                // UF
                SizedBox(
                  width: compact ? double.infinity : 280,
                  child: loadingStates
                      ? const LinearProgressIndicator(minHeight: 2)
                      : DropdownButtonFormField<String>(
                          value: stateName,
                          items: states
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: onSelectState,
                          decoration: deco('Estado', Icons.flag_outlined),
                        ),
                ),
                // Cidade
                SizedBox(
                  width: compact ? double.infinity : 300,
                  child: DropdownButtonFormField<String>(
                    value: city,
                    items: cities
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: loadingCities ? null : onSelectCity,
                    decoration: deco('Cidade', Icons.location_city_outlined),
                  ),
                ),
                // Bairro
                SizedBox(
                  width: compact ? double.infinity : 260,
                  child: TextField(
                    controller: districtController,
                    onChanged: onDistrictChanged,
                    decoration: deco('Bairro (opcional)', Icons.map_outlined),
                  ),
                ),
                // Categoria
                SizedBox(
                  width: compact ? double.infinity : 260,
                  child: DropdownButtonFormField<String>(
                    value: categoryLabel,
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: onSelectCategory,
                    decoration: deco('Categoria', Icons.category_outlined),
                  ),
                ),
                // Status
                SizedBox(
                  width: compact ? double.infinity : 220,
                  child: DropdownButtonFormField<String>(
                    value: statusLabel,
                    items: statuses
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: onSelectStatus,
                    decoration: deco('Status', Icons.filter_alt_outlined),
                  ),
                ),
                // Período
                SizedBox(
                  width: compact ? double.infinity : 200,
                  child: DropdownButtonFormField<int>(
                    value: periodDays,
                    items: const [
                      DropdownMenuItem(value: 7, child: Text('Últimos 7 dias')),
                      DropdownMenuItem(value: 30, child: Text('Últimos 30 dias')),
                      DropdownMenuItem(value: 90, child: Text('Últimos 90 dias')),
                    ],
                    onChanged: onSelectPeriod,
                    decoration: deco('Período', Icons.calendar_today),
                  ),
                ),

                // Minhas denúncias
                FilterChip(
                  selected: mineOnly,
                  label: const Text('Minhas denúncias'),
                  onSelected: (v) => onToggleMineOnly(v),
                ),
              ],
            ),

            const SizedBox(height: 8),
            // Ações
            Row(
              children: [
                TextButton.icon(
                  onPressed: onUseMyLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Usar minha localização'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onClear,
                  child: const Text('Limpar'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onApply,
                  icon: const Icon(Icons.check),
                  label: const Text('Aplicar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text, required this.scheme});
  final TextTheme text;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 48),
            const SizedBox(height: 12),
            Text('Nenhuma denúncia encontrada com os filtros atuais.',
                style: text.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              'Ajuste os filtros no botão acima.',
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.item});
  final ReportSummary item;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListTile(
      leading: const Icon(Icons.report_outlined),
      title: Text(item.title, style: text.titleMedium),
      subtitle: Text(
        '${item.category} • ${item.city}${item.district != null ? ' - ${item.district}' : ''} • ${item.status}',
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detalhes da denúncia — em breve.')),
        );
      },
    );
  }
}
