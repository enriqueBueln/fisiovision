import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fisiovision/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<LoginScreen> {
  bool _isLoginMode = true;

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
    // Limpiar errores al cambiar de modo
    ref.read(authProvider.notifier).clearError();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: isDarkMode
            ? const Color(0xFF0E1117)
            : const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // LOGO
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(
                              0xFF1E88E5,
                            ).withOpacity(0.15)
                          : const Color(
                              0xFF1E88E5,
                            ).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.accessibility_new_rounded,
                      size: 60,
                      color: Color(0xFF1E88E5),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // TÍTULO
                  const Text(
                    'FisioVision',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Rehabilitación inteligente',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // CARD DEL FORMULARIO
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF1C2033)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isLoginMode
                        ? _LoginForm(onToggleMode: _toggleMode)
                        : _RegisterForm(onToggleMode: _toggleMode),
                  ),

                  const SizedBox(height: 32),

                  // LINK DE CAMBIO DE MODO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLoginMode
                            ? '¿No tienes cuenta?'
                            : '¿Ya tienes cuenta?',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          fontSize: 15,
                        ),
                      ),
                      TextButton(
                        onPressed: _toggleMode,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                        ),
                        child: Text(
                          _isLoginMode
                              ? 'Crear cuenta'
                              : 'Iniciar sesión',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// FORMULARIO DE LOGIN
class _LoginForm extends ConsumerStatefulWidget {
  final VoidCallback onToggleMode;

  const _LoginForm({required this.onToggleMode});

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isObscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .login(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );

    if (!mounted) return;

    if (success) {
      final authState = ref.read(authProvider);
      final user = authState.user;
      print("Usuario logueado: ${user?.isTerapeuta}");
      if (user != null) {
        // Redirigir según el tipo de usuario
        if (user.isTerapeuta) {
          context.go('/pacientes');
        } else {
          context.go('/home');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final formWidth = isMobile ? double.infinity : 380.0;

    // Mostrar error si existe
    if (authState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      });
    }

    return Center(
      child: SizedBox(
        width: formWidth,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 32),

              // EMAIL
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 15),
                decoration: _buildInputDecoration(
                  isDarkMode: isDarkMode,
                  label: 'Email',
                  hint: 'tu@email.com',
                  icon: Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Requerido';
                  if (!value.contains('@'))
                    return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // PASSWORD
              TextFormField(
                controller: _passCtrl,
                obscureText: _isObscure,
                style: const TextStyle(fontSize: 15),
                decoration: _buildInputDecoration(
                  isDarkMode: isDarkMode,
                  label: 'Contraseña',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _isObscure = !_isObscure),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Requerido';
                  if (value.length < 6)
                    return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // OLVIDÉ MI CONTRASEÑA
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => print("Recuperar contraseña"),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // BOTÓN
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: isDarkMode
                        ? Colors.grey[800]
                        : Colors.grey[300],
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Ingresar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// FORMULARIO DE REGISTRO
class _RegisterForm extends ConsumerStatefulWidget {
  final VoidCallback onToggleMode;

  const _RegisterForm({required this.onToggleMode});

  @override
  ConsumerState<_RegisterForm> createState() =>
      _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _secondNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isObscure = true;
  bool _isObscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _secondNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final phoneNumber = _phoneCtrl.text.isNotEmpty
        ? int.tryParse(_phoneCtrl.text)
        : null;

    final success = await ref
        .read(authProvider.notifier)
        .register(
          name: _nameCtrl.text.trim(),
          secondName: _secondNameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          phoneNumber: phoneNumber,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Registro exitoso! Ahora inicia sesión'),
          backgroundColor: Colors.green,
        ),
      );
      // Cambiar a modo login
      widget.onToggleMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final formWidth = isMobile ? double.infinity : 380.0;

    // Mostrar error si existe
    if (authState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      });
    }

    return Center(
      child: SizedBox(
        width: formWidth,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Crear cuenta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 32),

              // NOMBRE
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(fontSize: 15),
                decoration: _buildInputDecoration(
                  isDarkMode: isDarkMode,
                  label: 'Nombre',
                  hint: 'Tu nombre',
                  icon: Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Requerido';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // APELLIDO
              TextFormField(
                controller: _secondNameCtrl,
                style: const TextStyle(fontSize: 15),
                decoration: _buildInputDecoration(
                  isDarkMode: isDarkMode,
                  label: 'Apellido',
                  hint: 'Tu apellido',
                  icon: Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Requerido';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // EMAIL
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 15),
                decoration: _buildInputDecoration(
                  isDarkMode: isDarkMode,
                  label: 'Email',
                  hint: 'tu@email.com',
                  icon: Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Requerido';
                  if (!value.contains('@'))
                    return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // TELÉFONO (OPCIONAL)
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 15),
                decoration: _buildInputDecoration(
                  isDarkMode: isDarkMode,
                  label: 'Teléfono (opcional)',
                  hint: '1234567890',
                  icon: Icons.phone_outlined,
                ),
              ),
              const SizedBox(height: 20),

              // CONTRASEÑA
              TextFormField(
                controller: _passCtrl,
                obscureText: _isObscure,
                style: const TextStyle(fontSize: 15),
                decoration: _buildInputDecoration(
                  isDarkMode: isDarkMode,
                  label: 'Contraseña',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _isObscure = !_isObscure),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Requerido';
                  if (value.length < 6)
                    return 'Mínimo 6 caracteres';
                  if (value.length > 72)
                    return 'Máximo 72 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // CONFIRMAR CONTRASEÑA
              TextFormField(
                controller: _confirmPassCtrl,
                obscureText: _isObscureConfirm,
                style: const TextStyle(fontSize: 15),
                decoration: _buildInputDecoration(
                  isDarkMode: isDarkMode,
                  label: 'Confirmar contraseña',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(
                      () => _isObscureConfirm = !_isObscureConfirm,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Requerido';
                  if (value != _passCtrl.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // BOTÓN
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: isDarkMode
                        ? Colors.grey[800]
                        : Colors.grey[300],
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Crear cuenta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Función auxiliar para crear decoración de inputs
InputDecoration _buildInputDecoration({
  required bool isDarkMode,
  required String label,
  required String hint,
  required IconData icon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, size: 20),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: isDarkMode
        ? const Color(0xFF252B3F)
        : const Color(0xFFF8F9FA),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.grey.withOpacity(0.15),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(0xFF1E88E5),
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.redAccent,
        width: 1,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
  );
}
