import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

// https://www.youtube.com/watch?v=6tfBflFUO7s
Future openFile(File? file) async {
  OpenFilex.open(file?.path);
}

Future<File?> downloadFile(String url, String name) async {
  try {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/$name');

    final response = await Dio()
        .get(url, options: Options(responseType: ResponseType.bytes, followRedirects: true, receiveTimeout: 0));

    final raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(response.data);
    await raf.close();
    return file;
  } catch (e) {
    print(e);
    return null;
  }
}

String extractFileName(String url) {
  return url.split('/').last;
}
