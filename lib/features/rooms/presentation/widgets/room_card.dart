import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/room_model.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onTap;

  const RoomCard({super.key, required this.room, required this.onTap});

  Color _getStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.ready:
        return AppColors.statusReady;
      case RoomStatus.inProgress:
        return AppColors.statusInProgress;
      case RoomStatus.outOfOrder:
        return AppColors.statusOutOfOrder;
    }
  }

  String _getStatusText(RoomStatus status) {
    switch (status) {
      case RoomStatus.ready:
        return 'រួចរាល់';
      case RoomStatus.inProgress:
        return 'កំពុងរៀបចំ';
      case RoomStatus.outOfOrder:
        return 'ផ្អាក/ខូច';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(room.status).withValues(alpha: 0.15),
          child: Icon(Icons.meeting_room, color: _getStatusColor(room.status)),
        ),
        title: Text(
          'បន្ទប់ ${room.roomNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ប្រភេទ៖ ${room.roomType} | ជាន់ទី ${room.floor}'),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  room.acStatus ? Icons.ac_unit : Icons.ac_unit_outlined,
                  size: 16,
                  color: room.acStatus ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 8),
                Icon(
                  room.lightStatus ? Icons.lightbulb : Icons.lightbulb_outline,
                  size: 16,
                  color: room.lightStatus ? Colors.amber : Colors.grey,
                ),
                const SizedBox(width: 8),
                Icon(
                  room.lockStatus ? Icons.lock : Icons.lock_open,
                  size: 16,
                  color: room.lockStatus ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(room.status),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getStatusText(room.status),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
