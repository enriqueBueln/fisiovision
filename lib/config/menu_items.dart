// Archivo: lib/config/menu_items.dart
import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final String link;
  final IconData icon;

  const MenuItem({
    required this.title,
    required this.link,
    required this.icon,
  });
}

const appMenuItems = <MenuItem>[
  MenuItem(
    title: 'Pacientes',
    link: '/pacientes',
    icon: Icons.people_outline,
  ),
  MenuItem(
    title: 'Ejercicios',
    link: '/ejercicios',
    icon: Icons.fitness_center_outlined,
  ),
  // Puedes agregar más aquí...
];