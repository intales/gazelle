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
  /// The name of the parameter.
  final String? name;

  /// The type of the parameter.
  final String? type;

  /// Is a named parameter.
  final bool isNamed;

  /// The position of the parameter when it isn't named.
  final int? position;

  /// Builds a [ClassConstructorParameter].
  const ClassConstructorParameter({
    this.name,
    this.type,
    required this.isNamed,
    this.position,
  });
}
