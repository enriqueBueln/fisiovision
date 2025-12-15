import 'dart:convert';
import 'package:fisiovision/models/ejercicio_model.dart';
import 'package:fisiovision/providers/ejercicios_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Enum para tipos de ejercicio
enum TypeExercise {
  fuerza,
  movilidad,
  equilibrio,
  rotacion,
  extension,
  flexion,
  otro,
}

class ExerciseFormScreen extends ConsumerStatefulWidget {
  const ExerciseFormScreen({super.key});

  @override
  ConsumerState<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends ConsumerState<ExerciseFormScreen> {
  String? _selectedJoint;
  String? _selectedSide;
  final _formKey = GlobalKey<FormState>();
  final Map<String, Map<String, int>> _angulosMap = {};

  // Controladores temporales para agregar un nuevo ángulo
  final _tempJointCtrl = TextEditingController();
  final _tempAngleCtrl = TextEditingController();

  // Controladores
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _instruccionesCtrl = TextEditingController();
  final _precaucionesCtrl = TextEditingController();
  final _repeticionesCtrl = TextEditingController();
  final _seriesCtrl = TextEditingController();
  final _duracionCtrl = TextEditingController();
  final _toleranciaCtrl = TextEditingController();

  // Estado
  TypeExercise _tipoEjercicio = TypeExercise.fuerza;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _instruccionesCtrl.dispose();
    _precaucionesCtrl.dispose();
    _repeticionesCtrl.dispose();
    _seriesCtrl.dispose();
    _duracionCtrl.dispose();
    _toleranciaCtrl.dispose();
    _tempJointCtrl.dispose();
    _tempAngleCtrl.dispose();
    super.dispose();
  }

  Color _getTypeColor(TypeExercise type) {
    switch (type) {
      case TypeExercise.fuerza:
        return const Color(0xFFE53935);
      case TypeExercise.movilidad:
        return const Color(0xFF43A047);
      case TypeExercise.equilibrio:
        return const Color(0xFF1E88E5);
      case TypeExercise.rotacion:
        return const Color(0xFF8E24AA);
      case TypeExercise.extension:
        return const Color(0xFFFFB300);
      case TypeExercise.flexion:
        return const Color(0xFF00ACC1);
      case TypeExercise.otro:
        return const Color(0xFF6D4C41);
    }
  }

  String _getTypeText(TypeExercise type) {
    switch (type) {
      case TypeExercise.fuerza:
        return 'Fuerza 💪';
      case TypeExercise.movilidad:
        return 'Movilidad 🏃';
      case TypeExercise.equilibrio:
        return 'Equilibrio 🤸';
      case TypeExercise.rotacion:
        return 'Rotación 🔄';
      case TypeExercise.extension:
        return 'Extensión ➡️';
      case TypeExercise.flexion:
        return 'Flexión ⬅️';
      case TypeExercise.otro:
        return 'Otro ❓';
    }
  }

