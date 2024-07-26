import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ProfileService {
  final String server = 'https://backend-auth.tssw.cl';
  String token;

  ProfileService(this.token);

  Future<bool> updateUserProfile({String? displayName, File? photo}) async {
    try {
      if (displayName != null) {
        final response = await http.patch(
          Uri.parse('$server/update'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'displayName': displayName}),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to update display name');
        }
      }

      if (photo != null) {
        var request =
            http.MultipartRequest('POST', Uri.parse('$server/upload-photo'));
        request.headers['Authorization'] = 'Bearer $token';
        request.files
            .add(await http.MultipartFile.fromPath('file', photo.path));

        var response = await request.send();
        if (response.statusCode != 200) {
          throw Exception('Failed to update photo');
        }
      }

      return true;
    } catch (e) {
      Logger().e('Error updating profile: $e');
      return false;
    }
  }
}
