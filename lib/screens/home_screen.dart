import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/providers/auth_provider.dart';
import 'package:proyecto/providers/reparacion_provider.dart';
import 'package:proyecto/screens/menu_lateral.dart';
import 'package:proyecto/screens/create_rkproducto_screen.dart';
import 'package:proyecto/utils/image_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarProductos();
    });
  }

  Future<void> _cargarProductos() async {
    final reparacionProvider = Provider.of<ReparacionProvider>(context, listen: false);
    await reparacionProvider.cargarProductos();
  }

  final List<Color> _defaultColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  final List<IconData> _defaultIcons = [
    Icons.phone_iphone,
    Icons.computer,
    Icons.videogame_asset,
    Icons.sports_esports,
    Icons.tablet,
    Icons.tv,
    Icons.headset,
  ];

  Color _getColorForIndex(int index) {
    return _defaultColors[index % _defaultColors.length];
  }

  IconData _getIconForIndex(int index) {
    return _defaultIcons[index % _defaultIcons.length];
  }

  void navigateToCreateRkproducto(Map<String, dynamic> producto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRkproductoScreen(producto: producto),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final reparacionProvider = Provider.of<ReparacionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reparaciones RK'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: reparacionProvider.isLoading
                ? null
                : () async {
                    await reparacionProvider.cargarProductos();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Productos actualizados'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
          ),
        ],
      ),
      drawer: MenuLateral(authProvider: authProvider),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[50],
              child: Row(
                children: [
                  Icon(
                    reparacionProvider.isLoading
                        ? Icons.hourglass_empty
                        : reparacionProvider.errorMessage != null
                            ? Icons.error_outline
                            : Icons.check_circle_outline,
                    color: reparacionProvider.isLoading
                        ? Colors.orange
                        : reparacionProvider.errorMessage != null
                            ? Colors.red
                            : Colors.green,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reparacionProvider.isLoading
                              ? 'Cargando productos...'
                              : reparacionProvider.errorMessage != null
                                  ? 'Error cargando productos'
                                  : '¡Bienvenido/a!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (authProvider.userName != null)
                          Text(
                            authProvider.userName!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        if (reparacionProvider.errorMessage != null)
                          Text(
                            reparacionProvider.errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Productos de Reparación',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reparacionProvider.productos.isEmpty
                        ? 'No hay productos disponibles'
                        : 'Selecciona un producto para registrar una reparación',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  if (reparacionProvider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (reparacionProvider.productos.isEmpty)
                    _buildEmptyState()
                  else
                    _buildProductGrid(reparacionProvider, navigateToCreateRkproducto),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(
    ReparacionProvider reparacionProvider,
    Function(Map<String, dynamic>) showRepairDialog,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.1,
      children: List.generate(
        reparacionProvider.productos.length,
        (index) {
          final producto = reparacionProvider.productos[index];
          final hasImage = producto['imageBase64'].isNotEmpty;
          final color = _getColorForIndex(index);
          final icon = _getIconForIndex(index);

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => navigateToCreateRkproducto(producto),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(45),
                        border: Border.all(color: color.withOpacity(0.3), width: 2),
                      ),
                      child: hasImage
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(45),
                              child: Image(
                                image: ImageUtils.imageFromBase64String(producto['imageBase64']),
                                fit: BoxFit.cover,
                                width: 90,
                                height: 90,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    icon,
                                    size: 40,
                                    color: color,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              icon,
                              size: 40,
                              color: color,
                            ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      producto['name'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay productos de reparación',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega productos desde FacturaScripts para verlos aquí',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _cargarProductos,
            icon: const Icon(Icons.refresh),
            label: const Text('Recargar productos'),
          ),
        ],
      ),
    );
  }

}