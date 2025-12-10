import 'package:fisiovision/providers/paciente_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PatientsView extends ConsumerWidget {
  const PatientsView({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // 1. ESCUCHAMOS EL PROVIDER
    final asyncPacientes = ref.watch(pacientesProvider);

    // 2. USAMOS .when PARA MANEJAR ESTADOS
    return asyncPacientes.when(
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: CircularProgressIndicator(),
      )),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (pacientes) {
        
        // SI NO HAY PACIENTES
        if (pacientes.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20),
            child: Text("No hay pacientes registrados"),
          ));
        }

        // 3. UI CON DATOS REALES
        return Card(
          elevation: 0,
          margin: const EdgeInsets.all(16),
          color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text('👥', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Text(
                      'Lista de Pacientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${pacientes.length} pacientes', // Dato Real
                        style: const TextStyle(
                          color: Color(0xFF1E88E5),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Lista de pacientes REALES
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: pacientes.length,
                separatorBuilder: (c, i) => Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                ),
                itemBuilder: (context, index) {
                  final paciente = pacientes[index];
                  
                  // --- MAPEO DE DATOS FALTANTES ---
                  // Como tu DB no tiene "riesgo" ni "lesión" en tabla Paciente, 
                  // simulamos o usamos 'notes' para que no se rompa la UI.
                  const riesgoSimulado = 'Bajo'; // Default por ahora
                  final lesionTexto = paciente.notes != null && paciente.notes!.isNotEmpty 
                      ? paciente.notes! 
                      : 'Sin diagnóstico esp.';

                  return ListTile(
                    onTap: () => context.go('/paciente/${paciente.id}'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: _getRiskColor(riesgoSimulado).withOpacity(0.15),
                      child: Text(
                        paciente.name.isNotEmpty ? paciente.name.substring(0, 1) : '?',
                        style: TextStyle(
                          color: _getRiskColor(riesgoSimulado),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    title: Text(
                      paciente.nombreCompleto, // Usamos tu getter del Modelo
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.healing_outlined,
                            size: 14,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lesionTexto, // Mostramos las notas aquí
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Chip de riesgo simulado
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getRiskColor(riesgoSimulado).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_getRiskEmoji(riesgoSimulado), style: const TextStyle(fontSize: 10)),
                                const SizedBox(width: 4),
                                Text(
                                  riesgoSimulado,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _getRiskColor(riesgoSimulado),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Helpers de color (Mantenidos igual)
  Color _getRiskColor(String riesgo) {
    switch (riesgo) {
      case 'Alto': return const Color(0xFFE53935);
      case 'Medio': return const Color(0xFFFB8C00);
      case 'Bajo': return const Color(0xFF43A047);
      default: return Colors.grey;
    }
  }

  String _getRiskEmoji(String riesgo) {
    switch (riesgo) {
      case 'Alto': return '🔴';
      case 'Medio': return '🟡';
      case 'Bajo': return '🟢';
      default: return '⚪';
    }
  }
}
