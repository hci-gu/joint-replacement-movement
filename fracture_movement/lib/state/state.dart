import 'package:flutter/cupertino.dart';
import 'package:fracture_movement/storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/state.dart';
import 'package:personnummer/personnummer.dart';
import 'package:pocketbase/pocketbase.dart';

class Credentials {
  final String personalNumber;
  final String password;

  Credentials(this.personalNumber, this.password);
}

final pb = PocketBase('http://127.0.0.1:8090');

class Auth extends StateNotifier<RecordAuth?> {
  Auth([Credentials? credentials]) : super(null) {
    init(credentials);
  }

  Future<void> init(Credentials? credentials) async {
    if (credentials == null) {
      return;
    }

    state = await pb
        .collection('users')
        .authWithPassword(credentials.personalNumber, credentials.password);
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
    } catch (e) {
      rethrow;
    }
  }

  Future logout() async {
    state = null;
    Storage().clearCredentials();
  }
}

final authProvider = StateNotifierProvider<Auth, RecordAuth?>((ref) => Auth());
