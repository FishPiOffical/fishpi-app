import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/pi_title_bar.dart';
import 'account_logic.dart';

class AccountPage extends StatelessWidget {
  final AccountLogic logic = Get.put(AccountLogic());

  AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PiTitleBar.back(
        title: '账号与安全',
      ),
    );
  }
}
