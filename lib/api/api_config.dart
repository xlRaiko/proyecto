class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1';
  static const String apiPath = '/api/3';
  static const String globalApiKey = 'Dx88vjqWnUNSkDS4HFio';
  
  static const String loginEndpoint = '/login';
  static const String userEndpoint = '/users';
  static const String clientesEndpoint = '/clientes';
  static const String apiKeysEndpoint = '/api_keys';
  
  static String getApiUrl(String endpoint) {
    return '$baseUrl$apiPath$endpoint';
  }
  
  static Map<String, String> getHeaders({String? userApiKey}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json', 
      'token': userApiKey ?? globalApiKey,
    };
  }
  
  static Map<String, String> getLoginHeaders() {
    return {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
    };
  }
  
  static Map<String, String> getFormHeaders({String? userApiKey}) {
    return {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'token': userApiKey ?? globalApiKey,
    };
  }
  
  static String encodeFormData(Map<String, dynamic> data) {
    final items = <String>[];
    data.forEach((key, value) {
      if (value != null) {
        items.add('${Uri.encodeComponent(key)}=${Uri.encodeComponent(value.toString())}');
      }
    });
    return items.join('&');
  }
}