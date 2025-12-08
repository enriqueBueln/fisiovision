import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ConnectDeviceView extends StatefulWidget {
  const ConnectDeviceView({super.key});

  @override
  State<ConnectDeviceView> createState() =>
      _ConnectDeviceViewState();
}

class _ConnectDeviceViewState extends State<ConnectDeviceView> {
  final _codeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleConnect() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simular conexión al dispositivo
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              const Text('Dispositivo conectado exitosamente ✨'),
            ],
          ),
          backgroundColor: const Color(0xFF43A047),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      // Aquí puedes navegar a la siguiente pantalla
      // context.push('/camera-session');
      print("Conectando con código: ${_codeCtrl.text}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0A0E21)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? const Color(0xFF1A1F3A)
            : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/home'),
        ),
        title: Row(
          children: [
            const Text('🔗', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            const Text(
              'Conectar Dispositivo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono principal con animación sutil
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.laptop_chromebook_rounded,
                  size: 60,
                  color: Color(0xFF1E88E5),
                ),
              ),
              const SizedBox(height: 32),

              // Título principal
              Text(
                "Conectar con Laptop",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Descripción
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Text(
                  "Ingresa el código que aparece en tu pantalla grande para sincronizar la cámara.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Tarjeta de formulario mejorada
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF1A1F3A)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode:
                        AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        // Etiqueta del campo
                        Row(
                          children: [
                            Icon(
                              Icons.pin_outlined,
                              size: 20,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Código de 6 dígitos',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Campo de código
                        TextFormField(
                          controller: _codeCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: TextStyle(
                            fontSize: 32,
                            letterSpacing: 12,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: "000000",
                            hintStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.white24
                                  : Colors.grey[300],
                              letterSpacing: 12,
                            ),
                            counterText: "",
                            filled: true,
                            fillColor: isDarkMode
                                ? const Color(0xFF0F1629)
                                : const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: BorderSide(
                                color: isDarkMode
                                    ? Colors.white.withOpacity(
                                        0.05,
                                      )
                                    : Colors.grey.withOpacity(
                                        0.15,
                                      ),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: const BorderSide(
                                color: Color(0xFF1E88E5),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: const BorderSide(
                                color: Color(0xFFE53935),
                                width: 2,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: const BorderSide(
                                color: Color(0xFFE53935),
                                width: 2,
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 20,
                                ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el código';
                            }
                            if (value.length < 6) {
                              return 'El código debe tener 6 dígitos';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Botón de vincular
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : _handleConnect,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF1E88E5,
                              ),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[300],
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                        CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.link_rounded,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'VINCULAR DISPOSITIVO',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Información adicional
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(
                      0xFF1E88E5,
                    ).withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: const Color(0xFF1E88E5),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'El código se genera automáticamente en la pantalla grande y es válido por 5 minutos.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Ayuda adicional
              TextButton.icon(
                onPressed: () {
                  // Mostrar ayuda o tutorial
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: Color(0xFF1E88E5),
                          ),
                          SizedBox(width: 12),
                          Text('¿Cómo funciona?'),
                        ],
                      ),
                      content: const Text(
                        '1. Abre la aplicación en tu laptop\n'
                        '2. Encontrarás un código de 6 dígitos\n'
                        '3. Ingresa ese código aquí\n'
                        '4. ¡Listo! Tu cámara estará sincronizada',
                        style: TextStyle(height: 1.6),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('ENTENDIDO'),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(
                  Icons.help_outline_rounded,
                  size: 18,
                  color: isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
                label: Text(
                  '¿Necesitas ayuda?',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
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
