DateTime? parseDateTime(dynamic value) {
  if (value == null) return null;

  if (value is String) {
    return DateTime.tryParse(value);
  }

  if (value is List && value.length >= 6) {
    return DateTime(
      value[0], value[1], value[2], value[3], value[4], value[5],
    );
  }

  return null;
}
