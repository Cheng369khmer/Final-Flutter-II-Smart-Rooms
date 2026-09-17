import 'package:flutter/material.dart';

// ==========================================
// 1. DATA MODEL (ទម្រង់ទិន្នន័យបុគ្គលិក)
// ==========================================
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
}

// ==========================================
// 2. STAFF LIST SCREEN (ផ្ទាំងបង្ហាញបុគ្គលិក)
// ==========================================
class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

// បង្កើត Alias ឈ្មោះ StaffDirectoryScreen ក្នុងករណី Dashboard ចាស់របស់អ្នកហៅឈ្មោះនេះ
typedef StaffDirectoryScreen = StaffListScreen;

class _StaffListScreenState extends State<StaffListScreen> {
  // បញ្ជីទិន្នន័យបុគ្គលិកទាំងអស់
  final List<Staff> _allStaff = [
    Staff(
      id: 'CLU0001',
      name: 'សុខុម ថាងចេង',
      role: 'សាស្ត្រាចារ្យ (អគារ A)',
      shift: 'វេនព្រឹក (7:00 AM - 11:00 AM)',
      building: 'អគារ A',
      category: 'អគារ A',
      // មានរូបថតតែលោក សុខុម ថាងចេង ម្នាក់គត់
      image: 'lib/src/sokhom.tc.jpg',
    ),
    Staff(
      id: 'CLU0002',
      name: 'គង់ វណ្ណៈ',
      role: 'ផ្នែកបច្ចេកទេស (អគារ B)',
      shift: 'វេនព្រឹក (6:00 AM - 2:00 PM)',
      building: 'អគារ B',
      category: 'អគារ B',
      image: null, // អ្នកផ្សេងទៀតបង្ហាញ Logo CLU_Logo.png
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

  // ✅ Logic Filter & Search (ដំណើរការរលូន និងស្គាល់ទាំង ID, ឈ្មោះ, ឬអក្សរ O/0)
  List<Staff> get _filteredStaff {
    final cleanQuery = _searchQuery.toLowerCase().trim().replaceAll('o', '0');

    return _allStaff.where((staff) {
      // ១. ពិនិត្យ Category Tabs
      final matchesCategory =
          _selectedCategory == 'ទាំងអស់' || staff.category == _selectedCategory;

      // ២. ពិនិត្យ Search Query
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
        // ✅ ប៊ូតុង Back អាចចុចត្រឡប់ទៅកាន់ផ្ទាំងដើម (Dashboard) វិញបាន
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
            icon: const Icon(Icons.view_agenda_outlined,
                color: Color(0xFF16325C)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF16325C)),
            onPressed: () {
              setState(() {
                _selectedCategory = 'ទាំងអស់';
                _searchController.clear();
                _searchQuery = '';
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Box
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
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
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
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // Category Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
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

          // Grid View បង្ហាញ Card
          Expanded(
            child: displayList.isEmpty
                ? const Center(
                    child: Text(
                      'រកមិនឃើញបុគ្គលិកទេ',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    ),
                  )
                : GridView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      return StaffCardItem(
                        key: ValueKey(staff.id),
                        staff: staff,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. STAFF CARD WIDGET (កាតបុគ្គលិក)
// ==========================================
class StaffCardItem extends StatelessWidget {
  final Staff staff;

  const StaffCardItem({super.key, required this.staff});

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
          // Header ពណ៌ខៀវ + រូបថត
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
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFFE2E8F0),
                        // ✅ បង្ហាញរូបលោក សុខុម លើ CLU0001 ចំណែកអ្នកផ្សេងចេញ CLU_Logo.png (មិន Error 404)
                        backgroundImage:
                            (staff.image != null && staff.image!.isNotEmpty)
                                ? AssetImage(staff.image!)
                                : const AssetImage('lib/src/CLU_Logo.png')
                                    as ImageProvider,
                      ),
                    ),
                    // សញ្ញា Active ពណ៌បៃតង
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

          // ឈ្មោះបុគ្គលិក
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

          // ID Badge
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

          // Role Badge
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

          // វេនការងារ និង អគារ
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
                onPressed: () {},
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
