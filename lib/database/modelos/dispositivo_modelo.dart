class Dispositivo {
  final int id;
  final int usuarioId;
  final String nombre;
  final String tipo;
  final String marca;
  final String modelo;
  final String? numeroSerie;
  final String? descripcionProblema;

  Dispositivo({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.tipo,
    required this.marca,
    required this.modelo,
    this.numeroSerie,
    this.descripcionProblema,
  });

  factory Dispositivo.fromMap(Map<String, dynamic> mapa) {
    return Dispositivo(
      id: mapa['id'],
      usuarioId: mapa['usuario_id'],
      nombre: mapa['nombre'],
      tipo: mapa['tipo'],
      marca: mapa['marca'],
      modelo: mapa['modelo'],
      numeroSerie: mapa['numero_serie'],
      descripcionProblema: mapa['descripcion_problema'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'nombre': nombre,
      'tipo': tipo,
      'marca': marca,
      'modelo': modelo,
      'numero_serie': numeroSerie,
      'descripcion_problema': descripcionProblema,
    };
  }

  String get nombreCompleto => '$marca $modelo';
  String get descripcionCompleta => '$tipo - $marca $modelo';

  String get tipoTexto {
    switch (tipo) {
      case 'movil':
        return 'Móvil';
      case 'portatil':
        return 'Portátil';
      case 'tablet':
        return 'Tablet';
      case 'escritorio':
        return 'Escritorio';
      default:
        return tipo;
    }
  }
}