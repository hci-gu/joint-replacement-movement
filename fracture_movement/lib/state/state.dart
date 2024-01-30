import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/state.dart';
import 'package:personnummer/personnummer.dart';

final canContinueProvider = Provider((ref) {
  final step = ref.watch(onboardingStepProvider);
  final personalId = ref.watch(personalIdProvider);

  switch (step) {
    case 0:
      return true;
    case 1:
      return Personnummer.valid(personalId);
    case 3:
      return true;
    default:
      return false;
  }
});
