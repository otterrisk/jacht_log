enum DomainError { eventBeforeTripStart, eventAfterTripEnd, eventInFuture }

class DomainException implements Exception {
  final DomainError error;

  DomainException(this.error);

  @override
  String toString() => 'DomainException($error.message)';
}
