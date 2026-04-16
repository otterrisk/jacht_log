extension DateTimeX on DateTime {
  DateTime addYears(int years) => DateTime(
    year + years,
    month,
    day,
    hour,
    minute,
    second,
    millisecond,
    microsecond,
  );

  DateTime subYears(int years) => addYears(-years);
}
