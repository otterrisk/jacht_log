import 'package:jacht_log/domain/exception.dart';

extension DomainErrorExtension on DomainError {
  String get message {
    switch (this) {
      case DomainError.tipStartInFuture:
        return 'Tip start is in the future';
      case DomainError.tripEndBeforeTripStart:
        return 'Trip end is before trip start';
      case DomainError.eventBeforeTripStart:
        return 'Event is before trip start';
      case DomainError.eventAfterTripEnd:
        return 'Event is after trip end';
      case DomainError.eventInFuture:
        return 'Event is in the future';
      case DomainError.eventNotFound:
        return 'Event not found';
    }
  }
}
