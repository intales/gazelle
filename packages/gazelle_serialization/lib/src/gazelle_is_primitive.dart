/// Returns `true` when [object] is a primitive type.
bool isPrimitive(dynamic object) =>
    object is String || object is num || object is bool || object is DateTime;
