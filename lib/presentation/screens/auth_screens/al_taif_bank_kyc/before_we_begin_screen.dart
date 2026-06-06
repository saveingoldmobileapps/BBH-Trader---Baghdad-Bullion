import 'dart:io' show Platform;

import 'package:baghdad_bullion_house/core/theme/const_toasts.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_kyc_service.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../auth_kyc_screens/kyc_second_step_screen.dart';

/// Al-Taif / BBH bank client onboarding — steps 1–12 (matches BBH digital pack prototype).
class BBHOnboardingScreen extends StatefulWidget {
  const BBHOnboardingScreen({super.key});

  @override
  State<BBHOnboardingScreen> createState() => _BBHOnboardingScreenState();
}

class _KycPalette {
  static const Color cream = Color(0xFFF6F0E2);
  static const Color creamMuted = Color(0xFFE6DED0);
  static const Color ink = Color(0xFF1C2638);
  static const Color inkSoft = Color(0xFF2C3A52);
  static const Color eyebrow = Color(0xFF9A7B3F);
  static const Color goldLine = Color(0xFFBFA46F);
  static const Color primaryBtn = Color(0xFF16243C);
}

class _KycFormData {
  bool purposeConfirmed = false;

  final TextEditingController mobile = TextEditingController();
  final TextEditingController email = TextEditingController();
  String? branch;

  final TextEditingController arFirst = TextEditingController();
  final TextEditingController arFather = TextEditingController();
  final TextEditingController arGf = TextEditingController();
  final TextEditingController arSurname = TextEditingController();
  final TextEditingController arMother = TextEditingController();

  final TextEditingController enFirst = TextEditingController();
  final TextEditingController enFather = TextEditingController();
  final TextEditingController enGf = TextEditingController();
  final TextEditingController enSurname = TextEditingController();

  String? gender;
  final TextEditingController nationality = TextEditingController(
    text: 'Iraqi',
  );
  final TextEditingController dob = TextEditingController();
  final TextEditingController countryBirth = TextEditingController(
    text: 'Iraq',
  );
  final TextEditingController placeBirth = TextEditingController();

  final TextEditingController idPersonal = TextEditingController();
  final TextEditingController idSerial = TextEditingController();
  final TextEditingController idIssuePlace = TextEditingController();
  final TextEditingController idIssueDate = TextEditingController();
  final TextEditingController idExpiryDate = TextEditingController();

  bool residenceNa = false;
  final TextEditingController resNo = TextEditingController();
  final TextEditingController resPlace = TextEditingController();
  final TextEditingController resIssue = TextEditingController();
  final TextEditingController resExpiry = TextEditingController();

  bool passportNa = false;
  final TextEditingController ppNo = TextEditingController();
  final TextEditingController ppPlace = TextEditingController();
  final TextEditingController ppIssue = TextEditingController();
  final TextEditingController ppExpiry = TextEditingController();

  String? education;
  String? sector;
  final TextEditingController income = TextEditingController();
  final TextEditingController occupation = TextEditingController();
  final TextEditingController employer = TextEditingController();
  final TextEditingController employerAddr = TextEditingController();

  final TextEditingController addrGov = TextEditingController();
  final TextEditingController addrDistrict = TextEditingController();
  final TextEditingController addrCity = TextEditingController();
  final TextEditingController addrMahalla = TextEditingController();
  final TextEditingController addrStreet = TextEditingController();
  final TextEditingController addrHouse = TextEditingController();
  final TextEditingController addrLandmarkAr = TextEditingController();
  final TextEditingController addrLandmarkEn = TextEditingController();

  String? fatca;
  final TextEditingController fatcaTin = TextEditingController();
  final TextEditingController fatcaAddr = TextEditingController();

  String? pep;
  final TextEditingController pepPosition = TextEditingController();
  final TextEditingController pepCountry = TextEditingController();
  final TextEditingController pepFrom = TextEditingController();
  final TextEditingController pepTo = TextEditingController();

  void dispose() {
    mobile.dispose();
    email.dispose();
    arFirst.dispose();
    arFather.dispose();
    arGf.dispose();
    arSurname.dispose();
    arMother.dispose();
    enFirst.dispose();
    enFather.dispose();
    enGf.dispose();
    enSurname.dispose();
    nationality.dispose();
    dob.dispose();
    countryBirth.dispose();
    placeBirth.dispose();
    idPersonal.dispose();
    idSerial.dispose();
    idIssuePlace.dispose();
    idIssueDate.dispose();
    idExpiryDate.dispose();
    resNo.dispose();
    resPlace.dispose();
    resIssue.dispose();
    resExpiry.dispose();
    ppNo.dispose();
    ppPlace.dispose();
    ppIssue.dispose();
    ppExpiry.dispose();
    income.dispose();
    occupation.dispose();
    employer.dispose();
    employerAddr.dispose();
    addrGov.dispose();
    addrDistrict.dispose();
    addrCity.dispose();
    addrMahalla.dispose();
    addrStreet.dispose();
    addrHouse.dispose();
    addrLandmarkAr.dispose();
    addrLandmarkEn.dispose();
    fatcaTin.dispose();
    fatcaAddr.dispose();
    pepPosition.dispose();
    pepCountry.dispose();
    pepFrom.dispose();
    pepTo.dispose();
  }

