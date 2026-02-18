import 'dart:convert';
import 'package:http/http.dart' as http;

class Vimeo {
  Future<String> parseLink(String url) async {
    //example url
    //https://player.vimeo.com/video/76979871/config
    String apiUrl = "https://player.vimeo.com/video/${_getId(url)}/config";

    final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 10));
    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['request'] == null) {
      return "";
    }
    var request = jsonResponse["request"];
    var files = request['files'];
    var progressive = files['progressive'];
    if (progressive[0] != null) {
      var link = progressive[0]['url'];
      return link;
    }
    //m3u8 link
    var hls = files['hls'];
    var cdns = hls['cdns'];
    var akfire = cdns['akfire_interconnect_quic'];
    return akfire['url'];
  }

  String _getId(String url) {
    final regex = RegExp(r'\d+'); // Matches one or more digits in the URL
    final match = regex.firstMatch(url);

    if (match != null) {
      return match.group(0)!; // Return the first matched number as a string
    }

    throw FormatException("No numeric ID found in the URL");
  }

  //Rimon
  // String _getId(String url) {
  //   var parts = url.split("/");
  //   var id = parts[3];
  //   return id;
  // }
}
