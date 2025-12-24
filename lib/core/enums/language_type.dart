enum LanguageType {
  english,
  arabic;

  /// override string
  @override
  String toString() {
    switch (this) {
      case LanguageType.english:
        return "English";
      case LanguageType.arabic:
        return "Arabic";
    }
  }
}
