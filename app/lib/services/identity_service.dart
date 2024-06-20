String getFullNameOfObject(Map<String, dynamic> identityName) {
  String firstName = identityName['first_name'] ?? '';
  String middleName = identityName['middle_name'] ?? '';
  String lastName = identityName['last_name'] ?? '';
  String fullName = identityName['full_name'] ?? '';

  return fullName != '' ? fullName : '$firstName $middleName $lastName';
}

String getCorrectState(
    int step, emailVerified, phoneVerified, identityVerified) {
  if (step == 1) {
    if (!emailVerified) {
      return 'CurrentPhase';
    }
    return 'Verified';
  }

  if (step == 2) {
    if (!emailVerified && !phoneVerified) {
      return 'Unverified';
    }
    if (emailVerified && !phoneVerified) {
      return 'CurrentPhase';
    }

    return 'Verified';
  }

  if (step == 3) {
    if (identityVerified) {
      return 'Verified';
    }

    if (!emailVerified) {
      return 'Unverified';
    }

    if (!phoneVerified) {
      return 'Unverified';
    }

    if (emailVerified && phoneVerified && !identityVerified) {
      return 'CurrentPhase';
    }
  }

  return '';
}
