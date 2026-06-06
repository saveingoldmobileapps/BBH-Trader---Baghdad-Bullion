class BankDetails {
  final String beneficiaryName;
  final String bankName;
  final String iban;

  BankDetails({
    required this.beneficiaryName,
    required this.bankName,
    required this.iban,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankDetails &&
          runtimeType == other.runtimeType &&
          beneficiaryName == other.beneficiaryName &&
          bankName == other.bankName &&
          iban == other.iban;

  @override
  int get hashCode =>
      beneficiaryName.hashCode ^ bankName.hashCode ^ iban.hashCode;

  @override
  String toString() {
    return 'BankDetails{beneficiaryName: $beneficiaryName, bankName: $bankName, iban: $iban}';
  }
}
