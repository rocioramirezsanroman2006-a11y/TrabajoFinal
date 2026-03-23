# DOCUMENTACIÓN DE EJECUCIÓN
## Instalación, Protocolos y Control de Versiones - Split Bill App

---

## 1. INSTALACIÓN

### Requisitos Previos

**Software:**
- Flutter 3.0.0+ ([descargar](https://flutter.dev/docs/get-started/install/windows))
- Dart 3.0.0+ (incluido con Flutter)
- Git 2.0+
- Android SDK 21+ o iOS 11+
- 8GB RAM mínimo, 5GB espacio libre

**Configuración Inicial:**

```powershell
# Windows - Agregar Flutter a PATH
$env:Path += ";C:\flutter\bin"

# Verificar instalación
flutter --version
dart --version
git --version
```

### Instalación Paso a Paso

#### 1. Clonar Repositorio

```powershell
git clone https://github.com/tu-usuario/split_bill_app.git
cd split_bill_app
```

#### 2. Verificar Entorno

```powershell
flutter doctor

# Debe mostrar:
# ✓ Flutter
# ✓ Dart
# ✓ Android SDK (o Xcode para iOS)
# ✓ Android Studio / VS Code
```

**Si falta algo:**
```powershell
# Aceptar licencias Android
flutter doctor --android-licenses

# Instalar iOS dependencies (macOS)
flutter precache
```

#### 3. Obtener Dependencias

```powershell
# Descargar paquetes
flutter pub get

# Actualizar si es necesario
flutter pub upgrade
```

#### 4. Configurar Dispositivo/Emulador

**Emulador Android:**
```powershell
# Ver emuladores disponibles
flutter emulators

# Crear nuevo (si no existe)
flutter emulators create --name test_emulator

# Iniciar
flutter emulators launch test_emulator
```

**Dispositivo Físico:**
1. Habilitar "Modo Desarrollador" en teléfono
2. Conectar por USB
3. Autorizar acceso en dispositivo
4. Verificar: `flutter devices`

#### 5. Primera Ejecución

```powershell
# Ejecutar en dispositivo/emulador conectado
flutter run

# O especificar dispositivo
flutter run -d <device_id>

# En modo release (más rápido)
flutter run --release
```

### Verificación de Instalación

Todos estos deben funcionar sin errores:

```powershell
✓ flutter doctor           # Sin errores críticos
✓ flutter analyze          # Sin errores
✓ flutter test             # Sin fallos
✓ flutter run              # App inicia en device
✓ dart format --check lib/ # Sin cambios necesarios
```

---

## 2. PROTOCOLOS DE TRABAJO

### Protocolo de Desarrollo Diario

**Inicio de sesión:**
```powershell
# 1. Actualizar repositorio
git fetch origin
git pull origin develop

# 2. Crear rama de trabajo
git checkout -b feature/mi-cambio

# 3. Ejecutar app
flutter run

# En editor: hacer cambios (hot reload automático)
```

**Finalizar cambios:**
```powershell
# 4. Validar código
flutter analyze
dart format lib/

# 5. Ejecutar tests
flutter test

# 6. Commit
git add .
git commit -m "feat: descripción clara"

# 7. Push
git push origin feature/mi-cambio

# 8. Crear Pull Request en GitHub
```

### Protocolo de Code Review

**Revisor debe verificar:**

- [ ] Código pasa `flutter analyze`
- [ ] Código está formateado correctamente
- [ ] Tests pasan (100%)
- [ ] Cobertura de nuevas funciones es >70%
- [ ] Commits tienen mensajes descriptivos
- [ ] No hay secrets o datos sensibles
- [ ] Cambios son cohesivos

**Comentario típico:**
```
✅ LGTM (Looks Good To Me)
- Código limpio
- Tests completos
- Listo para merge
```

o

```
🔴 Cambios requeridos
- Faltan tests para función X
- Flutter analyze: error en línea 45
- Refactor: simplificar lógica de calcularDeudas()
```

### Protocolo de Release

**Checklist 7 días antes:**
- [ ] Feature branch completada y mergeada
- [ ] Code review aprobado
- [ ] Todos los tests pasan
- [ ] CHANGELOG.md actualizado
- [ ] Versión bumped en pubspec.yaml

**Día de release:**
- [ ] Build APK/AAB ejecutado exitosamente
- [ ] Screenshots preparados (1080x1920px)
- [ ] Descripción completa en store
- [ ] Privacidad/permisos configurados
- [ ] Subida a Play Store / App Store
- [ ] Enviado para revisión

**Post-release (7 días):**
- [ ] Monitorear crashlytics (si existe)
- [ ] Leer comentarios de usuarios
- [ ] Verificar ratings
- [ ] Preparar hotfix si es necesario

---

## 3. CONTROL DE VERSIONES CON GIT

### Estrategia de Branching: Git Flow

```
main (v1.0.0, v1.0.1) ← releases, hotfixes
    ↑
develop (HEAD) ← feature branches integradas
    ↑
feature/* (feature/nueva-funcionalidad)
bugfix/*  (bugfix/arreglo-rapido)
hotfix/*  (hotfix/urgente)
```

### Crear Feature Branch

```powershell
# Actualizar rama base
git checkout develop
git pull origin develop

# Crear rama de feature
git checkout -b feature/nombre-descriptivo

# Ejemplo:
git checkout -b feature/modo-proporcional
git checkout -b feature/compartir-whatsapp
git checkout -b bugfix/favoritos-duplicados
```

### Hacer Commits

```powershell
# Ver cambios
git status
git diff

# Agregar archivos
git add lib/modelos/gasto.dart
git add lib/pantallas/inicio.dart

# Commit con mensaje
git commit -m "feat: agregar modo proporcional

- Implementar lógica de cálculo proporcional
- Actualizar UI de PantallaDividirGastos
- Agregar tests unitarios"

# Ver historial
git log --oneline -5
```

**Formato de mensaje (importante):**
```
tipo(scope): descripción

tipo: feat, fix, docs, style, refactor, test, perf
scope: opcional, módulo afectado
descripción: qué y por qué, no cómo

Ejemplo bueno:
feat(historial): agregar función eliminar favorito
fix(gasto): arreglar cálculo modo equitativo
docs(readme): actualizar guía de instalación

Ejemplo malo:
fix
arreglo rapido
cambios varios
```

### Push y Pull Request

```powershell
# Primera vez: crear rama remota
git push -u origin feature/nombre

# Siguientes
git push origin feature/nombre

# Ver estado
git branch -v
git log origin/develop..HEAD  # Commits para pushear
```

**En GitHub:**
1. Click "Compare & pull request"
2. Escribir descripción detallada
3. Seleccionar reviewers
4. Esperar aprobación
5. Click "Merge pull request"

### Actualizar Rama (rebase)

```powershell
# Si develop fue actualizado mientras trabajabas
git fetch origin
git rebase origin/develop

# Si hay conflictos, resolver en editor y:
git add .
git rebase --continue

# Si se complica, abortar
git rebase --abort
git merge origin/develop  # Alternativa más segura
```

### Resolver Conflictos

```powershell
# Cuando hay conflictos en merge
# Git marca con:
# <<<<<<< HEAD
# código actual
# =======
# código remoto
# >>>>>>> origin/develop

# Opciones:
# 1. En VS Code: Click "Accept Current Change" o "Accept Incoming Change"
# 2. Editar manualmente

git add archivo_resuelto.dart
git commit -m "Merge: resolver conflictos en archivo_resuelto.dart"
```

### Ver Historial

```powershell
# Resumen
git log --oneline -10

# Detallado
git log --pretty=format:"%h - %an, %ar : %s"

# Gráfico (ver ramas)
git log --graph --oneline --all

# Por archivo
git log -- lib/modelos/gasto.dart

# Blame (quién cambió cada línea)
git blame lib/modelos/gasto.dart
```

### Tags (para Releases)

```powershell
# Crear tag
git tag -a v1.0.0 -m "Release v1.0.0

Features:
- Modo equitativo
- Modo proporcional
- Historial"

# Listar tags
git tag -l

# Push tag
git push origin v1.0.0

# Push todos
git push origin --tags
```

### Limpiar Ramas Locales

```powershell
# Ver ramas que ya fueron deletreadas en remoto
git branch -vv | grep ': gone]'

# Eliminar rama local
git branch -d feature/nombre

# Eliminar rama remota
git push origin --delete feature/nombre

# Clean up automático
git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -d
```

### Comandos de Emergencia

```powershell
# Deshacer último commit (mantener cambios)
git reset --soft HEAD~1

# Deshacer último commit (perder cambios)
git reset --hard HEAD~1

# Ver commits eliminados
git reflog

# Recuperar commit
git reset --hard <hash>

# Revertir específico commit
git revert <hash>  # ✅ Seguro si ya fue pushed
```

---

## 4. TABLA DE REFERENCIA RÁPIDA

### Git Workflow Básico

```powershell
git checkout develop              # Ir a develop
git pull origin develop           # Actualizar
git checkout -b feature/nombre    # Nueva rama
# ... hacer cambios ...
git add .                         # Preparar
git commit -m "tipo: mensaje"     # Commit
git push -u origin feature/nombre # Push (primera vez)
git push origin feature/nombre    # Push (siguientes)
# Pull Request en GitHub
# Merge y cleanup
```

### Workflow de Hotfix (Urgente)

```powershell
git checkout main              # Desde main
git checkout -b hotfix/issue   # Nueva rama hotfix
# ... arreglar problema ...
git commit -m "fix: descripción"
git push origin hotfix/issue
# Pull Request a main Y develop
# Merge y cleanup
```

### Estadísticas de Trabajo

```powershell
# Commits por autor
git shortlog -sn

# Líneas aggregadas por autor
git log --format='%an' | sort | uniq -c

# Cambios en período
git log --since="2 weeks ago" --oneline

# Contribuyentes
git log | grep "Author:" | sort | uniq
```

---

## 5. VARIABLES DE ENTORNO (Opcional)

Para desarrollo sin guardar credenciales en código:

```powershell
# Crear .env (gitignore)
# .env
KEYSTORE_PATH=android/app/key.jks
KEYSTORE_PASSWORD=tu_contraseña
KEY_ALIAS=upload-key
KEY_PASSWORD=tu_contraseña

# En gradle (build.gradle):
# storePassword: System.getenv("KEYSTORE_PASSWORD")
```

---

## 6. CHECKLIST DE INSTALACIÓN COMPLETA

- [ ] Flutter instalado (`flutter --version`)
- [ ] Git configurado (`git config --list`)
- [ ] Repositorio clonado
- [ ] `flutter pub get` ejecutado
- [ ] `flutter doctor` sin errores críticos
- [ ] Dispositivo/emulador conectado (`flutter devices`)
- [ ] `flutter run` ejecuta exitosamente
- [ ] `flutter analyze` sin errores
- [ ] `flutter test` pasa
- [ ] Editor configurado (VS Code / Android Studio)
- [ ] Rama de trabajo creada y lista

---

**Última actualización**: 23 de Marzo de 2026
**Versión**: 1.0.0
