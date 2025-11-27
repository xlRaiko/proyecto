import 'package:flutter/material.dart';
import 'package:proyecto/screens/login_screen.dart';
import 'temas/tema_app.dart';

void main() {
  runApp(MiAplicacion());
}

class MiAplicacion extends StatelessWidget {
  @override
  Widget build(BuildContext contexto) {
    return MaterialApp(
      title: 'TechRepair - Sistema de Citas',
      theme: TemaApp.temaDatos,
      home: PantallaLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}