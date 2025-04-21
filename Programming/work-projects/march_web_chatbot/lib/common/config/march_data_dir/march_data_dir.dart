
/// Conditional imports based on if 'dart.io' is supported.
///
/// We export calendar_builder 'app_data_dir_web.dart', but if dart.io is supported
/// then we export 'app_data_dir_vm.dart' instead.
export 'march_data_dir_web.dart' if (dart.library.io) 'march_data_dir_vm.dart';