import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/pi_title_bar.dart';
import 'complaint_logic.dart';

class ComplaintPage extends StatelessWidget {
  final ComplaintLogic logic = Get.put(ComplaintLogic());

  ComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PiTitleBar.back(
        title: '投诉举报',
      ),
    );
  }
}
