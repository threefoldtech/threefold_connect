import 'package:yggdrasil_plugin/yggdrasil_plugin.dart';

class VpnState {
  VpnState() {
    plugin = new YggdrasilPlugin();
  }

  YggdrasilPlugin plugin = new YggdrasilPlugin();

  bool vpnConnected = false;
  String ipAddress = "";
}
