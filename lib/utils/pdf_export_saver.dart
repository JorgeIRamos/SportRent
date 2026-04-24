import 'dart:typed_data';

import 'pdf_export_saver_stub.dart'
    if (dart.library.io) 'pdf_export_saver_io.dart'
    if (dart.library.html) 'pdf_export_saver_web.dart'
    as saver;

Future<String> savePdfBytes({
  required Uint8List bytes,
  required String fileName,
}) {
  return saver.savePdfBytes(bytes: bytes, fileName: fileName);
}
