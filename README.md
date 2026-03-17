# 💳 Aplicación para Dividir Gastos

Una aplicación Flutter para dividir cuentas de restaurantes de manera simple y eficiente. Ingresa los productos, asigna participantes y divide la cuenta automáticamente.

## 🎯 Características Principales

### 📱 Pantallas

1. **Inicio** - Dashboard principal con resumen de gastos
2. **Editar Ticket** - Agrega restaurante, productos y participantes
3. **Dividir Gastos** - Selecciona modo de división (equitativo o proporcional)
4. **Historial** - Visualiza gastos guardados con opción de favoritos
5. **Perfil** - Estadísticas y ranking de restaurantes

### ✨ Funcionalidades

- **Ingreso de productos**: Agrega artículos con precio y cantidad
- **División flexible**: 
  - Equitativo: divide el total entre todos
  - Proporcional: divide según qué consumió cada persona
- **Sistema de favoritos**: Marca restaurantes favoritos
- **Compartir desglose**: Envía por WhatsApp, Bizum o mensaje genérico
- **Historial persistente**: Guarda todos tus gastos
- **Estadísticas**: Análisis de gastos por restaurante y tiempo

## 📋 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── modelos/
│   ├── producto.dart        # Modelo de productos
│   ├── participante.dart    # Modelo de participantes
│   ├── gasto.dart           # Modelo de transacción
│   └── historial.dart       # Servicio de persistencia
├── pantallas/
│   ├── inicio.dart          # Home screen
│   ├── editar_ticket.dart   # Formulario de ingreso
│   ├── dividir_gastos.dart  # División de cuenta
│   ├── historial.dart       # Historial y favoritos
│   └── perfil.dart          # Estadísticas
├── servicios/
│   └── division.dart        # Lógica de cálculo de deudas
└── assets/                   # Imágenes y recursos
```

## 🛠️ Tecnologías

- **Framework**: Flutter 3.0+
- **Lenguaje**: Dart 3.0+
- **Diseño**: Material Design 3
- **Persistencia**: Memoria en aplicación (Singleton pattern)

## 📦 Dependencias

- `image_picker`: Para captura de imágenes
- `share_plus`: Para compartir contenido
- `url_launcher`: Para enlaces

## 🚀 Cómo ejecutar

```bash
flutter pub get
flutter run
```

## 📝 Licencia

MIT License
│   ├── split_service.dart   # Lógica de división
│   ├── share_service.dart   # Compartir y WhatsApp
│   └── history_service.dart # Gestión del historial
└── widgets/
    ├── custom_app_bar.dart       # AppBar personalizado
    ├── meal_item_card.dart       # Card para artículos
    └── person_selector.dart      # Selector de personas
```

## 🚀 Instalación y Ejecución

### Requisitos

- Flutter 3.0+
- Dart 3.0+

### Pasos

1. **Clonar o descargar el proyecto:**
   ```bash
   cd TrabajoFinal
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación:**
   ```bash
   flutter run
   ```

## 📦 Dependencias

- **image_picker**: Para capturar fotos de tickets
- **intl**: Para formato de fechas
- **share_plus**: Para compartir comprobantes
- **url_launcher**: Para abrir WhatsApp
- **uuid**: Para generar IDs únicos

## 💾 Almacenamiento de Datos

Actualmente, la aplicación almacena datos en memoria. Para persistencia entre sesiones, puedes integrar:

- **Hive**: Para almacenamiento local rápido
- **SQLite**: Para bases de datos más complejas
- **Firebase**: Para sincronización en la nube

## 🎨 Diseño y UX

- Interfaz limpia y moderna con Material Design 3
- Colores vibrantes (naranja profundo como color principal)
- Navegación intuitiva
- Cards y expansión tiles para agrupar información
- Indicadores visuales de progreso

## 📱 Pantallas Detalladas

### Home Screen
- Bienvenida
- 4 opciones principales mediante cards grandes
- Navegación clara y accesible

### Scan Screen
- Captura de foto (cámara/galería)
- Vista previa de la imagen
- Extracción simulada de artículos
- Opción de entrada manual
- Bot total actualizado

### Split Screen
- Nombre del restaurante
- Listado interactivo de artículos
- Selección visual de quién consume qué
- Agregación de nuevas personas
- Cálculo automático de división
- Desglose por persona
- Control de propina

### Share Screen
- Resumen detallado de la compra
- División por persona
- Botones de compartir (WhatsApp, SMS, genérico)
- Volver al inicio

### History Screen
- Lista de transacciones
- Expandable tiles con detalles
- Orden cronológico (más recientes primero)

### Trends Screen
- Estadísticas generales
- Gasto por persona con gráficos de barra
- Restaurante favorito
- Visitas por mes

## 🔄 Flujo de la Aplicación

```
Home → Scan → (Artículos) → Split → (División) → Share → (Enviado) → Home
                                      ↓
                                    History
                                      ↓
                                    Trends
```

## 🛠️ Personalización

### Cambiar Colores
En `main.dart`, modifica el tema:
```dart
theme: ThemeData(
  primarySwatch: Colors.deepOrange as MaterialColor?,
)
```

### Agregar Más Artículos
En `split_screen.dart`, expande la lista de artículos predefinidos en `_simulateOCRExtraction()`

### Integrar OCR Real
Reemplaza la lógica simulada en `scan_screen.dart` con librerías como:
- `ml_kit` para Firebase ML Kit
- `google_mlkit_text_recognition`

## 📊 Ejemplo de Uso

1. Abre la app
2. Selecciona "Escanear Ticket"
3. Captura el ticket o sube una imagen
4. Revisa los artículos extraídos (o agrega manualmente)
5. Ve a "Dividir Cuenta"
6. Selecciona los artículos de cada persona
7. Añade propina
8. Toca "Compartir Comprobante"
9. Elige cómo compartir (WhatsApp, SMS, etc.)
10. Comparte con tus amigos

## 🐛 Troubleshooting

### Error en image_picker
Asegúrate de que los permisos están configurados en `AndroidManifest.xml` e `Info.plist`

### WhatsApp no abre
Verifica que WhatsApp esté instalado en el dispositivo

### Datos no se guardan entre sesiones
Esto es normal, la app guarda en memoria. Integra Hive o SQLite para persistencia

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Sigue el estilo de código Flutter y crea un pull request

## 📄 Licencia

Este proyecto está bajo licencia MIT

## 📧 Contacto

Para preguntas o sugerencias, abre un issue en el repositorio

---

**¡Disfruta dividiendo tus cuentas de forma fácil! 🎉**
