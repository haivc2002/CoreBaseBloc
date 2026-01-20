sealed class Result<S> {
  const Result();

  static const isOk = 1;
  static const isError = -555;
  static const isHttp = -444;
  static const isNotConnect = -111;
  static const isTimeOut = -222;
  static const isDueServer = -333;

}

final class Success<S> extends Result<S> {
  const Success(this.value);
  final S value;
}

final class Failure<S> extends Result<S> {
  const Failure(this.errorCode);
  final int errorCode;
}