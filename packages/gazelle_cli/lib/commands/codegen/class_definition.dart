/// Represents the definition of a class.
class ClassDefinition {
  /// The class name.
  final String name;

  /// The class properties.
  final Set<ClassPropertyDefinition> properties;

  /// The class constructor parameters.
  final Set<ClassConstructorParameter> constructorParameters;

  /// Builds a [ClassDefinition].
  const ClassDefinition({
    required this.name,
    required this.properties,
    required this.constructorParameters,
  });
}

/// Represents the definition of a class property.
class ClassPropertyDefinition {
  /// The name of the property.
  final String name;

  /// The type of the property.
  final String type;

  /// Builds a [ClassPropertyDefinition].
  const ClassPropertyDefinition({
    required this.name,
    required this.type,
  });
}

/// Represents a constructor parameter of a given class.
class ClassConstructorParameter {
  /// The type of the parameter.
  final TypeDefinition type;

  /// The position of the parameter when it isn't named.
  final int? position;

  /// The name of the parameter.
  final String? name;

  /// Is a named parameter.
  bool get isNamed => name != null;

  /// Builds a [ClassConstructorParameter].
  const ClassConstructorParameter({
    required this.type,
    this.position,
    this.name,
  });
}

/// Represents a Dart type definition
class TypeDefinition {
  /// The source of the type.
  final String? source;

  /// The name of the type
  final String name;

  /// Returns `true` if the type represents an `int`.
  final bool isInt;

  /// Returns `true` if the type represents a `Map`.
  final bool isMap;

  /// Returns `true` if the type represents a `num`.
  final bool isNum;

  /// Returns `true` if the type represents a `Set`.
  final bool isSet;

  /// Returns `true` if the type represents a `bool`.
  final bool isBool;

  /// Returns `true` if the type represents an `enum`.
  final bool isEnum;

  /// Returns `true` if the type represents a `List`.
  final bool isList;

  /// Returns `true` if the type represents a `Null`.
  final bool isNull;

  /// Returns `true` if the type represents a `double`.
  final bool isDouble;

  /// Returns `true` if the type represents an `Object`.
  final bool isObject;

  /// Returns `true` if the type represents a `Record`.
  final bool isRecord;

  /// Returns `true` if the type represents a `String`.
  final bool isString;

  /// Returns `true` if the type represents a `Symbol`.
  final bool isSymbol;

  /// Returns `true` if the type represents a `Future`.
  final bool isFuture;

  /// Returns `true` if the type represents a `Stream`.
  final bool isStream;

  /// Returns `true` if the type represents an `Iterable`.
  final bool isIterable;

  /// Returns `true` if the type represents a `FutureOr`.
  final bool isFutureOr;

  /// Builds a [TypeDefinition] instance
  const TypeDefinition({
    this.source,
    required this.name,
    this.isInt = false,
    this.isMap = false,
    this.isNum = false,
    this.isSet = false,
    this.isBool = false,
    this.isEnum = false,
    this.isList = false,
    this.isNull = false,
    this.isDouble = false,
    this.isObject = false,
    this.isRecord = false,
    this.isString = false,
    this.isSymbol = false,
    this.isFuture = false,
    this.isStream = false,
    this.isIterable = false,
    this.isFutureOr = false,
  });
}
