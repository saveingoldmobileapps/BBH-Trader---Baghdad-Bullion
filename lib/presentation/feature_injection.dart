import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';

final getLocator = GetIt.instance;

void setupLocator() {
  /// Register your services
  // locator.registerLazySingleton<GetStartedProvider>(() => GetStartedProvider());
  getLocator.registerLazySingleton<Logger>(() => Logger());
  getLocator.registerLazySingleton<LocalDatabase>(() => LocalDatabase());
}
