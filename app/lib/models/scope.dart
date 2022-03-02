class Scope {
  bool? doubleName;
  bool? user;
  bool? email;
  bool? derivedSeed;
  bool? phone;
  bool? digitalTwin;
  bool? identityName;
  bool? identityDOB;
  bool? identityGender;
  bool? identityDocumentMeta;
  bool? identityCountry;
  bool? walletAddress;
  String? walletAddressData;

  Scope({this.doubleName, this.email});

  Scope.fromJson(Map<String, dynamic> json)
      : doubleName = json['doubleName'] as bool?,
        user = json['user'] as bool?,
        email = json['email'] as bool?,
        derivedSeed = json['derivedSeed'] as bool?,
        digitalTwin = json['digitalTwin'] as bool?,
        phone = json['phone'] as bool?,
        identityName = json['identityName'] as bool?,
        identityDOB = json['identityDOB'] as bool?,
        identityGender = json['identityGender'] as bool?,
        identityDocumentMeta = json['identityDocumentMeta'] as bool?,
        identityCountry = json['identityCountry'] as bool?,
        walletAddress = json['walletAddress'] as bool?,
        walletAddressData = json['walletAddressData'] as String?;

  Map<String, dynamic> toJson() => {
        'doubleName': doubleName,
        'email': email,
        'derivedSeed': derivedSeed,
        'digitalTwin': digitalTwin,
        'phone': phone,
        'identityName': identityName,
        'identityDOB': identityDOB,
        'identityGender': identityGender,
        'identityDocumentMeta': identityDocumentMeta,
        'identityCountry': identityCountry,
        'walletAddress': walletAddress,
        'walletAddressData': walletAddressData,
      };
}
