import 'package:fracture_movement/pocketbase.dart';
import 'package:fracture_movement/storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:push/push.dart';

class Credentials {
  final String personalNumber;
  final String password;

  Credentials(this.personalNumber, this.password);
}

class Auth extends StateNotifier<RecordAuth?> {
  Auth([Credentials? credentials]) : super(null) {
    init(credentials);
  }

  Future<void> init(Credentials? credentials) async {
    if (credentials == null) {
      return;
    }

    try {
      state = await pb
          .collection('users')
          .authWithPassword(credentials.personalNumber, credentials.password);
    } catch (e) {
      Storage().clearCredentials();
      rethrow;
    }
  }

  Future login(Credentials credentials) async {
    try {
      state = await pb
          .collection('users')
          .authWithPassword(credentials.personalNumber, credentials.password);
      Storage().storeCredentails(credentials);
    } catch (e) {
      rethrow;
    }
  }

  Future signup(Credentials credentials) async {
    try {
      await pb.collection('users').create(body: {
        'username': credentials.personalNumber,
        'password': credentials.password,
        'passwordConfirm': credentials.password,
      });

      state = await pb
          .collection('users')
          .authWithPassword(credentials.personalNumber, credentials.password);
      Storage().storeCredentails(credentials);
      await Push.instance.requestPermission();
      await pb.collection('users').update(state!.record!.id, body: {
        'device_token': await Push.instance.token,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future updatePassword(String newPassword) async {
    try {
      Credentials? credentials = Storage().getCredentials();
      await pb.collection('users').update(state!.record!.id, body: {
        'oldPassword': credentials?.password,
        'password': newPassword,
        'passwordConfirm': newPassword,
      });
      Storage().storeCredentails(Credentials(
        credentials!.personalNumber,
        newPassword,
      ));
    } catch (e) {
      rethrow;
    }
  }

  Future logout() async {
    state = null;
    Storage().clearCredentials();
  }

  Future toggleNotifications(bool enabled) async {
    try {
      if (enabled) {
        await Push.instance.requestPermission();
      }
      String? token = await Push.instance.token;
      await pb.collection('users').update(state!.record!.id, body: {
        'device_token': enabled ? token : null,
      });

      state = await pb.collection('users').authRefresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> notificationsEnabled() async {
    try {
      if (state == null) {
        return false;
      }
      final res = await pb.collection('users').getOne(state!.record!.id);
      return res.data['device_token'] != null &&
          res.data['device_token'].isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  Future deleteAccount() async {
    try {
      await pb.collection('users').delete(state!.record!.id);
      state = null;
      Storage().clearCredentials();
    } catch (e) {
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<Auth, RecordAuth?>((ref) => Auth());

// Future submitQuestionnaire(String name, Map<String, dynamic> answers) async {
//   await pb.collection('questionnaires').create(body: {
//     'name': name,
//     'user': pb.authStore.model!.id,
//     'answers': answers,
//   });
// }
