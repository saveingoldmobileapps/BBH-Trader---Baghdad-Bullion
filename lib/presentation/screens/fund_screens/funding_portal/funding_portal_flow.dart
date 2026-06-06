/// Funding portal flows from BBH prototype (mobile UI only).
enum FundingPortalFlow { link, instant, wire }

enum FundingPortalScreenId {
  // Link
  linkHome,
  linkEnter,
  linkVerify,
  linkSuccess,
  // Instant
  fundHome,
  fundChoose,
  fundAmount,
  fundReview,
  fundOtp,
  fundProcessing,
  fundSuccess,
  // Wire
  wireHome,
  wireChoose,
  wireInstructions,
  wireWaiting,
  wireWebhook,
  wireSuccess,
}

extension FundingPortalFlowX on FundingPortalFlow {
  String get label {
    switch (this) {
      case FundingPortalFlow.link:
        return 'Account linking';
      case FundingPortalFlow.instant:
        return 'Instant funding';
      case FundingPortalFlow.wire:
        return 'External wire';
    }
  }
}
