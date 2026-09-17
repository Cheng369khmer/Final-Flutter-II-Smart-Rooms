import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:smart_room_app/core/constants/api_endpoints.dart';
import 'package:smart_room_app/features/auth/controllers/auth_controller.dart';
import 'package:smart_room_app/features/auth/models/user_model.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  Map<String, dynamic>? attendanceData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    final user = ref.read(authProvider);
    setState(() => isLoading = true);
    try {
      final res = await Dio().get(
        '${ApiEndpoints.baseUrl}/api/attendance/today',
        queryParameters: {'username': user?.username ?? ''},
      );
      setState(() {
        attendanceData = res.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkIn() async {
    final user = ref.read(authProvider);
    try {
      final res = await Dio().post(
        '${ApiEndpoints.baseUrl}/api/attendance/check-in',
        data: {'username': user?.username ?? ''},
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.data['message']),
          backgroundColor: Colors.green,
        ),
      );
      _fetchAttendance();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _checkOut() async {
    final user = ref.read(authProvider);
    try {
      final res = await Dio().post(
        '${ApiEndpoints.baseUrl}/api/attendance/check-out',
        data: {'username': user?.username ?? ''},
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.data['message']),
          backgroundColor: Colors.blue,
        ),
      );
      _fetchAttendance();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showLeaveDialog() {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ស្នើសុំច្បាប់សម្រាក (Leave Request)'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
            labelText: 'មូលហេតុ (ឧ. ឈឺ ឬធុរៈផ្ទាល់ខ្លួន)',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('បោះបង់'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonCtrl.text.isEmpty) return;
              final user = ref.read(authProvider);
              await Dio().post(
                '${ApiEndpoints.baseUrl}/api/attendance/leave',
                data: {
                  'username': user?.username ?? '',
                  'reason': reasonCtrl.text.trim(),
                },
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('បានដាក់ពាក្យសុំច្បាប់ជោគជ័យ!'),
                  backgroundColor: Colors.orange,
                ),
              );
              _fetchAttendance();
            },
            child: const Text('ផ្ញើសំណើ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final isAdmin = user?.role == UserRole.admin;

    final stats = attendanceData?['stats'] ?? {};
    final userRecord = attendanceData?['user_status'];
    final List allRecords = attendanceData?['all_records'] ?? [];

    final hasCheckedIn =
        userRecord != null && userRecord['check_in_time'] != null;
    final hasCheckedOut =
        userRecord != null && userRecord['check_out_time'] != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'វត្តមាន និងកាលវិភាគការងារ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAttendance,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ១. កាតកត់ត្រាវត្តមានបុគ្គល (My Clock-in Card)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              user?.name ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                userRecord?['status'] ?? 'មិនទាន់មក',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'កាលបរិច្ឆេទថ្ងៃនេះ៖ ${stats['date'] ?? ""}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const Divider(color: Colors.white24, height: 24),

                        // បង្ហាញម៉ោង Check-in / Check-out
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTimeBadge(
                              'ម៉ោងចូល (In)',
                              userRecord?['check_in_time'] ?? '--:--',
                              Colors.greenAccent,
                            ),
                            _buildTimeBadge(
                              'ម៉ោងចេញ (Out)',
                              userRecord?['check_out_time'] ?? '--:--',
                              Colors.amberAccent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // ប៊ូតុងសកម្មភាព Check-in / Check-out / សុំច្បាប់
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: hasCheckedIn ? null : _checkIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.login),
                                label: const Text(
                                  'Check-in ចូល',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: (!hasCheckedIn || hasCheckedOut)
                                    ? null
                                    : _checkOut,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.logout),
                                label: const Text(
                                  'Check-out ចេញ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'សុំច្បាប់',
                              onPressed: _showLeaveDialog,
                              icon: const Icon(
                                Icons.edit_calendar,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ២. ស្ថិតិវត្តមានរួម (សម្រាប់ Admin និង HR)
                  const Text(
                    'ស្ថិតិវត្តមានបុគ្គលិកសរុបថ្ងៃនេះ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSummaryCard(
                        'មកធ្វើការ',
                        '${stats['present'] ?? 0}',
                        Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildSummaryCard(
                        'មកយឺត',
                        '${stats['late'] ?? 0}',
                        Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _buildSummaryCard(
                        'សុំច្បាប់',
                        '${stats['leave'] ?? 0}',
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildSummaryCard(
                        'អវត្តមាន',
                        '${stats['absent'] ?? 0}',
                        Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ៣. បញ្ជីវត្តមានបុគ្គលិកទាំងអស់ជាក់ស្តែង
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'បញ្ជីវត្តមានជាក់ស្តែង (Live Timesheet)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Admin/HR View',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allRecords.length,
                    itemBuilder: (context, i) {
                      final rec = allRecords[i];
                      final isPresent = rec['status'] == 'PRESENT';
                      final isLate = rec['status'] == 'LATE';
                      final isLeave = rec['status'] == 'LEAVE';

                      final color = isPresent
                          ? Colors.green
                          : (isLate
                                ? Colors.orange
                                : (isLeave ? Colors.blue : Colors.red));
                      final statusText = isPresent
                          ? 'ទាន់ពេល'
                          : (isLate
                                ? 'យឺត'
                                : (isLeave ? 'សុំច្បាប់' : 'អវត្តមាន'));

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.15),
                            child: Icon(
                              isPresent
                                  ? Icons.check
                                  : (isLate ? Icons.alarm : Icons.event_busy),
                              color: color,
                            ),
                          ),
                          title: Text(
                            rec['name'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            'ចូល៖ ${rec['check_in_time'] ?? "មិនទាន់"} • ចេញ៖ ${rec['check_out_time'] ?? "--"} \n${rec['shift'] ?? ""}',
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTimeBadge(String title, String time, Color col) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: col,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String count, Color col) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: col.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                color: col,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
