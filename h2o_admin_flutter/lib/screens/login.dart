import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../core/config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  bool _remember = false;
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<AuthProvider>().login(
            _emailCtrl.text,
            _passCtrl.text,
          );

      // Verificación de seguridad inmediata después del await
      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
      } else {
        final err = context.read<AuthProvider>().lastError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(err ?? 'Error de autenticación. Verifique sus datos.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppConfig.backgroundGray,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Logo and title
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor:
                              AppConfig.primaryBlue.withOpacity(0.1),
                          child: Icon(Icons.water_drop,
                              size: 56, color: AppConfig.primaryBlue),
                        ),
                        const SizedBox(height: 12),
                        Text('H2O Chimal',
                            style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConfig.primaryBlue)),
                        const SizedBox(height: 4),
                        Text('Portal de Administración Municipal',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: AppConfig.tertiaryTeal)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Card with login form
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: AppConfig.cardBorder)),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.email_outlined),
                                      labelText: 'Correo electrónico',
                                      hintText: 'nombre@chimalhuacan.gob.mx',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Por favor ingrese su correo';
                                      if (!value.contains('@'))
                                        return 'Ingrese un correo válido';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _passCtrl,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      prefixIcon:
                                          const Icon(Icons.lock_outline),
                                      labelText: 'Contraseña',
                                      suffixIcon: TextButton(
                                        onPressed: () {
                                          // placeholder
                                        },
                                        child: const Text(
                                            '¿Olvidó su contraseña?'),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Por favor ingrese su contraseña';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _remember,
                                        onChanged: (v) => setState(
                                            () => _remember = v ?? false),
                                      ),
                                      const SizedBox(width: 4),
                                      const Expanded(
                                          child:
                                              Text('Mantener sesión iniciada')),
                                    ],
                                  ),
                                  if (_error != null) ...[
                                    const SizedBox(height: 8),
                                    Text(_error!,
                                        style: TextStyle(
                                            color: AppConfig.statusPending)),
                                  ],
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.login),
                                      label: _loading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white)
                                          : const Text('Iniciar Sesión'),
                                      onPressed: _loading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppConfig.primaryBlue,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: Text(
                        '© 2026 Municipio de Chimalhuacán - Gestión de Agua Potable y Alcantarillado',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppConfig.cardBorder)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
