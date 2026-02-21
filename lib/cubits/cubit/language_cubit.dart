import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/states/language_cubit_state.dart';

class LanguageCubit extends Cubit<LanguageCubitState> {
  LanguageCubit() : super(LanguageCubitLoaded(languageCode: 'en'));

  void toggle() {
    final current = (state as LanguageCubitLoaded).languageCode;

    emit(LanguageCubitLoaded(languageCode: current == 'en' ? 'ar' : 'en'));
  }
}
