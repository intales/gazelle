/// Converts a snake case string into a pascal case string.
String snakeToPascalCase(String input) => input.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join('');
