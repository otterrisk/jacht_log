import 'package:jacht_log/domain/trip_validator.dart';
import 'package:jacht_log/presentation/mappers/issue_index.dart';

class ValidationViewModel {
  final List<ValidationIssue> issues;
  final Map<String, List<ValidationIssue>> index;

  ValidationViewModel(this.issues) : index = buildIssueIndex(issues);

  bool get hasErrors => issues.any((i) => i.severity == Severity.error);

  bool get hasWarnings => issues.any((i) => i.severity == Severity.warning);
}
