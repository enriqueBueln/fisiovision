import 'package:flutter/material.dart';

class PatientsView extends StatelessWidget {
  const PatientsView({super.key});

  // Datos de ejemplo
  List<Map<String, dynamic>> get _pacientes => [
    {
      'id': 1,
      'nombre': 'Carlos Méndez',
      'edad': 34,
      'genero': 'Masculino',
      'lesion': 'Lesión de LCA',
      'riesgo': 'Alto',
      'telefono': '667-123-4567',
      'email': 'carlos.mendez@email.com',
      'fechaIngreso': '15/11/2024',
      'sesiones': 12,
      'progreso': 65,
    },
    {
      'id': 2,
      'nombre': 'María González',
      'edad': 28,
      'genero': 'Femenino',
      'lesion': 'Esguince de tobillo',
      'riesgo': 'Bajo',
      'telefono': '667-234-5678',
      'email': 'maria.gonzalez@email.com',
      'fechaIngreso': '20/11/2024',
      'sesiones': 8,
      'progreso': 80,
    },
    {
      'id': 3,
      'nombre': 'Roberto Silva',
      'edad': 45,
      'genero': 'Masculino',
      'lesion': 'Tendinitis rotuliana',
      'riesgo': 'Medio',
      'telefono': '667-345-6789',
      'email': 'roberto.silva@email.com',
      'fechaIngreso': '10/11/2024',
      'sesiones': 15,
      'progreso': 45,
    },
    {
      'id': 4,
      'nombre': 'Ana Martínez',
      'edad': 52,
      'genero': 'Femenino',
      'lesion': 'Fractura de muñeca',
      'riesgo': 'Alto',
      'telefono': '667-456-7890',
      'email': 'ana.martinez@email.com',
      'fechaIngreso': '05/11/2024',
      'sesiones': 18,
      'progreso': 30,
    },
    {
      'id': 5,
      'nombre': 'Diego Ramírez',
      'edad': 31,
      'genero': 'Masculino',
      'lesion': 'Lumbalgia crónica',
      'riesgo': 'Medio',
      'telefono': '667-567-8901',
      'email': 'diego.ramirez@email.com',
      'fechaIngreso': '25/10/2024',
      'sesiones': 20,
      'progreso': 70,
    },
    {
      'id': 6,
      'nombre': 'Laura Hernández',
      'edad': 39,
      'genero': 'Femenino',
      'lesion': 'Síndrome del túnel carpiano',
      'riesgo': 'Bajo',
      'telefono': '667-678-9012',
      'email': 'laura.hernandez@email.com',
      'fechaIngreso': '30/11/2024',
      'sesiones': 6,
      'progreso': 90,
    },
    {
      'id': 7,
      'nombre': 'Pedro Sánchez',
      'edad': 41,
      'genero': 'Masculino',
      'lesion': 'Rotura del manguito rotador',
      'riesgo': 'Alto',
      'telefono': '667-789-0123',
      'email': 'pedro.sanchez@email.com',
      'fechaIngreso': '12/11/2024',
      'sesiones': 14,
      'progreso': 50,
    },
    {
      'id': 8,
      'nombre': 'Sofia López',
      'edad': 26,
      'genero': 'Femenino',
      'lesion': 'Fascitis plantar',
      'riesgo': 'Bajo',
      'telefono': '667-890-1234',
      'email': 'sofia.lopez@email.com',
      'fechaIngreso': '28/11/2024',
      'sesiones': 5,
      'progreso': 85,
    },
  ];

  void _showPatientModal(
    BuildContext context,
    Map<String, dynamic> paciente,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _PatientDetailModal(paciente: paciente),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(16),
      color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con emoji
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
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF1E88E5,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_pacientes.length} pacientes',
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

