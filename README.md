MI APLICACIÓN FLUTTER
=====================

[Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg)
[Dart Version](https://img.shields.io/badge/Dart-3.x-blue.svg)
[Licencia](https://img.shields.io/badge/Licencia-MIT-green.svg)

Una aplicación multiplataforma construida con Flutter, disponible para
Android, iOS, Web, Windows, macOS y Linux.


CARACTERÍSTICAS
---------------

*   Multiplataforma: Un único código base para todas las plataformas
    principales.
*   Interfaz moderna: Construida con los últimos componentes de Flutter.
*   Rendimiento nativo: Compilación a código nativo para cada plataforma.


CAPTURAS DE PANTALLA
--------------------

(Aquí puedes agregar capturas de pantalla de tu aplicación funcionando en
diferentes dispositivos)


TECNOLOGÍAS UTILIZADAS
----------------------

*   [Flutter](https://flutter.dev) - Framework de UI de Google
*   [Dart](https://dart.dev) - Lenguaje de programación optimizado para UI
*   Soporte para todas las plataformas desktop (Windows, macOS, Linux)
*   Compatibilidad con Web y móvil (Android/iOS)


REQUISITOS PREVIOS
------------------

Antes de comenzar, asegúrate de tener instalado:

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (versión 3.x
    o superior)
*   [Dart SDK](https://dart.dev/get-dart) (incluido con Flutter)
*   Un editor de código (recomendamos
    [VS Code](https://code.visualstudio.com/) o
    [Android Studio](https://developer.android.com/studio))
*   Para desarrollo móvil:
    *   Android Studio (para Android)
    *   Xcode (para iOS, solo macOS)
*   Para desarrollo web: cualquier navegador moderno


ESTRUCTURA DEL PROYECTO
-----------------------

proyecto/
├── lib/                    # Código fuente principal
├── android/                # Configuración específica de Android
├── ios/                    # Configuración específica de iOS
├── web/                    # Configuración específica de Web
├── windows/                # Configuración específica de Windows
├── macos/                  # Configuración específica de macOS
├── linux/                  # Configuración específica de Linux
├── pubspec.yaml            # Dependencias y configuración del proyecto
├── analysis_options.yaml   # Reglas de análisis de Dart
└── README.md               # Este archivo

ESTRUCTURA DEL LIB
-----------------------

lib/
├── api/
│   └── api_config.dart
├── providers/
│   ├── auth_provider.dart
│   └── reparacion_provider.dart
├── screens/
│   ├── about_screen.dart
│   ├── appointments_screen.dart
│   ├── create_kproducto_screen.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── menu_lateral.dart
│   ├── profile_screen.dart
│   └── register_screen.dart
├── utils/
│   └── image_utils.dart
└── main.dart

