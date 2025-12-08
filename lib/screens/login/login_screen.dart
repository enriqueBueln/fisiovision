import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';

// --- PROVIDER SIMULADO PARA ESTE EJEMPLO ---
// (En tu proyecto real, usa tu authProvider existente)
final authStateProvider = StateProvider<bool>(
  (ref) => false,
); // false = no cargando, true = cargando

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Detectar modo oscuro para colores de fondo
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? const Color(0xFF121212)
        : const Color(0xFFF5F5F5);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus
          ?.unfocus(), // Ocultar teclado al tocar fuera
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          // Centrado vertical y horizontal
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. LOGO Y TÍTULO
                const Icon(
                  Icons.accessibility_new_rounded,
                  size: 80,
                  color: Colors.teal,
                ),
                const SizedBox(height: 20),
                Text(
                  'FisioVision',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rehabilitación asistida por IA',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 40),

                // 2. FORMULARIO DENTRO DE CARD (Estilo consistente)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: const _LoginForm(),
                  ),
                ),

                const SizedBox(height: 30),

                // 3. REGISTER LINK
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta?',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // context.push('/register'); // Tu ruta de registro
                        print("Ir a registro");
                      },
                      child: const Text(
                        'Crear cuenta',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- FORMULARIO LÓGICO ---
class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm();

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  final _formKey = GlobalKey<FormState>();

  // Controladores simples (estilo pragmático)
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

    // 1. Activar estado de carga
    ref.read(authStateProvider.notifier).state = true;

    // 2. Simular petición API (Aquí iría tu llamada real)
    await Future.delayed(const Duration(seconds: 2));

    // 3. Desactivar carga
    if (!mounted) return;
    ref.read(authStateProvider.notifier).state = false;

    // 4. Navegar si todo salió bien
    // context.go('/pacientes');
    print("Login Exitoso: Email: ${_emailCtrl.text}");
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final formWidth = isMobile ? double.infinity : 400.0;

    return Center(
      child: SizedBox(
        width: formWidth,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // EMAIL INPUT
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (!value.contains('@')) return 'Correo no válido';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // PASSWORD INPUT
              TextFormField(
                controller: _passCtrl,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (value.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // BUTTON
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'INGRESAR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