  void markResidenceNa() {
    residenceNa = true;
    resNo.clear();
    resPlace.clear();
    resIssue.clear();
    resExpiry.clear();
  }

  void markPassportNa() {
    passportNa = true;
    ppNo.clear();
    ppPlace.clear();
    ppIssue.clear();
    ppExpiry.clear();
  }
}

class _BBHOnboardingScreenState extends State<BBHOnboardingScreen> {
  static const int _totalSteps = 12;

  final PageController _pageController = PageController();
  final _form = _KycFormData();

  int _currentPage = 0;
  bool _ipassInProgress = false;
  IpassKycResult? _completedIpassResult;
  final Set<String> _ipassLockedFields = {};

  static const _branches = <String>[
    'Baghdad — Head Office (Al-Nahar)',
    'Baghdad — Mansour',
    'Baghdad — Al-Kadhimiya',
    'Baghdad — Zayona',
    'Najaf — Grand Bazaar',
  ];

  static const _educationLevels = <String>[
    'Primary',
    'Secondary',
    'Diploma',
    "Bachelor's",
    "Master's",
    'Doctorate',
    'Other',
  ];

  static const _sectors = <String>[
    'Trade — Gold & Bullion',
    'Trade — General',
    'Manufacturing',
    'Agriculture',
    'Construction',
    'Real Estate',
    'Financial Services',
    'Public Sector',
    'Healthcare',
    'Education',
    'Other Services',
    'Not Applicable',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _form.dispose();
    super.dispose();
  }

  bool _nonEmpty(String? s) => s != null && s.trim().isNotEmpty;

  bool _validate(int step) {
    switch (step) {
      case 0:
        if (!_form.purposeConfirmed) {
          _toast('Confirm that this section was read to the client.');
          return false;
        }
        return true;
      case 1:
        if (!_nonEmpty(_form.mobile.text) ||
            !_nonEmpty(_form.email.text) ||
            _form.branch == null) {
          _toast('Enter mobile, email, and branch.');
          return false;
        }
        return true;
      case 2:
        if (!_nonEmpty(_form.arFirst.text) ||
            !_nonEmpty(_form.arFather.text) ||
            !_nonEmpty(_form.arGf.text) ||
            !_nonEmpty(_form.arSurname.text) ||
            !_nonEmpty(_form.arMother.text)) {
          _toast('Complete all Arabic name fields.');
          return false;
        }
        return true;
      case 3:
        if (!_nonEmpty(_form.enFirst.text) ||
            !_nonEmpty(_form.enFather.text) ||
            !_nonEmpty(_form.enGf.text) ||
            !_nonEmpty(_form.enSurname.text)) {
          _toast('Complete all English name fields.');
          return false;
        }
        return true;
      case 4:
        if (_form.gender == null ||
            !_nonEmpty(_form.nationality.text) ||
            !_nonEmpty(_form.dob.text) ||
            !_nonEmpty(_form.countryBirth.text) ||
            !_nonEmpty(_form.placeBirth.text)) {
          _toast('Complete gender, nationality, dates, and place of birth.');
          return false;
        }
        return true;
      case 5:
        if (!_nonEmpty(_form.idPersonal.text) ||
            !_nonEmpty(_form.idSerial.text) ||
            !_nonEmpty(_form.idIssuePlace.text) ||
            !_nonEmpty(_form.idIssueDate.text) ||
            !_nonEmpty(_form.idExpiryDate.text)) {
          _toast('Complete all National ID fields.');
          return false;
        }
        return true;
      case 6:
        if (!_form.residenceNa) {
          if (!_nonEmpty(_form.resNo.text) ||
              !_nonEmpty(_form.resPlace.text) ||
              !_nonEmpty(_form.resIssue.text) ||
              !_nonEmpty(_form.resExpiry.text)) {
            _toast('Complete residence card details or mark N/A.');
            return false;
          }
        }
        return true;
      case 7:
        if (!_form.passportNa) {
          if (!_nonEmpty(_form.ppNo.text) ||
              !_nonEmpty(_form.ppPlace.text) ||
              !_nonEmpty(_form.ppIssue.text) ||
              !_nonEmpty(_form.ppExpiry.text)) {
            _toast('Complete passport details or mark N/A.');
            return false;
          }
        }
        return true;
      case 8:
        if (_form.education == null ||
            _form.sector == null ||
            !_nonEmpty(_form.income.text) ||
            !_nonEmpty(_form.occupation.text) ||
            !_nonEmpty(_form.employer.text) ||
            !_nonEmpty(_form.employerAddr.text)) {
          _toast('Complete income and employment section.');
          return false;
        }
        return true;
      case 9:
        if (!_nonEmpty(_form.addrGov.text) ||
            !_nonEmpty(_form.addrDistrict.text) ||
            !_nonEmpty(_form.addrCity.text) ||
            !_nonEmpty(_form.addrMahalla.text) ||
            !_nonEmpty(_form.addrStreet.text) ||
            !_nonEmpty(_form.addrHouse.text) ||
            !_nonEmpty(_form.addrLandmarkAr.text) ||
            !_nonEmpty(_form.addrLandmarkEn.text)) {
          _toast('Complete the address fields.');
          return false;
        }
        return true;
      case 10:
        if (_form.fatca == null) {
          _toast('Select Yes or No for FATCA.');
          return false;
        }
        if (_form.fatca == 'Yes') {
          if (!_nonEmpty(_form.fatcaTin.text) ||
              !_nonEmpty(_form.fatcaAddr.text)) {
            _toast('Enter U.S. TIN and address for FATCA.');
            return false;
          }
        }
        return true;
      case 11:
        if (_form.pep == null) {
          _toast('Select Yes or No for PEP.');
          return false;
        }
        if (_form.pep == 'Yes') {
          if (!_nonEmpty(_form.pepPosition.text) ||
              !_nonEmpty(_form.pepCountry.text) ||
              !_nonEmpty(_form.pepFrom.text) ||
              !_nonEmpty(_form.pepTo.text)) {
            _toast('Complete PEP details.');
            return false;
          }
        }
        return true;
      default:
        return true;
    }
  }

