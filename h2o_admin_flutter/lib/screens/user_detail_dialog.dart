import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class UserDetailDialogScreen extends StatefulWidget {
  final String userId;
  final bool isEditMode;

  const UserDetailDialogScreen({
    required this.userId,
    this.isEditMode = false,
    super.key,
  });

  @override
  State<UserDetailDialogScreen> createState() => _UserDetailDialogScreenState();
}

class _UserDetailDialogScreenState extends State<UserDetailDialogScreen> {
  bool _isEdit = false;
  bool _loading = true;
  bool _saving = false;
  UserModel? _user;

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

  @override
  void initState() {
    super.initState();
    _isEdit = widget.isEditMode;

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _curpController = TextEditingController();
    _postalCodeController = TextEditingController();
    _coloniaController = TextEditingController();
    _streetController = TextEditingController();
    _blockController = TextEditingController();
    _exteriorNumberController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUser();
    });
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

  Future<void> _loadUser() async {
    setState(() => _loading = true);
    try {
      final userProvider = context.read<UserProvider>();
      final loadedUser = await userProvider.getUserDetail(widget.userId);
      if (loadedUser != null) {
        setState(() {
          _user = loadedUser;
          _emailController.text = loadedUser.email;
          _nameController.text = loadedUser.name ?? '';
          _phoneController.text = loadedUser.phone ?? '';
          _curpController.text = loadedUser.curp ?? '';
          _postalCodeController.text = loadedUser.postalCode ?? '';
          _coloniaController.text = loadedUser.colonia ?? '';
          _streetController.text = loadedUser.street ?? '';
          _blockController.text = loadedUser.block ?? '';
          _exteriorNumberController.text = loadedUser.exteriorNumber ?? '';
          _role = loadedUser.role;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No se pudo encontrar al usuario solicitado.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar detalles del usuario: $e')),
      );
      Navigator.of(context).pop();
    } finally {
      setState(() => _loading = false);
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _saving = true);

      final Map<String, dynamic> data = {
        'email': _emailController.text,
        'name': _nameController.text.isNotEmpty ? _nameController.text : null,
        'phone':
            _phoneController.text.isNotEmpty ? _phoneController.text : null,
        'curp': _curpController.text.isNotEmpty ? _curpController.text : null,
        'postal_code': _postalCodeController.text.isNotEmpty
            ? _postalCodeController.text
            : null,
        'colonia':
            _coloniaController.text.isNotEmpty ? _coloniaController.text : null,
        'street':
            _streetController.text.isNotEmpty ? _streetController.text : null,
        'block':
            _blockController.text.isNotEmpty ? _blockController.text : null,
        'exterior_number': _exteriorNumberController.text.isNotEmpty
            ? _exteriorNumberController.text
            : null,
        'role': _role.toString().split('.').last,
      };

      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      final success =
          await context.read<UserProvider>().updateUser(widget.userId, data);

      setState(() => _saving = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario actualizado con éxito'),
              backgroundColor: Colors.green,
            ),
          );
          // Reload user info to view mode
          _passwordController.clear();
          await _loadUser();
          setState(() {
            _isEdit = false;
          });
        } else {
          final err = context.read<UserProvider>().lastError;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err ?? 'Error al actualizar el usuario'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _cancel() {
    if (_user != null) {
      setState(() {
        _emailController.text = _user!.email;
        _nameController.text = _user!.name ?? '';
        _phoneController.text = _user!.phone ?? '';
        _curpController.text = _user!.curp ?? '';
        _postalCodeController.text = _user!.postalCode ?? '';
        _coloniaController.text = _user!.colonia ?? '';
        _streetController.text = _user!.street ?? '';
        _blockController.text = _user!.block ?? '';
        _exteriorNumberController.text = _user!.exteriorNumber ?? '';
        _role = _user!.role;
        _passwordController.clear();
        _isEdit = false;
      });
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
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pop(true), // Pop returning true to indicate potential change/reload
      child: Scaffold(
        backgroundColor: Colors.black54,
        body: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent tap propagation inside dialog
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650, maxHeight: 750),
              child: Card(
                margin: const EdgeInsets.all(24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 24,
                child: _loading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _buildDialogContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        _buildHeader(),

        // Body (Scrollable fields)
        Expanded(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: _isEdit ? _buildEditForm() : _buildViewDetails(),
          ),
        ),

        // Actions Footer
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    final displayName = _user?.name ?? 'Sin Nombre';
    final roleText = _getRoleText(_role);
    final roleColor = _getRoleColor(_role);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: roleColor.withOpacity(0.1),
            child: Icon(
              _role == UserRole.admin
                  ? Icons.admin_panel_settings
                  : _role == UserRole.operator
                      ? Icons.engineering
                      : Icons.person,
              color: roleColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEdit ? 'Editar Usuario' : 'Detalles de Usuario',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              roleText,
              style: TextStyle(
                color: roleColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Información General'),
        const SizedBox(height: 12),
        _buildDetailRow(
            Icons.email_outlined, 'Correo Electrónico', _user?.email ?? ''),
        _buildDetailRow(Icons.phone_outlined, 'Teléfono',
            _user?.phone ?? 'No especificado'),
        _buildDetailRow(
            Icons.badge_outlined, 'CURP', _user?.curp ?? 'No especificado'),
        const SizedBox(height: 24),
        _buildSectionTitle('Dirección Registrada'),
        const SizedBox(height: 12),
        _buildDetailRow(Icons.home_outlined, 'Calle y Número',
            '${_user?.street ?? 'No especificada'}${_user?.exteriorNumber != null ? ' #${_user!.exteriorNumber}' : ''}'),
        _buildDetailRow(
            Icons.map_outlined, 'Colonia', _user?.colonia ?? 'No especificada'),
        _buildDetailRow(Icons.grid_view_outlined, 'Manzana',
            _user?.block ?? 'No especificada'),
        _buildDetailRow(Icons.markunread_mailbox_outlined, 'Código Postal',
            _user?.postalCode ?? 'No especificado'),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.blue[800],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[550]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Correo Electrónico *',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'El correo electrónico es obligatorio';
              if (!value.contains('@'))
                return 'Ingrese un correo electrónico válido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Nueva Contraseña (dejar en blanco para conservar)',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<UserRole>(
            initialValue: _role,
            decoration: const InputDecoration(
              labelText: 'Rol *',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            items: UserRole.values
                .map((r) => DropdownMenuItem(
                      value: r,
                      child: Text(_getRoleText(r)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _role = v ?? UserRole.citizen),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre Completo',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _curpController,
            decoration: const InputDecoration(
              labelText: 'CURP',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Dirección'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _streetController,
                  decoration: const InputDecoration(
                    labelText: 'Calle',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _coloniaController,
                  decoration: const InputDecoration(
                    labelText: 'Colonia',
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _blockController,
                  decoration: const InputDecoration(labelText: 'Manzana'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _postalCodeController,
            decoration: const InputDecoration(
              labelText: 'Código Postal',
              prefixIcon: Icon(Icons.markunread_mailbox_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _isEdit
            ? [
                TextButton(
                  onPressed: _saving ? null : _cancel,
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 130,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Guardar Cambios'),
                  ),
                ),
              ]
            : [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Cerrar'),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 130,
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _isEdit = true),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
              ],
      ),
    );
  }
}
