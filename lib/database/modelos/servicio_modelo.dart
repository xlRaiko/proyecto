class Servicio {
  final int id;
  final String nombre;
  final String descripcion;
  final double precioBase;
  final String tipoDispositivo;
  final int tiempoEstimado;
  final bool activo;

  Servicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioBase,
    required this.tipoDispositivo,
    required this.tiempoEstimado,
    required this.activo,
  });

  factory Servicio.fromMap(Map<String, dynamic> mapa) {
    return Servicio(
      id: mapa['id'],
      nombre: mapa['nombre'],
      descripcion: mapa['descripcion'],
      precioBase: mapa['precio_base']?.toDouble() ?? 0.0,
      tipoDispositivo: mapa['tipo_dispositivo'],
      tiempoEstimado: mapa['tiempo_estimado'],
      activo: mapa['activo'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio_base': precioBase,
      'tipo_dispositivo': tipoDispositivo,
      'tiempo_estimado': tiempoEstimado,
      'activo': activo,
    };
  }

  String get tipoDispositivoTexto {
    switch (tipoDispositivo) {
      case 'movil':
        return 'Móvil';
      case 'portatil':
        return 'Portátil';
      case 'tablet':
        return 'Tablet';
      case 'escritorio':
        return 'Escritorio';
      case 'todos':
        return 'Todos los dispositivos';
      default:
        return tipoDispositivo;
    }
  }

  String get tiempoEstimadoTexto {
    if (tiempoEstimado < 60) {
      return '$tiempoEstimado min';
    } else {
      final horas = tiempoEstimado ~/ 60;
      final minutos = tiempoEstimado % 60;
      return minutos > 0 ? '$horas h $minutos min' : '$horas h';
    }
  }
}