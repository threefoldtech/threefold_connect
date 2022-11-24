import 'dart:typed_data';

Uint8List toHex(String input) {
  double length = input.length / 2;
  Uint8List bytes = new Uint8List(length.ceil());

  for (int i = 0; i < bytes.length; i++) {
    String x = input.substring(i * 2, i * 2 + 2);
    bytes[i] = int.parse(x, radix: 16);
  }

  return bytes;
}
