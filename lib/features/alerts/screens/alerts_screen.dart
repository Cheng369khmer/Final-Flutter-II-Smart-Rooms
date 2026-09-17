import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<dynamic> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      final res = await Dio().get('${ApiEndpoints.baseUrl}/api/requests');
      setState(() {
        requests = res.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _approve(String id) async {
    await Dio().post('${ApiEndpoints.baseUrl}/api/requests/$id/approve');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('បានអនុម័តសំណើ និងកែប្រែស្ថានភាពបន្ទប់រួចរាល់!'),
        backgroundColor: Colors.green,
      ),
    );
    _fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'ការស្នើសុំ & Alerts',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                final isPending = req['status'] == 'pending';
                final isApproved = req['status'] == 'approved';

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'បន្ទប់ ${req['room_number']} (${req['building']})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isApproved
                                    ? Colors.green.shade100
                                    : (isPending
                                          ? Colors.amber.shade100
                                          : Colors.red.shade100),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isApproved
                                    ? 'បានយល់ព្រម'
                                    : (isPending
                                          ? 'រង់ចាំអនុម័ត'
                                          : 'បានបដិសេធ'),
                                style: TextStyle(
                                  color: isApproved
                                      ? Colors.green.shade800
                                      : Colors.orange.shade800,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ប្រភេទ៖ ${req['type']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          req['description'],
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ស្នើដោយ៖ ${req['requested_by']} (${req['time']})',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            if (isPending)
                              ElevatedButton(
                                onPressed: () => _approve(req['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('យល់ព្រម (Approve)'),
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
}
