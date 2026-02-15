import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/providers/auth_provider.dart';
import 'package:proyecto/providers/reparacion_provider.dart';
import 'package:proyecto/utils/image_utils.dart';

class CreateRkproductoScreen extends StatefulWidget {
  final Map<String, dynamic> producto;

  const CreateRkproductoScreen({
    super.key,
    required this.producto,
  });

  @override
  State<CreateRkproductoScreen> createState() => _CreateRkproductoScreenState();
}

class _CreateRkproductoScreenState extends State<CreateRkproductoScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _observacionesController;

  String _tipoSeleccionado = 'Pantalla rota';
  bool _isLoading = false;

  final List<String> _tipos = [
    'Pantalla rota',
    'Batería rota',
    'Joystick',
    'Móvil',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _observacionesController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _guardarRkproducto() async {
    if (_nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre es requerido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final reparacionProvider = Provider.of<ReparacionProvider>(context, listen: false);

      final codcliente = authProvider.codCliente.toString();

      if (codcliente.isEmpty || codcliente == '0') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo obtener el código del cliente'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await reparacionProvider.crearRkproducto(
        nombre: _nombreController.text,
        tipo: _tipoSeleccionado,
        codcliente: codcliente,
        idproducto_reparacion: widget.producto['id'],
        observaciones: _observacionesController.text,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rkproducto "${_nombreController.text}" creado exitosamente'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(reparacionProvider.errorMessage ?? 'Error creando rkproducto'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final hasImage = widget.producto['imageBase64'].isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Rkproducto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Producto de Reparación Seleccionado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (hasImage)
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: ImageUtils.imageFromBase64String(
                              widget.producto['imageBase64'],
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ID: ',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        Expanded(
                          child: Text(
                            widget.producto['id'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nombre: ',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        Expanded(
                          child: Text(
                            widget.producto['name'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    if (widget.producto['description'].isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Descripción: ',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          Expanded(
                            child: Text(
                              widget.producto['description'],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (widget.producto['precio'].isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Precio: ',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          Expanded(
                            child: Text(
                              '\$${widget.producto['precio']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información del Cliente',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cliente: ',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        Expanded(
                          child: Text(
                            authProvider.userName ?? 'Sin nombre',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Código Cliente: ',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        Expanded(
                          child: Text(
                            authProvider.codCliente.toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Text(
              'Datos del producto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del producto *',
                hintText: 'Ej: iPhone X roto',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.edit),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _tipoSeleccionado,
              decoration: InputDecoration(
                labelText: 'Tipo de Reparación *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.category),
              ),
              items: _tipos
                  .map((tipo) => DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo),
                      ))
                  .toList(),
              onChanged: _isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _tipoSeleccionado = value);
                      }
                    },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _observacionesController,
              decoration: InputDecoration(
                labelText: 'Observaciones',
                hintText: 'Observaciones sobre el producto a reparar',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.notes),
              ),
              enabled: !_isLoading,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _guardarRkproducto,
                    icon: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isLoading ? 'Guardando...' : 'Guardar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}