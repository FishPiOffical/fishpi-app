import 'package:fishpi_app/widgets/pi_image.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'collection_list_logic.dart';

class CollectionListPage extends StatelessWidget {
  final CollectionListLogic logic = Get.put(CollectionListLogic());

  CollectionListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PiTitleBar.back(
        title: '典藏馆',
      ),
      body: logic.metals.isNotEmpty
          ? ListView.builder(
              itemCount: logic.metals.length,
              itemBuilder: (context, index) {
                return Image.network(
                  logic.metals[index].url + '&apiKey=${logic.apikey.value}',
                  width: 1.sw,
                );
                // return Text(logic.metals[index].url + '&apiKey=${logic.apikey.value}');
              },
            )
          : Center(child: Text('暂无数据')),
    );
  }
}
