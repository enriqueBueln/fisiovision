// import 'dart:convert';
// import 'package:fisiovision/models/ejercicio_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// // Importa tu modelo y tu provider aquí
// // import '../models/ejercicio_model.dart';
// // import '../providers/ejercicios_provider.dart';

// class EjercicioFormScreen extends ConsumerStatefulWidget {
//   const EjercicioFormScreen({super.key});

//   @override
//   ConsumerState<EjercicioFormScreen> createState() =>
//       _EjercicioFormScreenState();
// }

// class _EjercicioFormScreenState extends ConsumerState<EjercicioFormScreen> {
//   // 1. La Llave Global para validar el formulario
//   final _formKey = GlobalKey<FormState>();

//   // 2. Controladores para campos de texto
//   // Tip: Para ints, usaremos controllers de texto y parseamos después
//   final _nombreCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   final _refVideoCtrl = TextEditingController();
//   final _refImageCtrl = TextEditingController(); // Nuevo campo requerido
//   final _duracionCtrl = TextEditingController();
//   final _repsCtrl = TextEditingController();
//   final _seriesCtrl = TextEditingController();
//   final _toleranciaCtrl = TextEditingController();

//   // 3. Estado para el Enum (Valor inicial por defecto)
//   TypeExercise _selectedType = TypeExercise.Fuerza;

//   // 4. EL TRUCO: Estado local para manejar los Ángulos Objetivos dinámicamente
//   // Esto guardará: {"codo_izquierdo": 90, "rodilla": 45}
//   final Map<String, int> _angulosMap = {};

//   // Controladores temporales para agregar un nuevo ángulo
//   final _tempJointCtrl = TextEditingController();
//   final _tempAngleCtrl = TextEditingController();

//   @override
//   void dispose() {
//     // Buena práctica: Limpiar controladores para liberar memoria
//     _nombreCtrl.dispose();
//     _descCtrl.dispose();
//     _refVideoCtrl.dispose();
//     _refImageCtrl.dispose();
//     _duracionCtrl.dispose();
//     _repsCtrl.dispose();
//     _seriesCtrl.dispose();
//     _toleranciaCtrl.dispose();
//     _tempJointCtrl.dispose();
//     _tempAngleCtrl.dispose();
//     super.dispose();
//   }

//   // Función para guardar
//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       // Validacion extra: Que haya al menos un ángulo configurado
//       if (_angulosMap.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Agrega al menos un ángulo objetivo')),
//         );
//         return;
//       }

//       // 1. Convertir el mapa de ángulos a JSON String
//       final String jsonAngles = jsonEncode(_angulosMap);

//       // 2. Crear el objeto (Parseando los strings a int)
//       final nuevoEjercicio = Exercise(
//         id: DateTime.now().millisecondsSinceEpoch
//             .toString(), // ID temporal o vacío si el back lo genera
//         nombre: _nombreCtrl.text,
//         descripcion: _descCtrl.text,
//         referenceVideo: _refVideoCtrl.text,
//         referenceImage: _refImageCtrl.text,
//         durationSeconds: int.parse(_duracionCtrl.text),
//         repeticiones: int.parse(_repsCtrl.text),
//         series: int.parse(_seriesCtrl.text),
//         toleranceDegrees: int.parse(_toleranciaCtrl.text),
//         objetiveAngles: jsonAngles, // <--- AQUÍ VA EL JSON AUTOMÁTICO
//         completed: false,
//         type: _selectedType,
//       );

//       // 3. Llamar a tu Riverpod Provider (descomenta cuando tengas el provider)
//       // ref.read(ejerciciosProvider.notifier).agregarEjercicio(nuevoEjercicio);

//       print("Ejercicio guardado: ${nuevoEjercicio.objetiveAngles}"); // Debug
//       Navigator.pop(context); // Cerrar pantalla
//     }
//   }

//   // Helper para agregar ángulo a la lista visual
//   void _agregarAngulo() {
//     final joint = _tempJointCtrl.text.trim();
//     final angleStr = _tempAngleCtrl.text.trim();

