import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:flutter/cupertino.dart';

mixin BaseUtilities {
  ECWidget eCWidget(Object? errorCode, {Function()? onTap}) {
    if (errorCode.runtimeType != String && errorCode.runtimeType != int) {
      throw ArgumentError('errorCode must be String or type Result. -> "int"');
    }
    return ECWidget._(errorCode, onTap: onTap);
  }
}

class ECWidget extends StatelessWidget {
  final Object? _errorCode;
  final Function()? onTap;

  const ECWidget._(this._errorCode, {this.onTap}) : assert(
  _errorCode == null || _errorCode is int || _errorCode is String,
  "Type only recognizes int or String",
  );

  String get _getDefaultMessage {
    if(_errorCode is String) return _errorCode;
    switch (_errorCode) {
      case Result.isHttp:
        return "Lỗi kết nối, vui lòng thử lại sau.";
      case Result.isTimeOut:
        return "Máy chủ không phản hồi, vui lòng thử lại.";
      case Result.isNotConnect:
        return "Không có kết nối mạng, hãy kiểm tra Internet và thử lại.";
      case Result.isDueServer:
        return "Máy chủ không phản hồi, vui lòng thử lại.";
      case Result.isError:
        return "Đã xảy ra lỗi, vui lòng thử lại.";
      default:
        return "Máy chủ bận!";
    }
  }

  Widget _buildErrorContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _getErrorIcon,
        const SizedBox(height: 12),
        Text(
          _getDefaultMessage,
          style: Theme.of(context).textTheme.labelMedium,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget get _getErrorIcon {
    IconData iconData;
    switch (_errorCode) {
      case Result.isHttp:
        iconData = Icons.nearby_error;
        break;
      case Result.isTimeOut:
        iconData = CupertinoIcons.timer;
        break;
      case Result.isDueServer:
        iconData = CupertinoIcons.exclamationmark_circle;
        break;
      case Result.isNotConnect:
        iconData = CupertinoIcons.wifi_slash;
        break;
      case Result.isError:
        iconData = CupertinoIcons.xmark_circle;
        break;
      default:
        iconData = CupertinoIcons.info;
    }
    return Builder(
      builder: (context) {
        return Icon(iconData, size: 60, color: Theme.of(context).iconTheme.color);
      }
    );
  }

  String get onlyMesStr {
    String message = _getDefaultMessage;
    return message;
  }

  Widget get onlyMesWidget {
    return Builder(
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _getDefaultMessage,
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if(onTap != null) _reTryAction(context),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildErrorContent(context),
        if(onTap != null) _reTryAction(context),
      ],
    );
  }

  Widget _reTryAction(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        width: 120,
        child: WidgetButton(
          title: "Thử lại",
          contentStyle: Theme.of(context).textTheme.labelMedium?.sColor(Colors.white),
          onTap: onTap,
        ),
      ),
    );
  }
}