  void _agregarAngulo() {
    if (_selectedJoint == null || _selectedSide == null) return;

    final angle = int.tryParse(_tempAngleCtrl.text);
    if (angle == null) return;

    setState(() {
      _angulosMap[_selectedJoint!] ??= {};
      _angulosMap[_selectedJoint!]![_selectedSide!] = angle;
    });

    _tempAngleCtrl.clear();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simular llamada al backend
      await Future.delayed(const Duration(seconds: 2));
      final nuevoEjercicioData = Ejercicio(
        id: 0,
        name: _nombreCtrl.text.trim(),
        type: _tipoEjercicio.name.toLowerCase(),
        description: _descripcionCtrl.text.trim(),
        duration_seconds: int.tryParse(_duracionCtrl.text) ?? 0,
        repetitions: int.tryParse(_repeticionesCtrl.text) ?? 0,
        series: int.tryParse(_seriesCtrl.text) ?? 0,
        objective_angles: _angulosMap.isNotEmpty
            ? json.encode(_angulosMap)
            : '',
        tolerance_degrees: (int.tryParse(_toleranciaCtrl.text) ?? 0).toDouble(),
        instructions: _instruccionesCtrl.text.trim(),
        precautions: _precaucionesCtrl.text.trim(),
        reference_image: "asdasd",
        reference_video: "asdasd",
      );

      print('Datos listos para enviar al backend: $nuevoEjercicioData');

      if (!mounted) return;
      await ref
          .read(ejerciciosProvider.notifier)
          .agregarEjercicio(nuevoEjercicioData);
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              const Text('Ejercicio registrado exitosamente ✨'),
            ],
          ),
          backgroundColor: const Color(0xFF43A047),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) context.go('/ejercicios');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0E1117)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1C2033) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/ejercicios'),
        ),
        title: Row(
          children: [
            const Text('💪', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            const Text(
              'Nuevo Ejercicio',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SECCIÓN: Información Básica
              _SectionCard(
                emoji: '📋',
                title: 'Información Básica',
                children: [
                  _CustomTextField(
                    controller: _nombreCtrl,
                    label: 'Nombre del Ejercicio',
                    icon: Icons.fitness_center_outlined,
                    hint: 'Ej: Sentadillas con Banda',
                    validator: (value) => value!.trim().isEmpty
                        ? 'El nombre es obligatorio'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Tipo de Ejercicio
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF252B3F)
                          : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 20,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Tipo de Ejercicio',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: TypeExercise.values.map((type) {
                            final isSelected = _tipoEjercicio == type;
                            final color = _getTypeColor(type);
                            return InkWell(
                              onTap: () =>
                                  setState(() => _tipoEjercicio = type),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? color.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? color
                                        : (isDarkMode
                                              ? Colors.white24
                                              : Colors.grey[300]!),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 6,
                                        ),
                                        child: Icon(
                                          Icons.check_circle,
                                          color: color,
                                          size: 16,
                                        ),
                                      ),
                                    Text(
                                      _getTypeText(type),
                                      style: TextStyle(
                                        color: isSelected
                                            ? color
                                            : (isDarkMode
                                                  ? Colors.white70
                                                  : Colors.black87),
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _CustomTextField(
                    controller: _descripcionCtrl,
                    label: 'Descripción',
                    icon: Icons.description_outlined,
                    hint: 'Describe el ejercicio brevemente',
                    minLines: 2,
                    maxLines: 4,
                    validator: (value) => value!.trim().isEmpty
                        ? 'La descripción es obligatoria'
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // SECCIÓN: Métricas
              _SectionCard(
                emoji: '📊',
                title: 'Métricas del Ejercicio',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _CustomTextField(
                          controller: _repeticionesCtrl,
                          label: 'Repeticiones',
                          icon: Icons.repeat,
                          hint: '10',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.trim().isEmpty) return 'Requerido';
                            if (int.tryParse(value) == null) return 'Inválido';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CustomTextField(
                          controller: _seriesCtrl,
                          label: 'Series',
                          icon: Icons.layers_outlined,
                          hint: '3',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.trim().isEmpty) return 'Requerido';
                            if (int.tryParse(value) == null) return 'Inválido';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _CustomTextField(
                          controller: _duracionCtrl,
                          label: 'Duración (seg)',
                          icon: Icons.timer_outlined,
                          hint: '30',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CustomTextField(
                          controller: _toleranciaCtrl,
                          label: 'Tolerancia (°)',
                          icon: Icons.track_changes_outlined,
                          hint: '5',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _SectionCard(
                emoji: '📐',
                title: 'Ángulos Objetivo (Visión Artificial)',
                children: [
                  Row(
                    children: [
                      // --- SELECT ARTICULACIÓN ---
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _selectedJoint,
                          decoration: const InputDecoration(
                            labelText: 'Articulación',
                            prefixIcon: Icon(Icons.accessibility_new_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'cadera',
                              child: Text('Cadera'),
                            ),
                            DropdownMenuItem(
                              value: 'rodilla',
                              child: Text('Rodilla'),
                            ),
                            DropdownMenuItem(
                              value: 'codo',
                              child: Text('Codo'),
                            ),
                            DropdownMenuItem(
                              value: 'hombro',
                              child: Text('Hombro'),
                            ),
                          ],
                          onChanged: (v) => setState(() => _selectedJoint = v),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // --- SELECT LADO ---
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _selectedSide,
                          decoration: const InputDecoration(
                            labelText: 'Lado',
                            prefixIcon: Icon(Icons.swap_horiz),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'izquierdo',
                              child: Text('Izquierdo'),
                            ),
                            DropdownMenuItem(
                              value: 'derecho',
                              child: Text('Derecho'),
                            ),
                          ],
                          onChanged: (v) => setState(() => _selectedSide = v),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // --- GRADOS ---
                      Expanded(
                        child: _CustomTextField(
                          controller: _tempAngleCtrl,
                          label: 'Grados',
                          icon: Icons.straighten,
                          hint: '90',
                          keyboardType: TextInputType.number,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // --- BOTÓN AGREGAR ---
                      Container(
                        decoration: BoxDecoration(
                          color: _getTypeColor(_tipoEjercicio),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _agregarAngulo,
                          icon: const Icon(Icons.add, color: Colors.white),
                          tooltip: 'Agregar ángulo',
                        ),
                      ),
                    ],
                  ),

                  if (_angulosMap.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _angulosMap.entries.map((entry) {
                        final articulacion = entry.key;
                        final lados =
                            entry.value; // { "izquierdo": 10, "derecho": 5 }

                        return Chip(
                          backgroundColor: isDarkMode
                              ? const Color(0xFF252B3F)
                              : const Color(0xFFF8F9FA),
                          label: Text(
                            '$articulacion — izq: ${lados["izquierdo"] ?? "-"}° / der: ${lados["derecho"] ?? "-"}°',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 18,
                            color: Color(0xFFE53935),
                          ),
                          onDeleted: () =>
                              setState(() => _angulosMap.remove(articulacion)),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // SECCIÓN: Información Adicional
              _SectionCard(
                emoji: '📝',
                title: 'Información Adicional',
                children: [
                  _CustomTextField(
                    controller: _instruccionesCtrl,
                    label: 'Instrucciones (Opcional)',
                    icon: Icons.list_alt_outlined,
                    hint: 'Paso a paso del ejercicio',
                    minLines: 3,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  _CustomTextField(
                    controller: _precaucionesCtrl,
                    label: 'Precauciones (Opcional)',
                    icon: Icons.warning_amber_outlined,
                    hint: 'Advertencias o consideraciones',
                    minLines: 2,
                    maxLines: 4,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // BOTONES DE ACCIÓN
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => context.go('/ejercicios'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: isDarkMode
                              ? Colors.white24
                              : Colors.grey[300]!,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _getTypeColor(_tipoEjercicio),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[300],
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.save_outlined, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Registrar Ejercicio',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGETS PERSONALIZADOS
// ============================================================================

class _SectionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.emoji,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C2033) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? minLines;
  final int? maxLines;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.validator,
    this.minLines,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 15,
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
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
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }
}
