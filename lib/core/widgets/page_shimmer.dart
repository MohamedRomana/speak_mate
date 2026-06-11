import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_shimmer.dart';

/// شيمر تحميل لصفحات التفاصيل/الطلب (صورة + كروت + زر) —
/// يُستخدم بدل سبينر التحميل في كل الصفحات.
class PageShimmer extends StatelessWidget {
  /// ارتفاعات الكروت الوهمية تحت صورة البانر.
  final List<double> cardHeights;
  const PageShimmer({super.key, this.cardHeights = const [120, 180]});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // صورة البانر
          _block(height: 150.h, margin: EdgeInsets.all(16.r)),
          // الكروت
          ...cardHeights.map(
            (h) => _block(
              height: h.h,
              margin: EdgeInsetsDirectional.only(
                start: 16.w,
                end: 16.w,
                bottom: 16.h,
              ),
            ),
          ),
          // الزر
          _block(
            height: 50.h,
            margin: EdgeInsetsDirectional.only(
              start: 40.w,
              end: 40.w,
              top: 8.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _block({required double height, required EdgeInsetsGeometry margin}) {
    return Padding(
      padding: margin,
      child: CustomShimmer(
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
          ),
        ),
      ),
    );
  }
}
