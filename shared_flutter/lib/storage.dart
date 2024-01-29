import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  late SharedPreferences prefs;

  Future reloadPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future storePersonalId(String personalId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('personalId', personalId);
  }

  String? getPersonalid() {
    return prefs.getString('personalId');
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

  Future storeQuestionnaireDone() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool('questionnaire1', true);
  }

  bool getQuestionnaire1Done() {
    return prefs.getBool('questionnaire1') ?? false;
  }

  static final Storage _instance = Storage._internal();
  factory Storage() {
    return _instance;
  }
  Storage._internal();
}
