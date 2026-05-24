import 'package:auto_size_text/auto_size_text.dart';
import 'package:fishpi/types/user.dart';
import 'package:flutter/material.dart';

/// 抄作业完成感谢鸽鸽
class MedalWidget extends StatelessWidget {
  final Metal medal;
  final String level;

  const MedalWidget({
    super.key,
    required this.medal,
    this.level = '普通',
  });

  @override
  Widget build(BuildContext context) {
    final url = medal.attr.url;
    final backColor = _parseMedalColor(
      medal.attr.backcolor,
      const Color(0xFFF0D35E),
    );
    final fontColor = _parseMedalColor(
      medal.attr.fontcolor,
      const Color(0xFF18191F),
    );
    final levelStyle = _MedalLevelStyle.resolve(level);
    final medalKey = _medalKeySuffix(medal);

    return SizedBox(
      key: ValueKey('medal_effect_${levelStyle.key}_$medalKey'),
      height: 34,
      width: 132,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (levelStyle.hasGlow)
            Positioned(
              left: 2,
              top: 5,
              child: Container(
                width: 126,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: levelStyle.glowGradient,
                  boxShadow: levelStyle.glowShadows,
                ),
              ),
            ),
          Positioned(
            left: 4,
            top: 4,
            child: SizedBox(
              height: 25,
              width: 120,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 12,
                    top: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: backColor,
                        gradient: levelStyle.pillGradient,
                        backgroundBlendMode: BlendMode.overlay,
                        border: Border.all(
                          color: levelStyle.borderColor,
                          width: levelStyle.borderWidth,
                        ),
                      ),
                      padding: const EdgeInsets.only(left: 15, right: 10),
                      child: AutoSizeText(
                        medal.name,
                        minFontSize: 10,
                        style: TextStyle(color: fontColor),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: levelStyle.borderColor,
                          width: levelStyle.borderWidth,
                        ),
                        image: DecorationImage(image: NetworkImage(url)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (levelStyle.badgeText != null)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                key: ValueKey('medal_level_badge_${levelStyle.key}_$medalKey'),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: levelStyle.badgeBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: levelStyle.badgeBorderColor),
                ),
                child: Text(
                  levelStyle.badgeText!,
                  style: TextStyle(
                    color: levelStyle.badgeForeground,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Color _parseMedalColor(String value, Color fallback) {
  final normalized = value.trim().replaceFirst('#', '');
  final rgbText = normalized.length == 6 ? normalized : '';
  final argbText = normalized.length == 8 ? normalized : '';
  final parsed = int.tryParse(
    rgbText.isNotEmpty ? rgbText : argbText,
    radix: 16,
  );
  if (parsed == null) return fallback;
  return Color(rgbText.isNotEmpty ? 0xFF000000 | parsed : parsed);
}

String _medalKeySuffix(Metal medal) {
  final rawKey = medal.data.trim().isNotEmpty ? medal.data : medal.name;
  // Key 只用于测试和局部重建定位，压缩空白可以避免同一勋章出现不稳定后缀。
  return rawKey.trim().replaceAll(RegExp(r'\s+'), '_');
}

class _MedalLevelStyle {
  final String key;
  final Color borderColor;
  final double borderWidth;
  final Gradient? glowGradient;
  final Gradient? pillGradient;
  final List<BoxShadow> glowShadows;
  final String? badgeText;
  final Color badgeBackground;
  final Color badgeForeground;
  final Color badgeBorderColor;

  const _MedalLevelStyle({
    required this.key,
    required this.borderColor,
    this.borderWidth = 1,
    this.glowGradient,
    this.pillGradient,
    this.glowShadows = const [],
    this.badgeText,
    this.badgeBackground = Colors.black,
    this.badgeForeground = Colors.white,
    this.badgeBorderColor = Colors.black,
  });

  bool get hasGlow => glowGradient != null || glowShadows.isNotEmpty;

  static _MedalLevelStyle resolve(String level) {
    // 远端等级当前是中文文案，统一在组件内收口，后续新增等级时只需要改这里。
    switch (level.trim()) {
      case '精良':
        return fine;
      case '稀有':
        return rare;
      case '史诗':
        return epic;
      case '传说':
        return legendary;
      case '神话':
        return mythic;
      case '限定':
        return limited;
      case '普通':
      default:
        return normal;
    }
  }

  static const normal = _MedalLevelStyle(
    key: 'normal',
    borderColor: Color(0xFFCECECE),
  );

  static const fine = _MedalLevelStyle(
    key: 'fine',
    borderColor: Color(0xFF2F80ED),
    borderWidth: 1.2,
    glowGradient: LinearGradient(
      colors: [Color(0x262F80ED), Color(0x002F80ED)],
    ),
    glowShadows: [
      BoxShadow(
        color: Color(0x332F80ED),
        blurRadius: 8,
        spreadRadius: 1,
      ),
    ],
  );

  static const rare = _MedalLevelStyle(
    key: 'rare',
    borderColor: Color(0xFF8854D0),
    borderWidth: 1.2,
    glowGradient: LinearGradient(
      colors: [Color(0x268854D0), Color(0x008854D0)],
    ),
    glowShadows: [
      BoxShadow(
        color: Color(0x338854D0),
        blurRadius: 9,
        spreadRadius: 1,
      ),
    ],
  );

  static const epic = _MedalLevelStyle(
    key: 'epic',
    borderColor: Color(0xFFF59E0B),
    borderWidth: 1.35,
    glowGradient: LinearGradient(
      colors: [Color(0x33FFF3D0), Color(0x26F59E0B)],
    ),
    pillGradient: LinearGradient(
      colors: [Color(0x00FFFFFF), Color(0x2AF59E0B)],
    ),
    glowShadows: [
      BoxShadow(
        color: Color(0x33F59E0B),
        blurRadius: 10,
        spreadRadius: 1,
      ),
    ],
  );

  static const legendary = _MedalLevelStyle(
    key: 'legendary',
    borderColor: Color(0xFFD6A300),
    borderWidth: 1.45,
    glowGradient: LinearGradient(
      colors: [Color(0x44FDE68A), Color(0x11D6A300)],
    ),
    pillGradient: LinearGradient(
      colors: [Color(0x00FFFFFF), Color(0x33FDE68A)],
    ),
    glowShadows: [
      BoxShadow(
        color: Color(0x44F5C542),
        blurRadius: 12,
        spreadRadius: 1,
      ),
    ],
  );

  static const mythic = _MedalLevelStyle(
    key: 'mythic',
    borderColor: Color(0xFF7C3AED),
    borderWidth: 1.5,
    glowGradient: LinearGradient(
      colors: [Color(0x33FDE68A), Color(0x337C3AED), Color(0x3322D3EE)],
    ),
    pillGradient: LinearGradient(
      colors: [Color(0x22FDE68A), Color(0x267C3AED)],
    ),
    glowShadows: [
      BoxShadow(
        color: Color(0x447C3AED),
        blurRadius: 13,
        spreadRadius: 1.5,
      ),
    ],
  );

  static const limited = _MedalLevelStyle(
    key: 'limited',
    borderColor: Color(0xFFE53935),
    borderWidth: 1.45,
    glowGradient: LinearGradient(
      colors: [Color(0x33FFCC33), Color(0x26E53935)],
    ),
    pillGradient: LinearGradient(
      colors: [Color(0x22FFCC33), Color(0x22E53935)],
    ),
    glowShadows: [
      BoxShadow(
        color: Color(0x33E53935),
        blurRadius: 12,
        spreadRadius: 1,
      ),
    ],
    badgeText: '限定',
    badgeBackground: Color(0xFFE53935),
    badgeForeground: Colors.white,
    badgeBorderColor: Color(0xFFFFCC33),
  );
}
