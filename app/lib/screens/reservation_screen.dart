// import 'dart:convert';
// import 'dart:ffi';
//
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:http/http.dart';
// import 'package:threebotlogin/events/events.dart';
// import 'package:threebotlogin/events/go_wallet_event.dart';
// import 'package:threebotlogin/helpers/globals.dart';
// import 'package:threebotlogin/helpers/hex_color.dart';
// import 'package:threebotlogin/models/paymentRequest.dart';
// import 'package:threebotlogin/services/3bot_service.dart';
// import 'package:threebotlogin/services/shared_preference_service.dart';
// import 'package:threebotlogin/widgets/custom_dialog.dart';
// import 'package:threebotlogin/widgets/layout_drawer.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class ReservationScreen extends StatefulWidget {
//   ReservationScreen({Key key}) : super(key: key);
//
//   @override
//   _ReservationScreenState createState() => _ReservationScreenState();
// }
//
// class _ReservationScreenState extends State<ReservationScreen> {
//   String doubleName = '';
//   bool _isLoading = false;
//
//   Map<String, Object> _allProductKeys;
//
//   List _activatedProductKeys = [];
//   List _unActivatedProductKeys = [];
//
//   TextEditingController productKeyController = TextEditingController();
//   bool _isValid = false;
//   bool _layoutInputValid = true;
//   bool _isDigitalTwinActive = true;
//   bool disableReserveNowButton = false;
//
//   Future _getReservationDetails() async {
//     if (doubleName.isEmpty) {
//       String value = await getDoubleName();
//       doubleName = value;
//       setState(() {
//         doubleName = value;
//       });
//     }
//
//     Response reservationDetailsResult = await getReservationDetails(doubleName);
//     Map<String, Object> reservationDetails =
//         jsonDecode(reservationDetailsResult.body);
//
//     if (reservationDetails['details'] == null) {
//       return;
//     }
//
//     return reservationDetails['details'];
//   }
//
//   Future _checkReservations() async {
//     if (doubleName.isEmpty) {
//       String value = await getDoubleName();
//       doubleName = value;
//       setState(() {
//         doubleName = value;
//       });
//       if (!_isLoading) {
//         _loadingDialog();
//         setState(() {
//           _isLoading = true;
//         });
//       }
//     }
//
//     Response reservationsResult = await getReservations(doubleName);
//
//     if (reservationsResult.statusCode != 200) {
//       // TODO let user know there was an error
//       _isDigitalTwinActive = false;
//       return {"active": false};
//     }
//
//     await _fillProductKeys();
//
//     _isDigitalTwinActive = jsonDecode(reservationsResult.body)['active'];
//
//     Response allProductKeysResult = await getAllProductKeys();
//     Map<String, Object> allProductKeys = jsonDecode(allProductKeysResult.body);
//     _allProductKeys = allProductKeys;
//
//     if (_isLoading) {
//       Navigator.pop(context); // Remove loading screen
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<bool> _checkIfProductKeyIsValid(String productKey) async {
//     if (_allProductKeys.isEmpty) return false;
//     if (_allProductKeys['productkeys'] == null) return false;
//
//     for (var item in _allProductKeys['productkeys']) {
//       if (item['key'] == productKey) return true;
//     }
//     return false;
//   }
//
//   _fillProductKeys() async {
//     Response productKeysResult = await getProductKeys(doubleName);
//     Map<String, Object> productKeys = jsonDecode(productKeysResult.body);
//
//     _unActivatedProductKeys = [];
//     _activatedProductKeys = [];
//
//     if (productKeys == null) {
//       // There are no product keys available
//       return;
//     }
//
//     if (productKeys['productkeys'] == null) return [];
//
//     for (var item in productKeys['productkeys']) {
//       if (item['status'] == 1) {
//         _unActivatedProductKeys.add(item);
//       } else {
//         _activatedProductKeys.add(item);
//       }
//     }
//
//     return productKeys['productkeys'];
//   }
//
//   Future _showActivatedKeys() async {
//     return _activatedProductKeys;
//   }
//
//   Future _showUnActivatedKeys() async {
//     return _unActivatedProductKeys;
//   }
//
//   _activateProductKey(String productKey) async {
//     bool isValid = await _checkIfProductKeyIsValid(productKey);
//
//     if (isValid == false) {
//       return;
//     }
//
//     activateDigitalTwin(doubleName, productKey);
//     _successDialog();
//     productKeyController.text = '';
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_isLoading) {
//       return LayoutDrawer(
//         titleText: 'Reservations',
//         content: Stack(
//           children: [
//             SvgPicture.asset(
//               'assets/bg.svg',
//               alignment: Alignment.center,
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height,
//             ),
//             SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   FutureBuilder(
//                     future: _checkReservations(),
//                     builder: (BuildContext context,
//                         AsyncSnapshot<dynamic> snapshot) {
//                       Widget box = Container();
//                       box = _isDigitalTwinActive
//                           ? _reserved()
//                           : _notReservedYet();
//
//                       return Container(
//                         padding: EdgeInsets.all(25.0),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             box,
//                             SizedBox(
//                               height: 50.0,
//                             ),
//                             _reserveForLovedOnes(),
//                             SizedBox(
//                               height: 50.0,
//                             ),
//                             _productKeysItem(),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//     return Container();
//   }
//
//   Widget _notReservedYet() {
//     return _card(
//       title: 'Reserve your digital twin for life',
//       body: Column(
//         children: [
//           RichText(
//               text: TextSpan(
//             style: new TextStyle(
//               fontSize: 14.0,
//               color: Colors.black,
//             ),
//             children: <TextSpan>[
//               TextSpan(
//                 text:
//                     'With Digital Twin seamless experiences, grant yourself with a lifetime digital freedom and privacy for only 1000 TFT. \n \n',
//               ),
//               TextSpan(text: 'Visit '),
//               TextSpan(
//                 style: new TextStyle(
//                   color: Theme.of(context).primaryColor,
//                 ),
//                 text: 'Digital Twin website',
//                 recognizer: TapGestureRecognizer()
//                   ..onTap = () async {
//                     final url = 'https://mydigitaltwin.io/';
//                     if (await canLaunch(url)) {
//                       await launch(
//                         url,
//                         forceSafariVC: false,
//                       );
//                     }
//                   },
//               ),
//               TextSpan(text: ' for more info. '),
//             ],
//           )),
//           SizedBox(
//             height: 10,
//           ),
//           Row(mainAxisAlignment: MainAxisAlignment.end, children: [
//             ElevatedButton(
//               onPressed: disableReserveNowButton
//                   ? null
//                   : () {
//                       redirectToWallet(activatedDirectly: true);
//                     },
//               child: Text('Reserve Now'),
//             ),
//           ]),
//         ],
//       ),
//     );
//   }
//
//   Widget _reserved() {
//     return _card(
//       title: 'You Have Reserved Your Digital Twin',
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Wrap(
//             children: [
//               RichText(
//                   text: TextSpan(
//                 style: new TextStyle(
//                   fontSize: 14.0,
//                   color: Colors.black,
//                 ),
//                 children: [
//                   TextSpan(
//                     text: 'Digital Twin for Life is coming soon. Go to \n',
//                   ),
//                   TextSpan(
//                     style: new TextStyle(
//                       color: Theme.of(context).primaryColor,
//                     ),
//                     text: 'Digital Twin Website',
//                     recognizer: TapGestureRecognizer()
//                       ..onTap = () async {
//                         final url = 'https://mydigitaltwin.io/';
//                         if (await canLaunch(url)) {
//                           await launch(
//                             url,
//                             forceSafariVC: false,
//                           );
//                         }
//                       },
//                   ),
//                   TextSpan(
//                       text:
//                           ' and subscribe to our Telegram Channel for news and updates.'),
//                 ],
//               )),
//             ],
//           ),
//           SizedBox(
//             height: 10.0,
//           ),
//           TextButton.icon(
//             onPressed: () async {
//               final url = 'https://t.me/joinchat/JnJfqY9tfAU1NTY0';
//               if (await canLaunch(url)) {
//                 await launch(
//                   url,
//                   forceSafariVC: false,
//                 );
//               }
//             },
//             label: Text('Digital Twin Telegram Channel'),
//             icon: Icon(Icons.open_in_new),
//           ),
//           ElevatedButton(
//               onPressed: () {
//                 _showReservation();
//               },
//               child: Text('My Digital Twin Reservation'))
//         ],
//       ),
//     );
//   }
//
//   Widget _reserveForLovedOnes() {
//     return _card(
//       title: "Reserve Digital Twin for Life for Your Loved Ones",
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           RichText(
//               text: TextSpan(
//             style: new TextStyle(
//               fontSize: 14.0,
//               color: Colors.black,
//             ),
//             children: [
//               TextSpan(
//                 text:
//                     'Grant a Digital Twin for Life to your loved ones for only 1000 TFT. All you need is their 3Bot ID. \n \n',
//               ),
//               TextSpan(text: 'Visit '),
//               TextSpan(
//                 style: new TextStyle(
//                   color: Theme.of(context).primaryColor,
//                 ),
//                 text: 'Digital Twin website',
//                 recognizer: TapGestureRecognizer()
//                   ..onTap = () async {
//                     final url = 'https://mydigitaltwin.io/';
//                     if (await canLaunch(url)) {
//                       await launch(
//                         url,
//                         forceSafariVC: false,
//                       );
//                     }
//                   },
//               ),
//               TextSpan(text: ' for more info. '),
//             ],
//           )),
//           SizedBox(
//             height: 10,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   redirectToWallet(
//                       reservingFor: 'loved.3bot', activatedDirectly: false);
//                 },
//                 child: Text('Buy Product Key'),
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // TODO: make this code more performant
//   Widget _productKeysItem() {
//     return _card(
//       title: "Product keys",
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // FutureBuilder(
//           //     future: _fillProductKeys(),
//           //     builder: (context, snapshot) {
//           //       return Container();
//           //     }),
//           Row(
//             children: [
//               Text('Unclaimed',
//                   style:
//                       new TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                   textAlign: TextAlign.left)
//             ],
//           ),
//           Row(
//             children: [
//               FutureBuilder(
//                 future: _showUnActivatedKeys(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData && snapshot.data.length > 0) {
//                     return Expanded(
//                         child: ListView.builder(
//                             shrinkWrap: true,
//                             itemCount: _unActivatedProductKeys.length,
//                             itemBuilder: (context, index) {
//                               return Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     _unActivatedProductKeys.length <= 0
//                                         ? Container()
//                                         : Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     top: 8,
//                                                     right: 8,
//                                                     bottom: 8),
//                                                 child: Text('Product key ' +
//                                                     (index + 1).toString() +
//                                                     ': ' +
//                                                     _unActivatedProductKeys[
//                                                             index]['key']
//                                                         .toString()),
//                                               ),
//                                               new GestureDetector(
//                                                 onTap: () async {
//                                                   if (snapshot.hasData) {
//                                                     Clipboard.setData(
//                                                         new ClipboardData(
//                                                             text: snapshot
//                                                                 .data[index]
//                                                                     ['key']
//                                                                 .toString()));
//
//                                                     final snackBar = SnackBar(
//                                                       content: Text(
//                                                           'Product key copied to clipboard'),
//                                                     );
//
//                                                     ScaffoldMessenger.of(
//                                                             context)
//                                                         .showSnackBar(snackBar);
//                                                   }
//                                                 },
//                                                 child: Icon(
//                                                   Icons.content_copy,
//                                                   size: 14,
//                                                 ),
//                                               ),
//                                             ],
//                                           )
//                                   ]);
//                             }));
//                   } else {
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 8.0),
//                       child:
//                           Container(child: Text('No product keys available')),
//                     );
//                   }
//                 },
//               ),
//             ],
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           Row(
//             children: [
//               Text('Activated',
//                   style:
//                       new TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                   textAlign: TextAlign.left)
//             ],
//           ),
//           Row(
//             children: [
//               FutureBuilder(
//                 future: _showActivatedKeys(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData && snapshot.data.length > 0) {
//                     return Expanded(
//                         child: ListView.builder(
//                             shrinkWrap: true,
//                             itemCount: _activatedProductKeys.length,
//                             itemBuilder: (context, index) {
//                               return Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     _activatedProductKeys.length <= 0
//                                         ? Container()
//                                         : Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     top: 8, right: 8),
//                                                 child: Text(
//                                                     _activatedProductKeys[index]
//                                                             ['double_name']
//                                                         .toString()),
//                                               ),
//                                               Text(
//                                                 'Activated',
//                                                 style: TextStyle(
//                                                     color: Colors.green,
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                               )
//                                             ],
//                                           )
//                                   ]);
//                             }));
//                   } else {
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 8.0),
//                       child: Container(child: Text('No users activated')),
//                     );
//                   }
//                 },
//               ),
//             ],
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               _isDigitalTwinActive
//                   ? Container()
//                   : Flexible(
//                       child: Row(
//                       children: [
//                         Expanded(
//                             child: Padding(
//                           padding: const EdgeInsets.only(right: 25),
//                           child: TextFormField(
//                             controller: productKeyController,
//                             decoration: InputDecoration(
//                               border: UnderlineInputBorder(),
//                               labelText: 'Enter product key',
//                               errorText: _layoutInputValid
//                                   ? ''
//                                   : 'Enter a valid product key',
//                               errorBorder: _layoutInputValid
//                                   ? new OutlineInputBorder(
//                                       borderSide: new BorderSide(
//                                           color: Colors.transparent,
//                                           width: 0.0))
//                                   : new OutlineInputBorder(
//                                       borderSide: new BorderSide(
//                                           color: Colors.red, width: 1),
//                                     ),
//                             ),
//                           ),
//                         )),
//                         ElevatedButton(
//                           onPressed: () async {
//                             bool isValidated = await _checkIfProductKeyIsValid(
//                                 productKeyController.text);
//                             setState(() => _layoutInputValid = isValidated);
//
//                             if (!_layoutInputValid) return;
//                             _activateProductKey(productKeyController.text);
//                           },
//                           child: Text('Activate'),
//                         ),
//                       ],
//                     ))
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> redirectToWallet(
//       {String reservingFor, bool activatedDirectly}) async {
//     setState(() {
//       disableReserveNowButton = true;
//     });
//
//     if (reservingFor == null) {
//       reservingFor = doubleName;
//     }
//
//     Map<String, dynamic> data = {
//       'doubleName': doubleName,
//       'reservationBy': await getDoubleName(),
//       'activated_directly': activatedDirectly,
//     };
//
//     Response res = await sendProductReservation(data);
//
//     Map<String, dynamic> decode = json.decode(res.body);
//
//     Globals().paymentRequest = PaymentRequest.fromJson(decode);
//     Globals().paymentRequestIsUsed = false;
//
//     Events().emit(GoWalletEvent());
//
//     setState(() {
//       disableReserveNowButton = false;
//     });
//   }
//
//   Future _loadingDialog() {
//     return showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () => Future.value(false),
//           child: Dialog(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(
//                   height: 10,
//                 ),
//                 new CircularProgressIndicator(),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 new Text("One moment please"),
//                 SizedBox(
//                   height: 10,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Future _successDialog() {
//     return showDialog(
//         context: context,
//         builder: (BuildContext context) => CustomDialog(
//               image: Icons.check,
//               title: "Successfully activated",
//               description: "The product key was successfully activated",
//               actions: <Widget>[
//                 FlatButton(
//                   child: new Text("Ok"),
//                   onPressed: () {
//                     Navigator.pop(context);
//                     setState(() {});
//                   },
//                 ),
//               ],
//             ));
//   }
//
//   Future _showReservation() {
//     return showDialog(
//         context: context,
//         builder: (BuildContext context) => Dialog(
//               child: FutureBuilder(
//                 future: _getReservationDetails(),
//                 builder:
//                     (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//                   if (!snapshot.hasData) {
//                     return Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SizedBox(
//                           height: 10,
//                         ),
//                         new Text(
//                           'My Digital Twin',
//                           style: TextStyle(
//                               fontSize: 20.0, fontWeight: FontWeight.bold),
//                           textAlign: TextAlign.center,
//                         ),
//                         new Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             SizedBox(
//                               height: 10,
//                             ),
//                             new CircularProgressIndicator(),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             new Text("Loading"),
//                             SizedBox(
//                               height: 10,
//                             ),
//                           ],
//                         ),
//                       ],
//                     );
//                   }
//                   return Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SizedBox(
//                         height: 10,
//                       ),
//                       new Text(
//                         'My Digital Twin',
//                         style: TextStyle(
//                             fontSize: 20.0, fontWeight: FontWeight.bold),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: new Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             new Text('Reserved for:',
//                                 style: TextStyle(fontWeight: FontWeight.bold)),
//                             new Text(snapshot.data['double_name'])
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: new Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             new Text('Product Key:',
//                                 style: TextStyle(fontWeight: FontWeight.bold)),
//                             new Text(snapshot.data['key'])
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: new Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             new Text('Status:',
//                                 style: TextStyle(fontWeight: FontWeight.bold)),
//                             new Text('Activated',
//                                 style: TextStyle(
//                                     color: Colors.green,
//                                     fontWeight: FontWeight.bold))
//                           ],
//                         ),
//                       ),
//                       new ElevatedButton(
//                           onPressed: () {
//                             Navigator.pop(context, true);
//                           },
//                           child: Text('OK')),
//                       SizedBox(
//                         height: 10,
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ));
//   }
//
//   Widget _card({String title, Widget body}) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(5),
//         boxShadow: [
//           BoxShadow(
//               offset: Offset(1, 2),
//               blurRadius: 2.0,
//               spreadRadius: 0.0,
//               color: Colors.grey.shade300),
//         ],
//       ),
//       child: Container(
//         padding: EdgeInsets.all(25.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             body,
//           ],
//         ),
//       ),
//     );
//   }
// }
