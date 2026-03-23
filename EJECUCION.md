DOCUMENTACIÓN DE EJECUCIÓN

INSTALACIÓN

Necesitas Flutter 3.0+, Dart, Git y Android SDK. Descarga Flutter desde https://flutter.dev y agrega bin a PATH. Clona el repositorio, ejecuta flutter pub get, verifica con flutter doctor y conecta un dispositivo o emulador. Ejecuta flutter run para iniciar.

PROTOCOLO DE TRABAJO

Actualiza con git pull origin develop. Crea rama con git checkout -b feature/cambio. Haz cambios y ejecuta flutter run para ver en vivo. Valida con flutter analyze, formatea con dart format lib/ y ejecuta flutter test. Commitea con git commit -m "tipo: descripción" y pushea con git push origin feature/cambio. Abre pull request en GitHub.

RAMAS GIT

main: versiones publicadas. develop: rama principal. feature/nombre: funcionalidades. bugfix/nombre: arreglos. Crear rama: git checkout develop, git pull origin develop, git checkout -b feature/mi-cambio. Pushear: git push -u origin feature/mi-cambio la primera vez, luego git push origin feature/mi-cambio.

DEPENDENCIAS

Están en pubspec.yaml. Agregar con flutter pub add nombre. Actualizar con flutter pub upgrade. Se usan: flutter, share_plus, url_launcher, image_picker, cupertino_icons.

DESPLIEGUE

Android: flutter build appbundle --release genera el archivo en build/app/outputs/bundle/release/app-release.aab. Sube a Google Play Console con descripción y fotos. iOS: flutter build ios --release y configura en App Store Connect.
