import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/notification_entity.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.watch(firestoreProvider));
});

final notificationStreamProvider =
    StreamProvider.family<List<NotificationEntity>, String>((ref, parentId) {
      return ref
          .watch(notificationRepositoryProvider)
          .streamNotifications(parentId);
    });

// Using a StateNotifier or Controller isn't strictly needed for read/markRead if we access repo directly,
// but let's keep it consistent if needed. For now, simple repo usage via ref is fine in widgets.
// Or we can make a simple Controller for actions.

class NotificationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> markAsRead(String parentId, String notificationId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(notificationRepositoryProvider)
          .markAsRead(parentId, notificationId),
    );
  }

  Future<void> markAllAsRead(String parentId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(notificationRepositoryProvider).markAllAsRead(parentId),
    );
  }
}

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, void>(
      NotificationController.new,
    );
