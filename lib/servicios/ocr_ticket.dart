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
	final imagen = await _picker.pickImage(
	  source: source,
	  imageQuality: 85,
	  maxWidth: 2200,
	);

	if (imagen == null) {
	  return null;
	}

	final input = InputImage.fromFilePath(imagen.path);
	final textoReconocido = await _textRecognizer.processImage(input);

	return ParserTicket.parsearTexto(textoReconocido.text);
  }

  void dispose() {
	_textRecognizer.close();
  }
}

