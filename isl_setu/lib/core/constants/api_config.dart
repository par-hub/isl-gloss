/// API Configuration for the ISL Translation FastAPI backend server.
/// 
/// How to choose your [baseUrl]:
/// 
/// 1. Android Emulator -> host machine:
///    Use 'http://10.0.2.2:8000' (default)
/// 
/// 2. Physical Device -> local host machine on same WiFi network:
///    Use 'http://192.168.1.X:8000' (replace X with host PC's local IP address)
/// 
/// 3. Remote/Tunnel URL (e.g. ngrok):
///    Use 'https://your-ngrok-subdomain.ngrok-free.app'
class ApiConfig {
  static const String baseUrl = "http://192.168.29.2:8000";
  static const Duration timeout = Duration(seconds: 30);
  
  static const String translateEndpoint = '/translate';
}
