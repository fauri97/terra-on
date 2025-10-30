import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_footer.dart';
import '../services/service_locator.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Avatar apenas UI (upload real no backend)
  String? _avatarPath;

  // IBGE / Localização
  List<String> _states = [];
  List<String> _cities = [];
  String? _stateName; // ex.: "Rio Grande do Sul"
  String? _uf;        // ex.: "RS"
  String? _city;
  bool _loadingStates = false;
  bool _loadingCities = false;

  @override
  void initState() {
    super.initState();
    _prefillFromAuth();
    _bootstrapIbge();
  }

  void _prefillFromAuth() {
    _nameCtrl.text  = authService.userName ?? '';
    _emailCtrl.text = authService.userEmail ?? '';
    _uf   = authService.userUF;
    _city = authService.userCity;
    _stateName = _uf == null ? null : _guessStateFromUF(_uf!);
  }

  Future<void> _bootstrapIbge() async {
    setState(() => _loadingStates = true);
    final st = await ibgeService.getStates();
    st.sort();
    setState(() {
      _states = st;
      _loadingStates = false;
    });

    if (_uf != null) {
      await _loadCitiesForUF(_uf!);
    }
  }

  String? _guessStateFromUF(String uf) {
    const map = {
      'AC':'Acre','AL':'Alagoas','AP':'Amapá','AM':'Amazonas','BA':'Bahia',
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
    final geo = await geoService.getCurrentCityAndState();
    if (!mounted) return;

    if (geo.permissionDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão de localização negada.')),
      );
      return;
    }
    if (geo.uf == null || geo.city == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível detectar sua cidade.')),
      );
      return;
    }

    setState(() {
      _uf = geo.uf;
      _stateName = _guessStateFromUF(_uf!);
      _loadingCities = true;
    });
    await _loadCitiesForUF(_uf!);

    final detected = _cities.firstWhere(
      (c) => c.toLowerCase() == geo.city!.toLowerCase(),
      orElse: () => '',
    );
    setState(() => _city = detected.isEmpty ? null : detected);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Localização aplicada: ${geo.city} - ${geo.uf}')),
    );
  }

  void _pickAvatarUIOnly() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upload de foto será integrado depois.')),
    );
    setState(() => _avatarPath = 'avatar://placeholder');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if ((_uf ?? '').isEmpty || (_city ?? '').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione Estado (UF) e Cidade.')),
      );
      return;
    }

    authService.updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      uf: _uf,
      city: _city,
      photoPath: _avatarPath,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado.')),
    );
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alterar senha'),
        content: const Text('Fluxo de alteração de senha será implementado quando o backend estiver ativo.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar'))],
      ),
    );
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
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text('Meu perfil', style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Avatar
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(Icons.person, size: 44, color: scheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _pickAvatarUIOnly,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Alterar foto (UI)'),
                  ),

                  const SizedBox(height: 16),
                  // Dados básicos
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Informe seu nome' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Informe seu e-mail';
                      final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
                      return ok ? null : 'E-mail inválido';
                    },
                  ),

                  const SizedBox(height: 16),
                  // UF + Cidade
                  if (_loadingStates)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: LinearProgressIndicator(minHeight: 2),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _stateName,
                            items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => _onSelectState(v),
                            decoration: const InputDecoration(
                              labelText: 'Estado (UF)',
                              prefixIcon: Icon(Icons.flag_outlined),
                            ),
                            validator: (_) =>
                                (_stateName == null || _stateName!.isEmpty) ? 'Selecione a UF' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _city,
                            items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: _loadingCities ? null : (v) => setState(() => _city = v),
                            decoration: const InputDecoration(
                              labelText: 'Cidade',
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
                            validator: (_) => (_city == null || _city!.isEmpty) ? 'Selecione a cidade' : null,
                          ),
                        ),
                      ],
                    ),
                  if (_loadingCities)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _useMyLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Usar minha localização'),
                    ),
                  ),

                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Salvar alterações'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _changePassword,
                    icon: const Icon(Icons.lock_reset_outlined),
                    label: const Text('Alterar senha'),
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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }
}
