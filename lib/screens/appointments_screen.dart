import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/providers/auth_provider.dart';
import 'package:proyecto/providers/reparacion_provider.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('es_ES', null);
    setState(() {
      _localeInitialized = true;
    });
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reparacionProvider = Provider.of<ReparacionProvider>(context, listen: false);
    
    final codcliente = authProvider.codCliente.toString();
    if (codcliente.isNotEmpty && codcliente != '0') {
      await reparacionProvider.cargarCitas(codcliente);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mis Citas'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final reparacionProvider = Provider.of<ReparacionProvider>(context);
    final citas = reparacionProvider.citas;
    final isLoading = reparacionProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Citas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _cargarCitas,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : citas.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'No tienes citas programadas',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Las citas se crean automáticamente al registrar un producto',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
    : RefreshIndicator(
        onRefresh: _cargarCitas,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: citas.length,
          itemBuilder: (context, index) {
            return _buildAppointmentCard(citas[index]);
          },
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> cita) {
    DateTime? fecha;
    try {
      String fechaStr = cita['fecha'];
      List<String> parts = fechaStr.split('-');
      if (parts.length == 3) {
        fechaStr = '${parts[2]}-${parts[1]}-${parts[0]}';
      }
      fecha = DateTime.parse(fechaStr);
    } catch (e) {
      fecha = DateTime.now();
    }

    final String hora = cita['hora'] ?? '00:00:00';
    final String estado = cita['estado'] ?? 'Pendiente';
    final String nombreProducto = cita['nombre_producto'] ?? 'Sin nombre';
    final String descripcion = cita['descripcion'] ?? '';
    final String tecnico = cita['tecnico_asignado'] ?? 'Sin asignar';
    final String idcita = cita['idcita'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    estado,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(estado),
                ),
                Text(
                  'Cita #$idcita',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.black, size: 20),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, d MMMM y', 'es_ES').format(fecha),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.black, size: 20),
                const SizedBox(width: 8),
                Text(
                  hora.length >= 5 ? hora.substring(0, 5) : hora,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            
            const Divider(height: 24),
            
            _buildInfoRow('Producto:', nombreProducto),
            if (descripcion.isNotEmpty)
              _buildInfoRow('Descripción:', descripcion),
            _buildInfoRow('Técnico asignado:', tecnico),
            
            if (cita['observaciones'] != null && cita['observaciones'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Observaciones:', cita['observaciones']),
            ],
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAppointmentDetails(context, cita),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Ver Detalles'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmada':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'programada':
        return Colors.blue;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAppointmentDetails(BuildContext context, Map<String, dynamic> cita) {
    DateTime? fecha;
    try {
      String fechaStr = cita['fecha'];
      List<String> parts = fechaStr.split('-');
      if (parts.length == 3) {
        fechaStr = '${parts[2]}-${parts[1]}-${parts[0]}';
      }
      fecha = DateTime.parse(fechaStr);
    } catch (e) {
      fecha = DateTime.now();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de la Cita'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('ID Cita:', cita['idcita'] ?? ''),
              _buildDetailItem('Fecha:', DateFormat('dd/MM/yyyy').format(fecha ?? DateTime.now())),
              _buildDetailItem('Hora:', (cita['hora'] ?? '00:00').length >= 5 ? cita['hora'].substring(0, 5) : cita['hora'] ?? '00:00'),
              _buildDetailItem('Producto:', cita['nombre_producto'] ?? 'Sin nombre'),
              _buildDetailItem('Estado:', cita['estado'] ?? 'Pendiente'),
              if (cita['descripcion']?.toString().isNotEmpty ?? false)
                _buildDetailItem('Descripción:', cita['descripcion']),
              if (cita['observaciones']?.toString().isNotEmpty ?? false)
                _buildDetailItem('Observaciones:', cita['observaciones']),
              _buildDetailItem('Técnico:', cita['tecnico_asignado'] ?? 'Sin asignar'),
              if (cita['fecha_registro']?.toString().isNotEmpty ?? false)
                _buildDetailItem('Fecha registro:', cita['fecha_registro']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}