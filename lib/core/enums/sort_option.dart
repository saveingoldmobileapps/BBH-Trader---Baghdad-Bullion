enum SortOption {
  priceHighToLow,
  priceLowToHigh,
  newestFirst,
  oldestFirst;

  /// override string
  @override
  String toString() {
    switch (this) {
      case SortOption.priceHighToLow:
        return "price_high_to_low";
      case SortOption.priceLowToHigh:
        return "price_low_to_high";
      case SortOption.newestFirst:
        return "newest_first";
      case SortOption.oldestFirst:
        return "oldest_first";
    }
  }
}

enum ParamOption {
  paramPage,
  paramLimit;

  @override
  String toString() {
    switch (this) {
      case ParamOption.paramPage:
        return "1";
      case ParamOption.paramLimit:
        return "10";
    }
  }
}
