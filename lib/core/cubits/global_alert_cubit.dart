import 'package:flutter_bloc/flutter_bloc.dart';

class GlobalAlertCubit extends Cubit<bool> {
  GlobalAlertCubit()
    : super(false); // false = not dismissed (visible if needed)

  void dismiss() => emit(true);
  void reset() => emit(false);
}
