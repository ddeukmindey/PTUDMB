class ApiClient {
  static const String baseUrl = 'https://api.example.com';

  static Future<void> initialize() async {
  }

  static Future<dynamic> get(String endpoint) async {
    try {
      throw UnimplementedError('GET request not implemented');
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      throw UnimplementedError('POST request not implemented');
    } catch (e) {
      rethrow;
    }
  }


  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      throw UnimplementedError('PUT request not implemented');
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      throw UnimplementedError('DELETE request not implemented');
    } catch (e) {
      rethrow;
    }
  }
}

class NotesApi {
  static Future<List<dynamic>> fetchNotes() async {
    try {
      throw UnimplementedError('fetchNotes not implemented');
    } catch (e) {
      rethrow;
    }
  }


  static Future<dynamic> uploadNote(Map<String, dynamic> noteData) async {
    try {
      throw UnimplementedError('uploadNote not implemented');
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> updateNote(String noteId, Map<String, dynamic> noteData) async {
    try {
      throw UnimplementedError('updateNote not implemented');
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> deleteNote(String noteId) async {
    try {
      throw UnimplementedError('deleteNote not implemented');
    } catch (e) {
      rethrow;
    }
  }
}
