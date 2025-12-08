import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';

// Provider simulado
final authStateProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: isDarkMode
            ? const Color(0xFF0A0E21)
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

                  // LOGO SIMPLE
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
                    child: Icon(
                      Icons.accessibility_new_rounded,
                      size: 60,
                      color: const Color(0xFF1E88E5),
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
                          ? const Color(0xFF1A1F3A)
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
                    child: const _LoginForm(),
                  ),

                  const SizedBox(height: 32),

                  // LINK DE REGISTRO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes cuenta?',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          fontSize: 15,
                        ),
                      ),
                      TextButton(
                        onPressed: () => print("Ir a registro"),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                        ),
                        child: const Text(
                          'Crear cuenta',
                          style: TextStyle(
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

// FORMULARIO
class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm();

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

    ref.read(authStateProvider.notifier).state = true;
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    ref.read(authStateProvider.notifier).state = false;
    print("Login Exitoso: Email: ${_emailCtrl.text}");
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider);
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final formWidth = isMobile ? double.infinity : 380.0;

    return Center(
      child: SizedBox(
        width: formWidth,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TÍTULO DEL FORM
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
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'tu@email.com',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: isDarkMode
                      ? const Color(0xFF0F1629)
                      : const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.05)
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
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: '••••••••',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: isDarkMode
                      ? const Color(0xFF0F1629)
                      : const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.05)
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
                  onPressed: isLoading ? null : _submit,
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
                  child: isLoading
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
