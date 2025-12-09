import 'package:fisiovision/models/paciente_model.dart';
import 'package:fisiovision/providers/paciente_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientsView extends ConsumerWidget {
  const PatientsView({super.key});

  // Función auxiliar para mostrar el modal (Ahora recibe un objeto Paciente)
  void _showPatientModal(BuildContext context, Paciente paciente) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PatientDetailModal(paciente: paciente),
    );
  }

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
                    onTap: () => _showPatientModal(context, paciente), // Pasamos el objeto real
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
// ============================================================================
// PATIENT DETAIL MODAL
// ============================================================================
class _PatientDetailModal extends StatelessWidget {
  // Cambio clave: Recibe tu modelo, no un Map
  final Paciente paciente; 

  const _PatientDetailModal({required this.paciente});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final String lesion = paciente.notes ?? "Sin notas registradas";

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white24 : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header Avatar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    paciente.name.isNotEmpty ? paciente.name.substring(0, 1) : '?',
                    style: const TextStyle(
                      color: Color(0xFF1E88E5),
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  paciente.nombreCompleto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${paciente.edad} años • ${paciente.gender}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionCard(
                    icon: Icons.healing, emoji: '🏥', title: 'Información Clínica', // Cambio nombre
                    children: [
                      _InfoRow(
                        label: 'Notas / Lesión',
                        value: lesion,
                        icon: Icons.medical_services_outlined,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Fecha de ingreso (Registro)',
                        // No tenemos fecha ingreso, usamos birth_date o calculamos
                        value: "Registrado recientemente", 
                        icon: Icons.calendar_today_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sección de Progreso (Simulada para mantener estilo)
                  _SectionCard(
                    icon: Icons.trending_up, emoji: '📈', title: 'Progreso (Pendiente)',
                    children: [
                       const Text("Esta sección se activará cuando el paciente realice sesiones.", style: TextStyle(color: Colors.grey)),
                       // Puedes dejar el resto de tu UI original aquí si quieres que se vea "vacía" pero bonita
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Contacto
                  _SectionCard(
                    icon: Icons.contact_phone, emoji: '📞', title: 'Contacto',
                    children: [
                      _InfoRow(
                        label: 'Email',
                        value: paciente.email,
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Dirección',
                        value: paciente.address ?? 'No registrada',
                        icon: Icons.location_on_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String emoji;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF0F1629)
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color:
                      valueColor ??
                      (isDarkMode ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
