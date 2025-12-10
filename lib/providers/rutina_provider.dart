import 'package:flutter_riverpod/flutter_riverpod.dart';
// Asegúrate de importar tu modelo y tu servicio (ajusta la ruta si es necesario)
import '../models/ejercicio_model.dart';
import '../services/rutina_service.dart'; // Asumiendo que guardaste el servicio aquí

// 1. PROVEEDOR DEL SERVICIO (SINGLETON)
// Este lo usas con ref.read(rutinaServiceProvider) para llamar a 'asignarEjercicio'
final rutinaServiceProvider = Provider<RutinaService>((ref) {
  return RutinaService();
});

// 2. PROVEEDOR DE DATOS (FUTURE PROVIDER FAMILY)
// Este lo usas con ref.watch(rutinaPacienteProvider(idPaciente)) en la UI.
// - .family: Permite pasarle el 'idPaciente' como argumento.
// - .autoDispose: Limpia la memoria/cache cuando sales de la pantalla del paciente.
final rutinaPacienteProvider = FutureProvider.family.autoDispose<List<Ejercicio>, int>((ref, idPaciente) async {
  // Obtenemos la instancia del servicio
  final service = ref.watch(rutinaServiceProvider);
  
  // Llamamos a la función del servicio pasando el ID
  return service.getRutinaPaciente(idPaciente);
});