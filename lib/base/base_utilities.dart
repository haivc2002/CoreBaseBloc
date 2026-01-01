import 'package:core_base_bloc/base/base_context.dart';
import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:flutter/cupertino.dart';

mixin class BaseUtilities {

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

  String _getDefaultMessage() {
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

  Widget _buildErrorContent(String message, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _getErrorIcon(),
        const SizedBox(height: 12),
        Text(
          message,
          style: textStyleWithCtx(context).sColor(Colors.black54).medium,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _getErrorIcon() {
    IconData iconData;
    switch (_errorCode) {
      case Result.isHttp:
      case Result.isTimeOut:
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
    return Icon(iconData, size: 60, color: Colors.black54.withValues(alpha: 0.7));
  }

  String get onlyMesStr {
    String message = _getDefaultMessage();
    return message;
  }

  Widget onlyMesWidget(BuildContext context) {
    String message = _getDefaultMessage();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          message,
          style: textStyleWithCtx(context).sColor(Colors.black54).medium,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        if(onTap != null) _reTryAction(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String message = _getDefaultMessage();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildErrorContent(message, context),
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
          vertical: 8,
          title: "Thử lại",
          contentStyle: textStyleWithCtx(context).sColor(Colors.white).medium,
          onTap: onTap,
        ),
      ),
    );
  }
}