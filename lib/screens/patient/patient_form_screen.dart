import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientFormScreen extends ConsumerStatefulWidget {
  const PatientFormScreen({super.key});

  @override
  ConsumerState<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends ConsumerState<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nombreCtrl = TextEditingController();
  final _diagnosticoCtrl = TextEditingController();
  final _alergiasCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  // Estado
  DateTime? _fechaNacimiento;
  String _riesgo = 'Bajo'; // Nuevo campo para coincidir con la vista principal

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _diagnosticoCtrl.dispose();
    _alergiasCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Selecciona Fecha de Nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null && picked != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_fechaNacimiento == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Por favor, selecciona la fecha de nacimiento.'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      final nuevoPacienteData = {
        'nombre': _nombreCtrl.text,
        'fecha_nacimiento': _fechaNacimiento!.toIso8601String().split('T').first,
        'diagnostico': _diagnosticoCtrl.text,
        'alergias': _alergiasCtrl.text.isEmpty ? 'Ninguna' : _alergiasCtrl.text,
        'telefono': _telefonoCtrl.text,
        'riesgo': _riesgo,
      };

      print('Datos listos para enviar al backend: $nuevoPacienteData');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Paciente registrado con éxito!'),
            ],
          ),
          backgroundColor: Colors.teal.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      // Navigator.pop(context); o context.pop() si usas GoRouter
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Registrar Nuevo Paciente'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card principal del formulario
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título de sección
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.teal.shade100,
                            foregroundColor: Colors.teal.shade900,
                            child: const Icon(Icons.person_add, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Información del Paciente',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 20),

                      // Campo Nombre
                      TextFormField(
                        controller: _nombreCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nombre Completo',
                          prefixIcon: Icon(Icons.person, color: Colors.teal.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                          ),
                        ),
                        validator: (value) => value!.trim().isEmpty ? 'El nombre es obligatorio' : null,
                      ),
                      const SizedBox(height: 16),

                      // Campo Teléfono
                      TextFormField(
                        controller: _telefonoCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          prefixIcon: Icon(Icons.phone, color: Colors.teal.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value!.trim().isEmpty) return 'El teléfono es obligatorio';
                          if (value.trim().length < 8) return 'Teléfono muy corto';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo Fecha de Nacimiento
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _fechaNacimiento == null
                                  ? Colors.red.shade300
                                  : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: _fechaNacimiento == null
                                    ? Colors.red.shade400
                                    : Colors.teal.shade600,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _fechaNacimiento == null
                                      ? 'Fecha de Nacimiento (Requerido)'
                                      : 'Fecha de Nacimiento: ${_fechaNacimiento!.toLocal().toIso8601String().split('T').first}',
                                  style: TextStyle(
                                    color: _fechaNacimiento == null
                                        ? Colors.red.shade400
                                        : Colors.black87,
                                    fontWeight: _fechaNacimiento == null
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              Icon(Icons.edit, color: Colors.grey.shade400, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo Diagnóstico
                      TextFormField(
                        controller: _diagnosticoCtrl,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Diagnóstico / Lesión Principal',
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 60),
                            child: Icon(Icons.medical_services, color: Colors.teal.shade600),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                          ),
                        ),
                        validator: (value) => value!.trim().isEmpty ? 'El diagnóstico es obligatorio' : null,
                      ),
                      const SizedBox(height: 16),

                      // Campo Nivel de Riesgo
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.teal.shade600),
                                const SizedBox(width: 12),
                                const Text(
                                  'Nivel de Riesgo',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Bajo'),
                                    value: 'Bajo',
                                    groupValue: _riesgo,
                                    activeColor: Colors.teal.shade600,
                                    contentPadding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    onChanged: (value) => setState(() => _riesgo = value!),
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Alto'),
                                    value: 'Alto',
                                    groupValue: _riesgo,
                                    activeColor: Colors.teal.shade600,
                                    contentPadding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    onChanged: (value) => setState(() => _riesgo = value!),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo Alergias (Opcional)
                      TextFormField(
                        controller: _alergiasCtrl,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Alergias / Consideraciones médicas (Opcional)',
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 60),
                            child: Icon(Icons.local_hospital, color: Colors.teal.shade600),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // Botón de Guardar
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save, size: 24),
                label: const Text(
                  'Registrar Paciente',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}