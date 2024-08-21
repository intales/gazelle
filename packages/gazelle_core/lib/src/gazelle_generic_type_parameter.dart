/// A mixin that provides access to the generic type parameter of a class.
///
/// This mixin can be used with any generic class to expose its type parameter.
/// It defines a getter that returns the [Type] of the generic parameter [T].
///
/// Example usage:
/// ```dart
/// class MyGenericClass<T> with GazelleGenericTypeParameter<T> {
///   // Class implementation...
/// }
///
/// void main() {
///   final instance = MyGenericClass<String>();
///   print(instance.genericTypeParameter); // Outputs: String
/// }
/// ```
mixin GazelleGenericTypeParameter<T> {
  /// Returns the [Type] of the generic parameter [T].
  ///
  /// This getter allows access to the type information of the generic
  /// parameter at runtime, which can be useful for reflection-like
  /// capabilities or type-based logic.
  ///
  /// Returns:
  ///   The [Type] object representing the generic type parameter [T].
  Type get genericTypeParameter => T;
}
