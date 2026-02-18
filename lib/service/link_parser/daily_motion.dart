import 'dart:convert';
import 'package:http/http.dart' as http;

class DailyMotion {

  Future<String> parseDailyMotionLink(String url) async {
    //https://www.dailymotion.com/video/x8cdfw7
    String apiUrl = "https://www.dailymotion.com/player/metadata/video/${_getDailyMotionId(url)}";

    try {
      // Send the API request
      final response = await http.get(Uri.parse(apiUrl));

      // Check if the response status is successful (200)
      if (response.statusCode == 200) {
        // Parse the response to get the video URL
        String? link = jsonDecode(response.body)['qualities']['auto'][0]['url'];

        // Return the video URL or an empty string if not found
        return link ?? "";
      } else {
        // Handle the case where the response status code is not 200
        print("Failed to load video metadata. Status code: ${response.statusCode}");
        return "";
      }
    } catch (e) {
      // Catch any errors and handle them (e.g., network errors)
      print("Error occurred while fetching video data: $e");
      return "";
    }
  }

// Example method to extract the video ID (this should be implemented as needed)
  String _getDailyMotionId(String url) {
    // This method should parse the URL and return the video ID (e.g., "x8cdfw7")
    RegExp regExp = RegExp(r"video/([a-zA-Z0-9]+)");
    Match? match = regExp.firstMatch(url);
    return match?.group(1) ?? "";
  }
}
