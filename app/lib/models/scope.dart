class Scope {
  bool doubleName;
  bool user;
  bool email;
  bool derivedSeed;
  bool phone;

  Scope({this.doubleName, this.email});

  Scope.fromJson(Map<String, dynamic> json)
      : doubleName = json['doubleName'] as bool,
        user = json['user'] as bool,
        email = json['email'] as bool,
        derivedSeed = json['derivedSeed'] as bool,
        phone = json['phone'] as bool;

  Map<String, dynamic> toJson() => {
        'doubleName': doubleName,
        'email': email,
        'derivedSeed': derivedSeed,
        'phone': phone
      };
}
