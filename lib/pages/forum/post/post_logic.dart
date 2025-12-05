import 'package:fishpi/types/article.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/controller/im.dart';

class PostLogic extends GetxController {
  final imController = Get.find<IMController>();
  FleatherController controller = FleatherController();
  TextEditingController titleController = TextEditingController();
  TextEditingController tagController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
  }

  submit() async {
    final mdCode = ParchmentMarkdownCodec();
    final md = mdCode.encode(controller.document);
    String title = titleController.text;
    String tag = tagController.text.split(" ").join(",");
    ArticlePost articlePost = ArticlePost(
      title: title,
      content: md,
      tags: tag,
      showInList: 1,
    );
    var res = await imController.fishpi.article.post(articlePost);
    if (res != "") {
      ToastManager.showToast("发布成功");
      Get.back();
    }
  }
}
