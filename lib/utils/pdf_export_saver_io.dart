import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<String> savePdfBytes({
  required Uint8List bytes,
  required String fileName,
}) async {
  final downloads = await getDownloadsDirectory();
  final directory = downloads ?? await getApplicationDocumentsDirectory();
  await directory.create(recursive: true);

  final filePath = '${directory.path}${Platform.pathSeparator}$fileName';
  final file = File(filePath);
  await file.writeAsBytes(bytes, flush: true);
  return filePath;
}
