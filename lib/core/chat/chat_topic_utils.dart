class ChatTopicUtils {
  static const maxTopicLength = 40;

  static String? validateTopic(String text) {
    if (text.trim().length > maxTopicLength) {
      return '话题不能超过 $maxTopicLength 个字符';
    }
    return null;
  }

  static String normalizeTopic(String text) => text.trim();
}
