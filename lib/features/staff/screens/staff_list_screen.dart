import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:smart_room_app/core/constants/api_endpoints.dart';

// =========================================================================
// ១. DATA MODEL (ទម្រង់ទិន្នន័យបុគ្គលិក - ចាប់យករូបភាព និងព័ត៌មានតាម ID)
// =========================================================================
class Staff {
  final String id;
  final String name;
  final String role;
  final String shift;
  final String building;
  final String category;
  final String? image; // ផ្ទុករូបភាពផ្ទាល់ខ្លួន (បើគ្មាន គឺ null)

  Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.shift,
    required this.building,
    required this.category,
    this.image,
  });

  // បម្លែងទិន្នន័យ JSON ដែលទាញចេញពី Python FastAPI
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      shift: json['shift'] ?? '',
      building: json['building'] ?? '',
      category: json['category'] ?? '',
      image: json['image'],
    );
  }
}

// =========================================================================
// ២. STAGGERED ANIMATION WIDGET (ចលនាលោតចូលម្ដងមួយៗ រយៈពេលសរុប ~1s)
// =========================================================================
class StaggeredFadeSlideItem extends StatefulWidget {
  final int index; // លេខរៀងកាត (0, 1, 2, 3...)
  final Widget child;

  const StaggeredFadeSlideItem({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  State<StaggeredFadeSlideItem> createState() => _StaggeredFadeSlideItemState();
}

class _StaggeredFadeSlideItemState extends State<StaggeredFadeSlideItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // បង្កើត AnimationController រយៈពេល 450ms សម្រាប់កាតនីមួយៗ
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // Fade-in: ពីមើលមិនឃើញ (0.0) ទៅមើលឃើញច្បាស់ (1.0)
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    // Slide-up: រំកិលពីក្រោមឡើងលើបន្តិច
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    // គណនា Delay តាម Index (កាតទី ១ ចេញភ្លាម, កាតទី ២ ចេញបន្ទាប់... សរុប ~1 វិនាទី)
    final delayMs = widget.index * 110;
    Future.delayed(Duration(milliseconds: delayMs), () {
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
// ៣. CONTROLLER ANIMATION (ចលនារួញរីក / Scale Bounce ពេលប៉ះលើ Card)
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
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 120),
    );
    // ពេលសង្កត់ រួញចុះមក 0.95 ពេលលែងដៃ រីកមក 1.0 វិញ
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
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
// ៤. MAIN STAFF LIST SCREEN (ផ្ទាំងបញ្ជីបុគ្គលិក)
// =========================================================================
class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

typedef StaffDirectoryScreen = StaffListScreen;

class _StaffListScreenState extends State<StaffListScreen> {
  List<Staff> _allStaff = [];
  bool _isLoading = true;
  String _errorMessage = '';

  String _selectedCategory = 'ទាំងអស់';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'ទាំងអស់',
    'អគារ A',
    'អគារ B',
    'អគារ C',
    'ចំណតម៉ូតូ',
  ];

  // បញ្ជីទិន្នន័យបម្រុង (Fallback) ក្នុងករណី Server Python មិនទាន់បានបើក
  final List<Staff> _defaultStaffList = [
    Staff(
      id: 'CLU0001',
      name: 'សុខុម ថាងចេង',
      role: 'សាស្ត្រាចារ្យ (អគារ A)',
      shift: 'វេនព្រឹក (7:00 AM - 11:00 AM)',
      building: 'អគារ A',
      category: 'អគារ A',
      image: 'lib/src/sokhom.tc.jpg', // រូបភាពលោក សុខុម ចាប់តាម ID CLU0001
    ),
    Staff(
      id: 'CLU0002',
      name: 'គង់ វណ្ណៈ',
      role: 'ផ្នែកបច្ចេកទេស (អគារ B)',
      shift: 'វេនព្រឹក (6:00 AM - 2:00 PM)',
      building: 'អគារ B',
      category: 'អគារ B',
      image: null,
    ),
    Staff(
      id: 'CLU0003',
      name: 'ម៉េង ស្រីពៅ',
      role: 'ផ្នែកអនាម័យ (អគារ C - HR)',
      shift: 'វេនរសៀល (1:00 PM - 9:00 PM)',
      building: 'អគារ C',
      category: 'អគារ C',
      image: null,
    ),
    Staff(
      id: 'CLU0004',
      name: 'លី វិសាល',
      role: 'ផ្នែកសោរ (អគារ C)',
      shift: 'វេនយប់ (4:00 PM - 12:00 AM)',
      building: 'អគារ C',
      category: 'អគារ C',
      image: null,
    ),
    Staff(
      id: 'CLU0005',
      name: 'ពៅ សំបូរ',
      role: 'ចំណតម៉ូតូ',
      shift: 'វេនព្រឹក (7:30 AM - 5:30 PM)',
      building: 'ចំណតម៉ូតូ',
      category: 'ចំណតម៉ូតូ',
      image: null,
    ),
    Staff(
      id: 'CLU0006',
      name: 'សាន វិចិត្រ',
      role: 'ចំណតម៉ូតូ',
      shift: 'វេនព្រឹក (7:30 AM - 5:30 PM)',
      building: 'ចំណតម៉ូតូ',
      category: 'ចំណតម៉ូតូ',
      image: null,
    ),
    Staff(
      id: 'CLU0007',
      name: 'ជា ពិសិដ្ឋ',
      role: 'ចំណតម៉ូតូ',
      shift: 'វេនយប់ (5:30 PM - 9:30 PM)',
      building: 'ចំណតម៉ូតូ',
      category: 'ចំណតម៉ូតូ',
      image: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchStaffFromBackend();
  }

  // ទាញទិន្នន័យ Dynamic ពី Python FastAPI
  Future<void> _fetchStaffFromBackend() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await Dio().get(
        '${ApiEndpoints.baseUrl}/api/staff',
        options: Options(receiveTimeout: const Duration(seconds: 4)),
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        setState(() {
          _allStaff = data.map((item) => Staff.fromJson(item)).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      // ប្រសិនបើ Server Offline ឱ្យទាញយកទិន្នន័យបម្រុងស្វ័យប្រវត្តិ (មិនឱ្យចេញ Error ក្រហមឡើយ)
      setState(() {
        _isLoading = false;
        _allStaff = _defaultStaffList;
      });
    }
  }

  // Logic ស្វែងរកឆ្លាតវៃ (ដោះស្រាយការច្រឡំរវាងអក្សរ O និងលេខ 0)
  List<Staff> get _filteredStaff {
    final cleanQuery = _searchQuery.toLowerCase().trim().replaceAll('o', '0');

    return _allStaff.where((staff) {
      final matchesCategory =
          _selectedCategory == 'ទាំងអស់' || staff.category == _selectedCategory;

      final staffId = staff.id.toLowerCase().replaceAll('o', '0');
      final fullIdWithPrefix = 'id: $staffId';
      final name = staff.name.toLowerCase();
      final role = staff.role.toLowerCase();
      final building = staff.building.toLowerCase();

      final matchesSearch = cleanQuery.isEmpty ||
          name.contains(cleanQuery) ||
          role.contains(cleanQuery) ||
          building.contains(cleanQuery) ||
          staffId.contains(cleanQuery) ||
          fullIdWithPrefix.contains(cleanQuery);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // =======================================================================
  // ៥. HERO ANIMATION DIALOG (ផ្ទាំង DIGITAL ID QR CARD ហោះចេញពីរូបថត)
  // =======================================================================
  void _showDigitalIdDialog(BuildContext context, Staff staff) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ក្បាលកាត (Chenla University Header)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF16325C), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'lib/src/CLU_Logo.png',
                      width: 36,
                      height: 36,
                      errorBuilder: (_, __, ___) => const Icon(Icons.school,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'សាកលវិទ្យាល័យ ចេនឡា',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'CHENLA UNIVERSITY • DIGITAL ID',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 🚀 HERO ANIMATION TARGET (រូបថតហោះពង្រីកមកទីនេះដោយប្រើ staff.id)
              Hero(
                tag: 'staff-avatar-${staff.id}',
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF16325C), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xFFE2E8F0),
                        // ចាប់យករូបភាពតាម ID
                        backgroundImage:
                            (staff.image != null && staff.image!.isNotEmpty)
                                ? AssetImage(staff.image!)
                                : const AssetImage('lib/src/CLU_Logo.png')
                                    as ImageProvider,
                      ),
                    ),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ឈ្មោះ និង ID បុគ្គលិក
              Text(
                staff.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ID: ${staff.id} • ${staff.role}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // រូបភាព QR Code ពិតប្រាកដដែលស្កេនបាន
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=${Uri.encodeComponent("Chenla Smart Campus ID: ${staff.id} | Name: ${staff.name} | Role: ${staff.role}")}',
                    width: 140,
                    height: 140,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        width: 140,
                        height: 140,
                        child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 140,
                      height: 140,
                      color: Colors.white,
                      child: const Icon(Icons.qr_code_2,
                          size: 100, color: Color(0xFF16325C)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Text(
                'ស្កេនដើម្បីផ្ទៀងផ្ទាត់អត្តសញ្ញាណប័ណ្ណ',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),

              const SizedBox(height: 16),

              // ប៊ូតុងបិទ (Close Button)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16325C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'បិទ (Close)',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredStaff;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: const [
            Text(
              'បុគ្គលិករៀបចំបន្ទប់ & សាស្ត្រាចារ្យ',
              style: TextStyle(
                color: Color(0xFF16325C),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'CHENLA SMART CAMPUS DIRECTORY',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF16325C)),
            onPressed: _fetchStaffFromBackend,
          ),
        ],
      ),
      body: Column(
        children: [
          // ប្រអប់ Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'ស្វែងរកឈ្មោះ, ផ្នែក ឬអគារ...',
                  hintStyle:
                      const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  prefixIcon: const Icon(Icons.search,
                      color: Color(0xFF64748B), size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              size: 18, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // ===================================================================
          // ៦. EVENT ON TAB ITEM (ព្រឹត្តិការណ៍ពេលចុច Tab Filter)
          // ===================================================================
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    // ពេលចុច Tab វានឹង Update State និង Restart Staggered Animation ឡើងវិញ
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF475569),
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // ===================================================================
          // ៧. GRID VIEW ភ្ជាប់ STAGGERED ANIMATION
          // ===================================================================
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayList.isEmpty
                    ? const Center(
                        child: Text(
                          'រកមិនឃើញបុគ្គលិកទេ',
                          style:
                              TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        ),
                      )
                    : GridView.builder(
                        // Key ជួយ Reset Animation ពេលចុចប្តូរ Tab អគារ
                        key: ValueKey('grid_$_selectedCategory'),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final staff = displayList[index];

                          // ⭐ STAGGERED ITEM WRAPPER: ធ្វើឱ្យកាតនីមួយៗលេចចេញម្តងមួយៗ
                          return StaggeredFadeSlideItem(
                            key: ValueKey('${staff.id}_$_selectedCategory'),
                            index: index, // ចែករំលែក Delay តាមលំដាប់លំដោយ
                            child: AnimatedPressCard(
                              // ⭐ CONTROLLER ANIMATION: រួញរីកពេលចុចប៉ះ
                              onTap: () => _showDigitalIdDialog(context, staff),
                              child: StaffCardItem(
                                staff: staff,
                                onDigitalIdPressed: () =>
                                    _showDigitalIdDialog(context, staff),
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
}

// =========================================================================
// ៨. STAFF CARD ITEM (កាតបុគ្គលិកនីមួយៗ)
// =========================================================================
class StaffCardItem extends StatelessWidget {
  final Staff staff;
  final VoidCallback onDigitalIdPressed;

  const StaffCardItem({
    super.key,
    required this.staff,
    required this.onDigitalIdPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFF16325C),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              Positioned(
                top: 16,
                child: Stack(
                  children: [
                    // 🚀 HERO ANIMATION SOURCE (រូបថតតូចលើ Card ហោះទៅផ្ទាំងធំពេលចុច)
                    Hero(
                      tag: 'staff-avatar-${staff.id}',
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFFE2E8F0),
                          // ✅ រូបភាពចាប់តាម ID (Sokhom = sokhom.tc.jpg, ផ្សេងទៀត = CLU_Logo.png)
                          backgroundImage:
                              (staff.image != null && staff.image!.isNotEmpty)
                                  ? AssetImage(staff.image!)
                                  : const AssetImage('lib/src/CLU_Logo.png')
                                      as ImageProvider,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              staff.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF0F172A),
              ),
            ),
          ),

          const SizedBox(height: 3),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.badge_outlined,
                    size: 11, color: Color(0xFF64748B)),
                const SizedBox(width: 3),
                Text(
                  'ID: ${staff.id}',
                  style:
                      const TextStyle(fontSize: 10, color: Color(0xFF475569)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 5),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                staff.role,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF7E22CE),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 11, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        staff.shift,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 8.5, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.apartment,
                        size: 11, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'អគារ៖ ${staff.building}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 8.5, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ប៊ូតុង Digital ID
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: SizedBox(
              width: double.infinity,
              height: 28,
              child: ElevatedButton.icon(
                onPressed: onDigitalIdPressed,
                icon:
                    const Icon(Icons.qr_code_2, size: 14, color: Colors.white),
                label: const Text(
                  'Digital ID',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16325C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
