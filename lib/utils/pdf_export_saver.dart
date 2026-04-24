import 'dart:io';
import 'dart:typed_data';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String> savePdfBytes({
  required Uint8List bytes,
  required String fileName,
}) async {
  if (Platform.isAndroid) {
    // Needed for Android ≤ 9 (API 28); harmless no-op on newer versions
    await Permission.storage.request();

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(bytes);

    // MediaStore.Downloads: accessible in the phone's Downloads app.
    // API 30+ → MediaStore (scoped storage, no extra permission needed).
    // API ≤ 29 → direct file copy to /storage/emulated/0/Download/SportRent/.
    MediaStore.appFolder = 'SportRent';
    final ms = MediaStore();
    try {
      await ms.saveFile(
        tempFilePath: tempFile.path,
        dirType: DirType.download,
        dirName: DirName.download,
      );
    } finally {
      // API ≤ 29: saveFile copies but doesn't delete the temp file
      if (await tempFile.exists()) await tempFile.delete();
    }

    return 'Descargas/SportRent';
  }

  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return dir.path;
}
