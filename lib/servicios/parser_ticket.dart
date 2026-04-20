class ProductoDetectadoTicket {
  final String nombre;
  final double precio;
  final int cantidad;

  const ProductoDetectadoTicket({
    required this.nombre,
    required this.precio,
    this.cantidad = 1,
  });
}

class ResultadoParseTicket {
  final String? restauranteDetectado;
  final List<ProductoDetectadoTicket> productos;
  final double? totalDetectado;
  final List<String> lineas;

  const ResultadoParseTicket({
    required this.restauranteDetectado,
    required this.productos,
    required this.totalDetectado,
    required this.lineas,
  });

  bool get tieneDatos => restauranteDetectado != null || productos.isNotEmpty;
}

class ParserTicket {
  static final RegExp _regexPrecioFinal = RegExp(
    r'^(.*?)(\d+[\.,]\d{2})\s*(?:€|eur)?$',
    caseSensitive: false,
  );
  static final RegExp _regexPrecioInicio = RegExp(
    r'^(?:€\s*)?(\d+[\.,]\d{2})\s*(.*)$',
    caseSensitive: false,
  );
  static final RegExp _regexCantidad = RegExp(r'^\s*(\d+)\s*(?:x|X|\*)\s+(.+)$');
  static final RegExp _regexPrecio = RegExp(r'\d+[\.,]\d{2}');
  static final RegExp _regexSoloPrecio = RegExp(r'^(?:€\s*)?\d+[\.,]\d{2}\s*(?:€|eur)?$', caseSensitive: false);
  static final RegExp _regexTieneLetras = RegExp(r'[A-Za-zÁÉÍÓÚáéíóúÑñ]');
  static final RegExp _regexLineaRestaurante = RegExp(
    r'^\s*(\d+[\.,]?\d*)\s+(.+?)\s+(\d+[\.,]\d{2})\s+(\d+[\.,]\d{2})\s*$',
    caseSensitive: false,
  );
  static final RegExp _regexCantidadInicio = RegExp(r'^\s*(\d+[\.,]?\d*)\s+(.+)$');

  static const List<String> _palabrasExcluir = [
    'total',
    'subtotal',
    'iva',
    'i.v.a',
    'impuesto',
    'impuestos',
    'nif',
    'cif',
    'fecha',
    'hora',
    'tarjeta',
    'efectivo',
    'cambio',
    'gracias',
    'precio importe',
    'precio',
    'importe',
    'unidad',
    'descripcion',
    'mesa',
    'base',
    'tarjeta',
    'atendio',
    'atendido',
    'rte',
    'vendedor',
    'tlf',
    'tel',
    'telefono',
    'comensal',
    'comensals',
    'camarero',
    'camarera',
    'cambrer',
    'ticket',
    'fra',
    'simple',
    'data',
    'n ticket',
  ];

