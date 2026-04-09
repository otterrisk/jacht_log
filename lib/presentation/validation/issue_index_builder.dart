import 'package:jacht_log/domain/trip_validator.dart';

Map<String, List<ValidationIssue>> buildIssueIndex(
  List<ValidationIssue> issues,
) {
  final map = <String, List<ValidationIssue>>{};

  for (final issue in issues) {
    map.putIfAbsent(issue.event.id, () => []).add(issue);

    if (issue.relatedEvent != null) {
      map.putIfAbsent(issue.relatedEvent!.id, () => []).add(issue);
    }
  }

  return map;
}
