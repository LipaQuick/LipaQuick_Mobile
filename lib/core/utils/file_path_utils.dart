import 'package:lipa_quick/core/global/Application.dart';

class FilePathUtils{
  String getFilePathUrl(String chatDoc) {
    print('${ApplicationData().BASE_URL}/${chatDoc.replaceAll(r'\', r'/')}');
    return '${ApplicationData().BASE_URL}/${chatDoc.replaceAll(r'\', r'/')}';
  }

  String getFileName(String chatDoc) {
    print('${ApplicationData().BASE_URL}/${chatDoc.replaceAll(r'\', r'/')}'.split('/').last);
    return '${ApplicationData().BASE_URL}/${chatDoc.replaceAll(r'\', r'/')}'.split('/').last;
  }
}