// lib/core/theme/bloc/theme_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState.light()) {
    on<ToggleThemeEvent>((event, emit) {
      emit(state.isDarkMode ? ThemeState.light() : ThemeState.dark());
    });
  }
}