  void _toast(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  bool _isFieldLocked(String? fieldKey) =>
      fieldKey != null && _ipassLockedFields.contains(fieldKey);

  void _applyIpassPrefill(Map<String, String> values) {
    void setText(TextEditingController controller, String key) {
      final value = values[key];
      if (value == null) return;
      controller.text = value;
      _ipassLockedFields.add(key);
    }

    setText(_form.mobile, 'mobile');
    setText(_form.email, 'email');
    setText(_form.arFirst, 'arFirst');
    setText(_form.arFather, 'arFather');
    setText(_form.arGf, 'arGf');
    setText(_form.arSurname, 'arSurname');
    setText(_form.arMother, 'arMother');
    setText(_form.enFirst, 'enFirst');
    setText(_form.enFather, 'enFather');
    setText(_form.enGf, 'enGf');
    setText(_form.enSurname, 'enSurname');
    setText(_form.nationality, 'nationality');
    setText(_form.dob, 'dob');
    setText(_form.countryBirth, 'countryBirth');
    setText(_form.placeBirth, 'placeBirth');
    setText(_form.idPersonal, 'idPersonal');
    setText(_form.idSerial, 'idSerial');
    setText(_form.idIssuePlace, 'idIssuePlace');
    setText(_form.idIssueDate, 'idIssueDate');
    setText(_form.idExpiryDate, 'idExpiryDate');
    setText(_form.resNo, 'resNo');
    setText(_form.resPlace, 'resPlace');
    setText(_form.resIssue, 'resIssue');
    setText(_form.resExpiry, 'resExpiry');
    setText(_form.ppNo, 'ppNo');
    setText(_form.ppPlace, 'ppPlace');
    setText(_form.ppIssue, 'ppIssue');
    setText(_form.ppExpiry, 'ppExpiry');

    final gender = values['gender'];
    if (gender != null) {
      _form.gender = gender;
      _ipassLockedFields.add('gender');
    }
  }

  Future<bool> _ensureKycMediaPermissions() async {
    if (Platform.isIOS) return true;

    final camera = await Permission.camera.request();
    final mic = await Permission.microphone.request();
    if (camera.isGranted && mic.isGranted) return true;

    Toasts.getErrorToast(
      text: camera.isPermanentlyDenied || mic.isPermanentlyDenied
          ? 'Enable camera and microphone in app settings for identity verification.'
          : 'Camera and microphone permissions are required for identity verification.',
    );
    return false;
  }

  Future<void> _runIpassFromBeforeWeBegin() async {
    if (!_validate(0)) return;

    setState(() => _ipassInProgress = true);
    try {
      final config = IpassKycService.instance.loadConfigFromEnv();
      if (!config.isValid) {
        Toasts.getErrorToast(
          text:
              'Identity verification is not configured. Please try again later.',
        );
        return;
      }

      if (!await _ensureKycMediaPermissions()) return;

      final ipassResult = await IpassKycService.instance.startKycVerification(
        email: config.email,
        password: config.password,
        appToken: config.appToken,
        workflowId: config.workflowId,
        socialMediaEmail: config.socialMediaEmail.isNotEmpty
            ? config.socialMediaEmail
            : config.email,
        phoneNumber: config.phoneNumber,
        serverUrl: config.serverUrl,
        dbType: config.dbType,
        useDynamicDb: config.useDynamicDb,
        enableHologram: config.enableHologram,
      );

      if (!ipassResult.success || !ipassResult.apiStatus) {
        if (!mounted) return;
        Toasts.getErrorToast(
          text: AppLocalizations.of(context)!.shufti_pro_verification_failed,
        );
        return;
      }

      _completedIpassResult = ipassResult;
      final mappedFields = IpassOnboardingMapper.extractFieldValues(
        ipassResult.data,
      );
      if (kDebugMode) {
        IpassOnboardingMapper.logMappedFields(mappedFields);
      }
      _applyIpassPrefill(mappedFields);

      if (!mounted) return;
      setState(() {});
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } on IpassKycException catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      Toasts.getErrorToast(text: e.message);
    } on PlatformException catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      Toasts.getErrorToast(
        text:
            e.message ?? AppLocalizations.of(context)!.kyc_verification_failed,
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      Toasts.getErrorToast(
        text: AppLocalizations.of(context)!.kyc_verification_failed,
      );
    } finally {
      if (mounted) setState(() => _ipassInProgress = false);
    }
  }

