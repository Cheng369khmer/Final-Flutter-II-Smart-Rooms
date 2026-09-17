import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/room_model.dart';

abstract class RoomRepository {
  Future<List<RoomModel>> fetchRooms();
  Future<void> updateRoomDevice({
    required String roomId,
    RoomStatus? status,
    bool? acStatus,
    bool? lightStatus,
    bool? lockStatus,
  });
}

class RoomRepositoryImpl implements RoomRepository {
  final DioClient _client;

  RoomRepositoryImpl(this._client);

  @override
  Future<List<RoomModel>> fetchRooms() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.rooms);
      final List<dynamic> data = response.data;
      return data.map((json) => RoomModel.fromJson(json)).toList();
    } on DioException {
      return _mockRooms;
    }
  }

  @override
  Future<void> updateRoomDevice({
    required String roomId,
    RoomStatus? status,
    bool? acStatus,
    bool? lightStatus,
    bool? lockStatus,
  }) async {
    final Map<String, dynamic> body = {};
    if (status != null) body['status'] = status.name;
    if (acStatus != null) body['ac_status'] = acStatus;
    if (lightStatus != null) body['light_status'] = lightStatus;
    if (lockStatus != null) body['lock_status'] = lockStatus;

    await _client.dio.patch('${ApiEndpoints.rooms}/$roomId', data: body);
  }

  // Mock Data (បានបន្ថែម building)
  static const List<RoomModel> _mockRooms = [
    RoomModel(
      id: '1',
      building: 'អគារ A',
      roomNumber: 'A101',
      floor: 1,
      roomType: 'បន្ទប់រៀន',
      status: RoomStatus.ready,
      acStatus: false,
      lightStatus: false,
      lockStatus: true,
    ),
    RoomModel(
      id: '2',
      building: 'អគារ B',
      roomNumber: 'B203',
      floor: 2,
      roomType: 'បន្ទប់ប្រជុំ',
      status: RoomStatus.inProgress,
      acStatus: true,
      lightStatus: true,
      lockStatus: false,
    ),
    RoomModel(
      id: '3',
      building: 'អគារ C',
      roomNumber: 'C305',
      floor: 3,
      roomType: 'បន្ទប់វិទ្យាធិការ',
      status: RoomStatus.outOfOrder,
      acStatus: false,
      lightStatus: false,
      lockStatus: true,
    ),
  ];
}
