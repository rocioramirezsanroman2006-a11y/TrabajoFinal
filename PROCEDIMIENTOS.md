# PROCEDIMIENTOS DE DESARROLLO, PRUEBAS Y DESPLIEGUE
## Split Bill App

---

## 1. DESARROLLO

### Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada y navegación
├── pantallas/                   # UI
│   ├── inicio.dart
│   ├── editar_ticket.dart
│   ├── dividir_gastos.dart
│   ├── resumen_gasto.dart
│   ├── historial.dart
│   ├── perfil.dart
│   └── ajustes.dart
└── modelos/                     # Lógica de datos
    ├── gasto.dart
    ├── historial.dart (Singleton)
    └── participante.dart
```

### Arquitectura

- **Patrón Singleton**: `ServicioHistorial` para estado global
- **StatefulWidget**: Componentes con estado dinámico
- **Material Design 3**: Interfaz moderna
- **Persistencia**: En-memoria (List<Gasto>)

### Flujo de Desarrollo

```bash
# 1. Abrir rama de feature
git checkout -b feature/nueva-funcionalidad

# 2. Ejecutar app con hot reload
flutter run

# 3. Desarrollar cambios (auto-hot reload)

# 4. Validar código
flutter analyze
dart format lib/

# 5. Commit
git commit -m "feat: descripción del cambio"

# 6. Push y Pull Request
git push origin feature/nueva-funcionalidad
```

### Convenciones de Código

| Tipo | Convención | Ejemplo |
|------|-----------|---------|
| Clases | PascalCase | `PantallaInicio`, `Gasto` |
| Variables | camelCase | `gastoTotal`, `enEdicion` |
| Privadas | _camelCase | `_historial`, `_gastos` |
| Métodos | camelCase | `calcularDeudas()` |
| Archivos | snake_case | `editar_ticket.dart` |
| Constantes | const camelCase | `const double margen = 16.0` |

### Commits

```
Formato: tipo: descripción

feat:    Nueva funcionalidad
fix:     Corrección de bug
docs:    Cambios en documentación
style:   Formato (sin cambio lógico)
refactor: Refactorización
perf:    Performance
test:    Tests

Ejemplos:
✅ feat: agregar modo proporcional
✅ fix: arreglar cálculo de deudas
❌ fix
❌ arreglo
```

### Dependencias

```yaml
dependencies:
  flutter: sdk: flutter
  cupertino_icons: ^1.0.2
  image_picker: ^1.0.0
  share_plus: ^7.0.0          # WhatsApp sharing
  url_launcher: ^6.1.0        # Abrir URLs
```

**Agregar dependencia:**
```bash
flutter pub add nombre_paquete
```

**Actualizar todas:**
```bash
flutter pub upgrade
```

---

## 2. PRUEBAS

### Unit Tests

Archivo: `test/modelos/gasto_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:split_bill_app/modelos/gasto.dart';

void main() {
  group('Gasto', () {
    test('totalGasto calcula correctamente', () {
      final gasto = Gasto(
        id: '1',
        restaurante: 'Restaurant Test',
        fecha: DateTime.now(),
        modo: ModoGasto.equitativo,
        productos: [
          Producto(nombre: 'Pizza', precio: 10.00, participantesSeleccionados: []),
        ],
        participantes: [],
      );
      
      expect(gasto.totalGasto, 10.00);
    });

    test('calcularDeudas en modo equitativo', () {
      // Test de lógica de división
    });
  });
}
```

### Widget Tests

Archivo: `test/widgets/inicio_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PantallaInicio muestra título', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PantallaInicio()));
    
    expect(find.text('Inicio'), findsOneWidget);
  });
}
```

### Ejecutar Tests

```bash
# Todos los tests
flutter test

# Test específico
flutter test test/modelos/gasto_test.dart