//     if (joint.isNotEmpty && angleStr.isNotEmpty) {
//       setState(() {
//         _angulosMap[joint] = int.parse(angleStr);
//       });
//       _tempJointCtrl.clear();
//       _tempAngleCtrl.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Nuevo Ejercicio")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // --- SECCIÓN 1: DATOS BÁSICOS ---
//               TextFormField(
//                 controller: _nombreCtrl,
//                 decoration: const InputDecoration(
//                   labelText: "Nombre del Ejercicio",
//                 ),
//                 validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
//               ),
//               const SizedBox(height: 10),

//               DropdownButtonFormField<TypeExercise>(
//                 value: _selectedType,
//                 decoration: const InputDecoration(
//                   labelText: "Tipo de Ejercicio",
//                 ),
//                 items: TypeExercise.values.map((type) {
//                   return DropdownMenuItem(
//                     value: type,
//                     child: Text(
//                       type.toString().split('.').last,
//                     ), // Muestra solo "Fuerza"
//                   );
//                 }).toList(),
//                 onChanged: (val) => setState(() => _selectedType = val!),
//               ),
//               const SizedBox(height: 10),

//               TextFormField(
//                 controller: _descCtrl,
//                 decoration: const InputDecoration(labelText: "Descripción"),
//                 maxLines: 2,
//                 validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
//               ),

//               // --- SECCIÓN 2: NÚMEROS (Row para ahorrar espacio) ---
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _seriesCtrl,
//                       decoration: const InputDecoration(labelText: "Series"),
//                       keyboardType: TextInputType.number,
//                       validator: (value) =>
//                           int.tryParse(value ?? '') == null ? 'Num' : null,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _repsCtrl,
//                       decoration: const InputDecoration(
//                         labelText: "Repeticiones",
//                       ),
//                       keyboardType: TextInputType.number,
//                       validator: (value) =>
//                           int.tryParse(value ?? '') == null ? 'Num' : null,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _duracionCtrl,
//                       decoration: const InputDecoration(labelText: "Segundos"),
//                       keyboardType: TextInputType.number,
//                       validator: (value) =>
//                           int.tryParse(value ?? '') == null ? 'Num' : null,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _toleranciaCtrl,
//                 decoration: const InputDecoration(
//                   labelText: "Tolerancia (Grados)",
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) => int.tryParse(value ?? '') == null
//                     ? 'Debe ser número'
//                     : null,
//               ),

//               const SizedBox(height: 20),
//               const Divider(),

//               // --- SECCIÓN 3: LA PARTE INTERESANTE (Ángulos) ---
//               const Text(
//                 "Ángulos Objetivo (Visión Artificial)",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               const SizedBox(height: 10),

//               // Inputs pequeños para agregar
//               Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: TextField(
//                       // Usamos TextField normal porque no es del form principal
//                       controller: _tempJointCtrl,
//                       decoration: const InputDecoration(
//                         labelText: "Articulación (ej. codo_der)",
//                         isDense: true,
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     flex: 1,
//                     child: TextField(
//                       controller: _tempAngleCtrl,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         labelText: "Grados",
//                         isDense: true,
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: _agregarAngulo,
//                     icon: const Icon(Icons.add_circle, color: Colors.blue),
//                   ),
//                 ],
//               ),

//               // Lista visual de lo que llevamos agregado
//               if (_angulosMap.isNotEmpty)
//                 Container(
//                   margin: const EdgeInsets.only(top: 10),
//                   padding: const EdgeInsets.all(8),
//                   color: Colors.grey[100],
//                   child: Column(
//                     children: _angulosMap.entries.map((entry) {
//                       return ListTile(
//                         dense: true,
//                         title: Text(entry.key),
//                         trailing: Text("${entry.value}°"),
//                         leading: IconButton(
//                           icon: const Icon(
//                             Icons.delete,
//                             color: Colors.red,
//                             size: 20,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _angulosMap.remove(entry.key);
//                             });
//                           },
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),

//               const SizedBox(height: 20),

//               // --- BOTÓN FINAL ---
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: const Text("GUARDAR EJERCICIO"),
//               ),
//               const SizedBox(height: 40), // Espacio final
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum para tipos de ejercicio
enum TypeExercise { Fuerza, Cardio, Flexibilidad, Equilibrio }

class ExerciseFormScreen extends ConsumerStatefulWidget {
  const ExerciseFormScreen({super.key});

