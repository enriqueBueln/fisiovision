import 'package:flutter/material.dart';

class PatientsView extends StatelessWidget {
  const PatientsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ya no necesitamos Column ni Scaffold aquí, solo la lista.
    // Usamos un container o directo el contenido.
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 10), // Un poco de aire arriba
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        // shrinkWrap y physics son importantes si esto está dentro de un Column con scroll
        shrinkWrap: true, 
        physics: const ClampingScrollPhysics(), 
        itemCount: 8,
        separatorBuilder: (c, i) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              foregroundColor: Colors.teal.shade900,
              child: Text("P${index + 1}"),
            ),
            title: Text(
              "Paciente Ejemplo ${index + 1}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Lesión: LCA - Riesgo: ${index % 2 == 0 ? 'Bajo' : 'Alto'}",
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
               // Ejemplo: Ir al detalle del paciente
               
            },
          );
        },
      ),
    );
  }
}