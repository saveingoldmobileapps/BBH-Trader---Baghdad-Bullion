import 'package:flutter/material.dart';

import '../../presentation/screens/auth_screens/al_taif_bank_kyc/native/bbh_onboarding_form.dart';
import 'bbh_phone_number_util.dart';

/// Builds the final backend JSON from all onboarding steps.
class BbhOnboardingSubmissionBuilder {
  BbhOnboardingSubmissionBuilder._();

  static Map<String, dynamic> build({
    required BbhOnboardingForm form,
    required String kycReference,
    required DateTime submittedAt,
    Map<String, dynamic>? ipassBundle,
    String? signatureImageUrl,
  }) {
    String t(String? value) => value?.trim() ?? '';
    String tc(TextEditingController c) => c.text.trim();
    String englishOrArabic(TextEditingController en, TextEditingController ar) {
      final english = en.text.trim();
      if (english.isNotEmpty) return english;
      return ar.text.trim();
    }

    String joinAddress() {
      final parts = [
        tc(form.addrGov),
        tc(form.addrDistrict),
        tc(form.addrCity),
        tc(form.addrMahalla),
        tc(form.addrStreet),
        tc(form.addrHouse),
      ].where((p) => p.isNotEmpty).toList();
      return parts.join(', ');
    }

    String pepDetails() {
      if (form.pep != 'Yes') return '';
      final parts = [
        if (tc(form.pepPosition).isNotEmpty) 'Position: ${tc(form.pepPosition)}',
        if (tc(form.pepCountry).isNotEmpty) 'Country: ${tc(form.pepCountry)}',
        if (tc(form.pepFrom).isNotEmpty) 'From: ${tc(form.pepFrom)}',
        if (tc(form.pepTo).isNotEmpty) 'To: ${tc(form.pepTo)}',
      ];
      return parts.join(' | ');
    }

    final isFatca = form.fatca == 'Yes';
    final isPep = form.pep == 'Yes';
    final hasForeignRes = form.foreignRes == 'Yes';
    final hasForeignCit = form.foreignCit == 'Yes';
    final hasAccount = form.hasAccount == 'Yes';

    // National ID English first/last are not collected in UI — use passport
    // English names for those fields in the final payload.
    final nationalIdFirstName = !form.noPassport && tc(form.enFirst).isNotEmpty
        ? tc(form.enFirst)
        : englishOrArabic(form.idEnFirst, form.arFirst);
    final nationalIdLastName =
        !form.noPassport && tc(form.enSurname).isNotEmpty
            ? tc(form.enSurname)
            : englishOrArabic(form.idEnSurname, form.arSurname);

    return {
      'submissionMeta': {
        'kycReference': kycReference,
        'submittedAt': submittedAt.toUtc().toIso8601String(),
        'flow': 'bbh_native_onboarding',
        'version': '2.0',
      },
      'nationalIdDetails': {
        'idNumber': tc(form.idPersonal),
        'serialNumber': tc(form.idSerial),
        'firstName': nationalIdFirstName,
        'fatherName': englishOrArabic(form.idEnFather, form.arFather),
        'grandfatherName': englishOrArabic(form.idEnGf, form.arGf),
        'lastName': nationalIdLastName,
        'mothersName': tc(form.arMother),
        'firstNameArabic': tc(form.arFirst),
        'fatherNameArabic': tc(form.arFather),
        'grandfatherNameArabic': tc(form.arGf),
        'lastNameArabic': tc(form.arSurname),
        'mothersNameArabic': tc(form.arMother),
        if (tc(form.arSurnameAndGivenNames).isNotEmpty)
          'surnameAndGivenNamesAr': tc(form.arSurnameAndGivenNames),
        'mothersNameEnglish': englishOrArabic(form.idEnMother, form.arMother),
        'dateOfBirth': tc(form.dob),
        'nationality': tc(form.nationality),
        'gender': t(form.gender),
        'countryOfBirth': tc(form.countryBirth),
        'placeOfBirth': tc(form.placeBirth),
        'issuePlace': tc(form.idIssuePlace),
        'issueDate': tc(form.idIssueDate),
        'expiryDate': tc(form.idExpiryDate),
      },
      'residencyDetails': {
        'residencyNumber': tc(form.resNo),
        'issueDate': tc(form.resIssue),
        'expiryDate': tc(form.resExpiry),
        'country': tc(form.resPlace).isNotEmpty ? tc(form.resPlace) : 'Iraq',
        'issuePlace': tc(form.resPlace),
      },
      'passportDetails': {
        'hasPassport': !form.noPassport,
        'passportNumber': form.noPassport ? '' : tc(form.ppNo),
        'issueDate': form.noPassport ? '' : tc(form.ppIssue),
        'expiryDate': form.noPassport ? '' : tc(form.ppExpiry),
        'countryOfIssue': form.noPassport ? '' : tc(form.ppPlace),
        'firstName': form.noPassport ? '' : tc(form.enFirst),
        'lastName': form.noPassport ? '' : tc(form.enSurname),
        'grandfatherName': form.noPassport ? '' : tc(form.enGf),
        'mothersNameEnglish': form.noPassport ? '' : tc(form.enMother),
      },
      'iraqAddressDetails': {
        'governorate': tc(form.addrGov),
        'district': tc(form.addrDistrict),
        'city': tc(form.addrCity),
        'mahalla': tc(form.addrMahalla),
        'street': tc(form.addrStreet),
        'houseNumber': tc(form.addrHouse),
        'landmarkArabic': tc(form.addrLandmarkAr),
        'landmarkEnglish': tc(form.addrLandmarkEn),
        'fullAddress': joinAddress(),
      },
      'additionalResidence': {
        'hasForeignResidencyPermission': hasForeignRes,
        'country': hasForeignRes ? tc(form.foreignResCountry) : '',
        'residencyPermitCaptured': form.foreignResCaptured,
        'hasForeignCitizenship': hasForeignCit,
        'foreignCitizenshipCountry': hasForeignCit ? tc(form.foreignCitCountry) : '',
        'foreignPassportCaptured': form.foreignCitCaptured,
        'address': isFatca ? tc(form.fatcaAddr) : '',
        'taxResidence': hasForeignRes || isFatca,
      },
      'personalQuestionnaire': {
        'gender': t(form.gender),
        'employmentStatus': tc(form.occupation),
        'maritalStatus': '',
        'educationLevel': t(form.education),
        'economicSector': t(form.sector),
      },
      'sourceOfIncome': {
        'incomeSource': t(form.sector),
        'annualIncome': tc(form.income),
        'occupation': tc(form.occupation),
        'employer': tc(form.employer),
        'employerAddress': tc(form.employerAddr),
      },
      'fatcaDeclaration': {
        'isUsPerson': isFatca,
        'isUsCitizen': isFatca,
        'hasUsTaxObligation': isFatca,
        'tin': isFatca ? tc(form.fatcaTin) : '',
        'usAddress': isFatca ? tc(form.fatcaAddr) : '',
      },
      'pepDeclaration': {
        'isPep': isPep,
        'position': isPep ? tc(form.pepPosition) : '',
        'country': isPep ? tc(form.pepCountry) : '',
        'fromDate': isPep ? tc(form.pepFrom) : '',
        'toDate': isPep ? tc(form.pepTo) : '',
        'pepDetails': pepDetails(),
      },
      'contactInformation': {
        'email': tc(form.email),
        'mobile': BbhPhoneNumberUtil.toApiFormat(tc(form.mobile)),
        'emailVerified': form.verifiedEmail.value,
        'mobileVerified': form.verifiedMobile.value,
        'address': joinAddress(),
      },
      'custodianInformation': {
        'hasExistingAccount': hasAccount,
        'accountNumber': hasAccount ? tc(form.iban) : '',
        'iban': hasAccount ? tc(form.iban) : '',
        'custodianName': t(form.custodian),
      },
      'userConsent': {
        'purposeConfirmed': form.purposeConfirmed,
        'acceptedTerms': form.purposeConfirmed,
        'acceptedPrivacyPolicy': form.consentConfirmed,
        'consentDate': submittedAt.toUtc().toIso8601String(),
      },
      'signature': {
        'signerName': _signerName(form, englishOrArabic, tc),
        'signatureImage': signatureImageUrl?.trim() ?? '',
      },
      'documentCaptureStatus': {
        'nationalIdFront': form.idFrontCaptured,
        'nationalIdBack': form.idBackCaptured,
        'residenceFormFront': form.resFrontCaptured,
        'residenceFormBack': form.resBackCaptured,
        'passport': form.noPassport ? false : form.passportCaptured,
        'foreignResidencyPermit': form.foreignResCaptured,
        'foreignCitizenshipPassport': form.foreignCitCaptured,
      },
      'verificationStatus': {
        'verifiedFields': form.verifiedFields.toList(),
        'emailVerified': form.verifiedEmail.value,
        'mobileVerified': form.verifiedMobile.value,
      },
      'ipassVerificationData': ipassBundle ?? <String, dynamic>{},
    };
  }

  static String _signerName(
    BbhOnboardingForm form,
    String Function(TextEditingController, TextEditingController) englishOrArabic,
    String Function(TextEditingController) tc,
  ) {
    final entered = tc(form.signerName);
    if (entered.isNotEmpty) return entered;
    return form.nationalIdArabicFullName;
  }
}