  @override
  ConsumerState<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends ConsumerState<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  // 4. EL TRUCO: Estado local para manejar los Ángulos Objetivos dinámicamente
  // Esto guardará: {"codo_izquierdo": 90, "rodilla": 45}
  final Map<String, int> _angulosMap = {};

  // Controladores temporales para agregar un nuevo ángulo
  final _tempJointCtrl = TextEditingController();
  final _tempAngleCtrl = TextEditingController();
  // Controladores
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _objetiveAnglesCtrl = TextEditingController();
  final _instruccionesCtrl = TextEditingController();
  final _precaucionesCtrl = TextEditingController();
  final _repeticionesCtrl = TextEditingController();
  final _seriesCtrl = TextEditingController();
  final _duracionCtrl = TextEditingController();
  final _toleranciaCtrl = TextEditingController();

  // Estado
  TypeExercise _tipoEjercicio = TypeExercise.Fuerza;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _objetiveAnglesCtrl.dispose();
    _instruccionesCtrl.dispose();
    _precaucionesCtrl.dispose();
    _repeticionesCtrl.dispose();
    _seriesCtrl.dispose();
    _duracionCtrl.dispose();
    _toleranciaCtrl.dispose();
    super.dispose();
  }

  // Función de utilidad para obtener el color del tipo de ejercicio
  Color _getTypeColor(TypeExercise type) {
    switch (type) {
      case TypeExercise.Fuerza:
        return Colors.red.shade700;
      case TypeExercise.Cardio:
        return Colors.green.shade700;
      case TypeExercise.Flexibilidad:
        return Colors.blue.shade700;
      case TypeExercise.Equilibrio:
        return Colors.purple.shade700;
    }
  }

  void _agregarAngulo() {
    final joint = _tempJointCtrl.text.trim();
    final angleStr = _tempAngleCtrl.text.trim();

    if (joint.isNotEmpty && angleStr.isNotEmpty) {
      setState(() {
        _angulosMap[joint] = int.parse(angleStr);
      });
      _tempJointCtrl.clear();
      _tempAngleCtrl.clear();
    }
  }

  // Función de utilidad para obtener el texto del tipo de ejercicio
  String _getTypeText(TypeExercise type) {
    switch (type) {
      case TypeExercise.Fuerza:
        return 'Fuerza 💪';
      case TypeExercise.Cardio:
        return 'Cardio 🏃';
      case TypeExercise.Flexibilidad:
        return 'Flexibilidad 🤸';
      case TypeExercise.Equilibrio:
        return 'Equilibrio ⚖️';
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final nuevoEjercicioData = {
        'nombre': _nombreCtrl.text,
        'descripcion': _descripcionCtrl.text,
        'tipo': _tipoEjercicio.name,
        'repeticiones': int.tryParse(_repeticionesCtrl.text) ?? 0,
        'series': int.tryParse(_seriesCtrl.text) ?? 0,
        'duracion_segundos': int.tryParse(_duracionCtrl.text) ?? 0,
        'tolerancia_grados': int.tryParse(_toleranciaCtrl.text) ?? 0,
        'angulos_objetivo': _objetiveAnglesCtrl.text,
        'instrucciones': _instruccionesCtrl.text,
        'precauciones': _precaucionesCtrl.text,
      };

      print('Datos listos para enviar al backend: $nuevoEjercicioData');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('¡Ejercicio registrado con éxito!'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      // Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final typeColor = _getTypeColor(_tipoEjercicio);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Registrar Nuevo Ejercicio'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card principal del formulario
            Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título de sección con icono
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.fitness_center,
                              color: typeColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Información del Ejercicio',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(
                        height: 1,
                        color: colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 24),

                      // Campo Nombre
                      TextFormField(
                        controller: _nombreCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nombre del Ejercicio',
                          prefixIcon: Icon(
                            Icons.title,
                            color: colorScheme.primary,
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) => value!.trim().isEmpty
                            ? 'El nombre es obligatorio'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Tipo de Ejercicio
                      Text(
                        'Tipo de Ejercicio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: TypeExercise.values.map((type) {
                          final isSelected = _tipoEjercicio == type;
                          final color = _getTypeColor(type);
                          return InkWell(
                            onTap: () => setState(() => _tipoEjercicio = type),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color
                                    : color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: color,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 6),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  Text(
                                    _getTypeText(type),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Campo Descripción
                      TextFormField(
                        controller: _descripcionCtrl,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 60),
                            child: Icon(
                              Icons.description,
                              color: colorScheme.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) => value!.trim().isEmpty
                            ? 'La descripción es obligatoria'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Sección de Métricas
                      Text(
                        'Métricas del Ejercicio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Row con Repeticiones y Series
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _repeticionesCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Repeticiones',
                                prefixIcon: Icon(
                                  Icons.repeat,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest
                                    .withOpacity(0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value!.trim().isEmpty) return 'Obligatorio';
                                if (int.tryParse(value) == null)
                                  return 'Número inválido';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _seriesCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Series',
                                prefixIcon: Icon(
                                  Icons.layers,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest
                                    .withOpacity(0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value!.trim().isEmpty) return 'Obligatorio';
                                if (int.tryParse(value) == null)
                                  return 'Número inválido';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Row con Duración y Tolerancia
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _duracionCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Duración (seg)',
                                prefixIcon: Icon(
                                  Icons.timer,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest
                                    .withOpacity(0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _toleranciaCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Tolerancia (°)',
                                prefixIcon: Icon(
                                  Icons.track_changes,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest
                                    .withOpacity(0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // // Ángulos Objetivo
                      // TextFormField(
                      //   controller: _objetiveAnglesCtrl,
                      //   decoration: InputDecoration(
                      //     labelText: 'Ángulos Objetivo',
                      //     prefixIcon: Icon(Icons.straighten, color: colorScheme.primary),
                      //     filled: true,
                      //     fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //       borderSide: BorderSide.none,
                      //     ),
                      //     enabledBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //       borderSide: BorderSide(color: colorScheme.outlineVariant),
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //       borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      //     ),
                      //   ),
                      //   validator: (value) => value!.trim().isEmpty ? 'Los ángulos objetivo son obligatorios' : null,
                      // ),
                      // const SizedBox(height: 16),

                      // --- SECCIÓN 3: LA PARTE INTERESANTE (Ángulos) ---
                        const Text(
                        "Ángulos Objetivo (Visión Artificial)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        ),
                        const SizedBox(height: 10),

                        // Inputs pequeños para agregar (estilo consistente con el resto)
                        Row(
                        children: [
                          Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _tempJointCtrl,
                            decoration: InputDecoration(
                            labelText: "Articulación (ej. codo_der)",
                            isDense: true,
                            prefixIcon: Icon(
                              Icons.accessibility_new,
                              color: colorScheme.primary,
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                              ),
                            ),
                            ),
                          ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _tempAngleCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                            labelText: "Grados",
                            isDense: true,
                            prefixIcon: Icon(
                              Icons.straighten,
                              color: colorScheme.primary,
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                              ),
                            ),
                            ),
                          ),
                          ),
                          const SizedBox(width: 8),
                          // Botón añadir con estilo consistente
                          Material(
                          color: typeColor,
                          shape: const CircleBorder(),
                          child: IconButton(
                            onPressed: _agregarAngulo,
                            icon: const Icon(Icons.add, color: Colors.white),
                            tooltip: 'Agregar ángulo',
                          ),
                          ),
                        ],
                        ),

                        // Lista visual compacta de ángulos añadidos (chips coherentes con UI)
                        if (_angulosMap.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _angulosMap.entries.map((entry) {
                          return Chip(
                            backgroundColor:
                              colorScheme.surfaceVariant.withOpacity(0.2),
                            label: Text('${entry.key}: ${entry.value}°'),
                            deleteIcon: Icon(Icons.close,
                              size: 18, color: Colors.red.shade700),
                            onDeleted: () {
                            setState(() {
                              _angulosMap.remove(entry.key);
                            });
                            },
                          );
                          }).toList(),
                        ),
                        ],
                      const SizedBox(height: 16),

                      // Instrucciones
                      TextFormField(
                        controller: _instruccionesCtrl,
                        minLines: 3,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Instrucciones (Opcional)',
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 80),
                            child: Icon(
                              Icons.list_alt,
                              color: colorScheme.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Precauciones
                      TextFormField(
                        controller: _precaucionesCtrl,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Precauciones (Opcional)',
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 60),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
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
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save, size: 24),
                label: const Text(
                  'Registrar Ejercicio',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: typeColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
