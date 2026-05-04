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
  static final RegExp _regexSeparador = RegExp(r'^\s*[-_=]{4,}\s*$');
  static final RegExp _regexEspaciosDecimales = RegExp(r'(\d+)\s*[\.,]\s*(\d+)');

  static const List<String> _palabrasExcluir = [
    'total', 'subtotal', 'iva', 'i.v.a', '1va', 'impuesto', 'impuestos',
    'nif', 'cif', 'fecha', 'hora', 'tarjeta', 'efectivo', 'cambio',
    'gracias', 'precio importe', 'precio', 'importe', 'unidad',
    'descripcion', 'mesa', 'base', 'atendio', 'atendido', 'rte',
    'vendedor', 'tlf', 'tel', 'telefono', 'comensal', 'comensals',
    'camarero', 'camarera', 'cambrer', 'ticket', 'fra', 'simple',
    'data', 'n ticket', 'recapitulativo', 'base imponible', 'cuota',
    'tipo', 'puntos', 'operacion', 'atendido por', 'atend'
  ];

  static ResultadoParseTicket parsearTexto(String texto) {
    final lineas = texto
        .split('\n')
        .map((l) => l.replaceAll(RegExp(r'\s+'), ' ').trim())
        .map(_corregirLineaOcr)
        .where((l) => l.isNotEmpty)
        .toList();

    String? restaurante;
    final productos = <ProductoDetectadoTicket>[];
    double? total;
    bool seEncontroTotal = false;

    final rangoSeparador = _buscarDetallePorSeparadores(lineas);
    final inicioDetalle = rangoSeparador?.inicio ?? _buscarInicioDetalle(lineas);
    final finDetalle = rangoSeparador?.fin ?? -1;

    for (var i = 0; i < lineas.length; i++) {
      final linea = lineas[i];

      if (restaurante == null && (inicioDetalle == -1 || i <= inicioDetalle)) {
        restaurante = _intentarRestaurante(linea);
      }

      final totalLinea = _intentarExtraerTotal(linea);
      if (totalLinea != null) {
        total = totalLinea;
        seEncontroTotal = true;
      }

      if (inicioDetalle != -1 && i < inicioDetalle) continue;
      if (finDetalle != -1 && i > finDetalle) continue;
      if (seEncontroTotal) continue;
      if (!_regexTieneLetras.hasMatch(linea) || linea.contains('%')) continue;

      final producto = _parsearLineaProducto(linea);
      if (producto != null) {
        productos.add(producto);
        continue;
      }

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

  static String _corregirLineaOcr(String linea) {
    var corregida = linea.replaceAllMapped(
        _regexEspaciosDecimales,
            (m) => '${m.group(1)},${m.group(2)}'
    );
    corregida = corregida.replaceAll(RegExp(r'\s{2,}'), ' ');
    return corregida.trim();
  }

  static ProductoDetectadoTicket _construirProducto(String nombre, double precio, int cantidad) {
    var n = nombre; // Aún no limpiamos el nombre aquí
    var c = cantidad <= 0 ? 1 : cantidad;

    if (c == 1) {
      final match = _extraerCantidadFinalFlexible(n);
      if (match != null) {
        c = match.cantidad;
        n = match.nombre;
      }
    }

    n = _limpiarNombre(n);
    return ProductoDetectadoTicket(nombre: n, precio: precio, cantidad: c);
  }

  static String? _intentarRestaurante(String linea) {
    if (linea.length < 3 || RegExp(r'\d').hasMatch(linea)) return null;
    final texto = _normalizarTextoFiltro(linea);
    if (_palabrasExcluir.any((p) => texto.contains(_normalizarTextoFiltro(p)))) return null;
    return linea;
  }

  static double? _intentarExtraerTotal(String linea) {
    final texto = _normalizarTextoFiltro(linea);
    if (!texto.contains('total') || texto.contains('subtotal') || texto.contains('iva')) return null;
    final match = _regexPrecio.firstMatch(linea);
    return match != null ? _parsearPrecio(match.group(0)!) : null;
  }

  static ProductoDetectadoTicket? _parsearLineaProducto(String linea) {
    final nFiltro = _normalizarTextoFiltro(linea);
    if (_palabrasExcluir.any((p) => nFiltro.contains(_normalizarTextoFiltro(p)))) return null;

    final conDosPrecios = _parsearLineaConDosPrecios(linea);
    if (conDosPrecios != null) return conDosPrecios;

    final matchRest = _regexLineaRestaurante.firstMatch(linea);
    if (matchRest != null) {
      final cant = _parsearCantidad(matchRest.group(1) ?? '1');
      final pUni = _parsearPrecio(matchRest.group(3) ?? '0') ?? 0;
      final pTotal = _parsearPrecio(matchRest.group(4) ?? '0') ?? 0;
      final nombre = matchRest.group(2) ?? '';

      if (cant > 0 && pUni > 0 && (cant * pUni - pTotal).abs() <= 0.15) {
        return _construirProducto(nombre, pUni, cant);
      }
    }

    final matchInicio = _regexPrecioInicio.firstMatch(linea);
    if (matchInicio != null) {
      final precio = _parsearPrecio(matchInicio.group(1)!);
      final nombre = matchInicio.group(2) ?? '';
      if (precio != null && precio > 0 && _esNombreProductoValido(nombre)) {
        return _construirProducto(nombre, precio, 1);
      }
    }

    final matchFinal = _regexPrecioFinal.firstMatch(linea);
    if (matchFinal != null) {
      final precio = _parsearPrecio(matchFinal.group(2)!);
      var nombre = matchFinal.group(1)!;
      final cantidadInicio = _extraerCantidadInicioFlexible(nombre);
      if (cantidadInicio != null) {
        nombre = cantidadInicio.nombre;
        if (precio != null && precio > 0 && _esNombreProductoValido(nombre)) {
          return _construirProducto(nombre, precio, cantidadInicio.cantidad);
        }
      }

      if (precio != null && precio > 0 && _esNombreProductoValido(nombre)) {
        return _construirProducto(nombre, precio, 1);
      }
    }

    return null;
  }

  static ProductoDetectadoTicket? _parsearLineaConDosPrecios(String linea) {
    final matches = _regexPrecio.allMatches(linea).toList();
    if (matches.length < 2) return null;

    final pUnit = _parsearPrecio(matches[matches.length - 2].group(0)!);
    final pTotal = _parsearPrecio(matches[matches.length - 1].group(0)!);

    if (pUnit != null && pTotal != null && pUnit > 0) {
      final bloqueNombre = linea.substring(0, matches[matches.length - 2].start).trim();

      int cant = 1;
      String nombreLimpio = bloqueNombre;

      final inicio = _extraerCantidadInicioFlexible(bloqueNombre);
      if (inicio != null) {
        cant = inicio.cantidad;
        nombreLimpio = inicio.nombre;
      } else {
        final finalMatch = RegExp(r'^(.*?)\s+(\d+[\.,]?\d*)$').firstMatch(bloqueNombre);
        if (finalMatch != null) {
          final posibleNombre = finalMatch.group(1)?.trim() ?? '';
          final posibleCantidad = _parsearCantidad(finalMatch.group(2) ?? '1');
          if (_regexTieneLetras.hasMatch(posibleNombre)) {
            nombreLimpio = posibleNombre;
            cant = posibleCantidad;
          }
        }
      }

      final ratio = pTotal / pUnit;
      final ratioRedondeado = ratio.round();
      if ((ratio - ratioRedondeado).abs() <= 0.15 &&
          (cant <= 1 || (cant * pUnit - pTotal).abs() > 0.15)) {
        cant = ratioRedondeado;
      }

      if ((cant * pUnit - pTotal).abs() <= 0.2) {
        if (!_regexTieneLetras.hasMatch(nombreLimpio)) return null;
        return _construirProducto(nombreLimpio, pUnit, cant);
      }
    }
    return null;
  }

  static ProductoDetectadoTicket? _parsearNombreYPrecioSeparados({
    required String lineaNombre,
    required String lineaPrecio,
  }) {
    if (!_esNombreProductoValido(lineaNombre) || !_lineaPareceSoloPrecios(lineaPrecio)) return null;
    final precios = _regexPrecio
        .allMatches(lineaPrecio)
        .map((m) => _parsearPrecio(m.group(0)!))
        .whereType<double>()
        .toList();
    if (precios.isEmpty) return null;
    return _construirProducto(lineaNombre, precios.reduce((a, b) => a < b ? a : b), 1);
  }

  static String _limpiarNombre(String nombre) {
    return nombre
        .replaceFirst(RegExp(r'^\s*\d+\s*[xX]\s+'), '')
        .replaceFirst(RegExp(r'^\d+[\.,]?\d*\s+'), '')
        .replaceAll(RegExp(r'^[\-–—:\.]\s*'), '')
        .replaceAll(RegExp(r'\s*[\-–—:\.,]$'), '')
        .trim();
  }

  static int _buscarInicioDetalle(List<String> lineas) {
    for (var i = 0; i < lineas.length; i++) {
      final n = _normalizarTextoFiltro(lineas[i]);
      if ((n.contains('descrip') && n.contains('prec')) || (n.contains('unid') && n.contains('import'))) return i + 1;
    }
    return -1;
  }

  static _RangoDetalle? _buscarDetallePorSeparadores(List<String> lineas) {
    final separadores = <int>[];
    for (var i = 0; i < lineas.length; i++) {
      if (_regexSeparador.hasMatch(lineas[i])) separadores.add(i);
    }
    if (separadores.length < 2) return null;

    int mejorI = -1, mejorF = -1, max = 0;
    for (var i = 0; i < separadores.length - 1; i++) {
      int s = 0;
      for (var j = separadores[i] + 1; j < separadores[i+1]; j++) {
        if (_regexPrecio.hasMatch(lineas[j]) && _regexTieneLetras.hasMatch(lineas[j])) s++;
      }
      if (s > max) { max = s; mejorI = separadores[i] + 1; mejorF = separadores[i+1] - 1; }
    }
    return max > 0 ? _RangoDetalle(mejorI, mejorF) : null;
  }

  static bool _esNombreProductoValido(String n) =>
      n.length >= 2 && _regexTieneLetras.hasMatch(n) && !_regexSoloPrecio.hasMatch(n);

  static int _parsearCantidad(String t) {
    final valor = double.tryParse(t.trim().replaceAll(' ', '').replaceAll(',', '.'));
    if (valor == null || valor <= 0) return 1;
    return (valor - valor.round()).abs() < 0.15 ? valor.round() : valor.floor();
  }

  static String _normalizarTextoFiltro(String v) =>
      v.toLowerCase().replaceAll(RegExp(r'[^a-záéíóúñ0-9 ]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

  static double? _parsearPrecio(String t) {
    final n = t.trim().replaceAll('€', '').replaceAll(' ', '');
    if (n.contains(',') && n.contains('.')) return double.tryParse(n.replaceAll('.', '').replaceAll(',', '.'));
    return double.tryParse(n.replaceAll(',', '.'));
  }

  static bool _lineaPareceSoloPrecios(String l) =>
      !_regexTieneLetras.hasMatch(l) && _regexPrecio.hasMatch(l);

  static _CantidadNombre? _extraerCantidadFinalFlexible(String texto) {
    final match = RegExp(r'^(.*?)\s+(\d+)\s*$').firstMatch(texto);
    if (match == null || match.group(1)!.length < 3) return null;
    final nombre = match.group(1)!.trim();
    if (['n', 'no', 'nº', 'n2', 'num'].contains(nombre.toLowerCase().split(' ').last)) return null;
    final cant = int.tryParse(match.group(2)!);
    return (cant != null && cant > 0) ? _CantidadNombre(cant, nombre) : null;
  }

  static _CantidadNombre? _extraerCantidadInicioFlexible(String texto) {
    final conX = RegExp(r'^\s*(\d+)\s*[xX]\s+(.+)$').firstMatch(texto);
    if (conX != null) {
      final cant = int.tryParse(conX.group(1) ?? '1') ?? 1;
      final nombre = conX.group(2)?.trim() ?? '';
      if (cant > 0 && _regexTieneLetras.hasMatch(nombre)) {
        return _CantidadNombre(cant, nombre);
      }
    }

    final conEspacio = RegExp(r'^\s*(\d+)\s+(.+)$').firstMatch(texto);
    if (conEspacio != null) {
      final cant = int.tryParse(conEspacio.group(1) ?? '1') ?? 1;
      final nombre = conEspacio.group(2)?.trim() ?? '';
      if (cant > 0 && _regexTieneLetras.hasMatch(nombre)) {
        return _CantidadNombre(cant, nombre);
      }
    }

    final pegado = RegExp(r'^\s*(\d+)([A-Za-zÁÉÍÓÚáéíóúÑñ].+)$').firstMatch(texto);
    if (pegado != null) {
      final cant = int.tryParse(pegado.group(1) ?? '1') ?? 1;
      final nombre = pegado.group(2)?.trim() ?? '';
      if (cant > 0 && _regexTieneLetras.hasMatch(nombre)) {
        return _CantidadNombre(cant, nombre);
      }
    }

    return null;
  }
}

class _RangoDetalle { final int inicio, fin; const _RangoDetalle(this.inicio, this.fin); }
class _CantidadNombre { final int cantidad; final String nombre; const _CantidadNombre(this.cantidad, this.nombre); }