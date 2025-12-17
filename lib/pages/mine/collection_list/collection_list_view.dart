import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
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
                // TODO：坏了 svg 勋章显示不了，待修复
                return Image(
                  image: Svg(
                    logic.metals[index].url + '&apiKey=${logic.apikey.value}',
                    source: SvgSource.network,
                  ),
                  height: 1.sw,
                  width: 200,
                  fit: BoxFit.contain,
                );
              },
            )
          : Center(child: Text('暂无数据')),
    );
  }
}
