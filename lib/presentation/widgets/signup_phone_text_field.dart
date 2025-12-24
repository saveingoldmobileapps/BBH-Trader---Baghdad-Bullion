import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

import '../../../core/theme/const_colors.dart';

class CommonPhoneFieldWithDropdown extends StatefulWidget {
  final String title;
  final String hintText;
  final String isoCode;
  final TextEditingController? controller; // ✅ Made optional
  final void Function(String phoneNumber, String isoCode, String dialCode)
      onPhoneNumberChanged;
  final String? Function(String?)? validator;

  const CommonPhoneFieldWithDropdown({
    super.key,
    required this.title,
    required this.hintText,
    required this.isoCode,
    this.controller, // ✅ Optional now
    required this.onPhoneNumberChanged,
    this.validator,
  });

  @override
  State<CommonPhoneFieldWithDropdown> createState() =>
      _CommonPhoneFieldWithDropdownState();
}

class _CommonPhoneFieldWithDropdownState
    extends State<CommonPhoneFieldWithDropdown> {
  late PhoneNumber _phoneNumber;
  String _hintText = "";

  static const List<String> _restrictedCountries = [
    'IR',
    'RU',
    'KP',
    'VE',
    'DZ',
    'YE',
    'AF',
    'AO',
    'VI',
    'ML',
    'SN',
    'SO',
    'SS',
    'NA',
    'SY',
    'BF',
    'CM',
    'CD',
    'ZA'
  ];

  static const List<String> _allCountries = [
    'AF',
    'AX',
    'AL',
    'DZ',
    'AS',
    'AD',
    'AO',
    'AI',
    'AQ',
    'AG',
    'AR',
    'AM',
    'AW',
    'AU',
    'AT',
    'AZ',
    'BS',
    'BH',
    'BD',
    'BB',
    'BY',
    'BE',
    'BZ',
    'BJ',
    'BM',
    'BT',
    'BO',
    'BQ',
    'BA',
    'BW',
    'BV',
    'BR',
    'IO',
    'BN',
    'BG',
    'BF',
    'BI',
    'CV',
    'KH',
    'CM',
    'CA',
    'KY',
    'CF',
    'TD',
    'CL',
    'CN',
    'CX',
    'CC',
    'CO',
    'KM',
    'CG',
    'CD',
    'CK',
    'CR',
    'CI',
    'HR',
    'CU',
    'CW',
    'CY',
    'CZ',
    'DK',
    'DJ',
    'DM',
    'DO',
    'EC',
    'EG',
    'SV',
    'GQ',
    'ER',
    'EE',
    'ET',
    'FK',
    'FO',
    'FJ',
    'FI',
    'FR',
    'GF',
    'PF',
    'TF',
    'GA',
    'GM',
    'GE',
    'DE',
    'GH',
    'GI',
    'GR',
    'GL',
    'GD',
    'GP',
    'GU',
    'GT',
    'GG',
    'GN',
    'GW',
    'GY',
    'HT',
    'HM',
    'VA',
    'HN',
    'HK',
    'HU',
    'IS',
    'IN',
    'ID',
    'IQ',
    'IE',
    'IM',
    'IL',
    'IT',
    'JM',
    'JP',
    'JE',
    'JO',
    'KZ',
    'KE',
    'KI',
    'KP',
    'KR',
    'KW',
    'KG',
    'LA',
    'LV',
    'LB',
    'LS',
    'LR',
    'LY',
    'LI',
    'LT',
    'LU',
    'MO',
    'MK',
    'MG',
    'MW',
    'MY',
    'MV',
    'ML',
    'MT',
    'MH',
    'MQ',
    'MR',
    'MU',
    'YT',
    'MX',
    'FM',
    'MD',
    'MC',
    'MN',
    'ME',
    'MS',
    'MA',
    'MZ',
    'MM',
    'NA',
    'NR',
    'NP',
    'NL',
    'NC',
    'NZ',
    'NI',
    'NE',
    'NG',
    'NU',
    'NF',
    'MP',
    'NO',
    'OM',
    'PK',
    'PW',
    'PS',
    'PA',
    'PG',
    'PY',
    'PE',
    'PH',
    'PN',
    'PL',
    'PT',
    'PR',
    'QA',
    'RE',
    'RO',
    'RW',
    'BL',
    'SH',
    'KN',
    'LC',
    'MF',
    'PM',
    'VC',
    'WS',
    'SM',
    'ST',
    'SA',
    'SN',
    'RS',
    'SC',
    'SL',
    'SG',
    'SX',
    'SK',
    'SI',
    'SB',
    'SO',
    'ZA',
    'GS',
    'SS',
    'ES',
    'LK',
    'SD',
    'SR',
    'SJ',
    'SE',
    'CH',
    'SY',
    'TW',
    'TJ',
    'TZ',
    'TH',
    'TL',
    'TG',
    'TK',
    'TO',
    'TT',
    'TN',
    'TR',
    'TM',
    'TC',
    'TV',
    'UG',
    'UA',
    'AE',
    'GB',
    'US',
    'UM',
    'UY',
    'UZ',
    'VU',
    'VE',
    'VN',
    'VG',
    'VI',
    'WF',
    'EH',
    'YE',
    'ZM',
    'ZW'
  ];

  late final List<String> _allowedCountries =
      _allCountries.where((c) => !_restrictedCountries.contains(c)).toList();

  @override
  void initState() {
    super.initState();
    _phoneNumber = PhoneNumber(isoCode: widget.isoCode);
    _hintText = widget.hintText;
    _updateExampleNumber(widget.isoCode);
  }

  Future<void> _updateExampleNumber(String isoCode) async {
    try {
      final exampleNumber = await PhoneNumber.getRegionInfoFromPhoneNumber(
        '',
        isoCode,
      );

      final formattedExample = exampleNumber.phoneNumber?.replaceAll('+', '') ??
          _getFallbackHint(isoCode);

      setState(() {
        _hintText = formattedExample;
      });
    } catch (_) {
      setState(() {
        _hintText = _getFallbackHint(isoCode);
      });
    }
  }

  String _getFallbackHint(String iso) {
    switch (iso) {
      case 'AE':
        return '52 000 0000';
      case 'SA':
        return '5x xxx xxxx';
      case 'IN':
        return '9x xxxx xxxx';
      case 'PK':
        return '3xx xxxxxxx';
      case 'US':
        return '(201) 555-0123';
      case 'GB':
        return '07123 456789';
      default:
        return 'Enter phone number';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: AppColors.primaryGold500,
        focusColor: AppColors.goldLightColor,
        hintColor: Colors.black,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: InternationalPhoneNumberInput(
          onInputChanged: (PhoneNumber number) {
            _updateExampleNumber(number.isoCode ?? widget.isoCode);
            widget.onPhoneNumberChanged(
              number.phoneNumber ?? '',
              number.isoCode ?? widget.isoCode,
              number.dialCode ?? '',
            );
          },
          selectorConfig: const SelectorConfig(
            selectorType: PhoneInputSelectorType.DIALOG,
            setSelectorButtonAsPrefixIcon: true,
            leadingPadding: 8,
          ),
          ignoreBlank: false,
          autoValidateMode: AutovalidateMode.onUserInteraction,
          textFieldController: widget.controller, // ✅ Works even if null
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          formatInput: true,
          initialValue: _phoneNumber,
          countries: _allowedCountries,
          selectorTextStyle: const TextStyle(color: Colors.white),
          textStyle: TextStyle(
            color: AppColors.secondaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: GoogleFonts.roboto().fontFamily,
          ),
          inputDecoration: InputDecoration(
            labelText: widget.title.isNotEmpty
                ? widget.title
                : AppLocalizations.of(context)!.phone_number,
            hintText: _hintText,
            hintStyle: TextStyle(
              color: AppColors.secondaryColor,
              fontSize: 16,
              fontFamily: GoogleFonts.roboto().fontFamily,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            border: const OutlineInputBorder(),
          ),
          validator: widget.validator, // ✅ Ensures form validation works
          onSaved: (PhoneNumber? number) {
            if (number != null) {
              widget.onPhoneNumberChanged(
                number.phoneNumber ?? '',
                number.isoCode ?? widget.isoCode,
                number.dialCode ?? '',
              );
            }
          },
        ),
      ),
    );
  }
}
