import 'package:fracture_movement/state/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  late SharedPreferences prefs;

  Future reloadPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Credentials? getCredentials() {
    final String? personalNumber = prefs.getString('personalNumber');
    final String? password = prefs.getString('password');

    if (personalNumber != null && password != null) {
      return Credentials(personalNumber, password);
    }

    return null;
  }

  Future storeCredentails(Credentials credentials) async {
    await reloadPrefs();
    await prefs.setString('personalNumber', credentials.personalNumber);
    await prefs.setString('password', credentials.password);
  }

  Future clearCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('personalNumber');
    prefs.remove('password');
  }

  Future storeEventDate(DateTime date) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('eventDate', date.millisecondsSinceEpoch);
  }

  DateTime? getEventDate() {
    int? millisecondsSinceEpoch = prefs.getInt('eventDate');
    if (millisecondsSinceEpoch != null) {
      return DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    }
    return null;
  }

  Future clearEventDate() {
    return prefs.remove('eventDate');
  }

  static final Storage _instance = Storage._internal();
  factory Storage() {
    return _instance;
  }
  Storage._internal();
}
