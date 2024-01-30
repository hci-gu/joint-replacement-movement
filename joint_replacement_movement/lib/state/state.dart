import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/state.dart';
import 'package:movement_code/storage.dart';
import 'package:personnummer/personnummer.dart';

final canContinueProvider = Provider((ref) {
  final step = ref.watch(onboardingStepProvider);
  final personalId = ref.watch(personalIdProvider);
  final operationDate = ref.watch(operationDateProvider);
  final movementForm = ref.watch(movementFormProvider);

  switch (step) {
    case 0:
      return true;
    case 1:
      return Storage().getPersonalIdDone() ||
          (operationDate != null && Personnummer.valid(personalId));
    case 2:
      return movementForm.questionDuration1 != null &&
          movementForm.questionDuration2 != null;
    case 3:
      return true;
    default:
      return false;
  }
});
