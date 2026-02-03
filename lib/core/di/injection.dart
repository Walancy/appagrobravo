import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: false, // Permitir apenas imports absolutos no pacote
  asExtension: true, // default
)
void configureDependencies() => getIt.init();
