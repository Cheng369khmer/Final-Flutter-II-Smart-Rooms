import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:smart_room_app/core/constants/api_endpoints.dart';
import 'package:smart_room_app/features/auth/controllers/auth_controller.dart';
import 'package:smart_room_app/features/auth/models/user_model.dart';
import 'package:smart_room_app/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_room_app/features/rooms/presentation/screens/room_list_screen.dart';
import 'package:smart_room_app/features/alerts/screens/alerts_screen.dart';
import 'package:smart_room_app/features/reports/screens/reports_screen.dart';
import 'package:smart_room_app/features/staff/screens/staff_list_screen.dart';
import 'package:smart_room_app/features/parking/screens/parking_management_screen.dart';
import 'package:smart_room_app/features/attendance/screens/attendance_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentNavIndex = 0;

  // Function គ្រប់គ្រងការចុច Navigation Bar ខាងក្រោម
  void _onBottomNavTapped(int index) {
    if (index == _currentNavIndex && index == 0) return;

    setState(() => _currentNavIndex = index);

    Widget? targetScreen;
    if (index == 1) {
      targetScreen = const RoomListScreen();
    } else if (index == 2) {
      targetScreen = const AttendanceScreen();
    } else if (index == 3) {
      targetScreen = const ParkingManagementScreen();
    }

    if (targetScreen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => targetScreen!),
      ).then((_) {
        // ពេលថយក្រោយមកកាន់ Dashboard វិញ ឱ្យ Tab រត់មក Home (0) ដោយស្វ័យប្រវត្តិ
        if (mounted) {
          setState(() => _currentNavIndex = 0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header ខាងលើ
              _buildHeader(context, user),
              const SizedBox(height: 20),

              // 2. Quick Access Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quick Access',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoomListScreen(),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 3. Grid Menu Cards (មានចលនាពេលប៉ះ)
              _buildQuickAccessGrid(context, isAdmin, user),
              const SizedBox(height: 20),

              // 4. Today Duty Header (ដោះស្រាយបញ្ហា Overflow 9.9px)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isAdmin
                            ? 'កាលវិភាគប្រព័ន្ធ (System Schedule)'
                            : 'វេនការងាររបស់អ្នក (Today Duty)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AttendanceScreen(),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'កត់ត្រាវត្តមាន',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 5. Schedule Card (មានចលនាពេលចុច)
              _buildScheduleCard(context, isAdmin),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // 6. Bottom Navigation Bar ស្អាត និងឆ្លើយតបរហ័ស
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              activeIcon: Icon(Icons.home_filled, size: 26),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.meeting_room_outlined),
              activeIcon: Icon(Icons.meeting_room, size: 26),
              label: 'Rooms',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.co_present_outlined),
              activeIcon: Icon(Icons.co_present, size: 26),
              label: 'វត្តមាន',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.two_wheeler_outlined),
              activeIcon: Icon(Icons.two_wheeler, size: 26),
              label: 'Parking',
            ),
          ],
          onTap: _onBottomNavTapped,
        ),
      ),
    );
  }

  // Header ខាងលើ
  Widget _buildHeader(BuildContext context, UserModel? user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
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
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {},
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'ចាកចេញ (Logout)',
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(width: 4),
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF1E40AF), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'សួស្តី, ${user?.name ?? "អ្នកប្រើប្រាស់"} 👋',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          // ✅ កែត្រង់ null (Staff) ឱ្យចេញស្អាតបាត
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user?.role == UserRole.admin
                  ? 'តួនាទី៖ អ្នកគ្រប់គ្រងទូទៅ (Admin)'
                  : 'តួនាទី៖ ${user?.name ?? "បុគ្គលិក"} (Staff)',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'ស្វែងរកបន្ទប់, ឧបករណ៍, ឬកាលវិភាគ...',
                      hintStyle:
                          TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Grid បង្ហាញមុខងារ Quick Access
  Widget _buildQuickAccessGrid(
    BuildContext context,
    bool isAdmin,
    UserModel? user,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.88,
        children: isAdmin
            ? [
                _buildGridItem(
                  'គ្រប់គ្រងបន្ទប់',
                  'បញ្ជីបន្ទប់ ១៣០',
                  Icons.meeting_room,
                  const Color(0xFFEEF2FF),
                  const Color(0xFF4F46E5),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RoomListScreen()),
                  ),
                ),
                _buildGridItem(
                  'របាយការណ៍រួម',
                  'Live Overview',
                  Icons.bar_chart,
                  const Color(0xFFFEF3C7),
                  const Color(0xFFD97706),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportsScreen()),
                  ),
                ),
                _buildGridItem(
                  'អនុម័តសំណើ',
                  'សម្ភារៈ & ជួសជុល',
                  Icons.fact_check_outlined,
                  const Color(0xFFFCE7F3),
                  const Color(0xFFDB2777),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AlertsScreen()),
                  ),
                ),
                _buildGridItem(
                  'កត់ត្រាវត្តមាន',
                  'Check-in ចូល',
                  Icons.co_present,
                  const Color(0xFFEFF6FF),
                  const Color(0xFF2563EB),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                  ),
                ),
                _buildGridItem(
                  'បុគ្គលិកអគារ',
                  'Digital ID (QR)',
                  Icons.badge_outlined,
                  const Color(0xFFDCFCE7),
                  const Color(0xFF16A34A),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StaffListScreen()),
                  ),
                ),
                _buildGridItem(
                  'ចំណតម៉ូតូ',
                  'កឹបសំបុត្រ 500៛',
                  Icons.two_wheeler,
                  const Color(0xFFFFFBEB),
                  const Color(0xFFD97706),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ParkingManagementScreen()),
                  ),
                ),
              ]
            : [
                _buildGridItem(
                  'កត់ត្រាវត្តមាន',
                  'Check-in ចូល',
                  Icons.co_present,
                  const Color(0xFFEFF6FF),
                  const Color(0xFF2563EB),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                  ),
                ),
                _buildGridItem(
                  'បន្ទប់របស់ខ្ញុំ',
                  'បន្ទប់ត្រូវរៀបចំ',
                  Icons.checklist_rtl,
                  const Color(0xFFEEF2FF),
                  const Color(0xFF4F46E5),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RoomListScreen()),
                  ),
                ),
                _buildGridItem(
                  'ចំណតម៉ូតូ',
                  'កឹបសំបុត្រ 500៛',
                  Icons.two_wheeler,
                  const Color(0xFFFFFBEB),
                  const Color(0xFFD97706),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ParkingManagementScreen()),
                  ),
                ),
                _buildGridItem(
                  'ស្នើសុំសម្ភារៈ',
                  'Request Supplies',
                  Icons.inventory_2_outlined,
                  const Color(0xFFDCFCE7),
                  const Color(0xFF16A34A),
                  () =>
                      _showCreateRequestDialog(context, user, 'ស្នើសុំសម្ភារៈ'),
                ),
                _buildGridItem(
                  'រាយការណ៍បញ្ហា',
                  'Report Issue',
                  Icons.report_problem_outlined,
                  const Color(0xFFFCE7F3),
                  const Color(0xFFDB2777),
                  () => _showCreateRequestDialog(context, user, 'ជួសជុលឧបករណ៍'),
                ),
                _buildGridItem(
                  'Digital ID',
                  'My QR Card',
                  Icons.qr_code,
                  const Color(0xFFF3F4F6),
                  const Color(0xFF4B5563),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StaffListScreen()),
                  ),
                ),
              ],
      ),
    );
  }

  // Card នីមួយៗភ្ជាប់ជាមួយ AnimatedPressCard (ចលនាពេលចុច)
  Widget _buildGridItem(
    String title,
    String sub,
    IconData icon,
    Color bg,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return AnimatedPressCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: bg.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF1E293B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Schedule Card ខាងក្រោម (ភ្ជាប់ AnimatedPressCard ដូចគ្នា)
  Widget _buildScheduleCard(BuildContext context, bool isAdmin) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedPressCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AttendanceScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      'ម៉ោង',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                    Text(
                      '05:00',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                    Text(
                      'AM',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAdmin
                          ? 'បើកប្រព័ន្ធបន្ទប់ទាំងអស់ (អគារ A, B, C)'
                          : 'ត្រួតពិនិត្យ និងបើកបន្ទប់ទទួលបន្ទុក',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'កត់ត្រាវត្តមាន Check-in មុនចាប់ផ្តើមការងារ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateRequestDialog(
    BuildContext context,
    UserModel? user,
    String type,
  ) {
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
              decoration: const InputDecoration(
                labelText: 'លេខបន្ទប់ (ឧ. A101, B203)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(
                labelText: type == 'ស្នើសុំសម្ភារៈ'
                    ? 'រាយមុខសម្ភារៈ'
                    : 'រៀបរាប់ពីបញ្ហា',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('បោះបង់'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (descCtrl.text.isEmpty) return;
              try {
                await Dio().post(
                  '${ApiEndpoints.baseUrl}/api/requests',
                  data: {
                    'room_number': roomCtrl.text.trim(),
                    'requested_by': user?.name ?? 'អ្នករៀបចំបន្ទប់',
                    'type': type,
                    'description': descCtrl.text.trim(),
                    'building': roomCtrl.text.startsWith('B')
                        ? 'អគារ B'
                        : (roomCtrl.text.startsWith('C') ? 'អគារ C' : 'អគារ A'),
                  },
                );
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('បានផ្ញើសំណើជោគជ័យ!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('មានបញ្ហាក្នុងការផ្ញើសំណើ'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('ផ្ញើសំណើ'),
          ),
        ],
      ),
    );
  }
}

// ====================================================
// WIDGET ចលនាពេលចុច (BOUNCE / SCALE ANIMATION)
// ====================================================
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
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
