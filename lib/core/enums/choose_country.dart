enum ChooseCountry {
  uae,
  kuwait,
  bahrain,
  qatar;

  /// override string
  @override
  String toString() {
    switch (this) {
      case ChooseCountry.uae:
        return "UAE";
      case ChooseCountry.kuwait:
        return "Kuwait";
      case ChooseCountry.bahrain:
        return "Bahrain";
      case ChooseCountry.qatar:
        return "Qatar";
    }
  }
}