          // Lista de pacientes
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _pacientes.length,
            separatorBuilder: (c, i) => Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1),
            ),
            itemBuilder: (context, index) {
              final paciente = _pacientes[index];
              final riesgo = paciente['riesgo'] as String;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: _getRiskColor(
                    riesgo,
                  ).withOpacity(0.15),
                  child: Text(
                    paciente['nombre'].toString().substring(0, 1),
                    style: TextStyle(
                      color: _getRiskColor(riesgo),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                title: Text(
                  paciente['nombre'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.healing_outlined,
                        size: 14,
                        color: isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          paciente['lesion'],
                          style: TextStyle(
                            fontSize: 13,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _getRiskColor(
                            riesgo,
                          ).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getRiskEmoji(riesgo),
                              style: const TextStyle(fontSize: 10),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              riesgo,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getRiskColor(riesgo),
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
                  color: isDarkMode
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
                onTap: () => _showPatientModal(context, paciente),
                hoverColor: const Color(
                  0xFF1E88E5,
                ).withOpacity(0.05),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String riesgo) {
    switch (riesgo) {
      case 'Alto':
        return const Color(0xFFE53935);
      case 'Medio':
        return const Color(0xFFFB8C00);
      case 'Bajo':
        return const Color(0xFF43A047);
      default:
        return Colors.grey;
    }
  }

  String _getRiskEmoji(String riesgo) {
    switch (riesgo) {
      case 'Alto':
        return '🔴';
      case 'Medio':
        return '🟡';
      case 'Bajo':
        return '🟢';
      default:
        return '⚪';
    }
  }
}

// ============================================================================
// PATIENT DETAIL MODAL
// ============================================================================
class _PatientDetailModal extends StatelessWidget {
  final Map<String, dynamic> paciente;

  const _PatientDetailModal({required this.paciente});

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;
    final progreso = paciente['progreso'] as int;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white24
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header con avatar grande
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    paciente['nombre'].toString().substring(0, 1),
                    style: const TextStyle(
                      color: Color(0xFF1E88E5),
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  paciente['nombre'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${paciente['edad']} años • ${paciente['genero']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          // Contenido scrolleable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Diagnóstico
                  _SectionCard(
                    icon: Icons.healing,
                    emoji: '🏥',
                    title: 'Diagnóstico',
                    children: [
                      _InfoRow(
                        label: 'Lesión',
                        value: paciente['lesion'],
                        icon: Icons.medical_services_outlined,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Nivel de riesgo',
                        value: paciente['riesgo'],
                        icon: Icons.warning_amber_outlined,
                        valueColor: _getRiskColor(
                          paciente['riesgo'],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Fecha de ingreso',
                        value: paciente['fechaIngreso'],
                        icon: Icons.calendar_today_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Progreso
                  _SectionCard(
                    icon: Icons.trending_up,
                    emoji: '📈',
                    title: 'Progreso de rehabilitación',
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sesiones completadas',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${paciente['sesiones']} sesiones',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progreso general',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                '$progreso%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E88E5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progreso / 100,
                              minHeight: 10,
                              backgroundColor: isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey[200],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                    progreso >= 70
                                        ? const Color(0xFF43A047)
                                        : progreso >= 40
                                        ? const Color(0xFF1E88E5)
                                        : const Color(0xFFFB8C00),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Datos de contacto
                  _SectionCard(
                    icon: Icons.contact_phone,
                    emoji: '📞',
                    title: 'Información de contacto',
                    children: [
                      _InfoRow(
                        label: 'Teléfono',
                        value: paciente['telefono'],
                        icon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Email',
                        value: paciente['email'],
                        icon: Icons.email_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Acción de ver historial
                          },
                          icon: const Icon(
                            Icons.history,
                            size: 18,
                          ),
                          label: const Text('Historial'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            side: const BorderSide(
                              color: Color(0xFF1E88E5),
                            ),
                            foregroundColor: const Color(
                              0xFF1E88E5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Acción de editar
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Editar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            backgroundColor: const Color(
                              0xFF1E88E5,
                            ),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                        ),
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

  Color _getRiskColor(String riesgo) {
    switch (riesgo) {
      case 'Alto':
        return const Color(0xFFE53935);
      case 'Medio':
        return const Color(0xFFFB8C00);
      case 'Bajo':
        return const Color(0xFF43A047);
      default:
        return Colors.grey;
    }
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
