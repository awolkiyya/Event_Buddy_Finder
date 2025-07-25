import 'package:event_buddy_finder/commens/notification/data/repository/notification_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc(this.repository) : super(NotificationInitial()) {
    on<InitializeNotification>((event, emit) async {
      await repository.initFCMListeners();
      emit(NotificationLoaded());
    });
  }
}
