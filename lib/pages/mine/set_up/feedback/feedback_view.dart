import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'feedback_logic.dart';

class FeedbackPage extends StatelessWidget {
  final FeedbackLogic logic = Get.put(FeedbackLogic());

  FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PiTitleBar.back(
        title: '意见反馈',
      ),
    );
  }
}
