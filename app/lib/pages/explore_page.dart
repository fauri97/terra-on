import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../core/repositories/reports_repository.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_footer.dart';
import '../services/service_locator.dart';
import '../services/report_service.dart';

/// Modelo esperado (como no feed):
class ReportItem {
  final String description;
  final int authorId;
  final String authorName;
  final String longitude;
  final String latitude;
  final String address;
  final String city;
  final String state;
  final String bairro;
  final String cep;
  final List<String> imagesBase64;

  ReportItem({
    required this.description,
    required this.authorId,
    required this.authorName,
    required this.longitude,
    required this.latitude,
    required this.address,
    required this.city,
    required this.state,
    required this.bairro,
    required this.cep,
    required this.imagesBase64,
  });
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {

  late final ReportsRepository _repo;
  
  // IBGE
  List<String> _states = [];
  List<String> _cities = [];
  String? _stateName; // "Rio Grande do Sul"
  String? _uf; // "RS"
  String? _city;
  bool _loadingStates = false;
  bool _loadingCities = false;

  // Filtros adicionais
  final _districtCtrl = TextEditingController();

  // UI labels (placeholder)
  String? _categoryFilterLabel;
  String? _statusFilterLabel;

  // Enums reais (se tiver)
  ReportCategory? _category;
  ReportStatus? _status;

  int? _periodDays; // 7 / 30 / 90
  bool _mineOnly = false;

  // Lista e loading
  bool _loadingList = false;
  List<ReportItem> _items = [];

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

    try {
      _uf = (authService as dynamic).userUF;
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
    return ReportPeriod(
      start: now.subtract(Duration(days: _periodDays!)),
      end: now,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadingList = true;
      _items = [];
    });

    try {
      // Mesma fonte do FeedPage
      final data = await _repo.getFeed();
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      setState(() => _items = []);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar: $e')));
    } finally {
      if (mounted) setState(() => _loadingList = false);
    }
  }

  int get _activeFiltersCount {
    int n = 0;
    if (_uf?.isNotEmpty == true) n++;
    if (_city?.isNotEmpty == true) n++;
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

    final panel = _FiltersContent(
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
        Navigator.of(context).pop();
      },
      onApply: () {
        Navigator.of(context).pop();
        _refresh();
      },
    );

    if (isWide) {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return Dialog(
            insetPadding: const EdgeInsets.only(
              left: 80,
              right: 16,
              top: 24,
              bottom: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: panel,
            ),
          );
        },
      );
    } else {
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
            child: panel,
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
                // Barra de filtros
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
                  ],
                ),
                const SizedBox(height: 12),

                // Lista estilo feed
                Expanded(
                  child: _loadingList
                      ? const Center(child: CircularProgressIndicator())
                      : _items.isEmpty
                      ? _EmptyState(scheme: scheme)
                      : ListView.separated(
                          itemCount: _items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => ReportCard(item: _items[i]),
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

/// ---- CARD estilo feed (avatar + descrição + carrossel + ações) ----

class ReportCard extends StatefulWidget {
  const ReportCard({super.key, required this.item});
  final ReportItem item;

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  late final PageController _pageCtrl;
  int _page = 0;

  bool _liking = false;
  bool _commenting = false;
  int _likeCount = 0;
  int _commentCount = 0;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLike() async {
    if (_liking) return;
    setState(() => _liking = true);
    try {
      final next = !_liked;
      setState(() {
        _liked = next;
        _likeCount += next ? 1 : -1;
      });
      await Future.delayed(const Duration(milliseconds: 600)); // simulação
      // TODO: chame o endpoint real de like aqui
    } catch (_) {
      setState(() {
        _liked = !_liked;
        _likeCount += _liked ? 1 : -1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao curtir. Tente novamente.')),
      );
    } finally {
      if (mounted) setState(() => _liking = false);
    }
  }

  Future<void> _onComment() async {
    if (_commenting) return;
    setState(() => _commenting = true);
    try {
      await Future.delayed(const Duration(milliseconds: 600)); // simulação
      // TODO: abrir composer/modal de comentário; ao enviar com sucesso:
      setState(() => _commentCount += 1);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao comentar. Tente novamente.')),
      );
    } finally {
      if (mounted) setState(() => _commenting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final item = widget.item;
    final images = item.imagesBase64;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                _AvatarPlaceholder(name: item.authorName),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.authorName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Descrição
            if (item.description.isNotEmpty)
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.9),
                ),
              ),

            // Carrossel
            if (images.isNotEmpty) ...[
              const SizedBox(height: 10),
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                      controller: _pageCtrl,
                      onPageChanged: (v) => setState(() => _page = v),
                      itemCount: images.length,
                      itemBuilder: (_, idx) {
                        final bytes = _decodeBase64(images[idx]);
                        if (bytes == null) {
                          return _BrokenImagePlaceholder(color: cs.error);
                        }
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            bytes,
                            gaplessPlayback: true,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                            errorBuilder: (_, __, ___) =>
                                _BrokenImagePlaceholder(color: cs.error),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 8,
                      child: _DotsIndicator(
                        length: images.length,
                        index: _page,
                        activeColor: cs.primary,
                        inactiveColor: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),
            // Ações
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: _liking ? null : _onLike,
                  icon: _liking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(_liked ? Icons.favorite : Icons.favorite_border),
                  label: Text('$_likeCount'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _commenting ? null : _onComment,
                  icon: _commenting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.mode_comment_outlined),
                  label: Text('$_commentCount'),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Compartilhar',
                  icon: const Icon(Icons.ios_share),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Uint8List? _decodeBase64(String data) {
    try {
      final comma = data.indexOf(',');
      final payload = comma >= 0 ? data.substring(comma + 1) : data;
      return base64Decode(payload);
    } catch (_) {
      return null;
    }
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final initials = _initials(name);
    return CircleAvatar(
      radius: 20,
      backgroundColor: cs.primaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          color: cs.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _initials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.length,
    required this.index,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int length;
  final int index;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: List.generate(length, (i) {
            final active = i == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: active ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _BrokenImagePlaceholder extends StatelessWidget {
  const _BrokenImagePlaceholder({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      alignment: Alignment.center,
      child: Icon(Icons.broken_image_outlined, size: 36, color: color),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scheme});
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
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 48),
            SizedBox(height: 12),
            Text(
              'Nenhuma denúncia encontrada com os filtros atuais.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'Ajuste os filtros no botão acima.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

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
    super.key,
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

            Wrap(
              spacing: compact ? 8 : 12,
              runSpacing: compact ? 8 : 12,
              children: [
                // Estado (nome por extenso)
                SizedBox(
                  width: compact ? double.infinity : 280,
                  child: loadingStates
                      ? const LinearProgressIndicator(minHeight: 2)
                      : DropdownButtonFormField<String>(
                          value: stateName,
                          items: states
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
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
                // Categoria (label apenas)
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
                // Status (label apenas)
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
                      DropdownMenuItem(
                        value: 30,
                        child: Text('Últimos 30 dias'),
                      ),
                      DropdownMenuItem(
                        value: 90,
                        child: Text('Últimos 90 dias'),
                      ),
                    ],
                    onChanged: onSelectPeriod,
                    decoration: deco('Período', Icons.calendar_today_outlined),
                  ),
                ),

                // Minhas denúncias
                FilterChip(
                  selected: mineOnly,
                  label: const Text('Minhas denúncias'),
                  onSelected: onToggleMineOnly,
                ),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onUseMyLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Usar minha localização'),
                ),
                const Spacer(),
                TextButton(onPressed: onClear, child: const Text('Limpar')),
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
