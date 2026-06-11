import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../gen/assets.gen.dart';

class CustomLottieWidget extends StatelessWidget {
  final String? lottieName;
  final double? height;
  final double? width;
  final double top;
  final double bottom;
  final double start;
  final double end;

  const CustomLottieWidget({
    super.key,
    this.lottieName,
    this.height,
    this.width,
    this.top = 0.0,
    this.bottom = 0.0,
    this.start = 0.0,
    this.end = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: top,
        bottom: bottom,
        start: start,
        end: end,
      ),
      child: Center(
        child: Lottie.asset(
          lottieName ?? Assets.img.loading,
          width: width ?? 350.w,
          height: height ?? 350.w,
          repeat: true,
          animate: true,
          onLoaded: (composition) {},
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
