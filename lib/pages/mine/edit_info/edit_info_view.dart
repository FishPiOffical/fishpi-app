import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'edit_info_logic.dart';

class EditInfoPage extends StatelessWidget {
  final EditInfoLogic logic = Get.put(EditInfoLogic());

  EditInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
