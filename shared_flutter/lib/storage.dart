import 'package:personnummer/personnummer.dart';
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

  Future storeQuestionnaireDone(String questionnaireId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool(questionnaireId, true);
  }

  bool getQuestionnaireDone(String questionnaireId) {
    return prefs.getBool(questionnaireId) ?? false;
  }

  bool getPersonalIdDone() {
    String? storedPersonalId = getPersonalid();
    if (storedPersonalId != null && Personnummer.valid(storedPersonalId)) {
      return true;
    }
    return false;
  }

  static final Storage _instance = Storage._internal();
  factory Storage() {
    return _instance;
  }
  Storage._internal();
}
