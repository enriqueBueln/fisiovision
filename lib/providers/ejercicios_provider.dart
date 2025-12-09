import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
// Asegúrate de importar tu modelo y tu servicio correctamente
import '../models/ejercicio_model.dart';
import '../services/ejercicio_service.dart'; 

// 1. EL NOTIFIER: Controla la lógica de los Ejercicios
class EjerciciosNotifier extends StateNotifier<AsyncValue<List<Ejercicio>>> {
  final EjercicioService _apiService;

  // Iniciamos con "loading" al igual que en pacientes
  EjerciciosNotifier(this._apiService) : super(const AsyncValue.loading()) {
    cargarEjercicios(); // Cargar ejercicios apenas se inicializa
  }

  // GET: Traer la lista desde el servicio
  Future<void> cargarEjercicios() async {
    try {
      state = const AsyncValue.loading(); // Poner en estado de carga
      final ejercicios = await _apiService.getEjercicios();
      state = AsyncValue.data(ejercicios); // ¡Éxito! Guardamos la lista
    } catch (e, stack) {
      state = AsyncValue.error(e, stack); // Manejo de error automático
    }
  }

  // POST: Agregar un ejercicio y recargar la lista
  Future<void> agregarEjercicio(Ejercicio nuevo) async {
    try {
      // 1. Llamamos al API para guardar
      await _apiService.addEjercicio(nuevo);
      
      // 2. Si no hubo error, recargamos la lista para ver el nuevo item
      await cargarEjercicios();
    } catch (e) {
      // Opcional: Aquí podrías manejar errores de subida si quisieras
      print("Error al agregar ejercicio: $e");
      rethrow; // Re-lanzamos para que la UI sepa que falló si es necesario
    }
  }
}

// 2. EL PROVIDER GLOBAL: Lo que usarás en tus Vistas (ExercisesView)
final ejerciciosProvider =
    StateNotifierProvider<EjerciciosNotifier, AsyncValue<List<Ejercicio>>>((ref) {
  // Leemos el servicio que definiste previamente
  final apiService = ref.watch(ejercicioServiceProvider);
  return EjerciciosNotifier(apiService);
});