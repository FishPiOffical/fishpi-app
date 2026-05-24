import 'dart:convert';

import 'package:fishpi/fishpi.dart';
import 'package:fishpi/src/request.dart';

/// 表情包接口
class Emoji {
  String token = '';
  List<String> _emojis = [];

  Emoji([String? token]) {
    this.token = token ?? this.token;
  }

  Map<String, String> get defaultEmojis {
    return {
      "doge":
          "https://cdn.jsdelivr.net/npm/vditor@3.8.7/dist/images/emoji/doge.png",
      "trollface":
          "https://cdn.jsdelivr.net/npm/vditor@3.8.7/dist/images/emoji/trollface.png",
      "huaji":
          "https://cdn.jsdelivr.net/npm/vditor@3.8.7/dist/images/emoji/huaji.gif",
      "octocat":
          "https://cdn.jsdelivr.net/npm/vditor@3.8.7/dist/images/emoji/octocat.png",
      "wulian":
          "https://cdn.jsdelivr.net/npm/vditor@3.8.7/dist/images/emoji/wulian.png",
      "smile": "https://file.${Request.domain}/emoji/graphics/smile.png",
      "laughing": "https://file.${Request.domain}/emoji/graphics/laughing.png",
      "blush": "https://file.${Request.domain}/emoji/graphics/blush.png",
      "smiley": "https://file.${Request.domain}/emoji/graphics/smiley.png",
      "relaxed": "https://file.${Request.domain}/emoji/graphics/relaxed.png",
      "smirk": "https://file.${Request.domain}/emoji/graphics/smirk.png",
      "heart_eyes":
          "https://file.${Request.domain}/emoji/graphics/heart_eyes.png",
      "kissing_heart":
          "https://file.${Request.domain}/emoji/graphics/kissing_heart.png",
      "kissing_closed_eyes":
          "https://file.${Request.domain}/emoji/graphics/kissing_closed_eyes.png",
      "flushed": "https://file.${Request.domain}/emoji/graphics/flushed.png",
      "relieved": "https://file.${Request.domain}/emoji/graphics/relieved.png",
      "satisfied":
          "https://file.${Request.domain}/emoji/graphics/satisfied.png",
      "grin": "https://file.${Request.domain}/emoji/graphics/grin.png",
      "wink": "https://file.${Request.domain}/emoji/graphics/wink.png",
      "stuck_out_tongue_winking_eye":
          "https://file.${Request.domain}/emoji/graphics/stuck_out_tongue_winking_eye.png",
      "stuck_out_tongue_closed_eyes":
          "https://file.${Request.domain}/emoji/graphics/stuck_out_tongue_closed_eyes.png",
      "grinning": "https://file.${Request.domain}/emoji/graphics/grinning.png",
      "kissing": "https://file.${Request.domain}/emoji/graphics/kissing.png",
      "kissing_smiling_eyes":
          "https://file.${Request.domain}/emoji/graphics/kissing_smiling_eyes.png",
      "stuck_out_tongue":
          "https://file.${Request.domain}/emoji/graphics/stuck_out_tongue.png",
      "sleeping": "https://file.${Request.domain}/emoji/graphics/sleeping.png",
      "worried": "https://file.${Request.domain}/emoji/graphics/worried.png",
      "frowning": "https://file.${Request.domain}/emoji/graphics/frowning.png",
      "anguished":
          "https://file.${Request.domain}/emoji/graphics/anguished.png",
      "open_mouth":
          "https://file.${Request.domain}/emoji/graphics/open_mouth.png",
      "grimacing":
          "https://file.${Request.domain}/emoji/graphics/grimacing.png",
      "confused": "https://file.${Request.domain}/emoji/graphics/confused.png",
      "hushed": "https://file.${Request.domain}/emoji/graphics/hushed.png",
      "expressionless":
          "https://file.${Request.domain}/emoji/graphics/expressionless.png",
      "unamused": "https://file.${Request.domain}/emoji/graphics/unamused.png",
      "sweat_smile":
          "https://file.${Request.domain}/emoji/graphics/sweat_smile.png",
      "sweat": "https://file.${Request.domain}/emoji/graphics/sweat.png",
      "disappointed_relieved":
          "https://file.${Request.domain}/emoji/graphics/disappointed_relieved.png",
      "weary": "https://file.${Request.domain}/emoji/graphics/weary.png",
      "pensive": "https://file.${Request.domain}/emoji/graphics/pensive.png",
      "disappointed":
          "https://file.${Request.domain}/emoji/graphics/disappointed.png",
      "confounded":
          "https://file.${Request.domain}/emoji/graphics/confounded.png",
      "fearful": "https://file.${Request.domain}/emoji/graphics/fearful.png",
      "cold_sweat":
          "https://file.${Request.domain}/emoji/graphics/cold_sweat.png",
      "persevere":
          "https://file.${Request.domain}/emoji/graphics/persevere.png",
      "cry": "https://file.${Request.domain}/emoji/graphics/cry.png",
      "sob": "https://file.${Request.domain}/emoji/graphics/sob.png",
      "joy": "https://file.${Request.domain}/emoji/graphics/joy.png",
      "astonished":
          "https://file.${Request.domain}/emoji/graphics/astonished.png",
      "scream": "https://file.${Request.domain}/emoji/graphics/scream.png",
      "tired_face":
          "https://file.${Request.domain}/emoji/graphics/tired_face.png",
      "angry": "https://file.${Request.domain}/emoji/graphics/angry.png",
      "rage": "https://file.${Request.domain}/emoji/graphics/rage.png",
      "triumph": "https://file.${Request.domain}/emoji/graphics/triumph.png",
      "sleepy": "https://file.${Request.domain}/emoji/graphics/sleepy.png",
      "yum": "https://file.${Request.domain}/emoji/graphics/yum.png",
      "mask": "https://file.${Request.domain}/emoji/graphics/mask.png",
      "sunglasses":
          "https://file.${Request.domain}/emoji/graphics/sunglasses.png",
      "dizzy_face":
          "https://file.${Request.domain}/emoji/graphics/dizzy_face.png",
      "imp": "https://file.${Request.domain}/emoji/graphics/imp.png",
      "smiling_imp":
          "https://file.${Request.domain}/emoji/graphics/smiling_imp.png",
      "neutral_face":
          "https://file.${Request.domain}/emoji/graphics/neutral_face.png",
      "no_mouth": "https://file.${Request.domain}/emoji/graphics/no_mouth.png",
      "innocent": "https://file.${Request.domain}/emoji/graphics/innocent.png",
      "alien": "https://file.${Request.domain}/emoji/graphics/alien.png",
      "yellow_heart":
          "https://file.${Request.domain}/emoji/graphics/yellow_heart.png",
      "blue_heart":
          "https://file.${Request.domain}/emoji/graphics/blue_heart.png",
      "purple_heart":
          "https://file.${Request.domain}/emoji/graphics/purple_heart.png",
      "heart": "https://file.${Request.domain}/emoji/graphics/heart.png",
      "green_heart":
          "https://file.${Request.domain}/emoji/graphics/green_heart.png",
      "broken_heart":
          "https://file.${Request.domain}/emoji/graphics/broken_heart.png",
      "heartbeat":
          "https://file.${Request.domain}/emoji/graphics/heartbeat.png",
      "heartpulse":
          "https://file.${Request.domain}/emoji/graphics/heartpulse.png",
      "two_hearts":
          "https://file.${Request.domain}/emoji/graphics/two_hearts.png",
      "revolving_hearts":
          "https://file.${Request.domain}/emoji/graphics/revolving_hearts.png",
      "cupid": "https://file.${Request.domain}/emoji/graphics/cupid.png",
      "sparkling_heart":
          "https://file.${Request.domain}/emoji/graphics/sparkling_heart.png",
      "sparkles": "https://file.${Request.domain}/emoji/graphics/sparkles.png",
      "star": "https://file.${Request.domain}/emoji/graphics/star.png",
      "star2": "https://file.${Request.domain}/emoji/graphics/star2.png",
      "dizzy": "https://file.${Request.domain}/emoji/graphics/dizzy.png",
      "boom": "https://file.${Request.domain}/emoji/graphics/boom.png",
      "collision":
          "https://file.${Request.domain}/emoji/graphics/collision.png",
      "anger": "https://file.${Request.domain}/emoji/graphics/anger.png",
      "exclamation":
          "https://file.${Request.domain}/emoji/graphics/exclamation.png",
      "question": "https://file.${Request.domain}/emoji/graphics/question.png",
      "grey_exclamation":
          "https://file.${Request.domain}/emoji/graphics/grey_exclamation.png",
      "grey_question":
          "https://file.${Request.domain}/emoji/graphics/grey_question.png",
      "zzz": "https://file.${Request.domain}/emoji/graphics/zzz.png",
      "dash": "https://file.${Request.domain}/emoji/graphics/dash.png",
      "sweat_drops":
          "https://file.${Request.domain}/emoji/graphics/sweat_drops.png",
      "notes": "https://file.${Request.domain}/emoji/graphics/notes.png",
      "musical_note":
          "https://file.${Request.domain}/emoji/graphics/musical_note.png",
      "fire": "https://file.${Request.domain}/emoji/graphics/fire.png",
      "poop": "https://file.${Request.domain}/emoji/graphics/poop.png",
      "+1": "https://file.${Request.domain}/emoji/graphics/%2B1.png",
      "thumbsup": "https://file.${Request.domain}/emoji/graphics/thumbsup.png",
      "-1": "https://file.${Request.domain}/emoji/graphics/-1.png",
      "thumbsdown":
          "https://file.${Request.domain}/emoji/graphics/thumbsdown.png",
      "ok_hand": "https://file.${Request.domain}/emoji/graphics/ok_hand.png",
      "punch": "https://file.${Request.domain}/emoji/graphics/punch.png",
      "facepunch":
          "https://file.${Request.domain}/emoji/graphics/facepunch.png",
      "fist": "https://file.${Request.domain}/emoji/graphics/fist.png",
      "v": "https://file.${Request.domain}/emoji/graphics/v.png",
      "wave": "https://file.${Request.domain}/emoji/graphics/wave.png",
      "hand": "https://file.${Request.domain}/emoji/graphics/hand.png",
      "raised_hand":
          "https://file.${Request.domain}/emoji/graphics/raised_hand.png",
      "open_hands":
          "https://file.${Request.domain}/emoji/graphics/open_hands.png",
      "point_up": "https://file.${Request.domain}/emoji/graphics/point_up.png",
      "point_down":
          "https://file.${Request.domain}/emoji/graphics/point_down.png",
      "point_left":
          "https://file.${Request.domain}/emoji/graphics/point_left.png",
      "point_right":
          "https://file.${Request.domain}/emoji/graphics/point_right.png",
      "raised_hands":
          "https://file.${Request.domain}/emoji/graphics/raised_hands.png",
      "pray": "https://file.${Request.domain}/emoji/graphics/pray.png",
      "point_up_2":
          "https://file.${Request.domain}/emoji/graphics/point_up_2.png",
      "clap": "https://file.${Request.domain}/emoji/graphics/clap.png",
      "muscle": "https://file.${Request.domain}/emoji/graphics/muscle.png",
      "couple": "https://file.${Request.domain}/emoji/graphics/couple.png",
      "family": "https://file.${Request.domain}/emoji/graphics/family.png",
      "two_men_holding_hands":
          "https://file.${Request.domain}/emoji/graphics/two_men_holding_hands.png",
      "two_women_holding_hands":
          "https://file.${Request.domain}/emoji/graphics/two_women_holding_hands.png",
      "dancer": "https://file.${Request.domain}/emoji/graphics/dancer.png",
      "dancers": "https://file.${Request.domain}/emoji/graphics/dancers.png",
      "ok_woman": "https://file.${Request.domain}/emoji/graphics/ok_woman.png",
      "no_good": "https://file.${Request.domain}/emoji/graphics/no_good.png",
      "information_desk_person":
          "https://file.${Request.domain}/emoji/graphics/information_desk_person.png",
      "raising_hand":
          "https://file.${Request.domain}/emoji/graphics/raising_hand.png",
      "bride_with_veil":
          "https://file.${Request.domain}/emoji/graphics/bride_with_veil.png",
      "person_with_pouting_face":
          "https://file.${Request.domain}/emoji/graphics/person_with_pouting_face.png",
      "person_frowning":
          "https://file.${Request.domain}/emoji/graphics/person_frowning.png",
      "bow": "https://file.${Request.domain}/emoji/graphics/bow.png",
      "couplekiss":
          "https://file.${Request.domain}/emoji/graphics/couplekiss.png",
      "couple_with_heart":
          "https://file.${Request.domain}/emoji/graphics/couple_with_heart.png",
      "massage": "https://file.${Request.domain}/emoji/graphics/massage.png",
      "haircut": "https://file.${Request.domain}/emoji/graphics/haircut.png",
      "nail_care":
          "https://file.${Request.domain}/emoji/graphics/nail_care.png",
      "boy": "https://file.${Request.domain}/emoji/graphics/boy.png",
      "girl": "https://file.${Request.domain}/emoji/graphics/girl.png",
      "woman": "https://file.${Request.domain}/emoji/graphics/woman.png",
      "man": "https://file.${Request.domain}/emoji/graphics/man.png",
      "baby": "https://file.${Request.domain}/emoji/graphics/baby.png",
      "older_woman":
          "https://file.${Request.domain}/emoji/graphics/older_woman.png",
      "older_man":
          "https://file.${Request.domain}/emoji/graphics/older_man.png",
      "person_with_blond_hair":
          "https://file.${Request.domain}/emoji/graphics/person_with_blond_hair.png",
      "man_with_gua_pi_mao":
          "https://file.${Request.domain}/emoji/graphics/man_with_gua_pi_mao.png",
      "man_with_turban":
          "https://file.${Request.domain}/emoji/graphics/man_with_turban.png",
      "construction_worker":
          "https://file.${Request.domain}/emoji/graphics/construction_worker.png",
      "cop": "https://file.${Request.domain}/emoji/graphics/cop.png",
      "angel": "https://file.${Request.domain}/emoji/graphics/angel.png",
      "princess": "https://file.${Request.domain}/emoji/graphics/princess.png",
      "smiley_cat":
          "https://file.${Request.domain}/emoji/graphics/smiley_cat.png",
      "smile_cat":
          "https://file.${Request.domain}/emoji/graphics/smile_cat.png",
      "heart_eyes_cat":
          "https://file.${Request.domain}/emoji/graphics/heart_eyes_cat.png",
      "kissing_cat":
          "https://file.${Request.domain}/emoji/graphics/kissing_cat.png",
      "smirk_cat":
          "https://file.${Request.domain}/emoji/graphics/smirk_cat.png",
      "scream_cat":
          "https://file.${Request.domain}/emoji/graphics/scream_cat.png",
      "crying_cat_face":
          "https://file.${Request.domain}/emoji/graphics/crying_cat_face.png",
      "joy_cat": "https://file.${Request.domain}/emoji/graphics/joy_cat.png",
      "pouting_cat":
          "https://file.${Request.domain}/emoji/graphics/pouting_cat.png",
      "japanese_ogre":
          "https://file.${Request.domain}/emoji/graphics/japanese_ogre.png",
      "japanese_goblin":
          "https://file.${Request.domain}/emoji/graphics/japanese_goblin.png",
      "see_no_evil":
          "https://file.${Request.domain}/emoji/graphics/see_no_evil.png",
      "hear_no_evil":
          "https://file.${Request.domain}/emoji/graphics/hear_no_evil.png",
      "speak_no_evil":
          "https://file.${Request.domain}/emoji/graphics/speak_no_evil.png",
      "guardsman":
          "https://file.${Request.domain}/emoji/graphics/guardsman.png",
      "skull": "https://file.${Request.domain}/emoji/graphics/skull.png",
      "feet": "https://file.${Request.domain}/emoji/graphics/feet.png",
      "lips": "https://file.${Request.domain}/emoji/graphics/lips.png",
      "kiss": "https://file.${Request.domain}/emoji/graphics/kiss.png",
      "droplet": "https://file.${Request.domain}/emoji/graphics/droplet.png",
      "ear": "https://file.${Request.domain}/emoji/graphics/ear.png",
      "eyes": "https://file.${Request.domain}/emoji/graphics/eyes.png",
      "nose": "https://file.${Request.domain}/emoji/graphics/nose.png",
      "tongue": "https://file.${Request.domain}/emoji/graphics/tongue.png",
      "love_letter":
          "https://file.${Request.domain}/emoji/graphics/love_letter.png",
      "bust_in_silhouette":
          "https://file.${Request.domain}/emoji/graphics/bust_in_silhouette.png",
      "busts_in_silhouette":
          "https://file.${Request.domain}/emoji/graphics/busts_in_silhouette.png",
      "speech_balloon":
          "https://file.${Request.domain}/emoji/graphics/speech_balloon.png",
      "thought_balloon":
          "https://file.${Request.domain}/emoji/graphics/thought_balloon.png"
    };
  }

