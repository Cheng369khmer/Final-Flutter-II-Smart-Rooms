import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_room_app/features/rooms/data/models/room_model.dart';
import 'package:smart_room_app/features/rooms/data/repositories/room_repository.dart';
import 'package:smart_room_app/features/rooms/presentation/controllers/room_controller.dart';

class RoomDetailScreen extends ConsumerStatefulWidget {
  final RoomModel room;
  const RoomDetailScreen({super.key, required this.room});

  @override
  ConsumerState<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends ConsumerState<RoomDetailScreen> {
  late bool _ac;
  late bool _light;
  late bool _lock;
  late RoomStatus _status;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _ac = widget.room.acStatus;
    _light = widget.room.lightStatus;
    _lock = widget.room.lockStatus;
    _status = widget.room.status;
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(roomRepositoryProvider)
          .updateRoomDevice(
            roomId: widget.room.id,
            status: _status,
            acStatus: _ac,
            lightStatus: _light,
            lockStatus: _lock,
          );
      ref.read(roomControllerProvider.notifier).loadRooms();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('បានរក្សាទុកការផ្លាស់ប្តូរទៅកាន់ Server រួចរាល់!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('មានបញ្ហា៖ $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('បន្ទប់ ${widget.room.roomNumber}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ប្រភេទ៖ ${widget.room.roomType}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ជាន់ទី៖ ${widget.room.floor} | លេខកូដសម្គាល់៖ #${widget.room.id}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'បញ្ជាឧបករណ៍ក្នុងបន្ទប់ (IoT Controls)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Icon(
                      Icons.ac_unit,
                      color: _ac ? Colors.blue : Colors.grey,
                    ),
                    title: const Text('ម៉ាស៊ីនត្រជាក់ (Air Conditioner)'),
                    subtitle: Text(_ac ? 'កំពុងបើក' : 'បានបិទ'),
                    value: _ac,
                    onChanged: (val) => setState(() => _ac = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: Icon(
                      Icons.lightbulb,
                      color: _light ? Colors.amber : Colors.grey,
                    ),
                    title: const Text('អំពូលភ្លើង (Lighting)'),
                    subtitle: Text(_light ? 'កំពុងបើក' : 'បានបិទ'),
                    value: _light,
                    onChanged: (val) => setState(() => _light = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: Icon(
                      _lock ? Icons.lock : Icons.lock_open,
                      color: _lock ? Colors.green : Colors.red,
                    ),
                    title: const Text('សោទ្វារ (Door Lock)'),
                    subtitle: Text(_lock ? 'ទ្វារបានចាក់សោ' : 'ទ្វារបើកចំហរ'),
                    value: _lock,
                    onChanged: (val) => setState(() => _lock = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ស្ថានភាពបន្ទប់ (Room Status)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('រួចរាល់'),
                  selected: _status == RoomStatus.ready,
                  selectedColor: Colors.green.shade100,
                  onSelected: (val) =>
                      setState(() => _status = RoomStatus.ready),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('កំពុងរៀបចំ'),
                  selected: _status == RoomStatus.inProgress,
                  selectedColor: Colors.orange.shade100,
                  onSelected: (val) =>
                      setState(() => _status = RoomStatus.inProgress),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('ផ្អាក/ខូច'),
                  selected: _status == RoomStatus.outOfOrder,
                  selectedColor: Colors.red.shade100,
                  onSelected: (val) =>
                      setState(() => _status = RoomStatus.outOfOrder),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'រក្សាទុកការផ្លាស់ប្តូរទៅកាន់ Server',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
