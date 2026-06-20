import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import 'components/reusable_crud_table.dart';
import 'components/statistic_card.dart';

class UsersAdminPage extends StatefulWidget {
  const UsersAdminPage({super.key});

  @override
  State<UsersAdminPage> createState() => _UsersAdminPageState();
}

class _UsersAdminPageState extends State<UsersAdminPage> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _loading = false;
  Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() => _loading = true);
    context.read<UserProvider>().getAll(
          search: _searchController.text,
          page: _currentPage,
          filters: _filters,
        ).then((_) {
          if (mounted) setState(() => _loading = false);
        });
  }

  Future<void> _openFiltersDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => UserFilterDialog(
        initialFilters: _filters,
      ),
    );
    if (result != null) {
      setState(() {
        _filters = result;
        _currentPage = 1;
      });
      _loadData();
    }
  }

  Future<void> _openUserFormDialog([UserModel? user]) async {
    final success = await showDialog<bool>(
      context: context,
      builder: (ctx) => UserFormDialog(user: user),
    );
    if (success == true) {
      _loadData();
    }
  }

  Future<void> _confirmDelete(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text('¿Está seguro de que desea eliminar al usuario "${user.name ?? user.email}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      final success = await context.read<UserProvider>().deleteUser(user.id);
      setState(() => _loading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Usuario eliminado con éxito' : 'Error al eliminar el usuario'),
          ),
        );
        if (success) _loadData();
      }
    }
  }

  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.operator:
        return 'Operador';
      case UserRole.citizen:
        return 'Ciudadano';
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.purple;
      case UserRole.operator:
        return Colors.blue;
      case UserRole.citizen:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final users = userProvider.users;
    final totalCount = userProvider.usersCount;
    final totalPages = (totalCount / _itemsPerPage).ceil();

    // Stats calculations
    int adminCount = users.where((u) => u.role == UserRole.admin).length;
    int operatorCount = users.where((u) => u.role == UserRole.operator).length;
    int citizenCount = users.where((u) => u.role == UserRole.citizen).length;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs and Actions Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gestión de Red',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Administración de Usuarios',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 120,
                  child: 
                ElevatedButton.icon(
                  onPressed: () => _openUserFormDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Usuario'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Statistics Section
            Row(
              children: [
                Expanded(
                  child: StatisticCard(
                    label: 'Usuarios Totales',
                    value: totalCount.toString(),
                    icon: Icons.people,
                    color: Colors.blue[700]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatisticCard(
                    label: 'Administradores',
                    value: adminCount.toString(),
                    icon: Icons.admin_panel_settings,
                    color: Colors.purple[700]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatisticCard(
                    label: 'Operadores',
                    value: operatorCount.toString(),
                    icon: Icons.engineering,
                    color: Colors.blue[500]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatisticCard(
                    label: 'Ciudadanos',
                    value: citizenCount.toString(),
                    icon: Icons.person,
                    color: Colors.green[600]!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search and Filter controls
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Buscar por email, nombre, teléfono o curp...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() => _currentPage = 1);
                      _loadData();
                    },
                    onSubmitted: (value) {
                      setState(() => _currentPage = 1);
                      _loadData();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filtrar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _openFiltersDialog,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_loading)
              const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ))
            else
              ReusableCrudTable<UserModel>(
                headers: const ['Email', 'Nombre Completo', 'CURP', 'Teléfono', 'Rol', 'Acciones'],
                flexes: const [2, 2, 2, 1, 1, 1],
                items: users,
                currentPage: _currentPage,
                totalPages: totalPages,
                totalCount: totalCount,
                itemsPerPage: _itemsPerPage,
                emptyMessage: 'No se encontraron usuarios en la lista.',
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                  _loadData();
                },
                rowBuilder: (context, user, index) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            user.email,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(user.name ?? 'Sin Nombre'),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(user.curp ?? 'N/A'),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(user.phone ?? 'N/A'),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getRoleColor(user.role).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getRoleText(user.role),
                              style: TextStyle(
                                color: _getRoleColor(user.role),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => _openUserFormDialog(user),
                              icon: const Icon(Icons.edit, color: Colors.grey),
                              iconSize: 20,
                              splashRadius: 20,
                            ),
                            IconButton(
                              onPressed: () => _confirmDelete(user),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              iconSize: 20,
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class UserFormDialog extends StatefulWidget {
  final UserModel? user;

  const UserFormDialog({this.user, super.key});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _curpController;
  late TextEditingController _postalCodeController;
  late TextEditingController _coloniaController;
  late TextEditingController _streetController;
  late TextEditingController _blockController;
  late TextEditingController _exteriorNumberController;
  
  UserRole _role = UserRole.citizen;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _emailController = TextEditingController(text: u?.email ?? '');
    _passwordController = TextEditingController();
    _nameController = TextEditingController(text: u?.name ?? '');
    _phoneController = TextEditingController(text: u?.phone ?? '');
    _curpController = TextEditingController(text: u?.curp ?? '');
    _postalCodeController = TextEditingController(text: u?.postalCode ?? '');
    _coloniaController = TextEditingController(text: u?.colonia ?? '');
    _streetController = TextEditingController(text: u?.street ?? '');
    _blockController = TextEditingController(text: u?.block ?? '');
    _exteriorNumberController = TextEditingController(text: u?.exteriorNumber ?? '');
    if (u != null) {
      _role = u.role;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _curpController.dispose();
    _postalCodeController.dispose();
    _coloniaController.dispose();
    _streetController.dispose();
    _blockController.dispose();
    _exteriorNumberController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      final Map<String, dynamic> data = {
        'email': _emailController.text,
        'name': _nameController.text.isNotEmpty ? _nameController.text : null,
        'phone': _phoneController.text.isNotEmpty ? _phoneController.text : null,
        'curp': _curpController.text.isNotEmpty ? _curpController.text : null,
        'postal_code': _postalCodeController.text.isNotEmpty ? _postalCodeController.text : null,
        'colonia': _coloniaController.text.isNotEmpty ? _coloniaController.text : null,
        'street': _streetController.text.isNotEmpty ? _streetController.text : null,
        'block': _blockController.text.isNotEmpty ? _blockController.text : null,
        'exterior_number': _exteriorNumberController.text.isNotEmpty ? _exteriorNumberController.text : null,
        'role': _role.toString().split('.').last,
      };

      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      bool success;
      if (widget.user != null) {
        success = await context.read<UserProvider>().updateUser(widget.user!.id, data);
      } else {
        // Para creación, password es obligatorio
        if (_passwordController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La contraseña es obligatoria para nuevos usuarios')),
          );
          setState(() => _loading = false);
          return;
        }
        success = await context.read<UserProvider>().createUser(data);
      }

      setState(() => _loading = false);

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
        } else {
          final err = context.read<UserProvider>().lastError;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err ?? 'Error al guardar el usuario')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;
    return AlertDialog(
      title: Text(isEdit ? 'Editar Usuario' : 'Nuevo Usuario'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Correo Electrónico *'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'El correo electrónico es obligatorio';
                    if (!value.contains('@')) return 'Ingrese un correo electrónico válido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: isEdit ? 'Nueva Contraseña (dejar en blanco para conservar)' : 'Contraseña *',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (!isEdit && (value == null || value.isEmpty)) {
                      return 'La contraseña es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  value: _role,
                  decoration: const InputDecoration(labelText: 'Rol *'),
                  items: UserRole.values
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r == UserRole.admin
                                ? 'Administrador'
                                : r == UserRole.operator
                                    ? 'Operador'
                                    : 'Ciudadano'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _role = v ?? UserRole.citizen),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre Completo'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _curpController,
                  decoration: const InputDecoration(labelText: 'CURP'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _postalCodeController,
                        decoration: const InputDecoration(labelText: 'Código Postal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _coloniaController,
                        decoration: const InputDecoration(labelText: 'Colonia'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _streetController,
                        decoration: const InputDecoration(labelText: 'Calle'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _blockController,
                        decoration: const InputDecoration(labelText: 'Manzana'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _exteriorNumberController,
                        decoration: const InputDecoration(labelText: 'Nº Ext'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _save,
          child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Guardar'),
        ),
      ],
    );
  }
}

class UserFilterDialog extends StatefulWidget {
  final Map<String, dynamic> initialFilters;

  const UserFilterDialog({required this.initialFilters, super.key});

  @override
  State<UserFilterDialog> createState() => _UserFilterDialogState();
}

class _UserFilterDialogState extends State<UserFilterDialog> {
  late Map<String, dynamic> _filters;

  late TextEditingController _idController;
  late TextEditingController _emailController;
  late TextEditingController _curpController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _postalCodeController;
  late TextEditingController _coloniaController;
  late TextEditingController _streetController;
  late TextEditingController _blockController;
  late TextEditingController _exteriorNumberController;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);
    _idController = TextEditingController(text: _filters['id'] ?? '');
    _emailController = TextEditingController(text: _filters['email__icontains'] ?? '');
    _curpController = TextEditingController(text: _filters['curp__icontains'] ?? '');
    _nameController = TextEditingController(text: _filters['name__icontains'] ?? '');
    _phoneController = TextEditingController(text: _filters['phone__icontains'] ?? '');
    _postalCodeController = TextEditingController(text: _filters['postal_code__icontains'] ?? '');
    _coloniaController = TextEditingController(text: _filters['colonia__icontains'] ?? '');
    _streetController = TextEditingController(text: _filters['street__icontains'] ?? '');
    _blockController = TextEditingController(text: _filters['block__icontains'] ?? '');
    _exteriorNumberController = TextEditingController(text: _filters['exterior_number__icontains'] ?? '');
  }

  @override
  void dispose() {
    _idController.dispose();
    _emailController.dispose();
    _curpController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _postalCodeController.dispose();
    _coloniaController.dispose();
    _streetController.dispose();
    _blockController.dispose();
    _exteriorNumberController.dispose();
    super.dispose();
  }

  void _apply() {
    _filters.clear();

    if (_idController.text.isNotEmpty) {
      _filters['id'] = _idController.text;
    }
    if (_emailController.text.isNotEmpty) {
      _filters['email__icontains'] = _emailController.text;
    }
    if (_curpController.text.isNotEmpty) {
      _filters['curp__icontains'] = _curpController.text;
    }
    if (_nameController.text.isNotEmpty) {
      _filters['name__icontains'] = _nameController.text;
    }
    if (_phoneController.text.isNotEmpty) {
      _filters['phone__icontains'] = _phoneController.text;
    }
    if (_postalCodeController.text.isNotEmpty) {
      _filters['postal_code__icontains'] = _postalCodeController.text;
    }
    if (_coloniaController.text.isNotEmpty) {
      _filters['colonia__icontains'] = _coloniaController.text;
    }
    if (_streetController.text.isNotEmpty) {
      _filters['street__icontains'] = _streetController.text;
    }
    if (_blockController.text.isNotEmpty) {
      _filters['block__icontains'] = _blockController.text;
    }
    if (_exteriorNumberController.text.isNotEmpty) {
      _filters['exterior_number__icontains'] = _exteriorNumberController.text;
    }
    if (_filters['role'] != null) {
      _filters['role'] = _filters['role'];
    }

    Navigator.of(context).pop({..._filters});
  }

  void _clear() {
    setState(() {
      _filters.clear();
      _idController.clear();
      _emailController.clear();
      _curpController.clear();
      _nameController.clear();
      _phoneController.clear();
      _postalCodeController.clear();
      _coloniaController.clear();
      _streetController.clear();
      _blockController.clear();
      _exteriorNumberController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtros Avanzados (Usuarios)'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rol
              const Text('Rol', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              DropdownButtonFormField<String>(
                value: _filters['role'],
                items: const [
                  DropdownMenuItem(value: 'citizen', child: Text('Ciudadano')),
                  DropdownMenuItem(value: 'operator', child: Text('Operador')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                ],
                onChanged: (v) => setState(() => _filters['role'] = v),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // ID
              const Text('ID (exacto)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  hintText: 'ID de usuario...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // Email
              const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Contiene...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // Name
              const Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Contiene...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // Phone
              const Text('Teléfono', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: 'Contiene...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // CURP
              const Text('CURP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _curpController,
                decoration: InputDecoration(
                  hintText: 'Contiene...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // Postal Code
              const Text('Código Postal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _postalCodeController,
                decoration: InputDecoration(
                  hintText: 'Contiene...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // Colonia
              const Text('Colonia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _coloniaController,
                decoration: InputDecoration(
                  hintText: 'Contiene...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // Street
              const Text('Calle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _streetController,
                decoration: InputDecoration(
                  hintText: 'Contiene...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // Block
              const Text('Manzana', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _blockController,
                decoration: InputDecoration(
                  hintText: 'Contiene...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // Exterior Number
              const Text('Número Exterior', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _exteriorNumberController,
                decoration: InputDecoration(
                  hintText: 'Contiene...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _clear, child: const Text('Limpiar')),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _apply, child: const Text('Aplicar')),
      ],
    );
  }
}