  /// 获取自定义表情列表
  Future<List<String>> get() async {
    try {
      var rsp = await Request.post('api/cloud/get', data: {
        'gameId': 'emojis',
        'apiKey': token,
      });

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      try {
        _emojis = List<String>.from(json.decode(rsp["data"]));
      } catch (e) {
        _emojis = [];
      }

      return List<String>.from(_emojis);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 设置表情包列表
  ///
  /// [data] 所有表情包图像列表
  Future<ResponseResult> set(List<String> data) async {
    try {
      var rsp = await Request.post('api/cloud/sync', data: {
        'gameId': 'emojis',
        'data': json.encode(data),
        'apiKey': token,
      });

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 添加表情包
  ///
  /// - `url` 表情包的 URL
  Future<List<String>> append(String url) async {
    var emojis = _emojis.isNotEmpty ? _emojis : await get();
    if (emojis.contains(url)) return Future.error('表情包已存在');
    emojis.add(url);
    await set(emojis);
    _emojis = emojis;
    return List<String>.from(_emojis);
  }

  /// 删除表情包
  ///
  /// - `url` 表情包的 URL
  Future<List<String>> remove(String url) async {
    var emojis = _emojis.isNotEmpty ? _emojis : await get();
    if (!emojis.contains(url)) return List<String>.from(emojis);
    emojis.remove(url);
    await set(emojis);
    _emojis = emojis;
    return List<String>.from(_emojis);
  }

  /// 检查表情包是否存在
  ///
  /// - `url` 表情包的 URL
  Future<bool> exists(String url) async {
    var emojis = _emojis.isNotEmpty ? _emojis : await get();
    return emojis.contains(url);
  }
}
