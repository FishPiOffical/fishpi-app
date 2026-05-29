import 'dart:convert';

import 'package:fishpi_app/core/manager/login_im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scan/scan.dart';

import '../core/controller/im.dart';
import '../utils/pi_utils.dart';

typedef ScanViewBuilder = Widget Function(
  ScanController controller,
  CaptureCallback onCapture,
);

class PiScan extends StatefulWidget {
  const PiScan({
    super.key,
    this.scanViewBuilder,
  });

  final ScanViewBuilder? scanViewBuilder;

  @override
  State<PiScan> createState() => _PiScanState();
}

class _PiScanState extends State<PiScan> {
  final ScanController _controller = ScanController();
  IconData _lightIcon = Icons.flash_on;
  bool _isClosing = false;
  bool _hasHandledResult = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) async {
            _releaseBeforeLeave();
          },
          child: Stack(
            children: [
              _buildScanView(),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.w, top: 12.h),
                  child: GestureDetector(
                    key: const ValueKey('scan_back_button'),
                    behavior: HitTestBehavior.opaque,
                    onTap: _closeScanner,
                    child: Container(
                      width: 42.w,
                      height: 42.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(21.w),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.white,
                        size: 20.w,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 100.w,
                bottom: 100.h,
                child: MaterialButton(
                  key: const ValueKey('scan_flash_button'),
                  child: Icon(
                    _lightIcon,
                    size: 40.w,
                    color: Styles.primaryColor,
                  ),
                  onPressed: () {
                    _controller.toggleTorchMode();
                    setState(() {
                      _lightIcon = _lightIcon == Icons.flash_on
                          ? Icons.flash_off
                          : Icons.flash_on;
                    });
                  },
                ),
              ),
              Positioned(
                right: 100.w,
                bottom: 100.h,
                child: MaterialButton(
                  key: const ValueKey('scan_album_button'),
                  onPressed: _pickImageAndScan,
                  child: Icon(
                    Icons.image,
                    size: 40.w,
                    color: Styles.primaryColor,
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildScanView() {
    final builder = widget.scanViewBuilder;
    if (builder != null) {
      return builder(_controller, _handleCapture);
    }
    return ScanView(
      controller: _controller,
      scanLineColor: Styles.primaryColor,
      onCapture: _handleCapture,
    );
  }

  Future<void> _pickImageAndScan() async {
    if (_isClosing || _hasHandledResult) return;
    _controller.pause();
    final res = await ImagePicker().pickMultiImage();
    if (!mounted || _isClosing || _hasHandledResult) return;
    if (res.isEmpty) {
      _controller.resume();
      return;
    }
    final XFile image = res.first;
    final result = await Scan.parse(image.path);
    if (!mounted || _isClosing || _hasHandledResult) return;
    if (result != null && result.isNotEmpty) {
      await _handleCapture(result);
    } else {
      _controller.resume();
    }
  }

  Future<void> _handleCapture(String result) async {
    if (_isClosing || _hasHandledResult) return;
    _hasHandledResult = true;
    _controller.pause();
    await getResult(result);
  }

  void _releaseBeforeLeave() {
    _controller.pause();
    LoginIM.close();
  }

  void _markClosing() {
    _isClosing = true;
    _releaseBeforeLeave();
  }

  void _closeScanner() {
    if (_isClosing) return;
    _markClosing();
    Get.back();
  }

  Future<void> getResult(String result) async {
    final imController = Get.find<IMController>();
    if (result.startsWith('login')) {
      bool isLogin = await PiUtils.hasToken();
      if (isLogin) {
        ToastManager.showToast('请先退出当前帐号!');
        _closeScanner();
        return;
      }
      final token = _readScanValue(result);
      if (token.isEmpty) {
        ToastManager.showToast('二维码无效');
        _closeScanner();
        return;
      }
      await imController.init(token);
      ToastManager.showToast('登录成功');
      await PiUtils.saveToken(token);
      _markClosing();
      AppNavigator.closeAllToHome();
    } else if (result.startsWith('web')) {
      bool isLogin = await PiUtils.hasToken();
      if (!isLogin) {
        ToastManager.showToast('请登录后尝试!');
        _closeScanner();
        return;
      }
      final targetId = _readScanValue(result);
      if (targetId.isEmpty) {
        ToastManager.showToast('二维码无效');
        _closeScanner();
        return;
      }
      try {
        await LoginIM.initWS();
        LoginIM.send(jsonEncode({
          "type": 3,
          "targetId": targetId,
        }));
        await Future.delayed(const Duration(seconds: 1));
        String apiKey = await PiUtils.getToken();
        LoginIM.send(jsonEncode({
          "type": 2,
          "targetId": targetId,
          "apiKey": apiKey,
        }));
        ToastManager.showToast('登录成功!');
        await Future.delayed(const Duration(milliseconds: 300));
        _closeScanner();
      } catch (_) {
        ToastManager.showToast('网页登录连接失败，请稍后重试');
        _closeScanner();
      }
    } else {
      _markClosing();
      AppNavigator.toScanResult(result);
    }
  }

  String _readScanValue(String result) {
    final index = result.indexOf(':');
    if (index < 0 || index == result.length - 1) return '';
    return result.substring(index + 1);
  }

  @override
  void dispose() {
    _releaseBeforeLeave();
    super.dispose();
  }
}
