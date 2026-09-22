import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:smart_room_app/core/constants/api_endpoints.dart';
import 'package:smart_room_app/features/rooms/presentation/screens/room_list_screen.dart';
import 'package:smart_room_app/features/staff/screens/staff_list_screen.dart';
import 'package:smart_room_app/features/parking/screens/parking_management_screen.dart';
import 'package:smart_room_app/features/attendance/screens/attendance_screen.dart';
import 'login_screen.dart'; // ដើម្បីស្គាល់ AppUser

class DashboardScreen extends StatefulWidget {
  final AppUser? currentUser;

  const DashboardScreen({super.key, this.currentUser});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  AppUser get user =>
      widget.currentUser ??
      AppUser(
        username: 'admin',
        fullName: 'អ្នកគ្រប់គ្រងទូទៅ',
        role: 'admin',
        roleTitle: 'អ្នកគ្រប់គ្រងទូទៅ (Admin)',
      );

  bool get isAdmin => user.role == 'admin';
  bool get isLecturer => user.role == 'lecturer';
  bool get isParkingStaff => user.role == 'parking';
  bool get isRoomStaff => user.role == 'room_staff';
  bool get isCleaner => user.role == 'cleaner';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 18),

              // Title Quick Access
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAdmin
                          ? 'សេវាកម្មគ្រប់គ្រងទូទៅ'
                          : 'មុខងារការងាររបស់អ្នក',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B)),
                    ),
                    if (isAdmin || isRoomStaff)
                      TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RoomListScreen())),
                        child: const Text('View Rooms',
                            style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ✅ GRID VIEW បែងចែកតាម ROLE
              _buildRoleSpecificGrid(context),
              const SizedBox(height: 20),

              // Banner វេនការងារ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  isAdmin ? 'កាលវិភាគប្រព័ន្ធទូទៅ' : 'វេនការងាររបស់អ្នកថ្ងៃនេះ',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B)),
                ),
              ),
              const SizedBox(height: 8),
              _buildScheduleCard(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF94A3B8),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.meeting_room_outlined), label: 'Rooms'),
          BottomNavigationBarItem(
              icon: Icon(Icons.co_present_outlined), label: 'វត្តមាន'),
          BottomNavigationBarItem(
              icon: Icon(Icons.two_wheeler_outlined), label: 'Parking'),
        ],
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          if (index == 1) {
            Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RoomListScreen()))
                .then((_) => setState(() => _currentNavIndex = 0));
          } else if (index == 2) {
            Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AttendanceScreen()))
                .then((_) => setState(() => _currentNavIndex = 0));
          } else if (index == 3) {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ParkingManagementScreen()))
                .then((_) => setState(() => _currentNavIndex = 0));
          }
        },
      ),
    );
  }

  // =========================================================================
  // LOGIC បែងចែកប៊ូតុង QUICK ACCESS តាម ROLE នីមួយៗ
  // =========================================================================
  Widget _buildRoleSpecificGrid(BuildContext context) {
    List<Widget> items = [];

    // ១. ប្រសិនបើជា ADMIN ➔ ឃើញទាំងអស់ (Full Access)
    if (isAdmin) {
      items = [
        _buildGridItem(
            'គ្រប់គ្រងបន្ទប់',
            'បញ្ជីបន្ទប់ ១៣០',
            Icons.meeting_room,
            const Color(0xFFEEF2FF),
            const Color(0xFF4F46E5),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RoomListScreen()))),
        _buildGridItem(
            'កត់ត្រាវត្តមាន',
            'Check-in / Timesheet',
            Icons.co_present,
            const Color(0xFFEFF6FF),
            const Color(0xFF2563EB),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AttendanceScreen()))),
        _buildGridItem(
            'បុគ្គលិកអគារ',
            'Digital ID (QR)',
            Icons.badge_outlined,
            const Color(0xFFDCFCE7),
            const Color(0xFF16A34A),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StaffListScreen()))),
        _buildGridItem(
            'ចំណតម៉ូតូ',
            'កឹបសំបុត្រ 500៛',
            Icons.two_wheeler,
            const Color(0xFFFFFBEB),
            const Color(0xFFD97706),
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ParkingManagementScreen()))),
        _buildGridItem(
            'ស្នើសុំសម្ភារៈ',
            'Request Supplies',
            Icons.inventory_2_outlined,
            const Color(0xFFF3E8FF),
            const Color(0xFF7E22CE),
            () => _showCreateRequestDialog(context, 'ស្នើសុំសម្ភារៈ')),
        _buildGridItem(
            'រាយការណ៍បញ្ហា',
            'Report Issue',
            Icons.report_problem_outlined,
            const Color(0xFFFCE7F3),
            const Color(0xFFDB2777),
            () => _showCreateRequestDialog(context, 'ជួសជុលឧបករណ៍')),
      ];
    }
    // ២. ប្រសិនបើជា សាស្ត្រាចារ្យ (LECTURER) ➔ ឃើញតែវត្តមាន, បន្ទប់បង្រៀន, ដាក់ពិន្ទុ
    else if (isLecturer) {
      items = [
        _buildGridItem(
            'កត់ត្រាវត្តមាន',
            'វត្តមាននិស្សិត & គ្រូ',
            Icons.co_present,
            const Color(0xFFEFF6FF),
            const Color(0xFF2563EB),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AttendanceScreen()))),
        _buildGridItem(
            'បន្ទប់បង្រៀន',
            'ពិនិត្យ AC & ភ្លើង',
            Icons.meeting_room,
            const Color(0xFFEEF2FF),
            const Color(0xFF4F46E5),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RoomListScreen()))),
        _buildGridItem(
            'ដាក់ពិន្ទុសិស្ស',
            'Grading & Scores',
            Icons.assignment_turned_in_outlined,
            const Color(0xFFDCFCE7),
            const Color(0xFF16A34A),
            () => _showMockDialog('មុខងារដាក់ពិន្ទុសិស្ស (Grading Sheet)')),
        _buildGridItem(
            'Digital ID',
            'My QR Card',
            Icons.qr_code,
            const Color(0xFFF3F4F6),
            const Color(0xFF4B5563),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StaffListScreen()))),
      ];
    }
    // ៣. ប្រសិនបើជា សន្តិសុខ (PARKING STAFF) ➔ ឃើញតែចំណតម៉ូតូ & វត្តមានខ្លួនឯង
    else if (isParkingStaff) {
      items = [
        _buildGridItem(
            'កឹបសំបុត្រម៉ូតូ',
            'ច្រកទ្វារ (500៛)',
            Icons.two_wheeler,
            const Color(0xFFFFFBEB),
            const Color(0xFFD97706),
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ParkingManagementScreen()))),
        _buildGridItem(
            'វេនការងារសន្តិសុខ',
            'Schedule',
            Icons.security,
            const Color(0xFFEFF6FF),
            const Color(0xFF2563EB),
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ParkingManagementScreen()))),
        _buildGridItem(
            'កត់ត្រាវត្តមាន',
            'Check-in វេនយាម',
            Icons.co_present,
            const Color(0xFFDCFCE7),
            const Color(0xFF16A34A),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AttendanceScreen()))),
        _buildGridItem(
            'Digital ID',
            'My Security ID',
            Icons.qr_code,
            const Color(0xFFF3F4F6),
            const Color(0xFF4B5563),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StaffListScreen()))),
      ];
    }
    // ៤. ប្រសិនបើជា បុគ្គលិករៀបចំបន្ទប់ (ROOM STAFF) ➔ បន្ទប់, ស្នើសុំសម្ភារៈ, ជួសជុល
    else if (isRoomStaff) {
      items = [
        _buildGridItem(
            'បន្ទប់ត្រូវរៀបចំ',
            'ត្រួតពិនិត្យបន្ទប់',
            Icons.meeting_room,
            const Color(0xFFEEF2FF),
            const Color(0xFF4F46E5),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RoomListScreen()))),
        _buildGridItem(
            'ស្នើសុំសម្ភារៈ',
            'Request Supplies',
            Icons.inventory_2_outlined,
            const Color(0xFFDCFCE7),
            const Color(0xFF16A34A),
            () => _showCreateRequestDialog(context, 'ស្នើសុំសម្ភារៈ')),
        _buildGridItem(
            'រាយការណ៍ខូច',
            'Report Issue',
            Icons.report_problem_outlined,
            const Color(0xFFFCE7F3),
            const Color(0xFFDB2777),
            () => _showCreateRequestDialog(context, 'ជួសជុលឧបករណ៍')),
        _buildGridItem(
            'កត់ត្រាវត្តមាន',
            'Check-in ម៉ោង 5 AM',
            Icons.co_present,
            const Color(0xFFEFF6FF),
            const Color(0xFF2563EB),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AttendanceScreen()))),
        _buildGridItem(
            'Digital ID',
            'Staff ID Card',
            Icons.qr_code,
            const Color(0xFFF3F4F6),
            const Color(0xFF4B5563),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StaffListScreen()))),
      ];
    }
    // ៥. ប្រសិនបើជា បុគ្គលិកអនាម័យ (CLEANER) ➔ សម្អាតបន្ទប់ & សម្ភារៈ
    else {
      items = [
        _buildGridItem(
            'បន្ទប់ត្រូវសម្អាត',
            'Cleaning List',
            Icons.cleaning_services_outlined,
            const Color(0xFFEEF2FF),
            const Color(0xFF4F46E5),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RoomListScreen()))),
        _buildGridItem(
            'សុំសម្ភារៈអនាម័យ',
            'Cleaning Supplies',
            Icons.inventory_2_outlined,
            const Color(0xFFDCFCE7),
            const Color(0xFF16A34A),
            () => _showCreateRequestDialog(context, 'ស្នើសុំសម្ភារៈអនាម័យ')),
        _buildGridItem(
            'កត់ត្រាវត្តមាន',
            'Check-in ចូលធ្វើការ',
            Icons.co_present,
            const Color(0xFFEFF6FF),
            const Color(0xFF2563EB),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AttendanceScreen()))),
        _buildGridItem(
            'Digital ID',
            'My ID Card',
            Icons.qr_code,
            const Color(0xFFF3F4F6),
            const Color(0xFF4B5563),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StaffListScreen()))),
      ];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.88,
        children: items,
      ),
    );
  }

  // Header ខាងលើ
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A2540), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              const Text('Chenla Smart Campus',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'ចាកចេញ (Logout)',
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'សួស្តី, ${user.fullName} 👋',
            style: const TextStyle(
                fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12)),
            child: Text(
              user.roleTitle,
              style: const TextStyle(
                  fontSize: 11.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String title, String sub, IconData icon, Color bg,
      Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: Icon(icon, color: iconColor, size: 20)),
            const SizedBox(height: 6),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                    color: Color(0xFF1E293B)),
                maxLines: 1),
            const SizedBox(height: 1),
            Text(sub,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context) {
    String dutyTime = '05:00 AM';
    String dutyTitle = 'ត្រួតពិនិត្យ និងបើកបន្ទប់ទទួលបន្ទុក';
    if (isLecturer) {
      dutyTime = '07:30 AM';
      dutyTitle = 'បង្រៀនមុខវិជ្ជា Mobile Programming (A101)';
    } else if (isParkingStaff) {
      dutyTime = '07:30 AM';
      dutyTitle = 'យាមច្រកទ្វារចំណតម៉ូតូ (វេនថ្ងៃ)';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
            ]),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(dutyTime,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D4ED8),
                      fontSize: 12)),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(dutyTitle,
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }

  void _showMockDialog(String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: const Text(
            'មុខងារនេះត្រូវបានអនុញ្ញាតសម្រាប់តែសាស្ត្រាចារ្យប៉ុណ្ណោះ។'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('យល់ព្រម'))
        ],
      ),
    );
  }

  void _showCreateRequestDialog(BuildContext context, String type) {
    final roomCtrl = TextEditingController(text: 'A101');
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('បង្កើត $type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: roomCtrl,
                decoration: const InputDecoration(labelText: 'លេខបន្ទប់')),
            TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'ការបរិយាយ')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('បោះបង់')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('បានផ្ញើសំណើជោគជ័យ!'),
                  backgroundColor: Colors.green));
            },
            child: const Text('ផ្ញើ'),
          ),
        ],
      ),
    );
  }
}
