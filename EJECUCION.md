DOCUMENTACIÓN DE EJECUCIÓN
Instalación, Protocolos y Control de Versiones

INSTALACIÓN

Para instalar Split Bill App, primero se necesita tener Flutter versión 3.0.0 o superior, que incluye Dart 3.0.0. También es necesario Git, Android SDK 21 o superior, por lo menos 8 GB de RAM y 5 GB de espacio libre en el disco duro.

En Windows, después de descargar Flutter, se debe agregar la carpeta bin a la variable PATH del sistema. Se puede verificar que la instalación fue exitosa ejecutando flutter --version y dart --version. El comando flutter doctor realiza una verificación completa del entorno y reporta qué falta configurar, incluyendo el Android SDK, emuladores Android, Android Studio o VS Code.

Para obtener el código del proyecto, se clona el repositorio con git clone, seguido de la URL. Dentro de la carpeta del proyecto, se ejecuta flutter pub get para descargar todas las dependencias especificadas en pubspec.yaml.

Si esta es la primera vez usando Flutter, es posible que se deba aceptar las licencias de Android con flutter doctor --android-licenses. Este comando interactivo pide confirmación para varios componentes del SDK de Android.

Para desarrollar es necesario tener un dispositivo o emulador conectado. Un emulador Android se puede listar con flutter emulators, crear con flutter emulators create, e iniciar con flutter emulators launch. Para dispositivos físicos, se debe habilitar el modo de desarrollador en el teléfono Android, conectarlo por USB y autorizar el acceso cuando se solicite.

Una vez que todo esté configurado, se puede ejecutar flutter run para compilar e instalar la aplicación en el dispositivo o emulador. Durante el desarrollo, cualquier cambio en el código se refleja automáticamente con hot reload. Para verificar que todo funciona, se ejecutan flutter analyze para buscar errores, flutter test para correr las pruebas y dart format --check lib/ para verificar el formato.

PROTOCOLOS DE TRABAJO

El protocolo diario de desarrollo comienza actualizando el repositorio local con git fetch origin y git pull origin develop. Luego se crea una rama de feature con un nombre descriptivo, por ejemplo feature/modo-proporcional o bugfix/favoritos-duplicados. Se ejecuta flutter run para ver los cambios en tiempo real mientras se desarrolla.

Al finalizar el cambio, se valida ejecutando flutter analyze y dart format lib/ para asegurar que no hay errores y que el código está formateado correctamente. Se ejecutan los tests con flutter test. Después se preparan los cambios con git add . y se hace un commit con un mensaje que describe claramente qué se cambió. El commit se pushea a la rama remota y se crea un pull request en GitHub.

Cuando el código es revisado, el revisor verifica que flutter analyze no reporte errores, que los tests pasen al 100%, que el código esté bien formateado, que la cobertura sea suficiente, que los commits tengan mensajes descriptivos y que no haya información sensible. Si todo está bien, aprueba el cambio. Si hay problemas, los reporta para que sean corregidos.

El protocolo de release comienza una semana antes de la publicación. Se verifica que todos los features estén completos y mergeados, que hayan pasado code review, que todos los tests pasen y que CHANGELOG.md esté actualizado. El día del release, se ejecuta flutter build appbundle --release para generar el archivo que se subirá a Google Play Store. Se preparan los screenshots, se escribe la descripción final y se configuran los permisos de privacidad. Después se sube el archivo a Google Play Console y se envía para revisión, esperando entre 24 y 72 horas. Los primeros siete días después del release son críticos, se deben monitorear los comentarios de usuarios, ratings y cualquier reporte de crashes.

CONTROL DE VERSIONES CON GIT

Git Flow es la estrategia de branching utilizada en este proyecto. Existen ramas de feature para nuevas funcionalidades, ramas bugfix para correcciones, ramas hotfix para problemas urgentes que requieren solución inmediata, y ramas release para prepara versions finales.

