import 'package:equatable/equatable.dart';

class Vitals extends Equatable {
  final String bloodPressure;
  final String heartRate;
  final String temperature;

  const Vitals({
    required this.bloodPressure,
    required this.heartRate,
    required this.temperature,
  });

  @override
  List<Object?> get props => [bloodPressure, heartRate, temperature];
}
