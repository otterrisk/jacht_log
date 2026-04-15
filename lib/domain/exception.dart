enum DomainError {
  tripNotStarted,
  tripAlreadyStarted,
  tripNotActive,
  tripStartInFuture,
  tripEndBeforeTripStart,
  eventBeforeTripStart,
  eventAfterTripEnd,
  eventNotFound,
}

class DomainException implements Exception {
  final DomainError error;

  DomainException(this.error);

  @override
  String toString() => 'DomainException($error)';
}
