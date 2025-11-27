import 'package:flutter/material.dart';
import 'package:proyecto/database/modelos/cita_modelo.dart';

class TarjetaCita extends StatelessWidget {
  final Cita cita;
  final bool puedeEditar;
  final Function onActualizada;

  const TarjetaCita({
    super.key,
    required this.cita,
    required this.puedeEditar,
    required this.onActualizada,
  });

  @override
  Widget build(BuildContext contexto) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cita #${cita.id}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: cita.colorEstado.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cita.colorEstado,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    cita.textoEstado,
                    style: TextStyle(
                      color: cita.colorEstado,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  cita.fechaFormateada,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  cita.horario,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              cita.descripcion,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Costo estimado: \$${cita.costoEstimado}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                if (cita.costoFinal > 0)
                  Text(
                    'Final: \$${cita.costoFinal}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
            if (puedeEditar) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Implementar edición de cita
                      },
                      child: Text('Editar'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Implementar eliminación de cita
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text('Eliminar'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}