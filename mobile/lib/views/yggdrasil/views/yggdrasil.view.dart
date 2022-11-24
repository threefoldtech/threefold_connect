import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/core/router/tabs/views/tabs.views.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/styles/text.styles.dart';
import 'package:threebotlogin/core/yggdrasil/classes/yggdrasil.classes.dart';
import 'package:yggdrasil_plugin/yggdrasil_plugin.dart';

class YggDrasilScreen extends StatefulWidget {
  YggDrasilScreen();

  _YggDrasilScreenState createState() => _YggDrasilScreenState();
}

class _YggDrasilScreenState extends State<YggDrasilScreen> {
  VpnState _vpnState = new VpnState();
  bool _vpnTimeoutRunning = false;

  String _ipAddress = '';
  Text _statusMessage = Text('');

  bool isDoneConnecting = false;

  bool _isSwitched = Globals().vpnState.vpnConnected;

  _YggDrasilScreenState() {
    _vpnState = Globals().vpnState;
    _vpnState.plugin.setOnReportIp(reportIp);
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      if (!_vpnState.vpnConnected) return setVpnDisconnectedLayout();
      return setVpnConnectedLayout();
    });
  }

  void reportIp(String ip) {
    print("Yggdrasil: received following ip: $ip");
    _vpnState.ipAddress = ip;
    isDoneConnecting = true;
    setState(() {});
  }

  void setVpnConnectedLayout() {
    _isSwitched = true;
    _ipAddress = "IP Address: " + _vpnState.ipAddress;
    _statusMessage = new Text('Connected', style: kConnectedTextStyle());
    setState(() {});
  }

  void setVpnConnected() {
    isDoneConnecting = true;
    _vpnTimeoutRunning = false;

    _statusMessage = new Text('Connected', style: kConnectedTextStyle());
    _ipAddress = 'IP Address: ' + _vpnState.ipAddress;
    _vpnState.vpnConnected = true;
    setState(() {});
  }

  void setVpnDisconnectedLayout() {
    _ipAddress = "";
    _statusMessage = new Text('Not connected', style: kDisconnectedTextStyle());
    setState(() {});
  }

  void setVpnConnectingLayout() {
    _ipAddress = "";
    _statusMessage = new Text('Connecting', style: kConnectingTextStyle());
    setState(() {});
  }

  void setVpnDisconnectingLayout() {
    _vpnTimeoutRunning = true;
    _ipAddress = "";
    _statusMessage = new Text('Disconnecting', style: kDisconnectedTextStyle());
    setState(() {});
  }

  void setAskForPermissionsLayout() {
    _isSwitched = false;
    _vpnTimeoutRunning = false;

    _ipAddress = "Please click connect again after accepting VPN permissions.";
    _statusMessage = new Text('Not connected', style: kDisconnectedTextStyle());

    setState(() {});
  }

  Future<void> connectVpn() async {
    _vpnTimeoutRunning = true;
    setVpnConnectingLayout();

    setState(() {});

    connectToYggDrasil();
  }

  Future<void> disconnectVpn() async {
    _vpnTimeoutRunning = true;

    setVpnDisconnectingLayout();

    setState(() {});

    _vpnState.plugin.stopVpn();
    _vpnState.vpnConnected = false;
    _vpnState.plugin = new YggdrasilPlugin();
    _isSwitched = false;
    _vpnTimeoutRunning = false;
    isDoneConnecting = false;

    setVpnDisconnectedLayout();

    setState(() {});
  }

  Future<void> connectToYggDrasil() async {
    int counter = 0;

    while (isDoneConnecting == false && counter <= 10) {
      print('Counter: $counter');
      await Future.delayed(Duration(seconds: 1));
      counter++;
      setState(() {});
    }

    if (isDoneConnecting == true) {
      isDoneConnecting = false;
      _vpnTimeoutRunning = false;
      _vpnState.vpnConnected = true;
      setVpnConnectedLayout();
      return;
    }
    disconnectVpn();
  }

  void copyYggdrasilAddressToClipboard() {
    if (_vpnState.ipAddress == "") return;

    Clipboard.setData(new ClipboardData(text: _vpnState.ipAddress));
    final snackBar = SnackBar(content: Text('Address copied to clipboard'));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget yggdrasilImage() {
    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width,
      child: Image.asset('assets/planetary-network.png'),
    );
  }

  Widget connectionInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        connectorSwitch(),
        _statusMessage,
      ]),
    );
  }

  Widget introductionText = Padding(
    padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
    child: Text("Enable to connect to ThreeFold's secure network", style: const TextStyle(fontSize: 14)),
  );

  Widget connectorSwitch() {
    return Switch(
      value: _isSwitched,
      onChanged: _vpnTimeoutRunning
          ? null
          : (value) async {
              if (_vpnState.vpnConnected) {
                return disconnectVpn();
              }

              setVpnDisconnectingLayout();
              bool isVPNConnectionStarted = await _vpnState.plugin.startVpn(await getEdCurveKeys());

              if (!isVPNConnectionStarted) {
                return setAskForPermissionsLayout();
              }

              await connectVpn();
            },
      activeColor: Theme.of(context).primaryColorDark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
      titleText: 'Planetary Network',
      content: Stack(
        children: <Widget>[
          Column(
            children: [
              yggdrasilImage(),
              Text('Planetary Network', style: kTitle()),
              introductionText,
              connectionInfo(),
              new GestureDetector(
                onTap: () => copyYggdrasilAddressToClipboard(),
                child: Text(_ipAddress),
              ),
            ],
          )
        ],
      ),
    );
  }
}
