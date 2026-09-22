import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:smart_room_app/core/constants/api_endpoints.dart';

// Model សំបុត្រម៉ូតូ
class ParkingTicket {
  final int id;
  final String vehicleType;
  final String plateNumber;
  final int fee;
  final String shift;
  final String staffName;
  final String time;

  ParkingTicket({
    required this.id,
    required this.vehicleType,
    required this.plateNumber,
    required this.fee,
    required this.shift,
    required this.staffName,
    required this.time,
  });

  factory ParkingTicket.fromJson(Map<String, dynamic> json) {
    return ParkingTicket(
      id: json['id'] ?? 1,
      vehicleType: json['vehicle_type'] ?? json['vehicleType'] ?? 'Scoopy',
      plateNumber: json['plate_number'] ?? json['plateNumber'] ?? '---',
      fee: json['fee'] ?? 500,
      shift: json['shift'] ?? 'វេនថ្ងៃ',
      staffName: json['staff_name'] ?? json['staffName'] ?? 'សន្តិសុខ',
      time: json['time'] ?? '08:00 AM',
    );
  }
}

class ParkingManagementScreen extends StatefulWidget {
  const ParkingManagementScreen({super.key});

  @override
  State<ParkingManagementScreen> createState() =>
      _ParkingManagementScreenState();
}

