# Split Bill App

Aplicación para dividir cuentas de restaurantes. Ingresa productos, asigna participantes y divide automáticamente.

## Características

Ingreso de productos con precio y cantidad. División equitativa o proporcional según consumo. Sistema de favoritos para restaurantes. Compartir desglose por WhatsApp, Bizum o mensaje. Historial de todos los gastos. Estadísticas de gasto por restaurante.

## Estructura

lib/main.dart es el punto de entrada. lib/pantallas/ tiene la interfaz (inicio, editar_ticket, dividir_gastos, historial, perfil, ajustes). lib/modelos/ tiene la lógica (gasto, participante, historial). lib/servicios/ maneja la división de cuentas y compartir contenido.

## Tecnologías

Flutter 3.0+, Dart 3.0+, Material Design. Usa image_picker para fotos, share_plus para compartir, url_launcher para enlaces.

## Instalar y Ejecutar

Necesitas Flutter 3.0+ y Dart 3.0+. Clona el proyecto, ejecuta flutter pub get, luego flutter run.

## Documentación

Ve a PROCEDIMIENTOS.md para desarrollo, pruebas y despliegue. Ve a EJECUCION.md para instalación, protocolos de trabajo y control de versiones.
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
