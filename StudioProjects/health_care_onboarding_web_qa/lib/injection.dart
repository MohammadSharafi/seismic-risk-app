import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

// Initialize GetIt instance
final GetIt getIt = GetIt.instance;

// Helper function to retrieve dependencies
T inject<T extends Object>() => getIt<T>();

// Initialize dependency injection with environment
@injectableInit
void configureInjection(String environment) {
  getIt.init(environment: environment); // Use generated init method
}

// Module for registering dependencies
@module
abstract class AppModule {
  // Add your dependencies here, e.g.:
  // @lazySingleton
  // SomeService get someService => SomeServiceImpl();
}