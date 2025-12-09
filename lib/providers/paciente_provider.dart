import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import '../models/paciente_model.dart';
import '../services/paciente_service.dart';

// 1. EL NOTIFIER: Controla la lógica
class PacientesNotifier extends StateNotifier<AsyncValue<List<Paciente>>> {
  final PacienteService _apiService;

  // Iniciamos con "loading" (AsyncValue.loading())
  PacientesNotifier(this._apiService) : super(const AsyncValue.loading()) {
    cargarPacientes(); // Cargar datos al iniciar
  }

  Future<void> cargarPacientes() async {
    try {
      state = const AsyncValue.loading(); // Poner en "cargando"
      final pacientes = await _apiService.getPacientes();
      state = AsyncValue.data(pacientes); // ¡Éxito! Guardamos la data
    } catch (e, stack) {
      state = AsyncValue.error(e, stack); // Manejo de error automático
    }
  }

  // Ejemplo de agregar para que la UI se actualice sola
  Future<void> agregarPaciente(Paciente nuevo) async {
    // Aquí podrías llamar al API primero
    await _apiService.addPaciente(nuevo);
    // Y luego recargas la lista
    cargarPacientes();
  }
}

// 2. EL PROVIDER GLOBAL: Lo que usarás en tus Vistas
final pacientesProvider =
    StateNotifierProvider<PacientesNotifier, AsyncValue<List<Paciente>>>((ref) {
      // Leemos el servicio del paso anterior
      final apiService = ref.watch(pacienteServiceProvider);
      return PacientesNotifier(apiService);
    });
