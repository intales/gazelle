# Gazelle Serialization Library

This library is part of the Gazelle backend framework.
It provides serialization and deserialization functionality for Dart objects,
supporting both primitive types and custom models.

## Key Features

- Serialization of Dart objects to JSON format
- Deserialization of JSON objects to Dart instances
- Support for primitive types (String, num, bool, DateTime)
- Handling of lists and nested objects
- Extensible through `GazelleModelProvider` and `GazelleModelType`

## Usage

### Serialization

To serialize an object:
```dart
final jsonObject = serialize(object: myObject, modelProvider: myModelProvider);
```

### Deserialization

To deserialize an object:
```dart
final myObject = deserialize<MyType>(jsonObject: jsonData, modelProvider: myModelProvider);
```

To deserialize an list of objects:
```dart
final myObjects = deserializeList<MyType>(jsonObject: jsonData, modelProvider: myModelProvider);
```

### Defining custom models
1. Create a class that extends `GazelleModelType`:
```dart
class MyTypeModel extends GazelleModelType<MyType> {
  @override
  Map<String, dynamic> toJson(MyType value) {
    // Implement serialization logic
  }

  @override
  MyType fromJson(Map<String, dynamic> json) {
    // Implement deserialization logic
  }
}
```

2. Create a `GazelleModelProvider`:
```dart
class MyModelProvider extends GazelleModelProvider {
  @override
  Map<Type, GazelleModelType> get modelTypes => {
    MyType: MyTypeModel(),
    // Add other custom types here
  };
}
```
## Notes

- The library automatically handles the serialization of DateTime to ISO 8601 format.
- For unrecognized types, the library will return the string representation of the object.
