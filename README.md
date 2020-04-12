# search_map_place

This is a Flutter package that uses the Google Maps API to make a TextField that tries to autocomplete places as the user types, with simple smooth animations, providing a nice UI and UX.
This will also provide great information about the user selected place, like the coordinates, the bounds to determine the zoom of the GoogleMap widget, and so on.

<img src="./example/search_map_place_example.gif" alt="example" width="300"/>

> This is an example of what can be done using this package. To see the source code, check the examples folder.

## Getting Started

To install, add it to your `pubspec.yaml` file:

```
dependencies:
    search_map_place: <latest>
```

After that, make sure you have the following APIs activated in your Google Cloud Platform:
- Places
- Geolocation
- Geocoding

You can now import it to your file and use it on your app.

```dart
import 'package:search_map_place/search_map_place.dart';
```

## How to use it

Where you want to add the search widget, call `SearchMapPlaceWidget`'s constructor:

```dart
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: SearchMapPlaceWidget(
        apiKey: // YOUR GOOGLE MAPS API KEY
      )
    )
  );
}
```

The constructor has 7 attributes related to the API:
- `String apiKey` is the only required attribute. It is the Google Maps API Key your application is using
- `(Place) void onSelected` is a callback function called when the user selects one of the autocomplete options. 
- `(Place) void onSearch` is a callback function called when the user clicks on the search icon.
- `String language` is the Language used for the autocompletion. Default is 'en' (english). Check the full list of [supported languages](https://developers.google.com/maps/faq#languagesupport) for the Google Maps API
- `LatLng location` is the point around which you wish to retrieve place information. If this value is provided, `radius` must be provided aswell.
- `int radius` is the distance (in meters) within which to return place results. Note that setting a radius biases results to the indicated area, but may not fully restrict results to the specified area. If this value is provided, `location` must be provided aswell. See [Location Biasing and Location Restrict](https://developers.google.com/places/web-service/autocomplete#location_biasing) in the Google Maps API documentation.
- `bool restrictBounds` will return only those places that are strictly within the region defined by `location` and `radius`.
- `PlaceType placeType` will allow you to filter Places by its type. For more information on available types, check [supported types for Autocompletion](https://developers.google.com/places/web-service/autocomplete?#place_types). On default, no filters are passed to the request, which means all Place types will be shown on autocompletion.

### The `Place` class

This class will be returned on the `onSelected` and `onSearch` methods. It allows us to get more information about the user selected place.

Initially, it provides you with only basic information:
- `description` contains the human-readable name for the returned result. For establishment results, this is usually the business name.
- `placeId`A textual identifier that uniquely identifies a place. For more information about place IDs, see the [Place IDs](https://developers.google.com/places/web-service/place-id) overview.
- `types` contains an array of types that apply to this place. The array can contain multiple values. Learn more about [Place types](https://developers.google.com/places/web-service/supported_types).
- `fullJSON` has the full JSON response received from the Places API. Can be used to extract extra information. More info on the [Places Autocomplete API documentation](https://developers.google.com/places/web-service/autocomplete)

However, you can get more information like the `coordinates` and the `bounds` of the place by calling
```dart
await myPlace.geolocation;
```

## Example

Here's an example of the widget being used:

```dart
return SearchMapPlaceWidget(
    apiKey: YOUR_API_KEY,
    // The language of the autocompletion
    language: 'en',
    // The position used to give better recomendations. In this case we are using the user position
    location: userPosition.coordinates,
    radius: 30000,
    onSelected: (Place place) async {
        final geolocation = await place.geolocation;

        // Will animate the GoogleMap camera, taking us to the selected position with an appropriate zoom
        final GoogleMapController controller = await _mapController.future;
        controller.animateCamera(CameraUpdate.newLatLng(geolocation.coordinates));
        controller.animateCamera(CameraUpdate.newLatLngBounds(geolocation.bounds, 0));
    },
);
```

## Future Implementations

There are a lot of features that can be added to this package. Here are some features I want to implement (or could be implemented by someone else):

- [ ] Make the widget more personalizable
- [ ] Make this package independent of `google_maps_flutter`
- [ ] Allow users to close the box clicking outside of it
- [ ] Proper widget dimensions for phones in portrait orientation or foldables.