import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/vip_name_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PiTransferPage extends StatelessWidget {
  final ValueChanged onEditingCompleteText;
  final TextEditingController controller = TextEditingController();
  final String user;
  final String? userId;
  final String? userName;
  final OutlineInputBorder border = const OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black,
      width: 2,
    ),
    borderRadius: BorderRadius.all(
      Radius.circular(50),
    ),
  );

  PiTransferPage({
    super.key,
    required this.onEditingCompleteText,
    required this.user,
    this.userId,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.black.withValues(alpha: .5),
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4CC),
                      border: Border.all(color: Colors.black, width: 2.w),
                      borderRadius: BorderRadius.circular(16.w),
                    ),
                    width: 280.w,
                    height: 190.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '转账给',
                              style: TextStyle(
                                color: Styles.primaryTextColor,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Flexible(
                              child: VipNameText(
                                userId: userId,
                                userName: userName ?? user,
                                fallback: user,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: const Color(0xFFEB3805),
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '转账后积分即时到账，请谨慎交易！',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Styles.primaryTextColor,
                          ),
                        ),
                        TextField(
                          controller: controller,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Styles.primaryTextColor,
                          ),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: '转账金额',
                            hintStyle: const TextStyle(
                              color: Styles.primaryTextColor,
                            ),
                            contentPadding:
                                const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            filled: true,
                            fillColor: Colors.white,
                            border: border,
                            enabledBorder: border,
                            focusedBorder: border,
                            prefixIcon: const Icon(
                              Icons.monetization_on_outlined,
                            ),
                            counterText: "",
                          ),
                          maxLength: 9,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 110.w,
                                height: 35.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: Styles.primaryTextColor,
                                    width: 2.w,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '算了',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Styles.primaryTextColor,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                onEditingCompleteText(controller.text);
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 110.w,
                                height: 35.h,
                                decoration: BoxDecoration(
                                  color: Styles.primaryTextColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: Styles.primaryTextColor,
                                    width: 2.w,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '转账',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
