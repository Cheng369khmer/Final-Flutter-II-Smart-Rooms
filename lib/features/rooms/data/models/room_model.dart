enum RoomStatus { ready, inProgress, outOfOrder }

class RoomModel {
  final String id;
  final String building;
  final String roomNumber;
  final int floor;
  final String roomType;
  final RoomStatus status;
  final bool acStatus;
  final bool lightStatus;
  final bool lockStatus;

  const RoomModel({
    required this.id,
    required this.building,
    required this.roomNumber,
    required this.floor,
    required this.roomType,
    required this.status,
    required this.acStatus,
    required this.lightStatus,
    required this.lockStatus,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? '',
      building: json['building'] ?? 'អគារ A',
      roomNumber: json['room_number'] ?? '',
      floor: json['floor'] ?? 1,
      roomType: json['room_type'] ?? 'បន្ទប់ទូទៅ',
      status: _parseStatus(json['status']),
      acStatus: json['ac_status'] ?? false,
      lightStatus: json['light_status'] ?? false,
      lockStatus: json['lock_status'] ?? true,
    );
  }

  static RoomStatus _parseStatus(String? status) {
    switch (status) {
      case 'ready':
        return RoomStatus.ready;
      case 'inProgress':
        return RoomStatus.inProgress;
      default:
        return RoomStatus.outOfOrder;
    }
  }
}
