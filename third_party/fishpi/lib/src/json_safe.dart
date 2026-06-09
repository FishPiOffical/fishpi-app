String readString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

int readInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is bool) return value ? 1 : 0;
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return fallback;
  return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? fallback;
}

double readDouble(dynamic value, {double fallback = 0.0}) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is bool) return value ? 1.0 : 0.0;
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return fallback;
  return double.tryParse(text) ?? fallback;
}

bool readBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().trim().toLowerCase();
  if (text == 'true' || text == '1' || text == 'yes' || text == 'on') {
    return true;
  }
  if (text == 'false' || text == '0' || text == 'no' || text == 'off') {
    return false;
  }
  return fallback;
}

bool? readBoolOrNull(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().trim().toLowerCase();
  if (text == 'true' || text == '1' || text == 'yes' || text == 'on') {
    return true;
  }
  if (text == 'false' || text == '0' || text == 'no' || text == 'off') {
    return false;
  }
  return null;
}

T readEnum<T>(
  List<T> values,
  dynamic value, {
  required T fallback,
  int offset = 0,
}) {
  if (value == null) return fallback;
  final index = readInt(value, fallback: -999999) + offset;
  if (index < 0 || index >= values.length) return fallback;
  return values[index];
}

List<dynamic> readList(dynamic value) {
  if (value is List) return value;
  if (value is Iterable) return value.toList();
  return const [];
}

Map<String, dynamic> readMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}
