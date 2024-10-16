class Token {
  const Token({
    required this.message,
    required this.authToken,
    required this.scanRef,
    required this.clientId,
    required this.expiryTime,
    required this.sessionLength,
    required this.digitString,
    required this.tokenType,
  });

  final String message;
  final String authToken;
  final String scanRef;
  final String clientId;
  final int expiryTime;
  final int sessionLength;
  final String digitString;
  final String tokenType;

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
        message: json['message'],
        authToken: json['authToken'],
        scanRef: json['scanRef'],
        clientId: json['clientId'],
        expiryTime: json['expiryTime'],
        sessionLength: json['sessionLength'],
        digitString: json['digitString'],
        tokenType: json['tokenType']);
  }
}

class VerificationStatus {
  const VerificationStatus({
    required this.fraudTags,
    required this.mismatchTags,
    required this.autoDocument,
    required this.autoFace,
    required this.manualDocument,
    required this.manualFace,
    required this.scanRef,
    required this.clientId,
    required this.status,
  });
  final List<String> fraudTags;
  final List<String> mismatchTags;
  final String autoDocument;
  final String autoFace;
  final String manualDocument;
  final String manualFace;
  final String scanRef;
  final String clientId;
  final String status;

  factory VerificationStatus.fromJson(Map<String, dynamic> json) {
    return VerificationStatus(
        fraudTags: json['fraudTags'],
        mismatchTags: json['mismatchTags'],
        autoDocument: json['autoDocument'],
        autoFace: json['autoFace'],
        manualDocument: json['manualDocument'],
        manualFace: json['manualFace'],
        scanRef: json['scanRef'],
        clientId: json['clientId'],
        status: json['status']);
  }
}

class VerificationData {
  const VerificationData({
    required this.docFirstName,
    required this.docLastName,
    required this.docNumber,
    required this.docPersonalCode,
    required this.docExpiry,
    required this.docDob,
    required this.docDateOfIssue,
    required this.docType,
    required this.docSex,
    required this.docNationality,
    required this.docIssuingCountry,
    required this.docTemporaryAddress,
    required this.docBirthName,
    required this.birthPlace,
    required this.authority,
    required this.address,
    required this.mothersMaidenName,
    required this.driverLicenseCategory,
    required this.manuallyDataChanged,
    required this.fullName,
    required this.orgFirstName,
    required this.orgLastName,
    required this.orgNationality,
    required this.orgBirthPlace,
    required this.orgAuthority,
    required this.orgAddress,
    required this.orgTemporaryAddress,
    required this.orgMothersMaidenName,
    required this.orgBirthName,
    required this.selectedCountry,
    required this.ageEstimate,
    required this.clientIpProxyRiskLevel,
    required this.duplicateFaces,
    required this.duplicateDocFaces,
    required this.addressVerification,
    required this.additionalData,
    required this.scanRef,
    required this.clientId,
  });

  final String docFirstName;
  final String docLastName;
  final String docNumber;
  final String docPersonalCode;
  final String docExpiry;
  final String docDob;
  final String docDateOfIssue;
  final String docType;
  final String docSex;
  final String docNationality;
  final String docIssuingCountry;
  final String docTemporaryAddress;
  final String docBirthName;
  final String birthPlace;
  final String authority;
  final String address;
  final String mothersMaidenName;
  final String driverLicenseCategory;
  final bool manuallyDataChanged;
  final String fullName;
  final String orgFirstName;
  final String orgLastName;
  final String orgNationality;
  final String orgBirthPlace;
  final String orgAuthority;
  final String orgAddress;
  final String orgTemporaryAddress;
  final String orgMothersMaidenName;
  final String orgBirthName;
  final String selectedCountry;
  final String ageEstimate;
  final String clientIpProxyRiskLevel;
  final List<String> duplicateFaces;
  final List<String> duplicateDocFaces;
  final dynamic addressVerification;
  final dynamic additionalData;
  final String scanRef;
  final String clientId;

  factory VerificationData.fromJson(Map<String, dynamic> json) {
    return VerificationData(
        docFirstName: json['docFirstName'],
        docLastName: json['docLastName'],
        docNumber: json['docNumber'],
        docPersonalCode: json['docPersonalCode'],
        docExpiry: json['docExpiry'],
        docDob: json['docDob'],
        docDateOfIssue: json['docDateOfIssue'],
        docType: json['docType'],
        docSex: json['docSex'],
        docNationality: json['docNationality'],
        docIssuingCountry: json['docIssuingCountry'],
        docTemporaryAddress: json['docTemporaryAddress'],
        docBirthName: json['docBirthName'],
        birthPlace: json['birthPlace'],
        authority: json['authority'],
        address: json['address'],
        mothersMaidenName: json['mothersMaidenName'],
        driverLicenseCategory: json['driverLicenseCategory'],
        manuallyDataChanged: json['manuallyDataChanged'],
        fullName: json['fullName'],
        orgFirstName: json['orgFirstName'],
        orgLastName: json['orgLastName'],
        orgNationality: json['orgNationality'],
        orgBirthPlace: json['orgBirthPlace'],
        orgAuthority: json['orgAuthority'],
        orgAddress: json['orgAddress'],
        orgTemporaryAddress: json['orgTemporaryAddress'],
        orgMothersMaidenName: json['orgMothersMaidenName'],
        orgBirthName: json['orgBirthName'],
        selectedCountry: json['selectedCountry'],
        ageEstimate: json['ageEstimate'],
        clientIpProxyRiskLevel: json['clientIpProxyRiskLevel'],
        duplicateFaces: json['duplicateFaces'],
        duplicateDocFaces: json['duplicateDocFaces'],
        addressVerification: json['addressVerification'],
        additionalData: json['additionalData'],
        scanRef: json['scanRef'],
        clientId: json['clientId']);
  }
}
