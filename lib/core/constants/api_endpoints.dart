class ApiEndpoints {
  // ប្រើ 127.0.0.1 ត្រូវគ្នាទាំងស្រុងជាមួយ Uvicorn
  static const String baseUrl = 'http://127.0.0.1:8000';

  // --- ១. AUTHENTICATION ---
  static const String login = '$baseUrl/api/auth/login';

  // --- ២. ATTENDANCE (វត្តមាន & Check-In) ---
  static const String attendanceToday = '$baseUrl/api/attendance/today';
  static const String attendanceCheckIn = '$baseUrl/api/attendance/check-in';
  static const String attendanceCheckOut = '$baseUrl/api/attendance/check-out';
  static const String attendanceLeave = '$baseUrl/api/attendance/leave';

  // --- ៣. ROOMS MANAGEMENT (គ្រប់គ្រងបន្ទប់) ---
  static const String rooms = '$baseUrl/api/rooms';
  static String roomDetail(String roomId) => '$baseUrl/api/rooms/$roomId';
  static String updateRoomStatus(String roomId) =>
      '$baseUrl/api/rooms/$roomId/status';

  // --- ៤. PARKING (ចំណតម៉ូតូ ៥០០៛) ---
  static const String parkingTickets = '$baseUrl/api/parking/tickets';
  static const String parkingCheckIn = '$baseUrl/api/parking/check-in';
  static String parkingCheckOut(String ticketId) =>
      '$baseUrl/api/parking/check-out/$ticketId';

  // --- ៥. REQUESTS (សំណើស្នើសុំ) ---
  static const String requests = '$baseUrl/api/requests';
}
