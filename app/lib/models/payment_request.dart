import 'dart:convert';

class PaymentRequest {
  String address;
  double amount;
  String message;

  PaymentRequest(this.address, this.amount, this.message);

  PaymentRequest.fromJson(Map<String, dynamic> json)
      : address = json['address'] as String,
        amount = json['amount'] as double,
        message = json['message'] as String;

  Map<String, dynamic> toJson() => {
        'address': address,
        'amount': amount,
        'message': message,
      };

  @override
  String toString() {
    var encodedAmount = base64Encode(utf8.encode(amount.toString()));
    var encodedMessage = base64Encode(utf8.encode(message));
    var encodedAddress = base64Encode(utf8.encode(address));
    return '{"encodedAddress": "$encodedAddress", "encodedAmount": "$encodedAmount", "encodedMessage": "$encodedMessage"}';
  }
}
