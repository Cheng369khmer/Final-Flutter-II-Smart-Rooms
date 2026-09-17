import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:smart_room_app/core/constants/api_endpoints.dart';
import 'package:smart_room_app/features/auth/controllers/auth_controller.dart';
import 'package:smart_room_app/features/auth/models/user_model.dart';

class ParkingManagementScreen extends ConsumerStatefulWidget {
  const ParkingManagementScreen({super.key});

  @override
  ConsumerState<ParkingManagementScreen> createState() =>
      _ParkingManagementScreenState();
}

class _ParkingManagementScreenState
    extends ConsumerState<ParkingManagementScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  Map<String, dynamic>? parkingData;
  List<dynamic> parkingStaffs = [];
  bool isLoading = true;
  String _reportPeriod = 'ប្រចាំថ្ងៃ';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _initTabController(bool isAdmin) {
    final tabCount = isAdmin ? 3 : 2;
    if (_tabController == null || _tabController!.length != tabCount) {
      _tabController = TabController(length: tabCount, vsync: this);
    }
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final dio = Dio();
      final resTickets = await dio.get(
        '${ApiEndpoints.baseUrl}/api/parking/tickets',
      );
      final resStaffs = await dio.get(
        '${ApiEndpoints.baseUrl}/api/parking/staffs',
      );

      setState(() {
        parkingData = resTickets.data;
        parkingStaffs = resStaffs.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkOut(String ticketId) async {
    await Dio().post('${ApiEndpoints.baseUrl}/api/parking/check-out/$ticketId');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('បានកឹបសំបុត្រចេញពីសាលា និងទទួលប្រាក់ 500៛ រួចរាល់!'),
        backgroundColor: Colors.green,
      ),
    );
    _loadData();
  }

  void _showFastCheckInDialog(UserModel? user) {
    String selectedShift = 'វេនថ្ងៃ';
    String selectedBrand = 'Scoopy';
    final plateCtrl = TextEditingController();

    final List<String> popularBrands = [
      'Scoopy',
      'Dream',
      'Click',
      'Wave',
      'PCX',
      'ផ្សេងៗ',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isNight = selectedShift == 'វេនយប់';
          final currentGuard =
              user?.name ??
              (isNight ? 'ជា ពិសិដ្ឋ (វេនយប់)' : 'សាន វិចិត្រ (វេនព្រឹក)');

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.confirmation_number_rounded,
                  color: Color(0xFF2563EB),
                  size: 26,
                ),
                SizedBox(width: 8),
                Text(
                  'កឹបសំបុត្រចូលសាលា',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ជ្រើសរើសវេនការងារ (Shift) ៖',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(
                            Icons.wb_sunny,
                            size: 16,
                            color: Colors.orange,
                          ),
                          label: const Text(
                            '☀️ វេនថ្ងៃ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          selected: selectedShift == 'វេនថ្ងៃ',
                          selectedColor: Colors.amber.shade200,
                          onSelected: (val) {
                            if (val)
                              setDialogState(() => selectedShift = 'វេនថ្ងៃ');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(
                            Icons.nights_stay,
                            size: 16,
                            color: Colors.indigo,
                          ),
                          label: const Text(
                            '🌙 វេនយប់',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          selected: selectedShift == 'វេនយប់',
                          selectedColor: Colors.indigo.shade200,
                          onSelected: (val) {
                            if (val)
                              setDialogState(() => selectedShift = 'វេនយប់');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isNight
                          ? Colors.indigo.shade50
                          : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isNight
                            ? Colors.indigo.shade200
                            : Colors.amber.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isNight
                              ? Icons.access_time_filled
                              : Icons.access_time,
                          size: 16,
                          color: isNight
                              ? Colors.indigo
                              : Colors.amber.shade900,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            isNight
                                ? 'ម៉ោង៖ 5:30 PM - 9:30 PM • អ្នកកឹប៖ $currentGuard'
                                : 'ម៉ោង៖ 7:30 AM - 5:30 PM • អ្នកកឹប៖ $currentGuard',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isNight
                                  ? Colors.indigo.shade900
                                  : Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'ជ្រើសរើសម៉ាកម៉ូតូ ៖',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: popularBrands.map((brand) {
                      final isSel = selectedBrand == brand;
                      return ChoiceChip(
                        label: Text(brand),
                        selected: isSel,
                        selectedColor: const Color(0xFF2563EB),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) setDialogState(() => selectedBrand = brand);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: plateCtrl,
                    decoration: InputDecoration(
                      labelText: 'លេខកន្ទុយផ្លាកលេខ (ឧ. 8899) - មិនវាយក៏បាន',
                      prefixIcon: const Icon(Icons.two_wheeler),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'តម្លៃសំបុត្រកឹបចូល៖',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '500 រៀល',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('បោះបង់'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final plate = plateCtrl.text.trim().isEmpty
                      ? 'ម៉ូតូទូទៅ'
                      : plateCtrl.text.trim().toUpperCase();
                  await Dio().post(
                    '${ApiEndpoints.baseUrl}/api/parking/check-in',
                    data: {
                      'plate_number': plate,
                      'bike_model': selectedBrand,
                      'shift': selectedShift,
                      'staff_name': currentGuard,
                    },
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'បានកឹបសំបុត្រចូល ($selectedShift) ជោគជ័យ! (500៛)',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check, size: 18),
                label: const Text(
                  'កឹបសំបុត្រ (500៛)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final isAdmin = user?.role == UserRole.admin;
    _initTabController(isAdmin);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isAdmin
              ? 'គ្រប់គ្រងចំណតម៉ូតូ (Admin Panel)'
              : 'ច្រកទ្វារកឹបសំបុត្រម៉ូតូ (Staff Portal)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2563EB),
          tabs: isAdmin
              ? const [
                  Tab(icon: Icon(Icons.two_wheeler), text: 'កឹបសំបុត្រ (500៛)'),
                  Tab(
                    icon: Icon(Icons.bar_chart_rounded),
                    text: 'របាយការណ៍ចំណូល (Admin)',
                  ),
                  Tab(icon: Icon(Icons.security), text: 'អ្នកយាម ៧ នាក់'),
                ]
              : const [
                  Tab(icon: Icon(Icons.two_wheeler), text: 'កឹបសំបុត្រ (500៛)'),
                  Tab(icon: Icon(Icons.security), text: 'វេនការងារសន្តិសុខ'),
                ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFastCheckInDialog(user),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'កឹបចូលសាលា (500៛)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: isAdmin
                  ? [_buildTicketsTab(), _buildReportTab(), _buildStaffsTab()]
                  : [_buildTicketsTab(), _buildStaffsTab()],
            ),
    );
  }

  // TAB ១: កឹបសំបុត្រ
  Widget _buildTicketsTab() {
    final List tickets = parkingData?['tickets'] ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length + 1,
      itemBuilder: (context, i) {
        if (i == tickets.length) return const SizedBox(height: 80);
        final t = tickets[i];
        final isParked = t['status'] == 'parked';
        final isDay = t['shift'] == 'វេនថ្ងៃ';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isParked
                        ? Colors.amber.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.two_wheeler,
                    color: isParked ? Colors.orange : Colors.green,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            t['plate_number'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              t['ticket_id'],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDay
                                  ? Colors.amber.shade100
                                  : Colors.indigo.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isDay ? '☀️ ថ្ងៃ' : '🌙 យប់',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isDay
                                    ? Colors.amber.shade900
                                    : Colors.indigo.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${t['bike_model']} • អ្នកកឹប៖ ${t['staff_name'] ?? "សន្តិសុខ"}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '• ចូលសាលា៖ ${t['check_in_time']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.blueGrey,
                        ),
                      ),
                      if (!isParked)
                        Text(
                          '• ចេញសាលា៖ ${t['check_out_time'] ?? ""}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '500 ៛',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 8),
                    isParked
                        ? ElevatedButton(
                            onPressed: () => _checkOut(t['ticket_id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'កឹបចេញ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'បានចេញ',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB ២: របាយការណ៍ចំណូល (សម្រាប់តែ ADMIN)
  Widget _buildReportTab() {
    final stats = parkingData?['stats'] ?? {};
    final dayShift = stats['day_shift'] ?? {};
    final nightShift = stats['night_shift'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['ប្រចាំថ្ងៃ', 'ប្រចាំសប្តាហ៍', 'ប្រចាំខែ', 'ប្រចាំឆ្នាំ']
                .map((p) {
                  final isSel = _reportPeriod == p;
                  return ChoiceChip(
                    label: Text(p),
                    selected: isSel,
                    selectedColor: const Color(0xFF2563EB),
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onSelected: (_) => setState(() => _reportPeriod = p),
                  );
                })
                .toList(),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'របាយការណ៍ចំណូល ($_reportPeriod)',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'កាលបរិច្ឆេទ៖ ${stats['today_date'] ?? ""}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ចំណូលសរុប៖',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${stats['total_revenue_riel'] ?? 0} រៀល',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildReportStatItem(
                      'សំបុត្រសរុប',
                      '${stats['total_tickets'] ?? 0}',
                      Colors.white,
                    ),
                    _buildReportStatItem(
                      'កំពុងចត',
                      '${stats['currently_parked'] ?? 0}',
                      Colors.amberAccent,
                    ),
                    _buildReportStatItem(
                      'ចេញពីសាលារួច',
                      '${stats['completed'] ?? 0}',
                      Colors.blueAccent,
                    ),
                    _buildReportStatItem(
                      'តម្លៃ ១ សំបុត្រ',
                      '500 ៛',
                      Colors.greenAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'ស្ថិតិចំណូលបែងចែកតាមវេន (Shift Breakdown)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.amber.shade100,
                    child: const Icon(Icons.wb_sunny, color: Colors.orange),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '☀️ វេនថ្ងៃ (7:30 AM - 5:30 PM)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'កឹបបានសរុប៖ ${dayShift['count'] ?? 0} សំបុត្រ (បុគ្គលិក ៤ នាក់)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${dayShift['revenue'] ?? 0} ៛',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.indigo.shade100,
                    child: const Icon(Icons.nights_stay, color: Colors.indigo),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🌙 វេនយប់ (5:30 PM - 9:30 PM)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'កឹបបានសរុប៖ ${nightShift['count'] ?? 0} សំបុត្រ (បុគ្គលិក ៣ នាក់)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${nightShift['revenue'] ?? 0} ៛',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportStatItem(String title, String val, Color color) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  // TAB ៣: អ្នកយាម ៧ នាក់
  Widget _buildStaffsTab() {
    final morningStaffs = parkingStaffs
        .where((s) => s['shift'] == 'វេនព្រឹក')
        .toList();
    final nightStaffs = parkingStaffs
        .where((s) => s['shift'] == 'វេនយប់')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShiftTitle(
            'វេនព្រឹក (7:30 AM - 5:30 PM)',
            'បុគ្គលិក ៤ នាក់',
            Colors.amber.shade800,
          ),
          const SizedBox(height: 10),
          ...morningStaffs.map((s) => _buildStaffItem(s)),

          const SizedBox(height: 24),

          _buildShiftTitle(
            'វេនយប់ (5:30 PM - 9:30 PM)',
            'បុគ្គលិក ៣ នាក់',
            Colors.indigo,
          ),
          const SizedBox(height: 10),
          ...nightStaffs.map((s) => _buildStaffItem(s)),
        ],
      ),
    );
  }

  Widget _buildShiftTitle(String title, String count, Color col) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: col,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: col.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count,
            style: TextStyle(
              color: col,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaffItem(dynamic s) {
    final isOnDuty = s['status'] == 'onDuty';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 26,
          backgroundImage: NetworkImage(s['photo']),
        ),
        title: Row(
          children: [
            Text(
              s['name'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isOnDuty ? Colors.green.shade100 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isOnDuty ? 'កំពុងយាម' : 'ក្រៅវេន',
                style: TextStyle(
                  color: isOnDuty ? Colors.green.shade800 : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${s['role']} • ${s['shift_time']}',
              style: const TextStyle(color: Color(0xFF2563EB), fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              'ទូរស័ព្ទ៖ ${s['phone']}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
