// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/assets.gen.dart';
import '../constants/colors.dart';
import 'custom_shimmer.dart';

class AppCachedImage extends StatelessWidget {
  final String image;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const AppCachedImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      width: width ?? 100.w,
      height: height ?? 100.h,
      fit: fit ?? BoxFit.cover,
      imageUrl: image,
      placeholder: (context, url) => CustomShimmer(
        child: Container(
          height: height ?? 100.h,
          width: width ?? 100.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            image: DecorationImage(
              image: AssetImage(
                Assets.img.logo.path,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: height ?? 100.h,
        width: width ?? 100.w,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 5.r,
              spreadRadius: 1.r,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Icon(
          Icons.error,
          color: Colors.white,
          size: 20.r,
        ),
      ),
    );
  }
}
