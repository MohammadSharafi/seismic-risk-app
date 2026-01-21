import 'package:equatable/equatable.dart';

enum Status {
  monitoring,
  needsReview,
  actionTaken;

  String get displayName {
    switch (this) {
      case Status.monitoring:
        return 'Monitoring';
      case Status.needsReview:
        return 'Needs Review';
      case Status.actionTaken:
        return 'Action Taken';
    }
  }

  static Status fromString(String value) {
    switch (value.toLowerCase().replaceAll(' ', '')) {
      case 'monitoring':
        return Status.monitoring;
      case 'needsreview':
        return Status.needsReview;
      case 'actiontaken':
        return Status.actionTaken;
      default:
        return Status.monitoring;
    }
  }
}
