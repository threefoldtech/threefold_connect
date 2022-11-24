import 'package:threebotlogin/api/3bot/services/user.service.dart';

bool isValidUsername(String value) {
  Pattern pattern = r'^[a-zA-Z0-9]+$';
  RegExp regex = new RegExp(pattern.toString());

  if (!regex.hasMatch(value)) {
    return false;
  }

  return true;
}

bool validateMnemonicWords(String seed, String confirmationWords) {
  List<String> words = confirmationWords.split(" ");
  List<String> seedWords = seed.split(" ");

  if (words.length != 3) return false;

  for (final String word in words) {
    if (!seedWords.contains(word)) {
      return false;
    }
  }

  return true;
}

Future<Map<String, dynamic>> validateUsername(String username) async {
  if (username == '') {
    return {'valid': false, 'reason': 'Please choose a name.'};
  }

  bool validUsername = isValidUsername(username);
  if (!validUsername) {
    return {'valid': false, 'reason': 'Please enter a valid name.'};
  }

  bool doesUserExist = await doesUserExistInBackend(username + '.3bot');
  if (doesUserExist) {
    return {'valid': false, 'reason': 'Sorry, this name is already in use.'};
  }

  return {'valid': true};
}