# Con cobertura
flutter test --coverage
```

### Checklist Pre-Commit

- [ ] `flutter analyze` sin errores
- [ ] `flutter test` pasando 100%
- [ ] `dart format --set-exit-if-changed lib/` correcto
- [ ] Cambios relacionados
- [ ] Tests cubren lógica nueva

---

## 3. DESPLIEGUE

### Pre-Despliegue: Checklist

```bash
# 1. Validar código
flutter analyze          # Sin errores
flutter test            # Todos pasan
dart format lib/        # Formateado

# 2. Incrementar versión
# pubspec.yaml: version: 1.0.0+1 → version: 1.1.0+2

# 3. Actualizar CHANGELOG.md

# 4. Build final
flutter clean
flutter pub get
```

### Android - Google Play Store

#### Generar Keystore (Primera Vez)

```powershell
keytool -genkey -v -keystore android/app/key.jks `
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload-key

# Guardar contraseña en lugar seguro
```

#### Configurar Signing

Archivo: `android/app/build.gradle`

```gradle
android {
    signingConfigs {
        release {
            keyAlias = "upload-key"
            keyPassword = "TU_CONTRASEÑA"
            storeFile = file("key.jks")
            storePassword = "TU_CONTRASEÑA"
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### Build Release

```powershell
# App Bundle (recomendado para Play Store)
flutter build appbundle --release

# Ubicación: build/app/outputs/bundle/release/app-release.aab

# O APK (para testing)
flutter build apk --release
```

#### Publicar en Google Play Console

1. **Crear app en** https://play.google.com/console
2. **Subir fichero .aab**
3. **Configurar:**
   - Nombre: Split Bill App
   - Descripción
   - Categoría: Finance
   - Screenshots (1080x1920px)
   - Icono (512x512px)
   - Política de privacidad
4. **Enviar para revisión** (24-72 horas)

### iOS - App Store (macOS)

```bash
# Build iOS Release
flutter build ios --release

# O con Xcode
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -config Release
cd ..
```

**Luego:** Configurar en App Store Connect (certificados, provisioning profiles)

### Versionado Semántico

```
1.0.0+1 = MAJOR.MINOR.PATCH+BUILD

1.0.0 → 1.1.0   Nueva feature (Minor)
1.0.0 → 1.0.1   Bugfix (Patch)
1.0.0 → 2.0.0   Cambio incompatible (Major)
1.0.0+1 → 1.0.0+2  Nueva build (Build)
```

### Rollback

Si es necesario volver a versión anterior:

```bash
# Crear nueva versión con fix
# Ejemplo: 1.0.1 para arreglar 1.0.0

# Android: Google Play actualiza automáticamente
# iOS: Rechazar versión anterior no es posible, crear nueva
```

### Post-Despliegue

- ✅ Monitorear primeras 24 horas
- ✅ Revisar ratings y comentarios
- ✅ Verificar crashes (si hay Crashlytics)
- ✅ Usuarios activos / retención
- ✅ Reportar issues si hay

---

## 4. TABLA RÁPIDA DE COMANDOS

| Tarea | Comando |
|-------|---------|
| Ejecutar app | `flutter run` |
| Analizar código | `flutter analyze` |
| Formatear | `dart format lib/` |
| Tests | `flutter test` |
| Clean | `flutter clean` |
| Dependencias | `flutter pub get` |
| Agregar paquete | `flutter pub add nombre` |
| Build APK | `flutter build apk --release` |
| Build AAB | `flutter build appbundle --release` |
| Ver dispositivos | `flutter devices` |
| Logs verbose | `flutter run -v` |

---

## 5. SOLUCIÓN DE PROBLEMAS COMUNES

| Problema | Solución |
|----------|----------|
| Hot reload no funciona | Usar hot restart (R) o flutter clean |
| Gradle error | `flutter clean` + `flutter pub get` |
| Versión SDK | `flutter doctor` ver requisitos |
| Keystore no encontrado | Verificar ruta en build.gradle |
| App no inicia en device | `flutter clean` + `flutter run` |
| Import no funciona | `flutter pub get` |

---

**Última actualización**: 23 de Marzo de 2026
**Versión**: 1.0.0
