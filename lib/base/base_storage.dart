import '../common/global.dart';

mixin class BaseStorage {

  void storageWrite(String key, Object value) {
    if (value is String) {
      Global.setString(key, value);
    } else if (value is int) {
      Global.setInt(key, value);
    } else if (value is bool) {
      Global.setBool(key, value);
    } else if (value is double) {
      Global.setDouble(key, value);
    } else {
      throw Exception("Unsupported type: ${value.runtimeType}");
    }
  }

  T? storageRead<T>(String key) {
    if(T == String) {
      return Global.getString(key) as T?;
    } else if(T == double) {
      return Global.getDouble(key) as T?;
    } else if(T == int) {
      return Global.getInt(key) as T?;
    } else if(T == bool) {
      return Global.getBool(key) as T?;
    } else {
      throw Exception("Unsupported type: ${T.runtimeType}");
    }
  }

  Future<bool> storageRemove(String key) async => Global.remove(key);

  Future<bool> storageClear() async => Global.clear();
}