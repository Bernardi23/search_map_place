part of search_map_place;

class Geocoding {
  Geocoding({this.apiKey, language = 'en'});
  String apiKey;
  String language;

  Future<dynamic> getGeolocation(String adress) async {
    String trimmedAdress = adress.replaceAllMapped(' ', (m) => '+');
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=$trimmedAdress&key=$apiKey&language=$language";
    final response = await http.get(url);
    final json = JSON.jsonDecode(response.body);
    return Geolocation.fromJSON(json);
  }
}
