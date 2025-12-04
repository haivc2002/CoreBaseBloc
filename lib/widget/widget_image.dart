import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_base_bloc/core_base_bloc.dart';

class WidgetImage extends StatelessWidget {
  final String? image;
  final double? height, width;
  final Widget? errorImage;
  final Widget? loadingImage;
  final BoxFit? fit;
  final double radius;

  WidgetImage({
    super.key,
    this.image,
    this.width,
    this.height,
    this.fit,
    Widget? loadingImage,
    Widget? errorImage,
    double? radius,
  }) : radius = radius ?? d.radius,
       loadingImage = loadingImage ?? d.loadingImage,
       errorImage = errorImage ?? d.errorImage;

  static ConfigImage get d => CoreBaseConfig.instance.configImage ?? ConfigImage();

  @override
  Widget build(BuildContext context) {
    if (image == null || image!.isEmpty) {
      return _errorWidget();
    }

    final isNetwork = image!.startsWith("http");
    final isAssets = image!.endsWith(".png") || image!.endsWith(".jpg");

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: (){
        String? finalImage = image;
        if (isNetwork && finalImage != null && finalImage.startsWith('http://')) {
          finalImage = finalImage.replaceFirst('http://', 'https://');
        }

        if(isNetwork) {
          return CachedNetworkImage(
            imageUrl: finalImage!,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            progressIndicatorBuilder: (context, url, progress) => _loadImage(),
            errorWidget: (context, url, error) => _errorWidget(),
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            httpHeaders: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
              'Referer': 'https://smfapi.atin.vn/',
            },
          );
        } else if(isAssets) {
          return Image.asset(
            image!,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _errorWidget(),
          );
        } else {
          return Image.file(
            File(image!),
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _errorWidget(),
          );
        }
      }(),
    );
  }

  Widget _loadImage() {
    return loadingImage ?? Center(child: WidgetWait());
  }

  Widget _errorWidget() {
    return errorImage ?? Icon(Icons.error);
  }
}