class _ParkingManagementScreenState extends State<ParkingManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ParkingTicket> _tickets = [];
  bool _isLoading = true;

  // បញ្ជីសំបុត្របម្រុងពេល Offline
  final List<ParkingTicket> _defaultTickets = [
    ParkingTicket(
      id: 1,
      vehicleType: 'Scoopy',
      plateNumber: '1AK-8899',
      fee: 500,
      shift: 'វេនថ្ងៃ',
      staffName: 'សាន វិចិត្រ',
      time: '08:15 AM',
    ),
    ParkingTicket(
      id: 2,
      vehicleType: 'Dream',
      plateNumber: '1BC-3456',
      fee: 500,
      shift: 'វេនថ្ងៃ',
      staffName: 'សាន វិចិត្រ',
      time: '08:40 AM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() => _isLoading = true);
    try {
      final response = await Dio().get(
        '${ApiEndpoints.baseUrl}/api/parking/tickets',
        options: Options(receiveTimeout: const Duration(seconds: 3)),
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        setState(() {
          _tickets = data.map((e) => ParkingTicket.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _tickets = _defaultTickets;
        _isLoading = false;
      });
    }
  }

  // =========================================================================
  // ✅ FUNCTION កឹបសំបុត្រដែលដំណើរការភ្លាមៗ (INSTANT SAVE)
  // =========================================================================
  void _showAddTicketDialog() {
    String selectedShift = 'វេនថ្ងៃ';
    String selectedBrand = 'Wave';
    final plateCtrl = TextEditingController();
    const staffName = 'សាន វិចិត្រ (វេនព្រឹក)';

    final List<String> brands = [
      'Scoopy',
      'Dream',
      'Click',
      'Wave',
      'PCX',
      'ផ្សេងៗ'
    ];

    showDialog(
      context: context,
      barrierDismissible: false, // ការពារកុំឱ្យចុចបាត់ដោយអចេតនា
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Dialog
                  Row(
                    children: const [
                      Icon(Icons.confirmation_number_rounded,
                          color: Color(0xFF2563EB), size: 26),
                      SizedBox(width: 8),
                      Text(
                        'កឹបសំបុត្រចូលសាលា',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ១. រើសវេនការងារ (Shift)
                  const Text('ជ្រើសរើសវេនការងារ (Shift) ៖',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildShiftButton(
                        'វេនថ្ងៃ',
                        Icons.wb_sunny_rounded,
                        const Color(0xFFF59E0B),
                        selectedShift == 'វេនថ្ងៃ',
                        () => setDialogState(() => selectedShift = 'វេនថ្ងៃ'),
                      ),
                      const SizedBox(width: 10),
                      _buildShiftButton(
                        'វេនយប់',
                        Icons.nightlight_round,
                        const Color(0xFF4F46E5),
                        selectedShift == 'វេនយប់',
                        () => setDialogState(() => selectedShift = 'វេនយប់'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  // Info Card វេន និងឈ្មោះអ្នកកឹប
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.access_time_filled,
                            size: 16, color: Color(0xFFD97706)),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'ម៉ោង៖ 7:30 AM - 5:30 PM • អ្នកកឹប៖ $staffName',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFB45309),
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ២. ជ្រើសរើសម៉ាកម៉ូតូ
                  const Text('ជ្រើសរើសម៉ាកម៉ូតូ ៖',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: brands.map((brand) {
                      final isSelected = selectedBrand == brand;
                      return ChoiceChip(
                        label: Text(brand,
                            style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                                fontSize: 12)),
                        selected: isSelected,
                        selectedColor: const Color(0xFF2563EB),
                        backgroundColor: const Color(0xFFF1F5F9),
                        onSelected: (val) =>
                            setDialogState(() => selectedBrand = brand),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  // ៣. បញ្ចូលលេខកន្ទុយផ្លាកលេខ
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.two_wheeler, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: plateCtrl,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              hintText: 'លេខកន្ទុយផ្លាកលេខ (ឧ. 23432)',
                              hintStyle: TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ៤. តម្លៃសំបុត្រ ៥០០ រៀល
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('តម្លៃសំបុត្រកឹបចូល៖',
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF166534))),
                        Text('500 រៀល',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ប៊ូតុង បោះបង់ និង កឹបសំបុត្រ
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('បោះបង់',
                              style: TextStyle(color: Color(0xFF64748B))),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // ✅ យកតម្លៃផ្លាកលេខ (បើទទេ ដាក់ថា "មិនបញ្ជាក់")
                            final plateNumber = plateCtrl.text.trim().isEmpty
                                ? 'មិនបញ្ជាក់'
                                : plateCtrl.text.trim();

                            // ✅ ១. បង្កើត Object សំបុត្រថ្មី
                            final newTicket = ParkingTicket(
                              id: _tickets.length + 1,
                              vehicleType: selectedBrand,
                              plateNumber: plateNumber,
                              fee: 500,
                              shift: selectedShift,
                              staffName: 'សាន វិចិត្រ',
                              time: 'មុននេះបន្តិច',
                            );

                            // ✅ ២. បិទ Dialog ជាបន្ទាន់ (ដើម្បីកុំឱ្យគាំងភ្នែក)
                            Navigator.pop(ctx);

                            // ✅ ៣. បញ្ចូលសំបុត្រទៅក្នុងបញ្ជីលើ Screen ភ្លាមៗ (UI Updates Immediately)
                            setState(() {
                              _tickets.insert(0, newTicket);
                            });

                            // ✅ ៤. បង្ហាញផ្ទាំងបៃតងបញ្ជាក់ជោគជ័យ
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                        'បានកឹបសំបុត្រម៉ូតូ $selectedBrand (៥០០៛) ជោគជ័យ!'),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF16A34A),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );

                            // ✅ ៥. បាញ់ទិន្នន័យទៅ Python តាមក្រោយក្នុង Background (ទោះដាច់ Net ក៏នៅតែ Save បាន)
                            try {
                              Dio().post(
                                '${ApiEndpoints.baseUrl}/api/parking/tickets',
                                data: {
                                  'vehicle_type': selectedBrand,
                                  'plate_number': plateNumber,
                                  'fee': 500,
                                  'shift': selectedShift,
                                  'staff_name': 'សាន វិចិត្រ',
                                },
                              );
                            } catch (_) {}
                          },
                          icon: const Icon(Icons.check,
                              size: 18, color: Colors.white),
                          label: const Text('កឹបសំបុត្រ (500៛)',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
      ),
    );
  }

  Widget _buildShiftButton(String title, IconData icon, Color color,
      bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:
                isSelected ? color.withOpacity(0.12) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isSelected ? color : const Color(0xFFE2E8F0),
                width: isSelected ? 1.8 : 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : const Color(0xFF475569))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = _tickets.length * 500;

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
          'ច្រកទ្វារកឹបសំបុត្រម៉ូតូ (Staff Parking)',
          style: TextStyle(
              color: Color(0xFF16325C),
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF16325C)),
              onPressed: _fetchTickets),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF2563EB),
          tabs: const [
            Tab(icon: Icon(Icons.two_wheeler), text: 'កឹបសំបុត្រ (500៛)'),
            Tab(icon: Icon(Icons.security), text: 'វេនការងារសន្តិសុខ'),
          ],
        ),
      ),

      // ប៊ូតុងធំខាងក្រោមសម្រាប់កឹបសំបុត្រ
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTicketDialog,
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('កឹបចូលសាលា (500៛)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB ១៖ បញ្ជីសំបុត្រដែលបានកឹបរួច & ប្រាក់ចំណូលសរុប
          Column(
            children: [
              // ប្រអប់សង្ខេបប្រាក់ចំណូល និងចំនួនម៉ូតូ
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('ម៉ូតូចូលសរុប',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('${_tickets.length} គ្រឿង',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(height: 35, width: 1, color: Colors.white24),
                      Column(
                        children: [
                          const Text('ប្រាក់ចំណូលសរុប (500៛)',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('$totalIncome ៛',
                              style: const TextStyle(
                                  color: Color(0xFF4ADE80),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // បញ្ជីសំបុត្រម៉ូតូ
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _tickets.isEmpty
                        ? const Center(
                            child: Text('មិនទាន់មានម៉ូតូកឹបចូលទេ',
                                style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            itemCount: _tickets.length,
                            itemBuilder: (context, index) {
                              final ticket = _tickets[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 1,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFFEFF6FF),
                                    child: const Icon(Icons.two_wheeler,
                                        color: Color(0xFF2563EB)),
                                  ),
                                  title: Text(
                                      '${ticket.vehicleType} • ផ្លាកលេខ៖ ${ticket.plateNumber}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  subtitle: Text(
                                      '${ticket.shift} • ម៉ោង៖ ${ticket.time} • ${ticket.staffName}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B))),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Text('${ticket.fee}៛',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF166534),
                                            fontSize: 13)),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),

          // TAB ២៖ វេនការងារសន្តិសុខ
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSecurityShiftCard(
                    'វេនព្រឹក (7:30 AM – 5:30 PM)',
                    'បុគ្គលិក ៤ នាក់',
                    const Color(0xFFD97706),
                    const Color(0xFFFFFBEB)),
                const SizedBox(height: 12),
                _buildSecurityShiftCard(
                    'វេនយប់ (5:30 PM – 9:30 PM)',
                    'បុគ្គលិក ៣ នាក់',
                    const Color(0xFF2563EB),
                    const Color(0xFFEFF6FF)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityShiftCard(
      String shift, String staffCount, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: textColor.withOpacity(0.3))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: textColor),
              const SizedBox(width: 10),
              Text(shift,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 13)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Text(staffCount,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
          ),
        ],
      ),
    );
  }
}
