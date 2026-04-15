import 'package:jacht_log/domain/exception.dart';

extension DomainErrorExtension on DomainError {
  String get message {
    switch (this) {
      case DomainError.tripNotStarted:
        return 'Trip not started';
      case DomainError.tripAlreadyStarted:
        return 'Trip already started';
      case DomainError.tripNotActive:
        return 'Trip not active';
      case DomainError.tripStartInFuture:
        return 'Tip start is in the future';
      case DomainError.tripEndBeforeTripStart:
        return 'Trip end is before trip start';
      case DomainError.eventBeforeTripStart:
        return 'Event is before trip start';
      case DomainError.eventAfterTripEnd:
        return 'Event is after trip end';
      case DomainError.eventNotFound:
        return 'Event not found';
    }
  }
}
