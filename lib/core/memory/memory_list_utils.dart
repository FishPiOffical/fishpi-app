class MemoryListUtils {
  MemoryListUtils._();

  static List<T> keepFirst<T>(Iterable<T> source, int maxLength) {
    final list = List<T>.from(source);
    if (maxLength <= 0 || list.length <= maxLength) return list;
    return list.sublist(0, maxLength);
  }

  static List<T> keepLast<T>(Iterable<T> source, int maxLength) {
    final list = List<T>.from(source);
    if (maxLength <= 0 || list.length <= maxLength) return list;
    return list.sublist(list.length - maxLength);
  }
}
