
import 'package:shared_preferences/shared_preferences.dart';

class PrefsHelper {
  static Future<String> getString(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    return preferences.getString(key) ?? "";
  }

  static Future<bool> getBool(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    return preferences.getBool(key) ?? false;
  }

  static Future setString(String key, value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, value);
  }

  static Future setBool(String key, bool value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(key, value);
  }
  static  Future setInt(String key,int value)async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt(key, value);
  }
  static Future<int> getInt(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt(key)??(-1);
  }
  static Future remove(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.remove(key);
  }
}
































//
// import 'package:logger/logger.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class PrefsHelper {
//   static Future<String> getString(String key) async {
//     Logger _logger = Logger();
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     _logger.i(
//       "$key niye aslam, ami jar value ::===>>> ${preferences.getString(key)}",
//     );
//     return preferences.getString(key) ?? "";
//   }
//
//   static Future<bool> getBool(String key) async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//
//     return preferences.getBool(key) ?? false;
//   }
//
//   static Future setString(String key, value) async {
//     Logger _logger = Logger();
//
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var x = await preferences.setString(key, value);
//
//     if (x) {
//       _logger.i("$key save korlam value dilam::===>>> $value");
//     } else {
//       _logger.i("$key save korte parchi na .... khubi dukkher bisoy");
//     }
//   }
//
//   static Future setBool(String key, bool value) async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     await preferences.setBool(key, value);
//   }
//
//   static Future setInt(String key, int value) async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     await preferences.setInt(key, value);
//   }
//
//   static Future<int> getInt(String key) async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     return preferences.getInt(key) ?? (-1);
//   }
//
//   static Future remove(String key) async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     return preferences.remove(key);
//   }
// }
