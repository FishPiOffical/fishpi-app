import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';

import '../../../widgets/metail_widget.dart';
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
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MedalWidget(
                        medal: logic.metals[index],
                      ),
                      10.verticalSpace,
                      Text(logic.metals[index].description)
                    ],
                  ),
                );
              },
            )
          : const Center(child: Text('暂无数据')),
    );
  }
}
