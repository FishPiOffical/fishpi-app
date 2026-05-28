import 'package:fishpi/fishpi.dart';

class ForumQueryOption {
  final String type;
  final String title;

  const ForumQueryOption({
    required this.type,
    required this.title,
  });

  static const latestReply = ForumQueryOption(
    type: ArticleListType.Reply,
    title: '最新回复',
  );

  static const latestPost = ForumQueryOption(
    type: ArticleListType.Recent,
    title: '最新发布',
  );

  static const hot = ForumQueryOption(
    type: ArticleListType.Hot,
    title: '热门',
  );

  static const perfect = ForumQueryOption(
    type: ArticleListType.Perfect,
    title: '精华',
  );

  static const defaults = [
    latestReply,
    latestPost,
    hot,
    perfect,
  ];

  static ForumQueryOption byType(String type) {
    return defaults.firstWhere(
      (option) => option.type == type,
      orElse: () => latestReply,
    );
  }
}
