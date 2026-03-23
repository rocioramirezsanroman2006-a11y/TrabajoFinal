PROCEDIMIENTOS DE DESARROLLO, PRUEBAS Y DESPLIEGUE

DESARROLLO

La aplicación está organizada en dos carpetas principales. La carpeta pantallas contiene toda la interfaz de usuario con los archivos inicio.dart, editar_ticket.dart, dividir_gastos.dart, resumen_gasto.dart, historial.dart, perfil.dart y ajustes.dart. La carpeta modelos tiene la lógica de datos con los archivos gasto.dart, historial.dart y participante.dart.

Para empezar a desarrollar un cambio, creas una rama nueva con git checkout -b feature/nombre-cambio. Luego ejecutas flutter run para ver tu aplicación en vivo. Flutter permite hot reload automático, lo que significa que los cambios se ven instantáneamente sin perder el estado de la app. Mientras trabajas, puedes ver los cambios reflejados en tiempo real.

Cuando termines tu cambio, ejecutas flutter analyze para verificar que no hay errores de código y dart format lib/ para asegurar que está bien formateado. Después haces un commit con un mensaje descriptivo usando git commit -m "tipo: descripción" y pusheas con git push origin feature/nombre-cambio.

Los nombres de código siguen convenciones específicas. Las clases se escriben en PascalCase como PantallaInicio o Gasto. Las variables y métodos usan camelCase como gastoTotal o calcularDeudas. Las variables privadas llevan guion bajo al inicio como _historial. Los nombres de archivos van en snake_case como editar_ticket.dart. Los commits deben especificar el tipo: feat para funcionalidad nueva, fix para arreglos, docs para documentación, refactor para mejorar código.

PRUEBAS

Las pruebas validan que el código funciona correctamente. Las pruebas unitarias prueban funciones individuales, como verificar que totalGasto calcula la suma correcta de productos o que calcularDeudas funciona en ambos modos. Las pruebas de widget verifican que las pantallas se muestran correctamente y responden a lo que hace el usuario.

Se ejecutan todas las pruebas con flutter test. Para ver cuánto código está cubierto, se usa flutter test --coverage. Antes de guardar cambios, debes verificar que flutter analyze no reporte errores, que flutter test pase completamente, que dart format lib/ no encuentre código sin formatear, que los cambios sean relacionados con una única funcionalidad y que las pruebas cubran la lógica nueva.

DESPLIEGUE

Antes de desplegar, validas el código ejecutando flutter analyze, flutter test y dart format lib/. Luego cambias la versión en pubspec.yaml siguiendo versionado semántico, por ejemplo de 1.0.0+1 a 1.1.0+2 si es una nueva funcionalidad, o a 1.0.1+2 si es un arreglo. Actualizas el archivo CHANGELOG.md documentando los cambios y ejecutas flutter clean seguido de flutter pub get.

Para Android, si es la primera vez generas un keystore con keytool y guardas la contraseña en lugar seguro. Configuras el signing en android/app/build.gradle con la ruta y las contraseñas. Luego ejecutas flutter build appbundle --release para generar el App Bundle, que es el formato que se sube a Google Play Store. El archivo resultante se encuentra en build/app/outputs/bundle/release/app-release.aab.

Para publicar en Google Play Console, creas una nueva app, subes el archivo .aab, configuras el nombre, descripción, fotos de 1080x1920 píxeles, icono y política de privacidad. Luego envías para revisión y esperas entre 24 y 72 horas.

Para iOS, ejecutas flutter build ios --release o usas Xcode directamente, y luego configuras lo necesario en App Store Connect.

COMANDOS

flutter run ejecuta la aplicación. flutter analyze revisa errores. dart format lib/ formatea el código. flutter test ejecuta las pruebas. flutter clean limpia archivos temporales. flutter pub get descarga dependencias. flutter pub add nombre agrega un paquete. flutter build appbundle --release genera el archivo para Play Store. flutter devices muestra dispositivos disponibles. flutter run -v muestra logs detallados.

PROBLEMAS COMUNES

Si hot reload no funciona, presiona R para hot restart o ejecuta flutter clean. Si hay error de Gradle, ejecuta flutter clean y flutter pub get. Si hay problemas de versión SDK, ejecuta flutter doctor. Si el keystore no se encuentra, verifica la ruta en build.gradle. Si la app no inicia, ejecuta flutter clean y flutter run. Si los imports no funcionan, ejecuta flutter pub get.

Última actualización: 23 de Marzo de 2026
