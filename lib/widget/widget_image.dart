import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:core_base_bloc/core_config/core_base_config_cubit.dart';

class WidgetImage extends StatelessWidget {
  final String? image;
  final double? height, width;
  final Widget? errorImage;
  final Widget? loadingImage;
  final BoxFit? fit;
  final double radius;
  final Color? color;

  const WidgetImage({
    super.key,
    this.image,
    this.width,
    this.height,
    this.fit,
    this.loadingImage,
    this.errorImage,
    this.radius = 0,
    this.color
  });

  @override
  Widget build(BuildContext context) {
    if (image == null || image!.isEmpty) return _errorWidget;

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
            color: color,
            fit: fit ?? BoxFit.cover,
            progressIndicatorBuilder: (context, url, progress) {
              return loadingImage ?? Center(child: WidgetWait());
            },
            errorWidget: (context, url, error) => _errorWidget,
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
            color: color,
            fit: fit ?? BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _errorWidget,
          );
        } else {
          return Image.file(
            File(image!),
            height: height,
            width: width,
            color: color,
            fit: fit ?? BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _errorWidget,
          );
        }
      }(),
    );
  }

  Widget get _errorWidget {
    return errorImage ?? Icon(Icons.error);
  }
}