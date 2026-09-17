import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/room_model.dart';
import '../../data/repositories/room_detail_screen.dart';
import '../controllers/room_controller.dart';
import '../widgets/room_card.dart';

class RoomListScreen extends ConsumerStatefulWidget {
  const RoomListScreen({super.key});

  @override
  ConsumerState<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends ConsumerState<RoomListScreen> {
  String _selectedBuilding = 'ទាំងអស់';

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(roomControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'គ្រប់គ្រងបន្ទប់ឆ្លាតវៃ (Smart Rooms)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(roomControllerProvider.notifier).loadRooms(),
          ),
        ],
      ),
      body: roomState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('មានបញ្ហា៖ $error')),
        data: (allRooms) {
          // ចម្រាញ់តាមអគារ
          final filteredRooms = _selectedBuilding == 'ទាំងអស់'
              ? allRooms
              : allRooms.where((r) => r.building == _selectedBuilding).toList();

          final readyCount = allRooms
              .where((r) => r.status == RoomStatus.ready)
              .length;
          final inProgressCount = allRooms
              .where((r) => r.status == RoomStatus.inProgress)
              .length;
          final outOfOrderCount = allRooms
              .where((r) => r.status == RoomStatus.outOfOrder)
              .length;

          return Column(
            children: [
              // ១. ផ្ទាំងសង្ខេបស្ថិតិបន្ទប់សរុប (Total Overview Cards)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'បន្ទប់សរុបទាំងអស់',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          '${allRooms.length} បន្ទប់',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatChip(
                          'រួចរាល់',
                          '$readyCount',
                          Colors.greenAccent,
                        ),
                        _buildStatChip(
                          'កំពុងរៀបចំ',
                          '$inProgressCount',
                          Colors.amberAccent,
                        ),
                        _buildStatChip(
                          'ផ្អាក/ខូច',
                          '$outOfOrderCount',
                          Colors.redAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ២. Tabs សម្រាប់ Filter តាមអគារ A, B, C
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip('ទាំងអស់ (${allRooms.length})', 'ទាំងអស់'),
                    const SizedBox(width: 8),
                    _buildFilterChip('អគារ A (៦០)', 'អគារ A'),
                    const SizedBox(width: 8),
                    _buildFilterChip('អគារ B (២០)', 'អគារ B'),
                    const SizedBox(width: 8),
                    _buildFilterChip('អគារ C (៥០ - HR/Staff)', 'អគារ C'),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ៣. បញ្ជីបន្ទប់
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(roomControllerProvider.notifier).loadRooms(),
                  child: ListView.builder(
                    itemCount: filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = filteredRooms[index];
                      return RoomCard(
                        room: room,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RoomDetailScreen(room: room),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatChip(String title, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedBuilding == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF2563EB),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (_) => setState(() => _selectedBuilding = value),
    );
  }
}
