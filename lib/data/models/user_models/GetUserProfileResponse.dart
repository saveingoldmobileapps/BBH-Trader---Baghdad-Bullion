class GetUserProfileResponse {
  String? status;
  num? code;
  String? message;
  Payload? payload;

  GetUserProfileResponse({
    this.status,
    this.code,
    this.message,
    this.payload,
  });

  GetUserProfileResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];
    payload =
        json['payload'] != null ? Payload.fromJson(json['payload']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['code'] = code;
    data['message'] = message;
    if (payload != null) {
      data['payload'] = payload!.toJson();
    }
    return data;
  }
}

class Payload {
  UserProfile? userProfile;

  Payload({this.userProfile});

  Payload.fromJson(Map<String, dynamic> json) {
    userProfile = json['userProfile'] != null
        ? UserProfile.fromJson(json['userProfile'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (userProfile != null) {
      data['userProfile'] = userProfile!.toJson();
    }
    return data;
  }
}

class UserProfile {
  String? id;
  String? accountId;
  String? userType;
  LocalizedField? firstName;
  LocalizedField? surname;
  String? dateOfBirthday;
  String? email;
  String? phoneNumber;
  LocalizedField? countryOfResidence;
  LocalizedField? nationality;
  String? imageUrl;
  String? timezone;
  bool? isPhoneVerified;
  bool? isEmailVerified;
  bool? isUserKYCVerified;
  num? moneyBalance;
  num? metalBalance;
  String? createdAt;
  String? updatedAt;
  String? leanCustomerId;
  String? personalInfoUpdateStatus;
  String? language;
  String? dialCode;
  String? isoCode;
  UserCustomKYCData? userCustomKYCData;

  UserProfile({
    this.id,
    this.accountId,
    this.userType,
    this.firstName,
    this.surname,
    this.dateOfBirthday,
    this.email,
    this.phoneNumber,
    this.countryOfResidence,
    this.nationality,
    this.imageUrl,
    this.timezone,
    this.isPhoneVerified,
    this.isEmailVerified,
    this.isUserKYCVerified,
    this.moneyBalance,
    this.metalBalance,
    this.createdAt,
    this.updatedAt,
    this.leanCustomerId,
    this.personalInfoUpdateStatus,
    this.language,
    this.userCustomKYCData,
    this.dialCode,
    this.isoCode,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    accountId = json['accountId'];
    userType = json['userType'];
    firstName = json['firstName'] != null
        ? LocalizedField.fromJson(json['firstName'])
        : null;
    surname = json['surname'] != null
        ? LocalizedField.fromJson(json['surname'])
        : null;
    dateOfBirthday = json['dateOfBirthday'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    countryOfResidence = json['countryOfResidence'] != null
        ? LocalizedField.fromJson(json['countryOfResidence'])
        : null;
    nationality = json['nationality'] != null
        ? LocalizedField.fromJson(json['nationality'])
        : null;
    imageUrl = json['imageUrl'];
    timezone = json['timezone'];
    isPhoneVerified = json['isPhoneVerified'];
    isEmailVerified = json['isEmailVerified'];
    isUserKYCVerified = json['isUserKYCVerified'];
    moneyBalance = json['moneyBalance'];
    metalBalance = json['metalBalance'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    leanCustomerId = json['leanCustomerId'];
    personalInfoUpdateStatus = json['personalInfoUpdateStatus'];
    language = json['language'];
    dialCode = json['dialCode'];
    isoCode = json['isoCode'];
    userCustomKYCData = json['userCustomKYCData'] != null
        ? UserCustomKYCData.fromJson(json['userCustomKYCData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['accountId'] = accountId;
    data['userType'] = userType;
    if (firstName != null) {
      data['firstName'] = firstName!.toJson();
    }
    if (surname != null) {
      data['surname'] = surname!.toJson();
    }
    data['dateOfBirthday'] = dateOfBirthday;
    data['email'] = email;
    data['phoneNumber'] = phoneNumber;
    if (countryOfResidence != null) {
      data['countryOfResidence'] = countryOfResidence!.toJson();
    }
    if (nationality != null) {
      data['nationality'] = nationality!.toJson();
    }
    data['imageUrl'] = imageUrl;
    data['timezone'] = timezone;
    data['isPhoneVerified'] = isPhoneVerified;
    data['isEmailVerified'] = isEmailVerified;
    data['isUserKYCVerified'] = isUserKYCVerified;
    data['moneyBalance'] = moneyBalance;
    data['metalBalance'] = metalBalance;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['leanCustomerId'] = leanCustomerId;
    data['personalInfoUpdateStatus'] = personalInfoUpdateStatus;
    data['language'] = language;
    if (userCustomKYCData != null) {
      data['userCustomKYCData'] = userCustomKYCData!.toJson();
    }
    return data;
  }
}

class LocalizedField {
  String? en;
  String? ar;

  LocalizedField({this.en, this.ar});

  LocalizedField.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ar = json['ar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['en'] = en;
    data['ar'] = ar;
    return data;
  }
}

class UserCustomKYCData {
  String? id;
  String? userId;
  String? employmentStatus;
  String? companyName;
  String? salaryRange;
  String? documentOfCountry;
  String? documentType;
  List<String>? documentImages;
  String? userImage;
  bool? isFirstNameMatched;
  bool? isSurNameMatched;
  bool? isDOBMatched;
  bool? isNationalityMatched;
  bool? isResidencyMatched;
  bool? isDocumentsValid;
  bool? isUserImageMatched;
  String? adminVerificationStatus;
  String? adminRemarks;
  String? createdAt;
  String? updatedAt;
  num? v;

  UserCustomKYCData({
    this.id,
    this.userId,
    this.employmentStatus,
    this.companyName,
    this.salaryRange,
    this.documentOfCountry,
    this.documentType,
    this.documentImages,
    this.userImage,
    this.isFirstNameMatched,
    this.isSurNameMatched,
    this.isDOBMatched,
    this.isNationalityMatched,
    this.isResidencyMatched,
    this.isDocumentsValid,
    this.isUserImageMatched,
    this.adminVerificationStatus,
    this.adminRemarks,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  UserCustomKYCData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    userId = json['userId'];
    employmentStatus = json['employmentStatus'];
    companyName = json['companyName'];
    salaryRange = json['salaryRange'];
    documentOfCountry = json['documentOfCountry'];
    documentType = json['documentType'];
    documentImages = json['documentImages'] != null
        ? List<String>.from(json['documentImages'])
        : [];
    userImage = json['userImage'];
    isFirstNameMatched = json['isFirstNameMatched'];
    isSurNameMatched = json['isSurNameMatched'];
    isDOBMatched = json['isDOBMatched'];
    isNationalityMatched = json['isNationalityMatched'];
    isResidencyMatched = json['isResidencyMatched'];
    isDocumentsValid = json['isDocumentsValid'];
    isUserImageMatched = json['isUserImageMatched'];
    adminVerificationStatus = json['adminVerificationStatus'];
    adminRemarks = json['adminRemarks'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = id;
    data['userId'] = userId;
    data['employmentStatus'] = employmentStatus;
    data['companyName'] = companyName;
    data['salaryRange'] = salaryRange;
    data['documentOfCountry'] = documentOfCountry;
    data['documentType'] = documentType;
    data['documentImages'] = documentImages;
    data['userImage'] = userImage;
    data['isFirstNameMatched'] = isFirstNameMatched;
    data['isSurNameMatched'] = isSurNameMatched;
    data['isDOBMatched'] = isDOBMatched;
    data['isNationalityMatched'] = isNationalityMatched;
    data['isResidencyMatched'] = isResidencyMatched;
    data['isDocumentsValid'] = isDocumentsValid;
    data['isUserImageMatched'] = isUserImageMatched;
    data['adminVerificationStatus'] = adminVerificationStatus;
    data['adminRemarks'] = adminRemarks;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = v;
    return data;
  }
}





// class GetUserProfileResponse {
//   String? status;
//   num? code;
//   String? message;
//   Payload? payload;

//   GetUserProfileResponse({
//     this.status,
//     this.code,
//     this.message,
//     this.payload,
//   });

//   GetUserProfileResponse.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     code = json['code'];
//     message = json['message'];
//     payload =
//         json['payload'] != null ? Payload.fromJson(json['payload']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['status'] = status;
//     data['code'] = code;
//     data['message'] = message;
//     if (payload != null) {
//       data['payload'] = payload!.toJson();
//     }
//     return data;
//   }
// }

// class Payload {
//   UserProfile? userProfile;

//   Payload({this.userProfile});

//   Payload.fromJson(Map<String, dynamic> json) {
//     userProfile = json['userProfile'] != null
//         ? UserProfile.fromJson(json['userProfile'])
//         : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     if (userProfile != null) {
//       data['userProfile'] = userProfile!.toJson();
//     }
//     return data;
//   }
// }

// class UserProfile {
//   String? id;
//   String? accountId;
//   String? userType;
//   String? firstName;
//   String? surname;
//   String? dateOfBirthday;
//   String? email;
//   String? phoneNumber;
//   String? countryOfResidence;
//   String? nationality;
//   String? imageUrl;
//   String? timezone;
//   bool? isPhoneVerified;
//   bool? isEmailVerified;
//   bool? isUserKYCVerified;
//   num? moneyBalance;
//   num? metalBalance;
//   String? createdAt;
//   String? updatedAt;
//   String? leanCustomerId;
//   String? personalInfoUpdateStatus;
//   String? language;
//   UserCustomKYCData? userCustomKYCData;

//   UserProfile({
//     this.id,
//     this.accountId,
//     this.userType,
//     this.firstName,
//     this.surname,
//     this.dateOfBirthday,
//     this.email,
//     this.phoneNumber,
//     this.countryOfResidence,
//     this.nationality,
//     this.imageUrl,
//     this.timezone,
//     this.isPhoneVerified,
//     this.isEmailVerified,
//     this.isUserKYCVerified,
//     this.moneyBalance,
//     this.metalBalance,
//     this.createdAt,
//     this.updatedAt,
//     this.leanCustomerId,
//     this.personalInfoUpdateStatus,
//     this.language,
//     this.userCustomKYCData,
//   });

//   UserProfile.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     accountId = json['accountId'];
//     userType = json['userType'];
//     firstName = json['firstName'];
//     surname = json['surname'];
//     dateOfBirthday = json['dateOfBirthday'];
//     email = json['email'];
//     phoneNumber = json['phoneNumber'];
//     countryOfResidence = json['countryOfResidence'];
//     nationality = json['nationality'];
//     imageUrl = json['imageUrl'];
//     timezone = json['timezone'];
//     isPhoneVerified = json['isPhoneVerified'];
//     isEmailVerified = json['isEmailVerified'];
//     isUserKYCVerified = json['isUserKYCVerified'];
//     moneyBalance = json['moneyBalance'];
//     metalBalance = json['metalBalance'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     leanCustomerId = json['leanCustomerId'];
//     personalInfoUpdateStatus = json['personalInfoUpdateStatus'];
//     language = json['language'];
//     userCustomKYCData = json['userCustomKYCData'] != null
//         ? UserCustomKYCData.fromJson(json['userCustomKYCData'])
//         : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['id'] = id;
//     data['accountId'] = accountId;
//     data['userType'] = userType;
//     data['firstName'] = firstName;
//     data['surname'] = surname;
//     data['dateOfBirthday'] = dateOfBirthday;
//     data['email'] = email;
//     data['phoneNumber'] = phoneNumber;
//     data['countryOfResidence'] = countryOfResidence;
//     data['nationality'] = nationality;
//     data['imageUrl'] = imageUrl;
//     data['timezone'] = timezone;
//     data['isPhoneVerified'] = isPhoneVerified;
//     data['isEmailVerified'] = isEmailVerified;
//     data['isUserKYCVerified'] = isUserKYCVerified;
//     data['moneyBalance'] = moneyBalance;
//     data['metalBalance'] = metalBalance;
//     data['createdAt'] = createdAt;
//     data['updatedAt'] = updatedAt;
//     data['leanCustomerId'] = leanCustomerId;
//     data['personalInfoUpdateStatus'] = personalInfoUpdateStatus;
//     data['language'] = language;
//     if (userCustomKYCData != null) {
//       data['userCustomKYCData'] = userCustomKYCData!.toJson();
//     }
//     return data;
//   }
// }

// class UserCustomKYCData {
//   String? id;
//   String? userId;
//   String? employmentStatus;
//   String? companyName;
//   String? salaryRange;
//   String? documentOfCountry;
//   String? documentType;
//   List<String>? documentImages;
//   String? userImage;
//   bool? isFirstNameMatched;
//   bool? isSurNameMatched;
//   bool? isDOBMatched;
//   bool? isNationalityMatched;
//   bool? isResidencyMatched;
//   bool? isDocumentsValid;
//   bool? isUserImageMatched;
//   String? adminVerificationStatus;
//   String? adminRemarks;
//   String? createdAt;
//   String? updatedAt;
//   num? v;

//   UserCustomKYCData({
//     this.id,
//     this.userId,
//     this.employmentStatus,
//     this.companyName,
//     this.salaryRange,
//     this.documentOfCountry,
//     this.documentType,
//     this.documentImages,
//     this.userImage,
//     this.isFirstNameMatched,
//     this.isSurNameMatched,
//     this.isDOBMatched,
//     this.isNationalityMatched,
//     this.isResidencyMatched,
//     this.isDocumentsValid,
//     this.isUserImageMatched,
//     this.adminVerificationStatus,
//     this.adminRemarks,
//     this.createdAt,
//     this.updatedAt,
//     this.v,
//   });

//   UserCustomKYCData.fromJson(Map<String, dynamic> json) {
//     id = json['_id'];
//     userId = json['userId'];
//     employmentStatus = json['employmentStatus'];
//     companyName = json['companyName'];
//     salaryRange = json['salaryRange'];
//     documentOfCountry = json['documentOfCountry'];
//     documentType = json['documentType'];
//     documentImages = json['documentImages'] != null
//         ? List<String>.from(json['documentImages'])
//         : [];
//     userImage = json['userImage'];
//     isFirstNameMatched = json['isFirstNameMatched'];
//     isSurNameMatched = json['isSurNameMatched'];
//     isDOBMatched = json['isDOBMatched'];
//     isNationalityMatched = json['isNationalityMatched'];
//     isResidencyMatched = json['isResidencyMatched'];
//     isDocumentsValid = json['isDocumentsValid'];
//     isUserImageMatched = json['isUserImageMatched'];
//     adminVerificationStatus = json['adminVerificationStatus'];
//     adminRemarks = json['adminRemarks'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     v = json['__v'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['_id'] = id;
//     data['userId'] = userId;
//     data['employmentStatus'] = employmentStatus;
//     data['companyName'] = companyName;
//     data['salaryRange'] = salaryRange;
//     data['documentOfCountry'] = documentOfCountry;
//     data['documentType'] = documentType;
//     data['documentImages'] = documentImages;
//     data['userImage'] = userImage;
//     data['isFirstNameMatched'] = isFirstNameMatched;
//     data['isSurNameMatched'] = isSurNameMatched;
//     data['isDOBMatched'] = isDOBMatched;
//     data['isNationalityMatched'] = isNationalityMatched;
//     data['isResidencyMatched'] = isResidencyMatched;
//     data['isDocumentsValid'] = isDocumentsValid;
//     data['isUserImageMatched'] = isUserImageMatched;
//     data['adminVerificationStatus'] = adminVerificationStatus;
//     data['adminRemarks'] = adminRemarks;
//     data['createdAt'] = createdAt;
//     data['updatedAt'] = updatedAt;
//     data['__v'] = v;
//     return data;
//   }
// }

