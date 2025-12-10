// providers/session_history_provider.dart
import 'package:fisiovision/models/sesion_history_model.dart';
import 'package:flutter/material.dart';
import 'package:fisiovision/services/session_history_service.dart';

class SessionHistoryProvider extends ChangeNotifier {
  final SessionHistoryService _service = SessionHistoryService();

  List<SessionHistoryModel> _sessions = [];
  bool _isLoading = false;
  String? _error;

  List<SessionHistoryModel> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtros
  String _statusFilter =
      'todas'; // 'todas', 'completada', 'en_curso', 'cancelada'
  String get statusFilter => _statusFilter;

  List<SessionHistoryModel> get filteredSessions {
    if (_statusFilter == 'todas') {
      return _sessions;
    }
    return _sessions
        .where((s) => s.status == _statusFilter)
        .toList();
  }

  // Sesiones agrupadas por fecha
  Map<String, List<SessionHistoryModel>> get sessionsByDate {
    final Map<String, List<SessionHistoryModel>> grouped = {};

    for (var session in filteredSessions) {
      final dateKey = _formatDateKey(session.dateStart);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(session);
    }

    return grouped;
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == today) {
      return 'Hoy';
    } else if (sessionDate == yesterday) {
      return 'Ayer';
    } else if (now.difference(sessionDate).inDays < 7) {
      return _getWeekdayName(date.weekday);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getWeekdayName(int weekday) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return days[weekday - 1];
  }

  Future<void> fetchSessions({
    int skip = 0,
    int limit = 50,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _service.getSessions(
        skip: skip,
        limit: limit,
      );
      _sessions.sort(
        (a, b) => b.dateStart.compareTo(a.dateStart),
      ); // Más recientes primero
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _sessions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  void clearFilter() {
    _statusFilter = 'todas';
    notifyListeners();
  }

  // Estadísticas
  int get totalSessions => _sessions.length;

  int get completedSessions =>
      _sessions.where((s) => s.status == 'completada').length;

  int get inProgressSessions =>
      _sessions.where((s) => s.status == 'en_curso').length;

  double get completionRate {
    if (_sessions.isEmpty) return 0.0;
    return (completedSessions / totalSessions) * 100;
  }
}
