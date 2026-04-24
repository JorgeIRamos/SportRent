import 'dart:typed_data';

Future<String> savePdfBytes({
  required Uint8List bytes,
  required String fileName,
}) {
  throw UnsupportedError('Exportación PDF no soportada en esta plataforma');
}
