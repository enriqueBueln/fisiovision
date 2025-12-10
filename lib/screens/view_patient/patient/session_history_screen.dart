// screens/view_patient/patient/session_history_screen.dart
import 'package:fisiovision/providers/session_history_provider.dart';
import 'package:fisiovision/widgets/scaffold_side_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SessionHistoryScreen extends StatelessWidget {
  const SessionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionHistoryProvider()..fetchSessions(),
      child: const ScaffoldSideMenu(
        title: "Historial de Sesiones",
        subtitle: "Revisa tu progreso y sesiones completadas",
        body: _SessionHistoryBody(),
      ),
    );
  }
}

class _SessionHistoryBody extends StatelessWidget {
  const _SessionHistoryBody();

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Consumer<SessionHistoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return _ErrorView(
            error: provider.error!,
            isDarkMode: isDarkMode,
            onRetry: () => provider.fetchSessions(),
          );
        }

        if (provider.sessions.isEmpty) {
          return _EmptyView(isDarkMode: isDarkMode);
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchSessions(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatisticsCards(
                  provider: provider,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 32),
                _FilterChips(
                  provider: provider,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 24),
                _SessionsList(
                  provider: provider,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatisticsCards extends StatelessWidget {
  final SessionHistoryProvider provider;
  final bool isDarkMode;

  const _StatisticsCards({
    required this.provider,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total',
            value: provider.totalSessions.toString(),
            icon: Icons.fitness_center,
            color: const Color(0xFF3B82F6),
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Completadas',
            value: provider.completedSessions.toString(),
            icon: Icons.check_circle,
            color: const Color(0xFF10B981),
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'En curso',
            value: provider.inProgressSessions.toString(),
            icon: Icons.timelapse,
            color: const Color(0xFFF59E0B),
            isDarkMode: isDarkMode,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDarkMode;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? Colors.white
                  : const Color(0xFF1E293B),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode
                  ? const Color(0xFF64748B)
                  : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final SessionHistoryProvider provider;
  final bool isDarkMode;

  const _FilterChips({
    required this.provider,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'Todas',
            isSelected: provider.statusFilter == 'todas',
            onTap: () => provider.setStatusFilter('todas'),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Completadas',
            isSelected: provider.statusFilter == 'completada',
            onTap: () => provider.setStatusFilter('completada'),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'En curso',
            isSelected: provider.statusFilter == 'en_curso',
            onTap: () => provider.setStatusFilter('en_curso'),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Canceladas',
            isSelected: provider.statusFilter == 'cancelada',
            onTap: () => provider.setStatusFilter('cancelada'),
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6)
              : (isDarkMode
                    ? const Color(0xFF1A1F3A)
                    : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : (isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.3)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDarkMode ? Colors.white70 : Colors.black87),
            fontWeight: isSelected
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SessionsList extends StatelessWidget {
  final SessionHistoryProvider provider;
  final bool isDarkMode;

  const _SessionsList({
    required this.provider,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final sessionsByDate = provider.sessionsByDate;

    if (provider.filteredSessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.filter_list_off,
                size: 64,
                color: isDarkMode
                    ? Colors.grey[600]
                    : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No hay sesiones con este filtro',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sessionsByDate.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 8),
              child: Text(
                entry.key,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? Colors.white
                      : const Color(0xFF1E293B),
                ),
              ),
            ),
            ...entry.value.map(
              (session) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SessionCard(
                  session: session,
                  isDarkMode: isDarkMode,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final dynamic session;
  final bool isDarkMode;

  const _SessionCard({
    required this.session,
    required this.isDarkMode,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completada':
        return const Color(0xFF10B981);
      case 'en_curso':
        return const Color(0xFFF59E0B);
      case 'cancelada':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completada':
        return Icons.check_circle;
      case 'en_curso':
        return Icons.timelapse;
      case 'cancelada':
        return Icons.cancel;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(session.status);
    final timeFormat = DateFormat('HH:mm');

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(session.status),
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.ejercicio.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${timeFormat.format(session.dateStart)}${session.dateEnd != null ? " - ${timeFormat.format(session.dateEnd!)}" : ""}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    session.statusDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.repeat,
                  size: 16,
                  color: isDarkMode
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 6),
                Text(
                  '${session.ejercicio.series} series × ${session.ejercicio.repetitions} reps',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: isDarkMode
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 6),
                Text(
                  '${session.ejercicio.durationSeconds}s',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final bool isDarkMode;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.isDarkMode,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar el historial',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool isDarkMode;

  const _EmptyView({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: isDarkMode
                ? Colors.grey[600]
                : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes sesiones registradas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las sesiones que completes aparecerán aquí',
            style: TextStyle(
              color: isDarkMode
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
