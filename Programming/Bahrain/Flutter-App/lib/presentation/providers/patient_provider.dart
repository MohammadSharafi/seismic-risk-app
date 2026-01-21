import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/patient_repository.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../../domain/repositories/visit_repository.dart';
import '../../infrastructure/repositories/patient_repository_impl.dart';
import '../../infrastructure/repositories/alarm_repository_impl.dart';
import '../../infrastructure/repositories/visit_repository_impl.dart';

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepositoryImpl();
});

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  return AlarmRepositoryImpl();
});

final visitRepositoryProvider = Provider<VisitRepository>((ref) {
  return VisitRepositoryImpl();
});

final patientsProvider = FutureProvider((ref) async {
  final repository = ref.watch(patientRepositoryProvider);
  return await repository.getAllPatients();
});

final alarmsProvider = FutureProvider((ref) async {
  final repository = ref.watch(alarmRepositoryProvider);
  return await repository.getAllAlarms();
});
