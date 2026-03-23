PROCEDIMIENTOS DE DESARROLLO, PRUEBAS Y DESPLIEGUE

DESARROLLO

El proyecto tiene dos carpetas: pantallas (con la interfaz) y modelos (con la lógica). Las pantallas son: inicio, editar_ticket, dividir_gastos, resumen_gasto, historial, perfil y ajustes. Los modelos son: gasto, historial y participante.

Para un cambio nuevo, haces una rama con git checkout -b feature/mi-cambio. Luego ejecutas flutter run para ver los cambios en vivo. Cuando termines, verificas con flutter analyze, formateas con dart format lib/, haces commit con un mensaje claro y pusheas.

Los nombres en código siguen estas reglas: clases en PascalCase (PantallaInicio), variables en camelCase (gastoTotal), variables privadas con _ (_historial), archivos en snake_case (inicio.dart).

Los commits deben decir qué hiciste: feat para funcionalidad nueva, fix para arreglo, docs para documentación, refactor para mejorar código.

PRUEBAS

Escribes pruebas para verificar que el código funciona. Las pruebas unitarias prueban funciones solas. Las pruebas de widget prueban las pantallas.

Ejecutas todas con flutter test. Para ver qué tanto código tienes cubierto: flutter test --coverage.

Antes de guardar cambios, verificas:
- flutter analyze no da errores
- flutter test pasa todo
- dart format lib/ está formateado bien
- las pruebas cubren lo nuevo

DESPLIEGUE

Antes de desplegar, validas: flutter analyze, flutter test, dart format lib/.

Cambias la versión en pubspec.yaml (de 1.0.0+1 a 1.1.0+2 si es algo nuevo, o 1.0.1+2 si es un arreglo).

Actualizas CHANGELOG.md con los cambios.

Para Android: generas un keystore si es primera vez, lo guardas seguro, luego ejecutas flutter build appbundle --release. El archivo sale en build/app/outputs/bundle/release/app-release.aab.

Subes a Google Play Console: nuevo app, subes el archivo, configuras nombre, fotos, privacidad. Esperas 24-72 horas para revisión.

Para iOS: flutter build ios --release, luego configuras en App Store Connect.

COMANDOS RAPIDOS

flutter run - ejecutar app
flutter analyze - revisar errores
dart format lib/ - formatear código
flutter test - ejecutar pruebas
flutter clean - limpiar
flutter pub get - descargar paquetes
flutter pub add nombre - agregar paquete
flutter build appbundle --release - generar para Play Store
flutter devices - ver dispositivos
flutter run -v - logs detallados

PROBLEMAS

Hot reload no funciona: presiona R o haz flutter clean.
Error de Gradle: flutter clean y flutter pub get.
SDK viejo: flutter doctor para ver qué le falta.
App no inicia: flutter clean y flutter run.
Imports rotos: flutter pub get.

Última actualización: 23 de Marzo de 2026
