PROCEDIMIENTOS DE DESARROLLO, PRUEBAS Y DESPLIEGUE

DESARROLLO

Estructura: carpeta pantallas con la interfaz (inicio, editar_ticket, dividir_gastos, resumen_gasto, historial, perfil, ajustes) y carpeta modelos con datos (gasto, historial, participante). Para cambios: crea rama con git checkout -b feature/nombre, ejecuta flutter run para ver en vivo con hot reload, valida con flutter analyze y dart format lib/, commitea con git commit -m "tipo: descripción" y pushea. Convenciones: clases PascalCase, variables camelCase, privadas con _, archivos snake_case. Tipos de commit: feat, fix, docs, refactor.

PRUEBAS

Ejecuta flutter test. Las pruebas unitarias validan funciones, las de widget validan pantallas. Verifica flutter analyze sin errores, flutter test pase, código formateado y pruebas con cobertura. Ver cobertura: flutter test --coverage.

DESPLIEGUE

Valida con flutter analyze, flutter test, dart format lib/. Cambia versión en pubspec.yaml siguiendo semántico. Android: flutter build appbundle --release genera .aab en build/app/outputs/bundle/release/. Sube a Google Play Console. iOS: flutter build ios --release y configura en App Store Connect.

COMANDOS

flutter run, flutter analyze, dart format lib/, flutter test, flutter clean, flutter pub get, flutter pub add nombre, flutter build appbundle --release, flutter devices, flutter run -v.

PROBLEMAS

Hot reload no funciona: R o flutter clean. Error Gradle: flutter clean y flutter pub get. SDK viejo: flutter doctor. App no inicia: flutter clean y flutter run.
