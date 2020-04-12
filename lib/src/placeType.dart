part of search_map_place;

class PlaceType {
  final String apiString;
  const PlaceType(this.apiString);

  static const geocode = PlaceType("geocode");
  static const address = PlaceType("address");
  static const establishment = PlaceType("establishment");
  static const region = PlaceType("(region)");
  static const cities = PlaceType("(cities)");
}
