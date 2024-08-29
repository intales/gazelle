import 'package:dart_console/dart_console.dart';

/// Asks the user for a selection in a menu and returns the selected option.
T getInputSelection<T>({
  required final List<T> options,
  required final String Function(T option) getOptionText,
  final String prompt = "Select an option:",
}) {
  final console = Console();
  int currentSelection = 0;
  final startLine = console.cursorPosition!.row;

  void printMenu() {
    console.cursorPosition = Coordinate(startLine, 0);
    console.writeLine(prompt);
    for (var i = 0; i < options.length; i++) {
      if (i == currentSelection) {
        console.setForegroundColor(ConsoleColor.yellow);
        console.write('--> ');
      } else {
        console.write('    ');
      }
      console.writeLine(getOptionText(options[i]));
      console.resetColorAttributes();
    }
  }

  printMenu();

  while (true) {
    final key = console.readKey();

    switch (key.controlChar) {
      case ControlCharacter.arrowUp:
        if (currentSelection > 0) currentSelection--;
        break;
      case ControlCharacter.arrowDown:
        if (currentSelection < options.length - 1) currentSelection++;
        break;
      case ControlCharacter.enter:
        return options[currentSelection];
      default:
        break;
    }

    printMenu();
  }
}