Para crear una rama de feature, primero se actualiza la rama develop con git checkout develop seguido de git pull origin develop. Luego se crea la nueva rama con git checkout -b feature/nombre. Se realizan los cambios necesarios y se hace commit con git add . y git commit -m "tipo: descripción". El formato del mensaje de commit es importante, debe especificar si es una feature, un fix, un cambio de documentación, un cambio de estilo, un refactor, una mejora de rendimiento o un test.

Después de varios commits en la rama de feature, se pushea con git push -u origin feature/nombre la primera vez, y git push origin feature/nombre las veces siguientes. En GitHub se crea un pull request describiendo los cambios realizados, el motivo de los cambios, y qué se testeó. Se espera a que otro desarrollador revise el código. Si hay cambios solicitados, se hacen y se pushean nuevamente. Una vez aprobado, se hace merge a develop.

Es común que mientras se está trabajando en una rama, otros desarrolladores hayan hecho cambios a develop que ahora es necesario integrar. Se usa git fetch origin para obtener los cambios remotos, seguido de git merge origin/develop para integrar esos cambios a la rama actual. Si hay conflictos, Git los marca claramente en los archivos afectados. Se resuelven manualmente, se agrega el archivo resuelto con git add, y se completa el merge con git commit.

Para ver historial de commits, se usa git log --oneline para un resumen conciso, git log --graph --oneline --all para ver visualmente las ramas y sus ramificaciones, y git blame para ver quién cambió cada línea de un archivo específico. Estos comandos ayudan a entender la evolución del código.

Para releases importantes, se crean tags con git tag -a v1.0.0 -m "Descripción". Los tags marcan versiones estables del código. Se pushean con git push origin v1.0.0 o todos a la vez con git push origin --tags.

Después de que merge a develop es completado, se puede limpiar la rama local con git branch -d feature/nombre y la rama remota con git push origin --delete feature/nombre. Es una buena práctica mantener el repositorio limpio, sin ramas antiguas que ya no se usan.

En caso de error, existen comandos de emergencia. Si se hizo un commit que no debería haberse hecho, se puede deshacer con git reset --soft HEAD~1 si se quieren mantener los cambios, o git reset --hard HEAD~1 si se quieren perder. Si se eliminó un commit por error, git reflog muestra todos los commits, incluso los eliminados, permitiendo recuperarlos con git reset --hard <hash>. Si un commit ya fue pushed, es más seguro usar git revert para crear un nuevo commit que deshace los cambios del anterior.

INSTALACIÓN DE DEPENDENCIAS Y CONFIGURACIÓN

Las dependencias del proyecto están especificadas en pubspec.yaml e incluyen el framework Flutter, el paquete share_plus para compartir por WhatsApp, url_launcher para abrir links, y otros. Para instalar nuevas dependencias, se usa flutter pub add nombre_paquete. Para actualizar dependencias existentes, se usa flutter pub upgrade.

El desarrollo se realiza sobre dispositivos Android o emuladores. Para testing manual, se ejecuta flutter run en modo debug para ver los cambios inmediatamente. Para testing más cercano a la producción, se ejecuta flutter run --release, que compila el código de manera optimizada.

Toda la configuración del desarrollo debe estar documentada. El keystore para firmar la aplicación debe guardarse en un lugar seguro con la contraseña anotada. Las claves de API, contraseñas y tokens nunca se guardan en el repositorio sino en archivos .env que están ignorados por Git.

VERIFICACIÓN FINAL

Después de instalar, se debe verificar que flutter doctor no reporte errores críticos. Se debe confirmar que flutter run compila y ejecuta la aplicación sin problemas. Se deben ejecutar flutter analyze y flutter test sin encontrar fallos. El ambiente está listo cuando todos estos pasos funcionan correctamente y la aplicación se muestra sin errores en el dispositivo o emulador.

Última actualización: 23 de Marzo de 2026
Versión: 1.0.0
