DOCUMENTACIÓN DE EJECUCIÓN
Instalación, Protocolos y Control de Versiones

INSTALACIÓN

Necesitas Flutter 3.0+, Dart 3.0+, Git, Android SDK, 8GB RAM y 5GB de espacio libre.

Descarga Flutter desde https://flutter.dev. Descomprime y agrega bin a PATH.

Verifica: flutter --version, dart --version, git --version

Clona: git clone https://github.com/tu-usuario/split_bill_app.git

Entra en la carpeta: flutter pub get

Revisa: flutter doctor (sin errores críticos)

Para emulador: flutter emulators launch nombre_emulador

Para dispositivo real: habilita modo desarrollador en el teléfono, conéctalo por USB, autoriza.

Ejecuta: flutter run

PROTOCOLOS DE TRABAJO

Protocolo diario:

1. Actualiza: git pull origin develop
2. Crea rama: git checkout -b feature/tu-cambio
3. Ejecuta: flutter run
4. Haz cambios
5. Valida: flutter analyze, dart format lib/
6. Ejecuta tests: flutter test
7. Guarda: git add . y git commit -m "feat: descripción"
8. Sube: git push origin feature/tu-cambio
9. Abre pull request en GitHub

Protocolo de revisión:

El revisor verifica:
- No hay errores en flutter analyze
- Tests pasan al 100%
- Código está formateado
- No hay secretos guardados
- El cambio tiene sentido

Si está bien, aprueba. Si no, pide cambios.

Protocolo de release:

7 días antes: verifica que todo esté listo y aprobado.

Día del release: genera build, prepara fotos, sube a Play Store, espera revisión.

Después: mira comentarios y ratings.

CONTROL DE VERSIONES CON GIT

Ramas:

main - versiones finales
develop - rama de desarrollo
feature/nombre - cambios nuevos
bugfix/nombre - arreglos
hotfix/nombre - emergencias

Para crear rama de feature:

git checkout develop
git pull origin develop
git checkout -b feature/mi-cambio

Haces cambios, luego:

git add .
git commit -m "tipo: descripción"

Tipos: feat, fix, docs, refactor

Ejemplos:
feat: agregar modo proporcional
fix: arreglar cálculo de deudas

Primera vez que subes:

git push -u origin feature/mi-cambio

Siguientes veces:

git push origin feature/mi-cambio

En GitHub haces pull request, esperas aprobación, luego merge.

Si otros hicieron cambios en develop mientras trabajabas:

git fetch origin
git merge origin/develop

Si hay conflictos, resuelves manualmente:

git add .
git commit -m "Merge: resolver conflictos"

Ver historial:

git log --oneline -5

Para versión final:

git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0

Limpiar rama cuando termines:

git branch -d feature/mi-cambio
git push origin --delete feature/mi-cambio

Si cometiste un error en el último commit:

git reset --soft HEAD~1  (mantiene cambios)
git reset --hard HEAD~1  (pierde cambios)

DEPENDENCIAS

Están en pubspec.yaml.

Para agregar: flutter pub add nombre

Para actualizar: flutter pub upgrade

Se usan: flutter, share_plus, url_launcher, image_picker, cupertino_icons

ANTES DE EMPEZAR

Verifica esto:
- Flutter instalado
- Git configurado
- Código clonado
- flutter pub get ejecutado
- flutter doctor sin errores críticos
- Dispositivo/emulador conectado
- flutter run funciona
- flutter analyze sin errores
- flutter test pasa

Última actualización: 23 de Marzo de 2026