  static ResultadoParseTicket parsearTexto(String texto) {
    final lineas = texto
        .split('\n')
        .map((l) => l.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((l) => l.isNotEmpty)
        .toList();

    String? restaurante;
    final productos = <ProductoDetectadoTicket>[];
    double? total;

    final inicioDetalle = _buscarInicioDetalle(lineas);

    for (var i = 0; i < lineas.length; i++) {
      final linea = lineas[i];
      if (restaurante == null && (inicioDetalle == -1 || i <= inicioDetalle)) {
        restaurante = _intentarRestaurante(linea);
      }

      if (inicioDetalle != -1 && i < inicioDetalle) {
        continue;
      }

      final totalLinea = _intentarExtraerTotal(linea);
      if (totalLinea != null) {
        total = total == null || totalLinea > total ? totalLinea : total;
        // El detalle de productos termina en la línea de total.
        break;
      }

      final producto = _parsearLineaProducto(linea);
      if (producto != null) {
        productos.add(producto);
        continue;
      }

      // Caso frecuente OCR: nombre y precio en lineas separadas.
      if (i + 1 < lineas.length) {
        final combinado = _parsearNombreYPrecioSeparados(
          lineaNombre: linea,
          lineaPrecio: lineas[i + 1],
        );

        if (combinado != null) {
          productos.add(combinado);
          i += 1;
        }
      }
    }

    return ResultadoParseTicket(
      restauranteDetectado: restaurante,
      productos: productos,
      totalDetectado: total,
      lineas: lineas,
    );
  }

  static String? _intentarRestaurante(String linea) {
    if (linea.length < 3) {
      return null;
    }

    final tieneDigitos = RegExp(r'\d').hasMatch(linea);
    if (tieneDigitos) {
      return null;
    }

    final texto = _normalizarTextoFiltro(linea);
    if (_palabrasExcluir.any((p) => texto.contains(_normalizarTextoFiltro(p)))) {
      return null;
    }

    return linea;
  }

  static double? _intentarExtraerTotal(String linea) {
    final texto = _normalizarTextoFiltro(linea);
    if (!texto.contains('total')) {
      return null;
    }

    if (texto.contains('subtotal')) {
      return null;
    }

    final match = _regexPrecio.firstMatch(linea);
    if (match == null) {
      return null;
    }

    return _parsearPrecio(match.group(0)!);
  }

  static ProductoDetectadoTicket? _parsearLineaProducto(String linea) {
    final texto = _normalizarTextoFiltro(linea);
    if (_palabrasExcluir.any((p) => texto.contains(_normalizarTextoFiltro(p)))) {
      return null;
    }

    final matchRestaurante = _regexLineaRestaurante.firstMatch(linea);
    if (matchRestaurante != null) {
      final cantidadRaw = matchRestaurante.group(1) ?? '1';
      final nombreRaw = (matchRestaurante.group(2) ?? '').trim();
      final precioUnitarioRaw = matchRestaurante.group(3) ?? '';
      final importeRaw = matchRestaurante.group(4) ?? '';

      var cantidad = _parsearCantidad(cantidadRaw);
      final nombre = _limpiarNombre(nombreRaw);
      if (!_esNombreProductoValido(nombre)) {
        return null;
      }

      var precio = _parsearPrecio(precioUnitarioRaw) ?? 0;
      final importe = _parsearPrecio(importeRaw) ?? 0;
      if (precio <= 0 && importe > 0) {
        final cantidadSegura = cantidad <= 0 ? 1 : cantidad;
        precio = importe / cantidadSegura;
      }
      if (precio <= 0) {
        return null;
      }

      final cantidadInferida = _inferirCantidad(importe: importe, precio: precio);
      if (cantidad <= 0 || (cantidadInferida > 0 && (cantidad - cantidadInferida).abs() > 1)) {
        cantidad = cantidadInferida > 0 ? cantidadInferida : 1;
      }

      return ProductoDetectadoTicket(
        nombre: nombre,
        precio: precio,
        cantidad: cantidad,
      );
    }

    final conDosPrecios = _parsearLineaConDosPrecios(linea);
    if (conDosPrecios != null) {
      return conDosPrecios;
    }

    if (_regexSoloPrecio.hasMatch(linea)) {
      return null;
    }

    final matchFinal = _regexPrecioFinal.firstMatch(linea);
    final matchInicio = _regexPrecioInicio.firstMatch(linea);

    String nombre;
    String? precioTexto;

    if (matchFinal != null) {
      nombre = (matchFinal.group(1) ?? '').trim();
      precioTexto = matchFinal.group(2);
    } else if (matchInicio != null) {
      precioTexto = matchInicio.group(1);
      nombre = (matchInicio.group(2) ?? '').trim();
    } else {
      return null;
    }

    if (precioTexto == null) {
      return null;
    }

    final precio = _parsearPrecio(precioTexto);
    if (precio == null || precio <= 0) {
      return null;
    }

    var cantidad = 1;
    final matchCantidad = _regexCantidad.firstMatch(nombre);
    if (matchCantidad != null) {
      cantidad = int.tryParse(matchCantidad.group(1) ?? '') ?? 1;
      nombre = (matchCantidad.group(2) ?? nombre).trim();
    }

    nombre = _limpiarNombre(nombre);

    if (!_esNombreProductoValido(nombre)) {
      return null;
    }

    return ProductoDetectadoTicket(
      nombre: nombre,
      precio: precio,
      cantidad: cantidad,
    );
  }

  static ProductoDetectadoTicket? _parsearNombreYPrecioSeparados({
    required String lineaNombre,
    required String lineaPrecio,
  }) {
    // Este modo se reserva para nombres "limpios" (sin numeros), para evitar
    // convertir metadatos tipo "TLF 91..." o "Comensals10" en productos.
    if (RegExp(r'\d').hasMatch(lineaNombre)) {
      return null;
    }

    final nombre = _limpiarNombre(lineaNombre);
    if (!_esNombreProductoValido(nombre)) {
      return null;
    }

    final textoNombre = _normalizarTextoFiltro(nombre);
    if (_palabrasExcluir.any((p) => textoNombre.contains(_normalizarTextoFiltro(p)))) {
      return null;
    }

    if (!_regexSoloPrecio.hasMatch(lineaPrecio)) {
      return null;
    }

    final precioTexto = _regexPrecio.firstMatch(lineaPrecio)?.group(0);
    if (precioTexto == null) {
      return null;
    }

    final precio = _parsearPrecio(precioTexto);
    if (precio == null || precio <= 0) {
      return null;
    }

    return ProductoDetectadoTicket(
      nombre: nombre,
      precio: precio,
      cantidad: 1,
    );
  }

  static String _limpiarNombre(String nombre) {
    return nombre
        .replaceFirst(RegExp(r'^\d+[\.,]?\d*\s+'), '')
        .replaceAll(RegExp(r'^[\-–—:\.]\s*'), '')
        .replaceAll(RegExp(r'\s*[\-–—:\.]$'), '')
        .trim();
  }

  static ProductoDetectadoTicket? _parsearLineaConDosPrecios(String linea) {
    final matches = _regexPrecio.allMatches(linea).toList();
    if (matches.length < 2) {
      return null;
    }

    // Formato frecuente en tickets tipo: Descripcion Quant Preu Import
    // Ej: "PAELLA DE MARISCO 8,00 17,95 143,60"
    if (matches.length >= 3) {
      final cantidadTexto = matches[matches.length - 3].group(0);
      final precioTexto = matches[matches.length - 2].group(0);
      final importeTexto = matches[matches.length - 1].group(0);

      if (cantidadTexto != null && precioTexto != null && importeTexto != null) {
        final inicioCantidad = matches[matches.length - 3].start;
        final nombreCandidato = _limpiarNombre(linea.substring(0, inicioCantidad).trim());

        final cantidad = _parsearCantidad(cantidadTexto);
        final precio = _parsearPrecio(precioTexto) ?? 0;
        final importe = _parsearPrecio(importeTexto) ?? 0;
        final cantidadInferida = _inferirCantidad(importe: importe, precio: precio);

        if (_esNombreProductoValido(nombreCandidato) &&
            cantidad > 0 &&
            precio > 0 &&
            importe > 0 &&
            (cantidad - cantidadInferida).abs() <= 1) {
          return ProductoDetectadoTicket(
            nombre: nombreCandidato,
            precio: precio,
            cantidad: cantidad,
          );
        }
      }
    }

    final precioUnitarioTexto = matches[matches.length - 2].group(0);
    final importeTexto = matches[matches.length - 1].group(0);
    if (precioUnitarioTexto == null || importeTexto == null) {
      return null;
    }

    var precio = _parsearPrecio(precioUnitarioTexto) ?? 0;
    final importe = _parsearPrecio(importeTexto) ?? 0;
    if (precio <= 0 || importe <= 0) {
      return null;
    }

    final inicioPrecios = matches[matches.length - 2].start;
    var bloqueNombre = linea.substring(0, inicioPrecios).trim();
    var cantidad = 1;

    final matchCantidad = _regexCantidadInicio.firstMatch(bloqueNombre);
    if (matchCantidad != null) {
      cantidad = _parsearCantidad(matchCantidad.group(1) ?? '1');
      bloqueNombre = (matchCantidad.group(2) ?? bloqueNombre).trim();
    }

    final cantidadInferida = _inferirCantidad(importe: importe, precio: precio);
    if (cantidad <= 0 || (cantidadInferida > 0 && (cantidad - cantidadInferida).abs() > 1)) {
      cantidad = cantidadInferida > 0 ? cantidadInferida : 1;
    }

    // Si el OCR fallo en precio unitario, lo derivamos del importe.
    if (cantidad > 0) {
      final derivado = importe / cantidad;
      if ((derivado - precio).abs() > 0.5) {
        precio = derivado;
      }
    }

    final nombre = _limpiarNombre(bloqueNombre);
    if (!_esNombreProductoValido(nombre)) {
      return null;
    }

    return ProductoDetectadoTicket(
      nombre: nombre,
      precio: precio,
      cantidad: cantidad <= 0 ? 1 : cantidad,
    );
  }

  static int _inferirCantidad({required double importe, required double precio}) {
    if (precio <= 0) {
      return 1;
    }

    final ratio = importe / precio;
    final candidato = ratio.round();
    if (candidato <= 0) {
      return 1;
    }

    if ((ratio - candidato).abs() <= 0.25) {
      return candidato;
    }

    return 1;
  }

  static int _buscarInicioDetalle(List<String> lineas) {
    for (var i = 0; i < lineas.length; i++) {
      final n = _normalizarTextoFiltro(lineas[i]);
      final contieneDescripcion =
          n.contains('descripcion') || n.contains('descrip') || n.contains('descripcio');
      final contienePrecio = n.contains('precio') || n.contains('preu');
      final contieneImporte = n.contains('importe') || n.contains('import');
      final contieneUnidad = n.contains('unid') || n.contains('unit') || n.contains('quant');

      final pareceCabeceraDetalle =
          (contieneDescripcion && contienePrecio) ||
          (contieneDescripcion && contieneImporte) ||
          (contieneUnidad && contienePrecio && contieneImporte);
      if (pareceCabeceraDetalle) {
        return i + 1;
      }
    }
    return -1;
  }

  static bool _esNombreProductoValido(String nombre) {
    if (nombre.length < 2) {
      return false;
    }
    if (_regexSoloPrecio.hasMatch(nombre)) {
      return false;
    }
    if (!_regexTieneLetras.hasMatch(nombre)) {
      return false;
    }
    return true;
  }

  static int _parsearCantidad(String texto) {
    final limpio = texto.trim().replaceAll(' ', '').replaceAll(',', '.');
    final valor = double.tryParse(limpio);
    if (valor == null) {
      return 1;
    }
    return valor.round();
  }

  static String _normalizarTextoFiltro(String valor) {
    return valor
        .toLowerCase()
        .replaceAll('1', 'i')
        .replaceAll('0', 'o')
        .replaceAll('5', 's')
        .replaceAll(RegExp(r'[^a-záéíóúñ ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static double? _parsearPrecio(String texto) {
    final normalizado = texto.trim().replaceAll('€', '').replaceAll(' ', '');

    if (normalizado.contains(',') && normalizado.contains('.')) {
      final limpio = normalizado.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(limpio);
    }

    if (normalizado.contains(',')) {
      return double.tryParse(normalizado.replaceAll(',', '.'));
    }

    return double.tryParse(normalizado);
  }
}

