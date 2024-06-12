/// Represents the definition of a class.
class ClassDefinition {
  /// The class name.
  final String name;

  /// The class properties.
  final Set<ClassPropertyDefinition> properties;

  /// Builds a [ClassDefinition].
  const ClassDefinition({
    required this.name,
    required this.properties,
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
