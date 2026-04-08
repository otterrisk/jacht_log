enum DomainError {
  tripStartInFuture,
  tripEndBeforeTripStart,
  eventBeforeTripStart,
  eventAfterTripEnd,
  eventInFuture,
  eventNotFound,
}

class DomainException implements Exception {
  final DomainError error;

  DomainException(this.error);

  @override
  String toString() => 'DomainException($error)';
}
