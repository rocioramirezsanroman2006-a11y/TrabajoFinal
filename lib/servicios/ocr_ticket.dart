import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'parser_ticket.dart';

class ServicioOcrTicket {
  final ImagePicker _picker;
  final TextRecognizer _textRecognizer;

  ServicioOcrTicket({
    ImagePicker? picker,
    TextRecognizer? textRecognizer,
  })  : _picker = picker ?? ImagePicker(),
        _textRecognizer =
            textRecognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  Future<ResultadoParseTicket?> escanearDesdeCamara() {
    return _escanear(ImageSource.camera);
  }

  Future<ResultadoParseTicket?> escanearDesdeGaleria() {
    return _escanear(ImageSource.gallery);
  }

  Future<ResultadoParseTicket?> _escanear(ImageSource source) async {
    // Mantenemos la calidad alta para facilitar la lectura de números
    final imagen = await _picker.pickImage(
      source: source,
      imageQuality: 100,
      maxWidth: 2200,
    );

    if (imagen == null) {
      return null;
    }

    final input = InputImage.fromFilePath(imagen.path);
    final textoReconocido = await _textRecognizer.processImage(input);

    // Reconstruimos el texto respetando las columnas horizontales
    final textoReconstruido = _reconstruirTextoPorLineas(textoReconocido);

    return ParserTicket.parsearTexto(textoReconstruido);
  }

  /// Procesa los bloques de texto de ML Kit y los alinea horizontalmente
  /// utilizando sus coordenadas (Bounding Box) en la imagen.
  String _reconstruirTextoPorLineas(RecognizedText recognizedText) {
    List<Map<String, dynamic>> lineasConPosicion = [];

    // 1. Extraer posiciones, incluyendo ahora la ALTURA de la caja de texto
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final double centroY =
            line.boundingBox.top + (line.boundingBox.height / 2);

        lineasConPosicion.add({
          'texto': line.text,
          'y': centroY,
          'x': line.boundingBox.left,
          'height': line.boundingBox.height, // Guardamos la altura de la letra
        });
      }
    }

    // Si no hay texto, devolvemos vacío
    if (lineasConPosicion.isEmpty) return '';

    // 2. Ordenar todas las líneas de arriba hacia abajo (eje Y)
    lineasConPosicion.sort((a, b) => (a['y'] as double).compareTo(b['y'] as double));

    // 3. Agrupar las líneas que están en la misma franja horizontal
    List<List<Map<String, dynamic>>> lineasAgrupadas = [];

    for (var elemento in lineasConPosicion) {
      if (lineasAgrupadas.isEmpty) {
        lineasAgrupadas.add([elemento]);
      } else {
        final ultimoGrupo = lineasAgrupadas.last;

        // EL ANCLA: Usamos la primera palabra del grupo como referencia fija.
        final yReferencia = ultimoGrupo.first['y'] as double;
        final alturaReferencia = ultimoGrupo.first['height'] as double;

        // TOLERANCIA DINÁMICA: El margen de error es el 50% de la altura de la letra.
        final toleranciaY = alturaReferencia * 0.5;

        // Comprobamos la distancia contra el ancla
        if (((elemento['y'] as double) - yReferencia).abs() <= toleranciaY) {
          ultimoGrupo.add(elemento);
        } else {
          // Si se pasa del margen, obligatoriamente es una línea nueva
          lineasAgrupadas.add([elemento]);
        }
      }
    }

    // 4. Ordenar cada grupo de izquierda a derecha (eje X) y construir el texto final
    StringBuffer textoFinal = StringBuffer();
    for (var grupo in lineasAgrupadas) {
      grupo.sort((a, b) => (a['x'] as double).compareTo(b['x'] as double));

      // Unimos los fragmentos de la misma línea con un espacio
      final lineaTexto = grupo.map((e) => e['texto']).join(' ');
      textoFinal.writeln(lineaTexto);
    }

    return textoFinal.toString();
  }

  void dispose() {
    _textRecognizer.close();
  }
}