import 'package:fisiovision/models/patients_model.dart';
import 'package:fisiovision/services/patients_services.dart';
import 'package:flutter/material.dart';

class AssignedExerciseProvider extends ChangeNotifier {
  final AssignedExerciseService _service =
      AssignedExerciseService();

  List<AssignedExerciseModel> _exercises = [];
  bool _isLoading = false;
  String? _error;

  List<AssignedExerciseModel> get exercises => _exercises;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Los ejercicios con is_active = false son los completados
  int get completedCount =>
      _exercises.where((e) => !e.isActive).length;

  int get totalCount => _exercises.length;

  double get progress =>
      totalCount > 0 ? completedCount / totalCount : 0.0;

  Future<void> fetchExercises({
    int skip = 0,
    int limit = 100,
    bool activeOnly = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _exercises = await _service.getAssignedExercises(
        skip: skip,
        limit: limit,
        activeOnly: activeOnly,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _exercises = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
