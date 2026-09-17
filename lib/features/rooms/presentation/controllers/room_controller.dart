import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/models/room_model.dart';
import '../../data/repositories/room_repository.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  return RoomRepositoryImpl(client);
});

class RoomNotifier extends AsyncNotifier<List<RoomModel>> {
  @override
  Future<List<RoomModel>> build() async {
    final repository = ref.watch(roomRepositoryProvider);
    return repository.fetchRooms();
  }

  Future<void> loadRooms() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(roomRepositoryProvider);
      return repository.fetchRooms();
    });
  }
}

final roomControllerProvider =
    AsyncNotifierProvider<RoomNotifier, List<RoomModel>>(() {
      return RoomNotifier();
    });