  void _next() {
    if (_currentPage == 0 && _completedIpassResult == null) {
      _runIpassFromBeforeWeBegin();
      return;
    }
    if (!_validate(_currentPage)) return;
    if (_currentPage < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      final onboardingPayload = _buildAlTaifOnboardingPayload();
      // After step 12, continue directly into identity verification (iPass KYC flow).
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => KycSecondStepScreen(
            alTaifOnboardingData: onboardingPayload,
            completedIpassResult: _completedIpassResult,
          ),
        ),
      );
    }
  }

  Map<String, dynamic> _buildAlTaifOnboardingPayload() {
    String? normalizedOrNull(String? value) {
      final v = value?.trim() ?? '';
      return v.isEmpty ? null : v;
    }

    return {
      "flow": "al_taif_bank_onboarding",
      "version": "1.0",
      "completedSteps": _totalSteps,
      "ipassVerification": _completedIpassResult?.toJson(),
      "ipassLockedFields": _ipassLockedFields.toList(),
      "step1Purpose": {
        "purposeConfirmed": _form.purposeConfirmed,
      },
      "step2Contact": {
        "mobile": normalizedOrNull(_form.mobile.text),
        "email": normalizedOrNull(_form.email.text),
        "branch": _form.branch,
      },
      "step3ArabicName": {
        "firstName": normalizedOrNull(_form.arFirst.text),
        "fatherName": normalizedOrNull(_form.arFather.text),
        "grandfatherName": normalizedOrNull(_form.arGf.text),
        "surname": normalizedOrNull(_form.arSurname.text),
        "motherName": normalizedOrNull(_form.arMother.text),
      },
      "step4EnglishName": {
        "firstName": normalizedOrNull(_form.enFirst.text),
        "fatherName": normalizedOrNull(_form.enFather.text),
        "grandfatherName": normalizedOrNull(_form.enGf.text),
        "surname": normalizedOrNull(_form.enSurname.text),
      },
      "step5PersonalDetails": {
        "gender": _form.gender,
        "nationality": normalizedOrNull(_form.nationality.text),
        "dateOfBirth": normalizedOrNull(_form.dob.text),
        "countryOfBirth": normalizedOrNull(_form.countryBirth.text),
        "placeOfBirth": normalizedOrNull(_form.placeBirth.text),
      },
      "step6NationalId": {
        "personalNumber": normalizedOrNull(_form.idPersonal.text),
        "cardSerialNumber": normalizedOrNull(_form.idSerial.text),
        "placeOfIssue": normalizedOrNull(_form.idIssuePlace.text),
        "dateOfIssue": normalizedOrNull(_form.idIssueDate.text),
        "dateOfExpiry": normalizedOrNull(_form.idExpiryDate.text),
      },
      "step7ResidenceCard": {
        "isNotApplicable": _form.residenceNa,
        "cardNumber": _form.residenceNa
            ? null
            : normalizedOrNull(_form.resNo.text),
        "placeOfIssue": _form.residenceNa
            ? null
            : normalizedOrNull(_form.resPlace.text),
        "dateOfIssue": _form.residenceNa
            ? null
            : normalizedOrNull(_form.resIssue.text),
        "dateOfExpiry": _form.residenceNa
            ? null
            : normalizedOrNull(_form.resExpiry.text),
      },
      "step8Passport": {
        "isNotApplicable": _form.passportNa,
        "passportNumber": _form.passportNa
            ? null
            : normalizedOrNull(_form.ppNo.text),
        "placeOfIssue": _form.passportNa
            ? null
            : normalizedOrNull(_form.ppPlace.text),
        "dateOfIssue": _form.passportNa
            ? null
            : normalizedOrNull(_form.ppIssue.text),
        "dateOfExpiry": _form.passportNa
            ? null
            : normalizedOrNull(_form.ppExpiry.text),
      },
      "step9IncomeEmployment": {
        "educationLevel": _form.education,
        "economicSector": _form.sector,
        "monthlyIncomeIqd": normalizedOrNull(_form.income.text),
        "occupation": normalizedOrNull(_form.occupation.text),
        "employerName": normalizedOrNull(_form.employer.text),
        "employerAddress": normalizedOrNull(_form.employerAddr.text),
      },
      "step10Address": {
        "governorate": normalizedOrNull(_form.addrGov.text),
        "district": normalizedOrNull(_form.addrDistrict.text),
        "cityOrTown": normalizedOrNull(_form.addrCity.text),
        "mahalla": normalizedOrNull(_form.addrMahalla.text),
        "street": normalizedOrNull(_form.addrStreet.text),
        "houseNumber": normalizedOrNull(_form.addrHouse.text),
        "nearestLandmarkArabic": normalizedOrNull(_form.addrLandmarkAr.text),
        "nearestLandmarkEnglish": normalizedOrNull(_form.addrLandmarkEn.text),
      },
      "step11Fatca": {
        "isUsPerson": _form.fatca == "Yes",
        "tinOrSsn": _form.fatca == "Yes"
            ? normalizedOrNull(_form.fatcaTin.text)
            : null,
        "usAddress": _form.fatca == "Yes"
            ? normalizedOrNull(_form.fatcaAddr.text)
            : null,
      },
      "step12Pep": {
        "isPep": _form.pep == "Yes",
        "positionOrRelation": _form.pep == "Yes"
            ? normalizedOrNull(_form.pepPosition.text)
            : null,
        "country": _form.pep == "Yes"
            ? normalizedOrNull(_form.pepCountry.text)
            : null,
        "from": _form.pep == "Yes"
            ? normalizedOrNull(_form.pepFrom.text)
            : null,
        "to": _form.pep == "Yes" ? normalizedOrNull(_form.pepTo.text) : null,
      },
    };
  }

  String _continueButtonLabel() {
    if (_currentPage == 0 && _completedIpassResult == null) {
      return 'VERIFY IDENTITY';
    }
    if (_currentPage == _totalSteps - 1) return 'COMPLETE';
    return 'CONTINUE';
  }

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _KycPalette.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _back,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                    color: _KycPalette.ink,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundImage: AssetImage('assets/png/app_ic.png'),
                        ),
                        const SizedBox(width: 8),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BBH',
                              style: TextStyle(
                                fontFamily: 'DINNextArabic',
                                letterSpacing: 1.2,
                                color: _KycPalette.ink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'BNK-001 · v1.0',
                              style: TextStyle(
                                fontSize: 11,
                                color: _KycPalette.inkSoft,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '${_currentPage + 1} of $_totalSteps',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _KycPalette.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth * (_currentPage + 1) / _totalSteps;
                  return Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _KycPalette.creamMuted,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        width: w,
                        decoration: BoxDecoration(
                          color: _KycPalette.goldLine,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _totalSteps,
                itemBuilder: (context, i) => _buildStep(i),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: ElevatedButton(
                onPressed: _ipassInProgress ? null : _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _KycPalette.primaryBtn,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _ipassInProgress
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _continueButtonLabel(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int i) {
    switch (i) {
      case 0:
        return _step1Purpose();
      case 1:
        return _step2Contact();
      case 2:
        return _step3Arabic();
      case 3:
        return _step4Latin();
      case 4:
        return _step5Personal();
      case 5:
        return _step6NationalId();
      case 6:
        return _step7Residence();
      case 7:
        return _step8Passport();
      case 8:
        return _step9Income();
      case 9:
        return _step10Address();
      case 10:
        return _step11Fatca();
      case 11:
        return _step12Pep();
      default:
        return const SizedBox.shrink();
    }
  }

  // ——— Shared chrome ———

  Widget _eyebrow(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _KycPalette.eyebrow,
        letterSpacing: 1.0,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: _KycPalette.ink,
        height: 1.15,
      ),
    );
  }

  Widget _rule() {
    return Center(
      child: Container(
        width: 56,
        height: 2,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: _KycPalette.goldLine,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _lede(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _KycPalette.inkSoft,
        height: 1.5,
        fontSize: 15,
      ),
    );
  }

  InputDecoration _decoration(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: _KycPalette.inkSoft, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0D6C4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0D6C4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _KycPalette.ink, width: 1.4),
      ),
    );
  }

  Widget _textField({
    required TextEditingController c,
    required String label,
    String? fieldKey,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    TextCapitalization cap = TextCapitalization.none,
    bool readOnly = false,
    VoidCallback? onTap,
    TextDirection? textDirection,
  }) {
    final locked = _isFieldLocked(fieldKey);
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      textCapitalization: cap,
      readOnly: locked || readOnly,
      onTap: locked ? null : onTap,
      textDirection: textDirection,
      style: locked ? const TextStyle(color: _KycPalette.inkSoft) : null,
      decoration: _decoration(
        label,
        hint: hint,
        suffix: locked
            ? const Icon(
                Icons.lock_outline,
                size: 18,
                color: _KycPalette.inkSoft,
              )
            : null,
      ),
    );
  }

  Future<void> _pickDate(TextEditingController target, String fieldKey) async {
    if (_isFieldLocked(fieldKey)) return;
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 30, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year + 20),
    );
    if (d != null) {
      target.text =
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  Widget _togglePair({
    required String label,
    required String? groupValue,
    required void Function(String) onChanged,
    required String left,
    required String right,
    String? fieldKey,
  }) {
    final locked = _isFieldLocked(fieldKey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: _KycPalette.ink,
                fontSize: 14,
              ),
            ),
            if (locked) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.lock_outline,
                size: 16,
                color: _KycPalette.inkSoft,
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        IgnorePointer(
          ignoring: locked,
          child: Opacity(
            opacity: locked ? 0.65 : 1,
            child: Row(
              children: [
                Expanded(
                  child: _toggleChip(
                    label: left,
                    selected: groupValue == left,
                    onTap: () => setState(() => onChanged(left)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _toggleChip(
                    label: right,
                    selected: groupValue == right,
                    onTap: () => setState(() => onChanged(right)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggleChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? _KycPalette.ink : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _KycPalette.ink : const Color(0xFFE0D6C4),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? _KycPalette.cream : _KycPalette.ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _callout({required String title, required List<String> paragraphs}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE4CF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4C4A8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: _KycPalette.ink,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          for (final p in paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                p,
                style: const TextStyle(
                  color: _KycPalette.inkSoft,
                  height: 1.45,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _skipLink(String text, VoidCallback onTap) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () {
          onTap();
          setState(() {});
        },
        child: Text(
          text,
          style: const TextStyle(
            decoration: TextDecoration.underline,
            color: _KycPalette.inkSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ——— Steps ———

  Widget _clause(String num, String bold, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          num,
          style: const TextStyle(
            color: _KycPalette.eyebrow,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Color(0xFF2E2E2E),
                fontSize: 15,
                height: 1.55,
              ),
              children: [
                TextSpan(
                  text: bold,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _KycPalette.ink,
                  ),
                ),
                TextSpan(text: ' $body'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _step1Purpose() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('Section 1 · Purpose & Scope'),
          const SizedBox(height: 10),
          _title('Before we begin'),
          _rule(),
          const SizedBox(height: 14),
          _lede(
            'Please read the following with the Client. The agent shall confirm understanding before proceeding.',
          ),
          const SizedBox(height: 22),
          _clause(
            '1.1',
            'What this pack is for.',
            'The Bank account opened under this pack is used only to settle the Client\'s gold transactions with BBH — paying BBH for purchases and receiving funds for sales.',
          ),
          const SizedBox(height: 18),
          _clause(
            '1.2',
            'BBH\'s role.',
            'BBH collects this information on behalf of the Bank. The Bank holds the account; BBH handles the gold leg of every transaction.',
          ),
          const SizedBox(height: 18),
          _clause(
            '1.3',
            'Digital identity verification.',
            'The Client\'s national ID, live photograph, and chip data are captured in one step through iPass verification before completing the remaining sections.',
          ),
          const SizedBox(height: 28),
          InkWell(
            onTap: () => setState(
              () => _form.purposeConfirmed = !_form.purposeConfirmed,
            ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _form.purposeConfirmed
                      ? _KycPalette.ink
                      : const Color(0xFFE0D6C4),
                  width: _form.purposeConfirmed ? 1.5 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _form.purposeConfirmed
                          ? _KycPalette.ink
                          : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _KycPalette.ink),
                    ),
                    child: _form.purposeConfirmed
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: _KycPalette.cream,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'I have read this section to the Client, or the Client has read it, in a language they understand.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: _KycPalette.inkSoft,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step2Contact() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('Section 2.1 · Contact'),
          const SizedBox(height: 10),
          _title('Where can we reach the Client?'),
          _rule(),
          const SizedBox(height: 20),
          _textField(
            c: _form.mobile,
            fieldKey: 'mobile',
            label: 'Mobile Number',
            hint: '+964 7XX XXX XXXX',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 6),
          const Text(
            'International format with country code.',
            style: TextStyle(fontSize: 12, color: _KycPalette.inkSoft),
          ),
          const SizedBox(height: 16),
          _textField(
            c: _form.email,
            fieldKey: 'email',
            label: 'Email Address',
            hint: 'client@example.com',
            keyboardType: TextInputType.emailAddress,
            cap: TextCapitalization.none,
          ),
          const SizedBox(height: 6),
          const Text(
            'Lowercase only.',
            style: TextStyle(fontSize: 12, color: _KycPalette.inkSoft),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _form.branch,
            decoration: _decoration('Bank Branch'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Select branch…'),
              ),
              ..._branches.map(
                (b) => DropdownMenuItem(value: b, child: Text(b)),
              ),
            ],
            onChanged: (v) => setState(() => _form.branch = v),
          ),
        ],
      ),
    );
  }

  Widget _step3Arabic() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _eyebrow('القسم ٢.٢ · الاسم بالعربية'),
            const SizedBox(height: 10),
            _title('الاسم الكامل'),
            _rule(),
            const SizedBox(height: 12),
            _lede('كما هو مدوَّن في بطاقة الهوية الوطنية.'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _textField(
                    c: _form.arFirst,
                    fieldKey: 'arFirst',
                    label: 'الاسم الأول',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _textField(
                    c: _form.arFather,
                    fieldKey: 'arFather',
                    label: 'اسم الأب',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _textField(
                    c: _form.arGf,
                    fieldKey: 'arGf',
                    label: 'اسم الجد',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _textField(
                    c: _form.arSurname,
                    fieldKey: 'arSurname',
                    label: 'اللقب',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _textField(
              c: _form.arMother,
              fieldKey: 'arMother',
              label: 'اسم الأم',
            ),
          ],
        ),
      ),
    );
  }

  Widget _step4Latin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('Section 2.3 · Latin Name'),
          const SizedBox(height: 10),
          _title('Full name in English'),
          _rule(),
          const SizedBox(height: 12),
          _lede('Transliteration as it appears on the passport.'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _textField(
                  c: _form.enFirst,
                  fieldKey: 'enFirst',
                  label: 'First Name',
                  cap: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _textField(
                  c: _form.enFather,
                  fieldKey: 'enFather',
                  label: "Father's Name",
                  cap: TextCapitalization.words,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _textField(
                  c: _form.enGf,
                  fieldKey: 'enGf',
                  label: "Grandfather's",
                  cap: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _textField(
                  c: _form.enSurname,
                  fieldKey: 'enSurname',
                  label: 'Surname',
                  cap: TextCapitalization.words,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _step5Personal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('Section 2.4 · Personal Details'),
          const SizedBox(height: 10),
          _title('A few personal details'),
          _rule(),
          const SizedBox(height: 20),
          _togglePair(
            label: 'Gender',
            fieldKey: 'gender',
            groupValue: _form.gender,
            onChanged: (v) => _form.gender = v,
            left: 'Male',
            right: 'Female',
          ),
          const SizedBox(height: 20),
          _textField(
            c: _form.nationality,
            fieldKey: 'nationality',
            label: 'Nationality',
            cap: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _textField(
                  c: _form.dob,
                  fieldKey: 'dob',
                  label: 'Date of Birth',
                  readOnly: true,
                  onTap: () => _pickDate(_form.dob, 'dob'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _textField(
                  c: _form.countryBirth,
                  fieldKey: 'countryBirth',
                  label: 'Country of Birth',
                  cap: TextCapitalization.words,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _textField(
            c: _form.placeBirth,
            fieldKey: 'placeBirth',
            label: 'Place of Birth',
            hint: 'City or town (max 20 chars)',
            inputFormatters: [LengthLimitingTextInputFormatter(20)],
            cap: TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  Widget _step6NationalId() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('Section 2.5 · National Identity Card'),
          const SizedBox(height: 10),
          _title('National ID'),
          _rule(),
          const SizedBox(height: 12),
          _lede('Both numbers are printed on the same card.'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _textField(
                      c: _form.idPersonal,
                      fieldKey: 'idPersonal',
                      label: 'Personal Number',
                      hint: 'Permanent',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Same across renewals.',
                      style: TextStyle(
                        fontSize: 12,
                        color: _KycPalette.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _textField(
                      c: _form.idSerial,
                      fieldKey: 'idSerial',
                      label: 'ID Number (Card Serial)',
                      hint: 'Card serial',
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Changes on renewal.',
                      style: TextStyle(
                        fontSize: 12,
                        color: _KycPalette.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _textField(
            c: _form.idIssuePlace,
            fieldKey: 'idIssuePlace',
            label: 'Place of Issue',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _textField(
                  c: _form.idIssueDate,
                  fieldKey: 'idIssueDate',
                  label: 'Date of Issue',
                  readOnly: true,
                  onTap: () => _pickDate(_form.idIssueDate, 'idIssueDate'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _textField(
                  c: _form.idExpiryDate,
                  fieldKey: 'idExpiryDate',
                  label: 'Date of Expiry',
                  readOnly: true,
                  onTap: () => _pickDate(_form.idExpiryDate, 'idExpiryDate'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _step7Residence() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('Section 2.6 · Residence Card'),
          const SizedBox(height: 10),
          _title('Residence Card'),
          _rule(),
          const SizedBox(height: 12),
          _lede(
            'If the Client does not hold a residence card, mark this section "N/A".',
          ),
          const SizedBox(height: 20),
          if (_form.residenceNa)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Marked N/A — not applicable.',
                        style: TextStyle(
                          color: _KycPalette.inkSoft,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _form.residenceNa = false),
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ),
          IgnorePointer(
            ignoring: _form.residenceNa,
            child: Opacity(
              opacity: _form.residenceNa ? 0.45 : 1,
              child: Column(
                children: [
                  _textField(
                    c: _form.resNo,
                    fieldKey: 'resNo',
                    label: 'Residence Card Number',
                  ),
                  const SizedBox(height: 16),
                  _textField(
                    c: _form.resPlace,
                    fieldKey: 'resPlace',
                    label: 'Place of Issue',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _textField(
                          c: _form.resIssue,
                          fieldKey: 'resIssue',
                          label: 'Date of Issue',
                          readOnly: true,
                          onTap: () => _pickDate(_form.resIssue, 'resIssue'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _textField(
                          c: _form.resExpiry,
                          fieldKey: 'resExpiry',
                          label: 'Date of Expiry',
                          readOnly: true,
                          onTap: () => _pickDate(_form.resExpiry, 'resExpiry'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _skipLink('Mark this section N/A', () {
            _form.markResidenceNa();
          }),
        ],
      ),
    );
  }

  Widget _step8Passport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('Section 2.7 · Passport'),
          const SizedBox(height: 10),
          _title('Passport (if held)'),
          _rule(),
          const SizedBox(height: 20),
          if (_form.passportNa)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Marked N/A — not applicable.',
                        style: TextStyle(
                          color: _KycPalette.inkSoft,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _form.passportNa = false),
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ),
          IgnorePointer(
            ignoring: _form.passportNa,
            child: Opacity(
              opacity: _form.passportNa ? 0.45 : 1,
              child: Column(
                children: [
                  _textField(
                    c: _form.ppNo,
                    fieldKey: 'ppNo',
                    label: 'Passport Number',
                    cap: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),
                  _textField(
                    c: _form.ppPlace,
                    fieldKey: 'ppPlace',
                    label: 'Place of Issue',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _textField(
                          c: _form.ppIssue,
                          fieldKey: 'ppIssue',
                          label: 'Date of Issue',
                          readOnly: true,
                          onTap: () => _pickDate(_form.ppIssue, 'ppIssue'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _textField(
                          c: _form.ppExpiry,
                          fieldKey: 'ppExpiry',
                          label: 'Date of Expiry',
                          readOnly: true,
                          onTap: () => _pickDate(_form.ppExpiry, 'ppExpiry'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _skipLink('Mark this section N/A', () {
            _form.markPassportNa();
          }),
        ],
      ),
    );
  }

  Widget _step9Income() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('Section 2.8 – 2.9 · Income & Employment'),
          const SizedBox(height: 10),
          _title('Source of income'),
          _rule(),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _form.education,
            decoration: _decoration('Education Level'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Select…')),
              ..._educationLevels.map(
                (e) => DropdownMenuItem(value: e, child: Text(e)),
              ),
            ],
            onChanged: (v) => setState(() => _form.education = v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _form.sector,
            decoration: _decoration('Economic Sector'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Select…')),
              ..._sectors.map(
                (e) => DropdownMenuItem(value: e, child: Text(e)),
              ),
            ],
            onChanged: (v) => setState(() => _form.sector = v),
          ),
          const SizedBox(height: 16),
          _textField(
            c: _form.income,
            label: 'Total Monthly Income (IQD)',
            hint: 'e.g. 2500000',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _textField(
            c: _form.occupation,
            label: 'Occupation',
            hint: 'e.g. Goldsmith, Trader, Engineer',
            cap: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          _textField(
            c: _form.employer,
            label: 'Employer Name',
            hint: 'Or "Retired", "Student", "Housewife", "Unemployed"',
            cap: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          _textField(
            c: _form.employerAddr,
            label: 'Employer Address',
            maxLines: 4,
            cap: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  Widget _step10Address() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('Section 2.10 – 2.11 · Address'),
          const SizedBox(height: 10),
          _title('Where the Client lives'),
          _rule(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _textField(c: _form.addrGov, label: 'Governorate'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _textField(c: _form.addrDistrict, label: 'District'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _textField(c: _form.addrCity, label: 'City / Town'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _textField(c: _form.addrMahalla, label: 'Mahalla'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _textField(c: _form.addrStreet, label: 'Street'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _textField(c: _form.addrHouse, label: 'House No.'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _textField(
            c: _form.addrLandmarkAr,
            label: 'Nearest Landmark (Arabic)',
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),
          _textField(
            c: _form.addrLandmarkEn,
            label: 'Nearest Landmark (English)',
          ),
        ],
      ),
    );
  }

  Widget _step11Fatca() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('Section 3.1 · FATCA Declaration'),
          const SizedBox(height: 10),
          _title('U.S. tax residency'),
          _rule(),
          const SizedBox(height: 16),
          _callout(
            title: 'Who is a U.S. person?',
            paragraphs: const [
              'A U.S. citizen, a U.S. green-card holder, or any other person treated as a U.S. tax resident.',
            ],
          ),
          const SizedBox(height: 20),
          _togglePair(
            label: 'Is the Client a U.S. person for FATCA purposes?',
            groupValue: _form.fatca,
            onChanged: (v) => _form.fatca = v,
            left: 'No',
            right: 'Yes',
          ),
          if (_form.fatca == 'Yes') ...[
            const SizedBox(height: 20),
            _textField(c: _form.fatcaTin, label: 'U.S. TIN / SSN'),
            const SizedBox(height: 16),
            _textField(
              c: _form.fatcaAddr,
              label: 'U.S. Address (if applicable)',
              maxLines: 4,
            ),
          ],
        ],
      ),
    );
  }

  Widget _step12Pep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('Section 3.2 · PEP Declaration'),
          const SizedBox(height: 10),
          _title('Politically Exposed Person'),
          _rule(),
          const SizedBox(height: 16),
          _callout(
            title: 'What counts as a PEP?',
            paragraphs: const [
              'A person who holds — or has held in the previous twelve months — a prominent public function: heads of state, ministers, members of parliament, senior judges, senior military or police officers, senior officials of state-owned enterprises, or senior officials of political parties.',
              'The question covers the Client, close family members of a PEP, and known close associates.',
            ],
          ),
          const SizedBox(height: 20),
          _togglePair(
            label: 'Does the Client fall into any PEP category?',
            groupValue: _form.pep,
            onChanged: (v) => _form.pep = v,
            left: 'No',
            right: 'Yes',
          ),
          if (_form.pep == 'Yes') ...[
            const SizedBox(height: 20),
            _textField(
              c: _form.pepPosition,
              label: 'Position Held / Relationship to PEP',
            ),
            const SizedBox(height: 16),
            _textField(
              c: _form.pepCountry,
              label: 'Country',
              cap: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _textField(
                    c: _form.pepFrom,
                    label: 'From (MM/YYYY)',
                    hint: 'MM/YYYY',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _textField(
                    c: _form.pepTo,
                    label: 'To (MM/YYYY)',
                    hint: 'MM/YYYY',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
