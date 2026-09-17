import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:smart_room_app/core/constants/api_endpoints.dart';

// =========================================================================
// ១. DATA MODEL (ទម្រង់ទិន្នន័យបន្ទប់ឆ្លាតវៃ)
// =========================================================================
class Room {
  final String roomNumber;
  final String building;
  final int floor;
  final String type;
  String status; // 'រួចរាល់', 'កំពុងរៀបចំ', 'កំពុងជួសជុល', 'ផ្អាក/ប្រើមិនបាន'
  bool ac;
  bool light;
  bool lock;

  Room({
    required this.roomNumber,
    required this.building,
    required this.floor,
    required this.type,
    required this.status,
    this.ac = false,
    this.light = false,
    this.lock = true,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomNumber: json['room_number'] ?? '',
      building: json['building'] ?? '',
      floor: json['floor'] ?? 1,
      type: json['type'] ?? 'បន្ទប់ទូទៅ',
      status: json['status'] ?? 'រួចរាល់',
      ac: json['ac'] ?? false,
      light: json['light'] ?? false,
      lock: json['lock'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'room_number': roomNumber,
        'building': building,
        'floor': floor,
        'type': type,
        'status': status,
        'ac': ac,
        'light': light,
        'lock': lock,
      };
}

// =========================================================================
// ២. STAGGERED ANIMATION WIDGET
// =========================================================================
class StaggeredRoomItem extends StatefulWidget {
  final int index;
  final Widget child;

  const StaggeredRoomItem({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  State<StaggeredRoomItem> createState() => _StaggeredRoomItemState();
}

class _StaggeredRoomItemState extends State<StaggeredRoomItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) {
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

// =========================================================================
// ៣. PRESS / BOUNCE ANIMATION
// =========================================================================
class AnimatedPressCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const AnimatedPressCard({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<AnimatedPressCard> createState() => _AnimatedPressCardState();
}

class _AnimatedPressCardState extends State<AnimatedPressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

// =========================================================================
// ៤. MAIN ROOM LIST SCREEN
// =========================================================================
class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  List<Room> _allRooms = [];
  bool _isLoading = true;
  String _selectedBuilding = 'ទាំងអស់';

  // បញ្ជីជម្រើសស្ថានភាពបន្ទប់
  static const List<String> roomStatusOptions = [
    'រួចរាល់',
    'កំពុងរៀបចំ',
    'កំពុងជួសជុល',
    'ផ្អាក/ប្រើមិនបាន',
  ];

  // បញ្ជីបន្ទប់បម្រុងពេល Offline
  final List<Room> _defaultRooms = [
    Room(
      roomNumber: 'A101',
      building: 'អគារ A',
      floor: 1,
      type: 'បន្ទប់ទូទៅ',
      status: 'រួចរាល់',
      ac: true,
      light: true,
      lock: true,
    ),
    Room(
      roomNumber: 'A102',
      building: 'អគារ A',
      floor: 1,
      type: 'បន្ទប់ទូទៅ',
      status: 'កំពុងរៀបចំ',
      ac: false,
      light: true,
      lock: false,
    ),
    Room(
      roomNumber: 'B201',
      building: 'អគារ B',
      floor: 2,
      type: 'បន្ទប់ Lab',
      status: 'កំពុងជួសជុល',
      ac: false,
      light: false,
      lock: true,
    ),
    Room(
      roomNumber: 'C301',
      building: 'អគារ C',
      floor: 3,
      type: 'បន្ទប់ប្រជុំ',
      status: 'ផ្អាក/ប្រើមិនបាន',
      ac: false,
      light: false,
      lock: true,
    ),
    Room(
      roomNumber: 'C302',
      building: 'អគារ C',
      floor: 3,
      type: 'បន្ទប់ទូទៅ',
      status: 'រួចរាល់',
      ac: true,
      light: true,
      lock: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchRoomsFromBackend();
  }

  Future<void> _fetchRoomsFromBackend() async {
    setState(() => _isLoading = true);
    try {
      final response = await Dio().get(
        '${ApiEndpoints.baseUrl}/api/rooms',
        options: Options(receiveTimeout: const Duration(seconds: 4)),
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        setState(() {
          _allRooms = data.map((json) => Room.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _allRooms = _defaultRooms;
        _isLoading = false;
      });
    }
  }

  List<Room> get _filteredRooms {
    if (_selectedBuilding == 'ទាំងអស់') return _allRooms;
    return _allRooms.where((r) => r.building == _selectedBuilding).toList();
  }

  // គណនាស្ថិតិបន្ទប់ទាំង ៤ ប្រភេទ
  int get _readyCount => _allRooms
      .where((r) => r.status == 'រួចរាល់' || r.status == 'ជួសជុលរួច')
      .length;
  int get _inProgressCount =>
      _allRooms.where((r) => r.status == 'កំពុងរៀបចំ').length;
  int get _repairingCount =>
      _allRooms.where((r) => r.status == 'កំពុងជួសជុល').length;
  int get _outOfOrderCount => _allRooms
      .where((r) =>
          r.status == 'ផ្អាក/ប្រើមិនបាន' ||
          r.status == 'ប្រើមិនបាន' ||
          r.status == 'ផ្អាក/ខូច')
      .length;

  // ពណ៌តំណាងឱ្យស្ថានភាពនីមួយៗ
  static Color getStatusColor(String status) {
    if (status == 'រួចរាល់' || status == 'ជួសជុលរួច') {
      return const Color(0xFF16A34A); // បៃតង
    } else if (status == 'កំពុងរៀបចំ') {
      return const Color(0xFFF59E0B); // លឿងទុំ
    } else if (status == 'កំពុងជួសជុល') {
      return const Color(0xFF2563EB); // ខៀវ
    } else {
      return const Color(0xFFEF4444); // ក្រហម (ប្រើមិនបាន)
    }
  }

  // =======================================================================
  // ៥. POPUP DIALOG បន្ថែមបន្ទប់ថ្មី (ADD ROOM DIALOG)
  // =======================================================================
  void _showAddRoomDialog(BuildContext context) {
    final roomNumberCtrl = TextEditingController();
    final floorCtrl = TextEditingController(text: '1');
    String building = 'អគារ A';
    String roomType = 'បន្ទប់ទូទៅ';
    String roomStatus = 'រួចរាល់';
    bool ac = false;
    bool light = false;
    bool lock = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.add_circle, color: Color(0xFF16325C)),
                SizedBox(width: 8),
                Text('បន្ថែមបន្ទប់ថ្មី (Admin)',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: roomNumberCtrl,
                    decoration: const InputDecoration(
                      labelText: 'លេខបន្ទប់ (ឧ. A205, B102)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: building,
                    decoration: const InputDecoration(
                        labelText: 'អគារ',
                        border: OutlineInputBorder(),
                        isDense: true),
                    items: ['អគារ A', 'អគារ B', 'អគារ C']
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => building = val!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: floorCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'ជាន់ទី (Floor)',
                        border: OutlineInputBorder(),
                        isDense: true),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: roomType,
                    decoration: const InputDecoration(
                        labelText: 'ប្រភេទបន្ទប់',
                        border: OutlineInputBorder(),
                        isDense: true),
                    items: ['បន្ទប់ទូទៅ', 'បន្ទប់ Lab', 'បន្ទប់ប្រជុំ']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => roomType = val!),
                  ),
                  const SizedBox(height: 12),

                  // ✅ DROPDOWN ស្ថានភាពបន្ទប់ពេញលេញ
                  DropdownButtonFormField<String>(
                    value: roomStatus,
                    decoration: const InputDecoration(
                        labelText: 'ស្ថានភាពបន្ទប់',
                        border: OutlineInputBorder(),
                        isDense: true),
                    items: roomStatusOptions.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: getStatusColor(s),
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text(s, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setDialogState(() => roomStatus = val!),
                  ),
                  const Divider(height: 24),
                  SwitchListTile(
                    title: const Text('ម៉ាស៊ីនត្រជាក់ (AC)',
                        style: TextStyle(fontSize: 12)),
                    value: ac,
                    dense: true,
                    onChanged: (v) => setDialogState(() => ac = v),
                  ),
                  SwitchListTile(
                    title: const Text('អំពូលភ្លើង (Light)',
                        style: TextStyle(fontSize: 12)),
                    value: light,
                    dense: true,
                    onChanged: (v) => setDialogState(() => light = v),
                  ),
                  SwitchListTile(
                    title: const Text('សោទ្វារ (Lock)',
                        style: TextStyle(fontSize: 12)),
                    value: lock,
                    dense: true,
                    onChanged: (v) => setDialogState(() => lock = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('បោះបង់')),
              ElevatedButton(
                onPressed: () async {
                  if (roomNumberCtrl.text.trim().isEmpty) return;

                  final newRoomData = {
                    'room_number': roomNumberCtrl.text.trim().toUpperCase(),
                    'building': building,
                    'floor': int.tryParse(floorCtrl.text.trim()) ?? 1,
                    'type': roomType,
                    'status': roomStatus,
                    'ac': ac,
                    'light': light,
                    'lock': lock,
                  };

                  try {
                    await Dio().post('${ApiEndpoints.baseUrl}/api/rooms',
                        data: newRoomData);
                  } catch (_) {}

                  setState(() {
                    _allRooms.insert(0, Room.fromJson(newRoomData));
                  });

                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'បានបន្ថែមបន្ទប់ ${roomNumberCtrl.text.toUpperCase()} (${roomStatus}) ជោគជ័យ!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16325C)),
                child: const Text('រក្សាទុក',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // =======================================================================
  // ៦. ROOM DETAIL & STATUS CHANGER MODAL (អាចចុចប្ដូរស្ថានភាពបន្ទប់បាន)
  // =======================================================================
  void _showRoomDetailDialog(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final currentColor = getStatusColor(room.status);

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'room-icon-${room.roomNumber}',
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: currentColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.meeting_room,
                              color: currentColor, size: 28),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'បន្ទប់ ${room.roomNumber}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${room.building} • ជាន់ទី ${room.floor} • ${room.type}',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ✅ កន្លែងចុចប្ដូរស្ថានភាពបន្ទប់ (STATUS CHANGER)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ប្ដូរស្ថានភាពបន្ទប់ (Change Status)៖',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: roomStatusOptions.contains(room.status)
                              ? room.status
                              : roomStatusOptions.first,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            isDense: true,
                          ),
                          items: roomStatusOptions.map((opt) {
                            final color = getStatusColor(opt);
                            return DropdownMenuItem(
                              value: opt,
                              child: Row(
                                children: [
                                  Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  Text(opt,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (newStatus) {
                            if (newStatus != null) {
                              setModalState(() => room.status = newStatus);
                              setState(() {}); // Update ទៅកាន់ Screen
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // IoT Controls Toggles
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('ឧបករណ៍បញ្ជាឆ្លាតវៃ (IoT Controls)៖',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  const SizedBox(height: 6),

                  SwitchListTile(
                    title: const Text('ម៉ាស៊ីនត្រជាក់ (AC)',
                        style: TextStyle(fontSize: 12.5)),
                    secondary: Icon(Icons.ac_unit,
                        color: room.ac ? Colors.blue : Colors.grey, size: 22),
                    value: room.ac,
                    dense: true,
                    onChanged: (val) {
                      setModalState(() => room.ac = val);
                      setState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('អំពូលភ្លើង (Lighting)',
                        style: TextStyle(fontSize: 12.5)),
                    secondary: Icon(Icons.lightbulb_outline,
                        color: room.light ? Colors.amber : Colors.grey,
                        size: 22),
                    value: room.light,
                    dense: true,
                    onChanged: (val) {
                      setModalState(() => room.light = val);
                      setState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('សោទ្វារ (Door Lock)',
                        style: TextStyle(fontSize: 12.5)),
                    secondary: Icon(room.lock ? Icons.lock : Icons.lock_open,
                        color: room.lock ? Colors.green : Colors.red, size: 22),
                    value: room.lock,
                    dense: true,
                    onChanged: (val) {
                      setModalState(() => room.lock = val);
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16325C)),
                      child: const Text('យល់ព្រម',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayRooms = _filteredRooms;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'គ្រប់គ្រងបន្ទប់ឆ្លាតវៃ (Smart Room)',
          style: TextStyle(
              color: Color(0xFF16325C),
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF16325C)),
            onPressed: _fetchRoomsFromBackend,
          ),
        ],
      ),

      // ប៊ូតុង Admin បន្ថែមបន្ទប់ថ្មី
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRoomDialog(context),
        backgroundColor: const Color(0xFF16325C),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('បន្ថែមបន្ទប់ថ្មី',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ),

      body: Column(
        children: [
          // ១. ផ្ទាំងសង្ខេបស្ថានភាពបន្ទប់ទាំង ៤ ប្រភេទ (Top Overview Card)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('បន្ទប់សរុបទាំងអស់',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                      Text('${_allRooms.length} បន្ទប់',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17)),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 16),
                  // ✅ បង្ហាញស្ថិតិទាំង ៤ ស្ថានភាពច្បាស់ៗ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatusMetric(
                          'រួចរាល់', '$_readyCount', const Color(0xFF4ADE80)),
                      _buildStatusMetric('កំពុងរៀបចំ', '$_inProgressCount',
                          const Color(0xFFFDE047)),
                      _buildStatusMetric('ជួសជុល', '$_repairingCount',
                          const Color(0xFF93C5FD)),
                      _buildStatusMetric('ប្រើមិនបាន', '$_outOfOrderCount',
                          const Color(0xFFF87171)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ២. Tabs Filter តាមអគារ
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              children: ['ទាំងអស់', 'អគារ A', 'អគារ B', 'អគារ C'].map((bldg) {
                final isSelected = _selectedBuilding == bldg;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedBuilding = bldg),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        bldg,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF475569),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // ៣. បញ្ជីបន្ទប់ភ្ជាប់ Staggered Animation
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayRooms.isEmpty
                    ? const Center(
                        child: Text('មិនមានបន្ទប់ទេ',
                            style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        key: ValueKey('room_list_$_selectedBuilding'),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                        itemCount: displayRooms.length,
                        itemBuilder: (context, index) {
                          final room = displayRooms[index];
                          return StaggeredRoomItem(
                            key: ValueKey(
                                '${room.roomNumber}_$_selectedBuilding'),
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AnimatedPressCard(
                                onTap: () =>
                                    _showRoomDetailDialog(context, room),
                                child: _buildRoomCard(room),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }

  Widget _buildRoomCard(Room room) {
    final statusColor = getStatusColor(room.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'room-icon-${room.roomNumber}',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.meeting_room_outlined,
                  color: statusColor, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'បន្ទប់ ${room.roomNumber}',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 3),
                Text(
                  'ប្រភេទ៖ ${room.type} | ជាន់ទី ${room.floor}',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 8),

                // ❄️💡🔒 IOT CONTROLS
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => room.ac = !room.ac),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: room.ac
                              ? Colors.blue.withOpacity(0.15)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.ac_unit,
                            size: 15,
                            color: room.ac ? Colors.blue : Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => room.light = !room.light),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: room.light
                              ? Colors.amber.withOpacity(0.2)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.lightbulb,
                            size: 15,
                            color: room.light
                                ? Colors.amber.shade700
                                : Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => room.lock = !room.lock),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: room.lock
                              ? Colors.green.withOpacity(0.15)
                              : Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(room.lock ? Icons.lock : Icons.lock_open,
                            size: 15,
                            color: room.lock ? Colors.green : Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              room.status,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
