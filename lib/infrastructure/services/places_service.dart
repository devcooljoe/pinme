import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceResult {
  final String placeId;
  final String description;
  final double? latitude;
  final double? longitude;

  PlaceResult({
    required this.placeId,
    required this.description,
    this.latitude,
    this.longitude,
  });
}

class PlacesService {
  static const String _apiKey = 'YOUR_GOOGLE_PLACES_API_KEY';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  static Future<List<PlaceResult>> searchPlaces(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final url = '$_baseUrl/autocomplete/json?input=$query&key=$_apiKey';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List;
        
        return predictions.map((p) => PlaceResult(
          placeId: p['place_id'],
          description: p['description'],
        )).toList();
      }
    } catch (e) {
      // Handle error silently
    }
    
    return [];
  }
  
  static Future<PlaceResult?> getPlaceDetails(String placeId) async {
    try {
      final url = '$_baseUrl/details/json?place_id=$placeId&key=$_apiKey';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['result'];
        final location = result['geometry']['location'];
        
        return PlaceResult(
          placeId: placeId,
          description: result['formatted_address'],
          latitude: location['lat'].toDouble(),
          longitude: location['lng'].toDouble(),
        );
      }
    } catch (e) {
      // Handle error silently
    }
    
    return null;
  }
}