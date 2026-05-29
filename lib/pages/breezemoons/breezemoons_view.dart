import 'package:fishpi/types/breezemoon.dart';
import 'package:fishpi_app/widgets/pi_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../res/styles.dart';
import '../../res/view.dart';
import '../../widgets/pi_breezemoon_item.dart';
import '../../widgets/pi_list_state.dart';
import 'breezemoons_logic.dart';

class BreezemoonsPage extends StatelessWidget {
  final BreezemoonsLogic logic = Get.find<BreezemoonsLogic>();

  BreezemoonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Container(
          width: 1.sw,
          height: 1.sh,
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
          ),
          child: SmartRefresher(
            controller: logic.refresherController,
            header: Views.buildHeader(),
            footer: Views.buildFooter(),
            enablePullUp: true,
            enablePullDown: true,
            onRefresh: logic.onRefresh,
            onLoading: logic.onLoading,
            child: ListView.builder(
              key: const ValueKey('breezemoon_scroll_list'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 20.h),
              itemBuilder: _buildBreezemoonList,
              itemCount: logic.list.isEmpty ? 2 : logic.list.length + 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreezemoonList(
    BuildContext context,
    int idx,
  ) {
    if (idx == 0) {
      return _buildPublishBox();
    }
    if (logic.list.isEmpty) {
      return _buildListState();
    }
    BreezemoonContent item = logic.list[idx - 1];
    return PiBreezemoonItem(breezemoon: item);
  }

  Widget _buildPublishBox() {
    return Obx(() {
      final error = logic.sendErrorText.value.trim();
      final overflow = logic.isContentOverflow;
      final helperText = error.isNotEmpty
          ? error
          : overflow
              ? '内容超过 ${BreezemoonsLogic.maxContentLength} 字，请精简后再发布'
              : '';
      final helperColor =
          helperText.isEmpty ? Styles.secondaryTextColor : Colors.redAccent;

      return Container(
        margin: EdgeInsets.only(bottom: 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40.h,
                    child: PiInput(
                      key: const ValueKey('breezemoon_publish_input'),
                      controller: logic.textEditingController,
                      onInputChanged: logic.onInputChanged,
                      hintText: '随便说说...',
                      textAlign: TextAlign.left,
                      textInputAction: TextInputAction.send,
                      onEditingComplete: logic.sendBreezemoon,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                _BreezemoonSendButton(logic: logic),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    helperText,
                    key: const ValueKey('breezemoon_send_error'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: helperColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${logic.contentLength}/${BreezemoonsLogic.maxContentLength}',
                  key: const ValueKey('breezemoon_content_counter'),
                  style: TextStyle(
                    color:
                        overflow ? Colors.redAccent : Styles.secondaryTextColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildListState() {
    return Obx(() {
      final error = logic.errorText.value.trim();
      final hasError = error.isNotEmpty;
      return PiListState(
        key: const ValueKey('breezemoon_list_state'),
        retryKey: const ValueKey('breezemoon_list_retry_button'),
        icon: hasError ? Icons.cloud_off_outlined : Icons.air_outlined,
        title: hasError ? '清风明月加载失败' : '暂无清风明月',
        message: hasError ? error : '下拉刷新，或者先写下此刻想说的话。',
        onRetry: logic.onRefresh,
      );
    });
  }
}

class _BreezemoonSendButton extends StatelessWidget {
  const _BreezemoonSendButton({required this.logic});

  final BreezemoonsLogic logic;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canSend = logic.canSend;
      final isSending = logic.isSending.value;
      final hasError = logic.sendErrorText.value.trim().isNotEmpty;

      return Semantics(
        button: true,
        enabled: canSend,
        label: isSending ? '清风明月发布中' : '发布清风明月',
        child: AnimatedOpacity(
          opacity: canSend || isSending ? 1 : 0.42,
          duration: const Duration(milliseconds: 150),
          child: Material(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10.r),
            child: InkWell(
              key: const ValueKey('breezemoon_send_button'),
              borderRadius: BorderRadius.circular(10.r),
              onTap: canSend ? logic.sendBreezemoon : null,
              child: Container(
                width: 64.w,
                height: 40.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: isSending
                      ? Row(
                          key: const ValueKey('breezemoon_sending_label'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12.w,
                              height: 12.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '发送中',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          hasError ? '重试' : '发布',
                          key: ValueKey(
                            hasError
                                ? 'breezemoon_retry_label'
                                : 'breezemoon_publish_label',
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
