import 'package:fisiovision/config/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// void main() {
//   runApp(const FisioApp());
// }

void main() {
  runApp(
    ProviderScope(
      // <--- ¡IMPORTANTE!
      child: MyApp(),
    ),
  );
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'FisioVision',
//       theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
//       home: EjercicioFormScreen(),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router( // .router es la clave
      routerConfig: appRouter, // Tu config de go_router
      title: 'Fisioterapia App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
    );
  }
}

// class FisioApp extends StatelessWidget {
//   const FisioApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Panel Fisioterapeuta',
//       theme: ThemeData(
//         primarySwatch: Colors.teal,
//         useMaterial3: true,
//         scaffoldBackgroundColor: const Color(
//           0xFFF5F7FA,
//         ), // Fondo gris suave web
//       ),
//       home: const MainDashboard(),
//     );
//   }
// }

// class MainDashboard extends StatefulWidget {
//   const MainDashboard({super.key});

//   @override
//   State<MainDashboard> createState() => _MainDashboardState();
// }

// class _MainDashboardState extends State<MainDashboard> {
//   int _selectedIndex = 0;

//   // Lista de Vistas
//   final List<Widget> _views = [
//     const PatientsView(),
//     const ExercisesView(),
//     const SessionsView(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           // 1. SIDEBAR (Navegación Lateral)
//           NavigationRail(
//             extended: true, // Texto visible (Ideal para Web)
//             backgroundColor: Colors.white,
//             elevation: 5,
//             selectedIndex: _selectedIndex,
//             onDestinationSelected: (int index) {
//               setState(() {
//                 _selectedIndex = index;
//               });
//             },
//             leading: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 children: [
//                   const Icon(
//                     Icons.health_and_safety,
//                     size: 40,
//                     color: Colors.teal,
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     "FisioTech",
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             destinations: const [
//               NavigationRailDestination(
//                 icon: Icon(Icons.people_outline),
//                 selectedIcon: Icon(Icons.people),
//                 label: Text('Pacientes'),
//               ),
//               NavigationRailDestination(
//                 icon: Icon(Icons.fitness_center_outlined),
//                 selectedIcon: Icon(Icons.fitness_center),
//                 label: Text('Ejercicios'),
//               ),
//               NavigationRailDestination(
//                 icon: Icon(Icons.assessment_outlined),
//                 selectedIcon: Icon(Icons.assessment),
//                 label: Text('Reportes/Sesiones'),
//               ),
//             ],
//           ),

//           // 2. CONTENIDO PRINCIPAL
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(32.0),
//               child: _views[_selectedIndex],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // VISTA 1: PACIENTES
// // ---------------------------------------------------------------------------
// class PatientsView extends StatelessWidget {
//   const PatientsView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Encabezado con Botón de Crear
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               "Gestión de Pacientes",
//               style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//             ),
//             ElevatedButton.icon(
//               onPressed: () {
//                 // Aquí abres el diálogo o página para crear paciente
//                 print("Crear Paciente");
//               },
//               icon: const Icon(Icons.add, color: Colors.white),
//               label: const Text(
//                 "Nuevo Paciente",
//                 style: TextStyle(color: Colors.white),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.teal,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 15,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),

//         // Tabla de Pacientes
//         Expanded(
//           child: Card(
//             elevation: 2,
//             color: Colors.white,
//             child: ListView.separated(
//               itemCount: 8, // Datos simulados
//               separatorBuilder: (c, i) => const Divider(),
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: Colors.teal.shade100,
//                     child: Text("P${index + 1}"),
//                   ),
//                   title: Text(
//                     "Paciente Ejemplo ${index + 1}",
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text(
//                     "Lesión: Ligamento Cruzado Anterior - Riesgo: ${index % 2 == 0 ? 'Bajo' : 'Alto'}",
//                   ),
//                   trailing: const Icon(Icons.chevron_right),
//                   onTap: () {},
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // VISTA 2: EJERCICIOS
// // ---------------------------------------------------------------------------
// class ExercisesView extends StatelessWidget {
//   const ExercisesView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               "Catálogo de Ejercicios",
//               style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//             ),
//             ElevatedButton.icon(
//               onPressed: () {
//                 print("Crear Ejercicio");
//               },
//               icon: const Icon(Icons.add, color: Colors.white),
//               label: const Text(
//                 "Nuevo Ejercicio",
//                 style: TextStyle(color: Colors.white),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 15,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),

//         Expanded(
//           child: GridView.builder(
//             gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//               maxCrossAxisExtent: 300,
//               childAspectRatio: 3 / 2,
//               crossAxisSpacing: 20,
//               mainAxisSpacing: 20,
//             ),
//             itemCount: 6,
//             itemBuilder: (context, index) {
//               return Card(
//                 elevation: 3,
//                 color: Colors.white,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(
//                       Icons.accessibility_new,
//                       size: 50,
//                       color: Colors.orange,
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       "Sentadilla $index",
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     const Text(
//                       "Rango: 0° - 90°",
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(height: 10),
//                     TextButton(
//                       onPressed: () {},
//                       child: const Text("Editar Parámetros"),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // VISTA 3: SESIONES (REPORTES)
// // ---------------------------------------------------------------------------
// class SessionsView extends StatelessWidget {
//   const SessionsView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Historial de Sesiones",
//           style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 10),
//         const Text(
//           "Monitoreo de ejecución y alertas del sistema inteligente.",
//           style: TextStyle(color: Colors.grey),
//         ),
//         const SizedBox(height: 20),

//         Expanded(
//           child: Card(
//             color: Colors.white,
//             child: SingleChildScrollView(
//               child: DataTable(
//                 headingRowColor: MaterialStateProperty.all(
//                   Colors.grey.shade100,
//                 ),
//                 columns: const [
//                   DataColumn(
//                     label: Text(
//                       'Fecha/Hora',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   DataColumn(
//                     label: Text(
//                       'Paciente',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   DataColumn(
//                     label: Text(
//                       'Ejercicio',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   DataColumn(
//                     label: Text(
//                       'Puntuación',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   DataColumn(
//                     label: Text(
//                       'Estado',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//                 rows: List<DataRow>.generate(
//                   10,
//                   (index) => DataRow(
//                     cells: [
//                       DataCell(Text("2023-10-25 10:30 AM")),
//                       DataCell(Text("Paciente Ejemplo $index")),
//                       DataCell(Text("Flexión de Codo")),
//                       DataCell(
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: index % 3 == 0
//                                 ? Colors.red.shade100
//                                 : Colors.green.shade100,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             index % 3 == 0 ? "45% (Mal)" : "90% (Bien)",
//                             style: TextStyle(
//                               color: index % 3 == 0
//                                   ? Colors.red.shade800
//                                   : Colors.green.shade800,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const DataCell(Text("Completado")),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
