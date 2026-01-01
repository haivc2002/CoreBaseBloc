
import 'package:core_base_bloc/core_base_bloc.dart';

class Global {
  static SharedPreferences? _prefs;
  static final Map<String, dynamic> _memoryPrefs = <String, dynamic>{};

  static Future<SharedPreferences> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static void _setString(String key, String value) {
    _prefs?.setString(key, value);
    _memoryPrefs[key] = value;
  }

  static void _setInt(String key, int value) {
    _prefs?.setInt(key, value);
    _memoryPrefs[key] = value;
  }

  static void _setDouble(String key, double value) {
    _prefs?.setDouble(key, value);
    _memoryPrefs[key] = value;
  }

  static void _setBool(String key, bool value) {
    _prefs?.setBool(key, value);
    _memoryPrefs[key] = value;
  }

  static String _getString(String key, {String? def}) {
    String? val;
    if (_memoryPrefs.containsKey(key)) {
      val = _memoryPrefs[key];
    }
    val ??= _prefs?.getString(key);
    val ??= def;
    _memoryPrefs[key] = val;
    return val ?? '';
  }

  static int _getInt(String key, {int? def}) {
    int? val;
    if (_memoryPrefs.containsKey(key)) {
      val = _memoryPrefs[key];
    }
    val ??= _prefs?.getInt(key);
    val ??= def;
    _memoryPrefs[key] = val;
    return val ?? -1;
  }

  static double _getDouble(String key, {double? def}) {
    double? val;
    if (_memoryPrefs.containsKey(key)) {
      val = _memoryPrefs[key];
    }
    val ??= _prefs?.getDouble(key);
    val ??= def;
    _memoryPrefs[key] = val;
    return val ?? -1;
  }

  static bool _getBool(String key, {bool def = false}) {
    bool? val = _prefs?.getBool(key);
    if (val == null && _memoryPrefs.containsKey(key)) {
      val = _memoryPrefs[key];
    } else {
      val ??= def;
    }
    _memoryPrefs[key] = val!;
    return val;
  }

  static Future<bool> _remove(String key) async {
    _memoryPrefs.remove(key);
    return await _prefs?.remove(key) ?? false;
  }

  static Future<bool> _clear() async {
    _memoryPrefs.clear();
    return await _prefs?.clear() ?? false;
  }
}

void storageWrite(String key, Object value) {
  if (value is String) {
    Global._setString(key, value);
  } else if (value is int) {
    Global._setInt(key, value);
  } else if (value is bool) {
    Global._setBool(key, value);
  } else if (value is double) {
    Global._setDouble(key, value);
  } else {
    throw Exception("Unsupported type: ${value.runtimeType}");
  }
}

T? storageRead<T>(String key) {
  if(T == String) {
    return Global._getString(key) as T?;
  } else if(T == double) {
    return Global._getDouble(key) as T?;
  } else if(T == int) {
    return Global._getInt(key) as T?;
  } else if(T == bool) {
    return Global._getBool(key) as T?;
  } else {
    throw Exception("Unsupported type: ${T.runtimeType}");
  }
}

Future<bool> storageRemove(String key) async => Global._remove(key);

Future<bool> storageClear() async => Global._clear();