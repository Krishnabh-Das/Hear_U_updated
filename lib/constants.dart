// constants.dart
import 'package:get_storage/get_storage.dart';

class AppConstants {
  static final GetStorage _storage = GetStorage();

  // Getter methods to access the values, explicitly allowing null
  static String? get username => _storage.read('username');
  static String? get randname => _storage.read('randname');
  static String? get userId => _storage.read('userId');

  // Setter methods
  static void setUsername(String? value) => _storage.write('username', value);
  static void setRandname(String? value) => _storage.write('randname', value);
  static void setUserId(String? value) => _storage.write('userId', value);

  // Clear all stored values
  static void clear() {
    _storage.remove('username');
    _storage.remove('randname');
    _storage.remove('userId');
  }
}
