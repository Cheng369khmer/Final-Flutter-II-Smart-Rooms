import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../rooms/presentation/controllers/room_controller.dart';
import '../../rooms/data/models/room_model.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomState = ref.watch(roomControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'របាយការណ៍រួម (Live Overview)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: roomState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rooms) {
          final buildingA = rooms.where((r) => r.building == 'អគារ A').toList();
          final buildingB = rooms.where((r) => r.building == 'អគារ B').toList();
          final buildingC = rooms.where((r) => r.building == 'អគារ C').toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ទិដ្ឋភាពទូទៅនៃអគារទាំង ៣',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildBuildingReportCard(
                  'អគារ A',
                  buildingA,
                  '៦០ បន្ទប់ (បន្ទប់រៀន & Lab)',
                  Colors.blue,
                ),
                _buildBuildingReportCard(
                  'អគារ B',
                  buildingB,
                  '២០ បន្ទប់ (បន្ទប់ប្រជុំ & សិក្ខាសាលា)',
                  Colors.amber,
                ),
                _buildBuildingReportCard(
                  'អគារ C',
                  buildingC,
                  '៥០ បន្ទប់ (ជាន់ទី ២: Staff & HR)',
                  Colors.purple,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBuildingReportCard(
    String name,
    List<RoomModel> rooms,
    String desc,
    Color color,
  ) {
    final ready = rooms.where((r) => r.status == RoomStatus.ready).length;
    final inProgress = rooms
        .where((r) => r.status == RoomStatus.inProgress)
        .length;
    final outOfOrder = rooms
        .where((r) => r.status == RoomStatus.outOfOrder)
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(Icons.business, color: color),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      desc,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'រួចរាល់៖ $ready',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'កំពុងរៀបចំ៖ $inProgress',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ផ្អាក/ខូច៖ $outOfOrder',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
