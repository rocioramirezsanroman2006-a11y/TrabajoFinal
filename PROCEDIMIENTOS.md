PROCEDIMIENTOS DE DESARROLLO, PRUEBAS Y DESPLIEGUE

DESARROLLO

La aplicación está estructurada en dos carpetas principales: pantallas, que contiene toda la interfaz de usuario, y modelos, que contiene la lógica de datos. En la carpeta de pantallas tenemos inicio.dart, editar_ticket.dart, dividir_gastos.dart, resumen_gasto.dart, historial.dart, perfil.dart y ajustes.dart. En modelos tenemos gasto.dart, historial.dart y participante.dart.

La arquitectura utiliza el patrón Singleton para el ServicioHistorial, que permite mantener el estado global de la aplicación. Los componentes utilizan StatefulWidget para aquellas pantallas que necesitan cambiar de estado dinámicamente. La interfaz sigue Material Design 3 y la persistencia de datos se mantiene en memoria mediante una lista de gastos.

Para desarrollar, primero se crea una rama de feature con git checkout -b feature/nombre-funcionalidad. Luego se ejecuta flutter run para ver los cambios en tiempo real. Flutter permite hot reload automático, lo que significa que los cambios se ven instantáneamente sin perder el estado de la aplicación. Cuando el cambio esté completo, se valida con flutter analyze para verificar que no hay errores de sintaxis y con dart format lib/ para asegurar que el código esté formateado correctamente. Después se hace un commit con un mensaje descriptivo y se pushea la rama al repositorio.

Las convenciones de código son importantes para mantener la consistencia. Las clases se escriben en PascalCase como PantallaInicio o Gasto. Las variables y métodos en camelCase como gastoTotal o calcularDeudas(). Las variables privadas llevan guion bajo al inicio como _historial. Los archivos se escriben en snake_case como editar_ticket.dart. Los commits deben tener un formato tipo: descripción, donde tipo puede ser feat para nuevas funcionalidades, fix para correcciones, docs para documentación, style para formato, refactor para refactorización de código, perf para mejoras de rendimiento y test para tests.

Las dependencias del proyecto incluyen flutter como el framework principal, cupertino_icons para iconos, image_picker para seleccionar imágenes, share_plus para compartir por WhatsApp y url_launcher para abrir URLs. Se pueden agregar nuevas dependencias con flutter pub add nombre_paquete y actualizar todas con flutter pub upgrade.

PRUEBAS

Para asegurar la calidad del código, se implementan pruebas a diferentes niveles. Las pruebas unitarias validan la lógica individual de cada componente, como verificar que totalGasto calcula correctamente la suma de productos o que calcularDeudas funciona tanto en modo equitativo como proporcional. Las pruebas de widget verifican que la interfaz se renderiza correctamente y responde a las interacciones del usuario, por ejemplo que PantallaInicio muestre el título correcto o que el botón eliminar funcione apropiadamente.

Se ejecutan todas las pruebas con flutter test. Si solo se quiere ejecutar un archivo específico, se usa flutter test test/modelos/gasto_test.dart. Para ver la cobertura del código, se ejecuta flutter test --coverage. Antes de hacer un commit, se debe verificar que flutter analyze no reporte errores, que flutter test pase el 100% de las pruebas, que dart format --set-exit-if-changed lib/ no encuentre archivos sin formatear, que los cambios sean cohesivos relacionados con una única funcionalidad y que haya tests que cubran la lógica nueva.

DESPLIEGUE

Antes de desplegar, se debe validar el código ejecutando flutter analyze, flutter test y dart format lib/. Luego se incrementa la versión en pubspec.yaml siguiendo el versionado semántico, por ejemplo de 1.0.0+1 a 1.1.0+2 si es una nueva feature, o a 1.0.1+2 si es un bugfix. Se actualiza el archivo CHANGELOG.md documentando los cambios y finalmente se ejecuta flutter clean y flutter pub get.

Para Android, primero se genera un keystore si es la primera vez con keytool, guardando la contraseña en un lugar seguro. Se configura el signing en android/app/build.gradle con la ruta al keystore y las contraseñas. Luego se ejecuta flutter build appbundle --release para generar el App Bundle, que es el formato recomendado para Google Play Store. El archivo resultante se encuentra en build/app/outputs/bundle/release/app-release.aab.

Para publicar en Google Play Console, se crea una nueva app, se sube el archivo .aab, se configura el nombre, descripción, categoría Finance, se agregaron screenshots de 1080x1920 píxeles, icono y política de privacidad, y finalmente se envía para revisión, lo que tarda entre 24 y 72 horas.

Para iOS, se ejecuta flutter build ios --release o se utiliza Xcode directamente. Luego se debe configurar lo necesario en App Store Connect incluyendo certificados y provisioning profiles.

El versionado semántico se formato es MAJOR.MINOR.PATCH+BUILD. Una versión cambia a MAJOR cuando hay cambios incompatibles, a MINOR cuando se agrega una nueva funcionalidad, a PATCH cuando se arregla un bug y BUILD aumenta con cada nueva compilación. Después del despliegue se deben monitorear las primeras 24 horas, revisar ratings y comentarios de usuarios, verificar si hay crashes y estar atento a reportes de problemas.

COMANDOS PRINCIPALES

Para ejecutar la aplicación se usa flutter run. Para analizar código flutter analyze. Para formatear dart format lib/. Para ejecutar tests flutter test. Para limpiar flutter clean. Para obtener dependencias flutter pub get. Para agregar un paquete flutter pub add nombre. Para generar APK flutter build apk --release. Para generar App Bundle flutter build appbundle --release. Para ver dispositivos disponibles flutter devices. Para logs detallados flutter run -v.

PROBLEMAS COMUNES

Si hot reload no funciona, se puede intentar hot restart presionando R o ejecutando flutter clean. Si hay error de Gradle, se ejecuta flutter clean seguido de flutter pub get. Si hay problemas de versión SDK, se ejecuta flutter doctor para ver qué falta instalar. Si el keystore no se encuentra, se verifica la ruta en build.gradle. Si la app no inicia en el dispositivo, se ejecuta flutter clean y luego flutter run. Si los imports no funcionan, se ejecuta flutter pub get.

Última actualización: 23 de Marzo de 2026
Versión: 1.0.0
