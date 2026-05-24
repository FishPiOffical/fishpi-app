/// 清风明月内容
class BreezemoonContent {
  /// 发布者用户名
  String authorName;

  /// 最后更新时间
  String updated;

  /// 清风明月ID
  String oId;

  /// 创建时间
  String created;

  /// 发布者头像URL
  String thumbnailURL48;

  /// 发布时间
  String timeAgo;

  /// 正文
  String content;

  /// 创建时间
  String createTime;

  /// 发布城市（可能为空，请注意做判断）
  String city;

  BreezemoonContent({
    this.authorName = '',
    this.updated = '',
    this.oId = '',
    this.created = '',
    this.thumbnailURL48 = '',
    this.timeAgo = '',
    this.content = '',
    this.createTime = '',
    this.city = '',
  });

  BreezemoonContent.from(Map<String, dynamic> data)
      : authorName = data['breezemoonAuthorName'] ?? '',
        updated = data['breezemoonUpdated']?.toString() ?? '',
        oId = data['oId'],
        created = data['breezemoonCreated']?.toString() ?? '',
        thumbnailURL48 = data['breezemoonAuthorThumbnailURL48'] ?? '',
        timeAgo = data['timeAgo'] ?? '',
        content = data['breezemoonContent'] ?? '',
        createTime = data['breezemoonCreateTime'] ?? '',
        city = data['breezemoonCity'] ?? '';

  Map<String, dynamic> toJson() => {
        'breezemoonAuthorName': authorName,
        'breezemoonUpdated': updated,
        'oId': oId,
        'breezemoonCreated': created,
        'breezemoonAuthorThumbnailURL48': thumbnailURL48,
        'timeAgo': timeAgo,
        'breezemoonContent': content,
        'breezemoonCreateTime': createTime,
        'breezemoonCity': city,
      };

  @override
  String toString() {
    return 'BreezemoonContent{breezemoonAuthorName: $authorName, breezemoonUpdated: $updated, oId: $oId, breezemoonCreated: $created, breezemoonAuthorThumbnailURL48: $thumbnailURL48, timeAgo: $timeAgo, breezemoonContent: $content, breezemoonCreateTime: $createTime, breezemoonCity: $city}';
  }
}
