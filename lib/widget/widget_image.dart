import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:core_base_bloc/core_config/core_base_cubit.dart';

class WidgetImage extends StatelessWidget {
  final String? image;
  final double? height, width;
  final Widget? errorImage;
  final Widget? loadingImage;
  final BoxFit? fit;
  final double? radius;
  final Color? color;

  const WidgetImage({
    super.key,
    this.image,
    this.width,
    this.height,
    this.fit,
    this.loadingImage,
    this.errorImage,
    this.radius,
    this.color
  });

  @override
  Widget build(BuildContext context) {
    final sys = context.watch<CoreBaseCubit>().state.initBaseWidget?.configImage ?? ConfigImage();
    final resultRadius = radius ?? sys.radius;
    final resultLoadingImage = loadingImage ?? sys.loadingImage;
    final resultErrorImage = errorImage ?? sys.errorImage;
    if (image == null || image!.isEmpty) return _errorWidget(resultErrorImage);

    final isNetwork = image!.startsWith("http");
    final isAssets = image!.endsWith(".png") || image!.endsWith(".jpg");

    return ClipRRect(
      borderRadius: BorderRadius.circular(resultRadius),
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
            progressIndicatorBuilder: (context, url, progress) => _loadImage(resultLoadingImage),
            errorWidget: (context, url, error) => _errorWidget(resultErrorImage),
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
            errorBuilder: (context, error, stackTrace) => _errorWidget(resultErrorImage),
          );
        } else {
          return Image.file(
            File(image!),
            height: height,
            width: width,
            color: color,
            fit: fit ?? BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _errorWidget(resultErrorImage),
          );
        }
      }(),
    );
  }

  Widget _loadImage(Widget? loading) {
    return loading ?? Center(child: WidgetWait());
  }

  Widget _errorWidget(Widget? error) {
    return error ?? Icon(Icons.error);
  }
}