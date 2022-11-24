import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;

Future<String> getDeviceInfo() async {
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  String info = '';
  if (Platform.isIOS) {
    IosDeviceInfo i = await deviceInfoPlugin.iosInfo;
    info = 'IOS_' + i.systemVersion.toString();
  }

  if (Platform.isAndroid) {
    AndroidDeviceInfo i = await deviceInfoPlugin.androidInfo;
    info = 'ANDROID_' +
        i.brand.toString().replaceAll(' ', '').toUpperCase() +
        '_' +
        i.model.toString().replaceAll(' ', '').toUpperCase() +
        '_SDK' +
        i.version.sdkInt.toString();
  }

  return info;
}
