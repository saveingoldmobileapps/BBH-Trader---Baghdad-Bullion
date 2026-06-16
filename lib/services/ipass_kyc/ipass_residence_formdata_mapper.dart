import '../../data/models/ipass_model/ipass_formdata_result_response.dart';
import 'ipass_html_field_mapper.dart';
import 'ipass_onboarding_mapper.dart';

/// Maps iPass FormData OCR (handwritten residency forms) to onboarding fields.
class IpassResidenceFormdataMapper {
  IpassResidenceFormdataMapper._();

  static Map<String, String> mapResults({
    IpassFormDataResultResponse? front,
    IpassFormDataResultResponse? back,
  }) {
    final mergedText = [
      _collectOcrText(front),
      _collectOcrText(back),
    ].where((t) => t.trim().isNotEmpty).join('\n');

    if (mergedText.isEmpty) return {};

    final normalized = _normalizeArabicDigits(mergedText);
    final out = <String, String>{};

    void put(String key, String? value) {
      final v = value?.trim();
      if (v != null && v.isNotEmpty) out[key] = v;
    }

    final formNo = _firstMatch(
      normalized,
      [
        RegExp(r'رقم\s*الاستمارة\s*([0-9]+)'),
        RegExp(r'رقم\s*التسلسل\s*([0-9]+)'),
        RegExp(r'التسلسل\s*/?\s*([0-9]+)'),
        RegExp(r'(?:التسلسل|الرمز)[^\n]*\n\s*([0-9]{6,12})'),
        RegExp(r'(?:^|\n)\s*([0-9]{7,10})\s*(?:\n|$)'),
      ],
    );
    put('resNo', formNo);

    final neighborhood = _firstMatch(
      normalized,
      [
        RegExp(r'حي\s+([^\n]+)'),
        RegExp(r'مكتب\s+معلومات\s+([^\n]+)'),
      ],
    );
    put('resPlace', neighborhood);

    final issueDateParts = RegExp(
      r'تاريخ\s*تنظيم\s*الاستمارة\s*([0-9]{1,2})\s*/\s*([0-9]{4})\s*/\s*([0-9]{1,2})',
    ).firstMatch(normalized);
    if (issueDateParts != null) {
      final y = issueDateParts.group(2)!;
      final m = issueDateParts.group(3)!.padLeft(2, '0');
      final d = issueDateParts.group(1)!.padLeft(2, '0');
      put('resIssue', '$y-$m-$d');
    } else {
      final issueDate = _firstMatch(
        normalized,
        [
          RegExp(
            r'تاريخ\s*تنظيم\s*الاستمارة\s*([0-9]{4}[/-][0-9]{1,2}[/-][0-9]{1,2})',
          ),
          RegExp(r'تاريخ\s*تنظيم\s*الاستمارة\s*([0-9/]+)'),
        ],
      );
      put('resIssue', _normalizeDate(issueDate));
    }

    return out;
  }

  /// HTML field keys scoped to residence scan target.
  static Map<String, String> toHtmlFields({
    IpassFormDataResultResponse? front,
    IpassFormDataResultResponse? back,
  }) {
    final mapped = mapResults(front: front, back: back);
    return IpassHtmlFieldMapper.forScanTarget(
      IpassScanTarget.residence,
      IpassHtmlFieldMapper.toHtmlFieldValues(mapped),
    );
  }

  static String _collectOcrText(IpassFormDataResultResponse? response) {
    if (response == null) return '';
    final parts = <String>[];

    final content = response.ocrContent;
    if (content != null && content.trim().isNotEmpty) {
      parts.add(content);
    }

    final pages =
        response.result?.analyzeResult?.rawAnalyzeJson?['pages'] ??
        response.rawJson?['analyzeResult']?['pages'];
    if (pages is List) {
      for (final page in pages) {
        if (page is! Map) continue;
        final lines = page['lines'];
        if (lines is! List) continue;
        for (final line in lines) {
          if (line is Map && line['content'] is String) {
            final text = (line['content'] as String).trim();
            if (text.isNotEmpty) parts.add(text);
          }
        }
      }
    }

    return parts.join('\n');
  }

  static String _normalizeArabicDigits(String input) {
    const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
    const easternArabic = '۰۱۲۳۴۵۶۷۸۹';
    var out = input;
    for (var i = 0; i < 10; i++) {
      out = out.replaceAll(arabicIndic[i], '$i');
      out = out.replaceAll(easternArabic[i], '$i');
    }
    return out;
  }

  static String? _firstMatch(String text, List<RegExp> patterns) {
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        final value = match.group(1)?.trim();
        if (value != null && value.isNotEmpty) return value;
      }
    }
    return null;
  }

  static String? _normalizeDate(String? raw) {
    if (raw == null) return null;
    final v = raw.trim();
    if (v.isEmpty) return null;

    final dmy = RegExp(r'^(\d{4})[/-](\d{1,2})[/-](\d{1,2})$');
    final dmyMatch = dmy.firstMatch(v);
    if (dmyMatch != null) {
      final y = dmyMatch.group(1)!;
      final m = dmyMatch.group(2)!.padLeft(2, '0');
      final d = dmyMatch.group(3)!.padLeft(2, '0');
      return '$y-$m-$d';
    }

    final alt = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$');
    final altMatch = alt.firstMatch(v);
    if (altMatch != null) {
      return '${altMatch.group(3)}-'
          '${altMatch.group(2)!.padLeft(2, '0')}-'
          '${altMatch.group(1)!.padLeft(2, '0')}';
    }
    return v;
  }
}
