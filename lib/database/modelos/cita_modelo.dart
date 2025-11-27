import 'package:flutter/material.dart';

class Cita {
  final int id;
  final int usuarioId;
  final int dispositivoId;
  final int servicioId;
  final DateTime fechaCita;
  final String horario;
  final String estado;
  final String descripcion;
  final double costoEstimado;
  final double costoFinal;
  final String? notasTecnico;
  final String? notasCliente;
  final int? tecnicoAsignadoId;
  final DateTime fechaCreacion;

  Cita({
    required this.id,
    required this.usuarioId,
    required this.dispositivoId,
    required this.servicioId,
    required this.fechaCita,
    required this.horario,
    required this.estado,
    required this.descripcion,
    required this.costoEstimado,
    required this.costoFinal,
    this.notasTecnico,
    this.notasCliente,
    this.tecnicoAsignadoId,
    required this.fechaCreacion,
  });

  factory Cita.fromMap(Map<String, dynamic> mapa) {
    return Cita(
      id: mapa['id'],
      usuarioId: mapa['usuario_id'],
      dispositivoId: mapa['dispositivo_id'],
      servicioId: mapa['servicio_id'],
      fechaCita: DateTime.parse(mapa['fecha_cita']),
      horario: mapa['horario'],
      estado: mapa['estado'],
      descripcion: mapa['descripcion'],
      costoEstimado: mapa['costo_estimado']?.toDouble() ?? 0.0,
      costoFinal: mapa['costo_final']?.toDouble() ?? 0.0,
      notasTecnico: mapa['notas_tecnico'],
      notasCliente: mapa['notas_cliente'],
      tecnicoAsignadoId: mapa['tecnico_asignado_id'],
      fechaCreacion: DateTime.parse(mapa['fecha_creacion']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'dispositivo_id': dispositivoId,
      'servicio_id': servicioId,
      'fecha_cita': fechaCita.toIso8601String().split('T')[0],
      'horario': horario,
      'estado': estado,
      'descripcion': descripcion,
      'costo_estimado': costoEstimado,
      'costo_final': costoFinal,
      'notas_tecnico': notasTecnico,
      'notas_cliente': notasCliente,
      'tecnico_asignado_id': tecnicoAsignadoId,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  String get fechaFormateada {
    return '${fechaCita.day}/${fechaCita.month}/${fechaCita.year}';
  }

  String get textoEstado {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'confirmada':
        return 'Confirmada';
      case 'en_progreso':
        return 'En Progreso';
      case 'completada':
        return 'Completada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return estado;
    }
  }

  Color get colorEstado {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'confirmada':
        return Colors.blue;
      case 'en_progreso':
        return Colors.purple;
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}