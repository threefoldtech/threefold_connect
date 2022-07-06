import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/vpn_state.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:yggdrasil_plugin/yggdrasil_plugin.dart';

class PlanetaryNetworkScreen extends StatefulWidget {
  @override
  _PlanetaryNetworkScreenState createState() => _PlanetaryNetworkScreenState();
}

class _PlanetaryNetworkScreenState extends State<PlanetaryNetworkScreen> {
  VpnState _vpnState = new VpnState();
  bool _vpnTimeoutRunning = false;

  String _ipAddress = '';
  Text _statusMessage = Text('');

  bool isDoneConnecting = false;

  bool _isSwitched = Globals().vpnState.vpnConnected;

  void reportIp(String ip) {
    print('RECEVING DATA IN REPORT IP');
    print(ip);
    _vpnState.ipAddress = ip;
    isDoneConnecting = true;
    setState(() {});
  }

  _PlanetaryNetworkScreenState() {
    _vpnState = Globals().vpnState;
    initPlatformState();
    _vpnState.plugin.setOnReportIp(reportIp);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    platformVersion = await _vpnState.plugin.platformVersion();
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      if (_vpnState.vpnConnected) {
        print(_vpnState.ipAddress);

        _ipAddress = "IP Address: " + _vpnState.ipAddress;
        _statusMessage =
            new Text('Connected', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16));
        return;
      }
      _ipAddress = '';
      _statusMessage =
          new Text('Not Connected', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16));
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
      titleText: 'Planetary Network',
      content: Stack(
        children: <Widget>[
          SvgPicture.asset(
            'assets/bg.svg',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Column(
            children: [
              Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: Image.asset('assets/planetary-network.png'),
              ),
              Text('Planetary Network', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
                child: Text(
                    "Enable to connect to ThreeFold's secure network",
                    style: const TextStyle(fontSize: 14)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _statusMessage,
                  Switch(
                    value: _isSwitched,
                    // If the user spams the button, the application would crash => use a timeout
                    onChanged: _vpnTimeoutRunning
                        ? null
                        : (value) async {
                            // Check status => if connected early return
                            if (_vpnState.vpnConnected) {
                              return disconnectVpn();
                            }

                            connectingVpnmessage();
                            bool isVPNConnectionStarted = await _vpnState.plugin.startVpn(await getEdCurveKeys());

                            if (!isVPNConnectionStarted) {
                              return askForVpnPermissions();
                            }

                            await connectVpn();
                          },

                    activeColor: Theme.of(context).primaryColorDark,
                  ),
                ]),
              ),
              new GestureDetector(
                onTap: () async {
                  if (_vpnState.ipAddress != "") {
                    Clipboard.setData(new ClipboardData(text: _vpnState.ipAddress));

                    final snackBar = SnackBar(
                      content: Text('Address copied to clipboard'),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: Text(_ipAddress),
              ),
            ],
          )
        ],
      ),
    );
  }

  void disconnectingVpnMessage() {
    _ipAddress = '';
    _vpnTimeoutRunning = true;
    _statusMessage = new Text('Disconnecting ...',
        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16));

    setState(() {});
  }

  void connectingVpnmessage() {
    _ipAddress = '';
    _vpnTimeoutRunning = true;
    _statusMessage =
        new Text('Connecting ...', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16));

    setState(() {});
  }

  void disconnectVpn() {
    _ipAddress = '';
    _vpnTimeoutRunning = true;
    _statusMessage = new Text('Disconnecting ...',
        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16));

    setState(() {});

    _vpnState.plugin.stopVpn();
    _vpnState.vpnConnected = false;
    _vpnState.plugin = new YggdrasilPlugin();
    _ipAddress = '';
    _isSwitched = false;

    _vpnTimeoutRunning = false;
    _statusMessage =
        new Text('Not connected', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16));

    setState(() {});
  }

  void askForVpnPermissions() {
    _ipAddress = "Please click connect again after accepting VPN permissions.";
    _isSwitched = false;
    _vpnTimeoutRunning = false;
    _statusMessage =
        new Text('Not connected', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16));

    setState(() {});
  }

  Future<void> connectVpn() async {
    _vpnTimeoutRunning = true;
    _statusMessage =
        new Text('Connecting ...', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16));

    setState(() {});

    connectToYggDrasil();
  }

  Future<void> connectToYggDrasil() async {
    int counter = 0;

    while (isDoneConnecting == false && counter <= 10) {
      await Future.delayed(Duration(seconds: 1));
      counter++;
      setState(() {});
    }

    if (isDoneConnecting == true) {
      isDoneConnecting = false;
      _vpnTimeoutRunning = false;
      _isSwitched = true;
      _statusMessage =
          new Text('Connected', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16));
      _ipAddress = 'IP Address: ' + _vpnState.ipAddress;
      setState(() {});
      _vpnState.vpnConnected = true;
    } else {
      disconnectVpn();
    }
  }
}
