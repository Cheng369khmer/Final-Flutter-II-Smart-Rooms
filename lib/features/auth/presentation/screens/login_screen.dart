import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

// Model សម្រាប់ផ្ទុកព័ត៌មានអ្នក Login
class AppUser {
  final String username;
  final String fullName;
  final String role; // 'admin', 'lecturer', 'parking', 'room_staff', 'cleaner'
  final String roleTitle;

  AppUser({
    required this.username,
    required this.fullName,
    required this.role,
    required this.roleTitle,
  });
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: '123');

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = true;
  String _selectedRole = 'admin';

  // បញ្ជីគណនីគំរូតាមមុខងារជាក់ស្តែង
  final Map<String, AppUser> _demoUsers = {
    'admin': AppUser(
      username: 'admin',
      fullName: 'អ្នកគ្រប់គ្រងប្រព័ន្ធ',
      role: 'admin',
      roleTitle: 'អ្នកគ្រប់គ្រងទូទៅ (Admin)',
    ),
    'sen.vichet': AppUser(
      username: 'sen.vichet',
      fullName: 'សាស្ត្រាចារ្យ សែន វិចិត្រ',
      role: 'lecturer',
      roleTitle: 'សាស្ត្រាចារ្យ (Lecturer)',
    ),
    'sokhom.tc': AppUser(
      username: 'sokhom.tc',
      fullName: 'សុខុម ថាងចេង',
      role: 'room_staff',
      roleTitle: 'បុគ្គលិករៀបចំបន្ទប់ & IT',
    ),
    'pao.sambour': AppUser(
      username: 'pao.sambour',
      fullName: 'ពៅ សំបូរ',
      role: 'parking',
      roleTitle: 'សន្តិសុខចំណតម៉ូតូ (Parking)',
    ),
    'meng.sreypov': AppUser(
      username: 'meng.sreypov',
      fullName: 'ម៉េង ស្រីពៅ',
      role: 'cleaner',
      roleTitle: 'បុគ្គលិកអនាម័យ (Cleaner)',
    ),
  };

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      if (password == '123') {
        final currentUser = _demoUsers[username] ??
            AppUser(
              username: username,
              fullName: username,
              role: 'room_staff',
              roleTitle: 'បុគ្គលិក (Staff)',
            );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('ចូលប្រព័ន្ធជោគជ័យ! ស្វាគមន៍ ${currentUser.fullName}'),
              ],
            ),
            backgroundColor: const Color(0xFF0D9488),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );

        // ✅ បញ្ជូនទិន្នន័យ currentUser ទៅកាន់ DashboardScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(currentUser: currentUser),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('លេខសម្ងាត់មិនត្រឹមត្រូវទេ! (លេខសម្ងាត់តេស្ត: 123)'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _selectRole(String username) {
    setState(() {
      _selectedRole = username;
      _usernameController.text = username;
      _passwordController.text = '123';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header ជាមួយ Logo សាកលវិទ្យាល័យចេនឡា
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 55, bottom: 35, left: 24, right: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A2540),
                    Color(0xFF133E68),
                    Color(0xFF1A5288)
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: ClipOval(
                      child: Image.asset(
                        'lib/src/CLU_Logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.school,
                            size: 45, color: Color(0xFF0A2540)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'សាកលវិទ្យាល័យ ចេនឡា',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'CHENLA UNIVERSITY',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Smart Campus & Facility Management',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ជ្រើសរើសគណនីសាកល្បង (Quick Role):',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 8),

                      // ✅ ប៊ូតុង Quick Role ទាំង ៥ តួនាទី
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildRoleChip(
                                'admin', 'Admin', Icons.admin_panel_settings),
                            const SizedBox(width: 8),
                            _buildRoleChip(
                                'sen.vichet', 'សាស្ត្រាចារ្យ', Icons.menu_book),
                            const SizedBox(width: 8),
                            _buildRoleChip('sokhom.tc', 'បុគ្គលិកបន្ទប់',
                                Icons.meeting_room),
                            const SizedBox(width: 8),
                            _buildRoleChip('pao.sambour', 'សន្តិសុខម៉ូតូ',
                                Icons.two_wheeler),
                            const SizedBox(width: 8),
                            _buildRoleChip('meng.sreypov', 'បុគ្គលិកអនាម័យ',
                                Icons.cleaning_services),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Username
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'ឈ្មោះគណនី (Username)',
                          prefixIcon: const Icon(Icons.person_outline,
                              color: Color(0xFF133E68)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'សូមបញ្ចូល Username'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'លេខសម្ងាត់ (Password)',
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Color(0xFF133E68)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'សូមបញ្ចូលលេខសម្ងាត់'
                            : null,
                      ),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                activeColor: const Color(0xFF133E68),
                                onChanged: (val) =>
                                    setState(() => _rememberMe = val ?? false),
                              ),
                              const Text('ចងចាំគណនី',
                                  style: TextStyle(fontSize: 12.5)),
                            ],
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('ភ្លេចលេខសម្ងាត់?',
                                style: TextStyle(
                                    fontSize: 12.5, color: Color(0xFF2563EB))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16325C),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('ចូលប្រព័ន្ធ (Login) →',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String username, String label, IconData icon) {
    final isSelected = _selectedRole == username;
    return InkWell(
      onTap: () => _selectRole(username),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF133E68) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color:
                  isSelected ? const Color(0xFF133E68) : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 15,
                color: isSelected ? Colors.white : const Color(0xFF133E68)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
